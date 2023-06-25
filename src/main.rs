use std::collections::{HashMap, HashSet, VecDeque};
use std::ops::Not;
use std::rc::Rc;
use crate::save_loader::{load_save, Wire, Point, Component as SaveComponent, ComponentType};
use crate::simulator::{Component, IntermediateComponent, simulate};
use crate::simulator::ComponentType::*;
use argparse::{ArgumentParser, Store};

mod save_loader;
mod versions;
mod simulator;

const DEBUG: bool = false;

fn main() {
    let mut path = String::new();

    {
        let mut ap = ArgumentParser::new();
        ap.set_description("Turing Complete Circuit Simulator");
        ap.refer(&mut path).add_argument("path", Store, "The path to the circuit.data file.");
        ap.parse_args_or_exit();
    }

    let (mut components, num_wires, data_bytes_needed, delay) = read_from_save(&path);

    for c in components.iter_mut() {
        if DEBUG {
            println!("{:?}", c)
        }
    }

    let latency_ram_delay = if delay > 0 {
        (1024f64 / (delay as f64)).ceil() as u64
    } else {
        1024
    };

    let result = simulate(components, num_wires, latency_ram_delay, data_bytes_needed, true, |_| true, |_, _| 0, |_, _| true);
    match result {
        Err(error) => {
            println!("{}", error);
        },
        Ok(num_ticks) => {
            println!("Simulation successfully exited after {} ticks", num_ticks);
        }
    }
}

fn read_from_save(path: &str) -> (Vec<Component>, usize, usize, u64) {
    let save = load_save(path);
    let save = save.unwrap();
    if DEBUG {
        for c in &*save.components {
            println!("{:?}", c.component_type)
        }
    }

    let wire_clusters = merge_wires(&save.wires);
    let components = resolve_components(&save.components, &save.dependencies);

    let mut required_data = HashMap::<Point, usize>::new();
    for component in &components {
        match component.component_type {
            DelayLine(_) | VirtualDelayLine(_) | Register(_) | VirtualRegister(_) | Counter(_, _) | VirtualCounter(_, _) => {
                required_data.entry(component.position).or_insert(8);
            }
            BitMemory | VirtualBitMemory | Register8Plus | VirtualRegister8Plus | VirtualRegister8Plus2 => {
                required_data.entry(component.position).or_insert(1);
            }
            Ram(size, _) | VirtualRam(size, _) | LatencyRam(size, _) | VirtualLatencyRam(size, _) | DualLoadRam(size, _) | VirtualDualLoadRam(size, _) | VirtualDualLoadRam2(size, _) | Rom(size, _) | VirtualRom(size, _) => {
                required_data.entry(component.position).or_insert((size as usize + 31) & 31usize.not());
            }
            HDD(size) | VirtualHDD(size) => {
                required_data.entry(component.position).or_insert((size as usize) << 3);
            }
            _ => {}
        }
    }

    let mut required_data: Vec<(Point, usize)> = required_data.into_iter().collect();
    required_data.sort_by_key(|(_, size)| {*size});
    let mut data_offsets = HashMap::<Point, usize>::new();
    let mut offset: usize = 0;
    for (p, s) in required_data.into_iter().rev() {
        data_offsets.insert(p, offset);
        offset += s;
    }

    let mut input_index: usize = 0;
    let mut output_index: usize = 0;
    let mut latency_index: usize = 0;
    let mut latency_index_map: HashMap<Point, usize> = HashMap::new();

    let components: Vec<Component> = components.into_iter().map(|c| {
        Component {
            numeric_id: match &c.component_type {
                Input(_, _) | SwitchedInput(_, _) => {
                    let i_index = input_index;
                    input_index += 1;
                    i_index
                }
                Output(_, _) | SwitchedOutput(_, _) | BidirectionalIO(_, _) => {
                    let o_index = output_index;
                    output_index += 1;
                    o_index
                }
                LatencyRam(_, _) | VirtualLatencyRam(_, _) => {
                    if let std::collections::hash_map::Entry::Vacant(e) = latency_index_map.entry(c.position) {
                        let l_index = latency_index;
                        latency_index += 1;
                        e.insert(l_index);
                        l_index
                    } else {
                        latency_index_map[&c.position]
                    }
                }
                _ => 0
            },
            component_type: c.component_type,
            inputs: c.inputs.iter().map(|(p, s)| {(map_point_to_wire_index(&wire_clusters, &(p + &c.position)), *s)}).collect(),
            outputs: c.outputs.iter().map(|(p, s, z)| {(map_point_to_wire_index(&wire_clusters, &(p + &c.position)), *s, *z)}).collect(),
            bidirectional: c.bidirectional.iter().map(|(p, s)| {(map_point_to_wire_index(&wire_clusters, &(p + &c.position)), *s)}).collect(),
            data_offset: *data_offsets.get(&c.position).unwrap_or(&offset)
        }
    }).collect();

    (components, wire_clusters.len(), offset, save.delay)
}

fn merge_wires(wire_segments: &Vec<Wire>) -> Vec<HashSet<Point>> {
    let mut wire_clusters: VecDeque<HashSet<Point>> = VecDeque::new();
    for wire in wire_segments {
        let first = *wire.points.first().unwrap();
        let second = *wire.points.last().unwrap();
        let mut set = HashSet::new();
        set.insert(first);
        set.insert(second);
        wire_clusters.push_back(set);
    }

    if wire_clusters.is_empty() {
        return wire_clusters.into();
    }

    loop {
        let last_cluster_length = wire_clusters.len();
        let mut num_to_check = wire_clusters.len();
        while num_to_check > 0 {
            let mut indices_to_remove: Vec<usize> = Vec::new();
            let mut first = wire_clusters.pop_front().unwrap();
            num_to_check -= 1;
            for (index, set) in wire_clusters.iter().enumerate() {
                if !first.is_disjoint(set) {
                    indices_to_remove.push(index);
                    first.extend(set);
                    if index < num_to_check {
                        num_to_check -= 1;
                    }
                }
            }

            indices_to_remove.reverse();
            for idx in indices_to_remove {
                wire_clusters.remove(idx);
            }
            wire_clusters.push_back(first);
        }

        if last_cluster_length == wire_clusters.len() {
            break;
        }
    }

    wire_clusters.into()
}

fn map_point_to_wire_index(wire_clusters: &[HashSet<Point>], point: &Point) -> Option<usize> {
    for (i, cluster) in wire_clusters.iter().enumerate() {
        if cluster.contains(point) {
            return Some(i);
        }
    }
    None
}

fn resolve_components(save_components: &[SaveComponent], dependencies: &[u64]) -> Vec<IntermediateComponent> {
    let mut components: Vec<IntermediateComponent> = Vec::new();

    save_components.iter().for_each(|c| {
        let component: IntermediateComponent = match c.component_type {
            ComponentType::Error => {
                panic!("Not Implemented")
            }
            ComponentType::Off => {
                IntermediateComponent {
                    component_type: Constant(0, 1),
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![(Point::new(1, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::On => {
                IntermediateComponent {
                    component_type: Constant(1, 1),
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![(Point::new(1, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Buffer1 => {
                IntermediateComponent {
                    component_type: Buffer(1),
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 1)],
                    outputs: vec![(Point::new(1, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Not => {
                IntermediateComponent {
                    component_type: Not(1),
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 1)],
                    outputs: vec![(Point::new(1, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::And => {
                IntermediateComponent {
                    component_type: And(1),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 1),
                        (Point::new(-1, 1), 1)
                    ],
                    outputs: vec![(Point::new(2, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::And3 => {
                IntermediateComponent {
                    component_type: And3,
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 1),
                        (Point::new(-1, 0), 1),
                        (Point::new(-1, 1), 1)
                    ],
                    outputs: vec![(Point::new(2, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Nand => {
                IntermediateComponent {
                    component_type: Nand(1),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 1),
                        (Point::new(-1, 1), 1)
                    ],
                    outputs: vec![(Point::new(2, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Or => {
                IntermediateComponent {
                    component_type: Or(1),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 1),
                        (Point::new(-1, 1), 1)
                    ],
                    outputs: vec![(Point::new(2, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Or3 => {
                IntermediateComponent {
                    component_type: Or3,
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 1),
                        (Point::new(-1, 0), 1),
                        (Point::new(-1, 1), 1)
                    ],
                    outputs: vec![(Point::new(2, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Nor => {
                IntermediateComponent {
                    component_type: Nor(1),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 1),
                        (Point::new(-1, 1), 1)
                    ],
                    outputs: vec![(Point::new(2, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Xor => {
                IntermediateComponent {
                    component_type: Xor(1),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 1),
                        (Point::new(-1, 1), 1)
                    ],
                    outputs: vec![(Point::new(2, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Xnor => {
                IntermediateComponent {
                    component_type: Xnor(1),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 1),
                        (Point::new(-1, 1), 1)
                    ],
                    outputs: vec![(Point::new(2, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Counter8 => {
                IntermediateComponent {
                    component_type: Counter(c.setting_1, 8),
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![(Point::new(1, 0), 8, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::VirtualCounter8 => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::Counter64 => {
                IntermediateComponent {
                    component_type: Counter(c.setting_1, 64),
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![(Point::new(2, 0), 64, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::VirtualCounter64 => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::Ram8 => {
                IntermediateComponent {
                    component_type: Ram(256, 8),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-13, -7), 1),
                        (Point::new(-13, -5), 8)
                    ],
                    outputs: vec![(Point::new(13, -7), 8, true)],
                    bidirectional: vec![]
                }
            }
            ComponentType::VirtualRam8 => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::Deleted0 => {panic!("Not Implemented")}
            ComponentType::Deleted1 => {panic!("Not Implemented")}
            ComponentType::Deleted17 => {panic!("Not Implemented")}
            ComponentType::Deleted18 => {panic!("Not Implemented")}
            ComponentType::Register8 | ComponentType::Register8Red => {
                IntermediateComponent {
                    component_type: Register(8),
                    position: c.position,
                    inputs: vec![(Point::new(-1, -1), 1)],
                    outputs: vec![(Point::new(1, 0), 8, true)],
                    bidirectional: vec![]
                }
            }
            ComponentType::VirtualRegister8 | ComponentType::VirtualRegister8Red => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::Register8RedPlus => {
                IntermediateComponent {
                    component_type: Register8Plus,
                    position: c.position,
                    inputs: vec![(Point::new(-1, -1), 1)],
                    outputs: vec![(Point::new(1, 0), 8, true)],
                    bidirectional: vec![]
                }
            }
            ComponentType::VirtualRegister8RedPlus => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::Register64 => {
                IntermediateComponent {
                    component_type: Register(64),
                    position: c.position,
                    inputs: vec![(Point::new(-3, -1), 1)],
                    outputs: vec![(Point::new(3, 0), 8, true)],
                    bidirectional: vec![]
                }
            }
            ComponentType::VirtualRegister64 => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::Switch8 => {
                IntermediateComponent {
                    component_type: Switch(8),
                    position: c.position,
                    inputs: vec![
                        (Point::new(0, -1), 1),
                        (Point::new(-1, 0), 8)
                    ],
                    outputs: vec![(Point::new(1, 0), 8, true)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Mux8 => {
                IntermediateComponent {
                    component_type: Mux(8),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 1),
                        (Point::new(-1, 0), 8),
                        (Point::new(-1, 1), 8)
                    ],
                    outputs: vec![(Point::new(1, 0), 8, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Decoder1 => {
                IntermediateComponent {
                    component_type: Dec1,
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 1)],
                    outputs: vec![
                        (Point::new(1, 0), 1, false),
                        (Point::new(1, 1), 1, false)
                    ],
                    bidirectional: vec![]
                }
            }
            ComponentType::Decoder3 => {
                IntermediateComponent {
                    component_type: Dec3,
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -3), 1),
                        (Point::new(-1, -2), 1),
                        (Point::new(-1, -1), 1),
                        (Point::new(0, -4), 1)
                    ],
                    outputs: vec![
                        (Point::new(1, -3), 1, false),
                        (Point::new(1, -2), 1, false),
                        (Point::new(1, -1), 1, false),
                        (Point::new(1, 0), 1, false),
                        (Point::new(1, 1), 1, false),
                        (Point::new(1, 2), 1, false),
                        (Point::new(1, 3), 1, false),
                        (Point::new(1, 4), 1, false)
                    ],
                    bidirectional: vec![]
                }
            }
            ComponentType::Constant8 => {
                IntermediateComponent {
                    component_type: Constant(c.setting_1, 8),
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![(Point::new(1, 0), 8, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Not8 => {
                IntermediateComponent {
                    component_type: Not(8),
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 8)],
                    outputs: vec![(Point::new(1, 0), 8, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Or8 => {
                IntermediateComponent {
                    component_type: Or(8),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 8),
                        (Point::new(-1, 0), 8)
                    ],
                    outputs: vec![(Point::new(1, 0), 8, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::And8 => {
                IntermediateComponent {
                    component_type: And(8),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 8),
                        (Point::new(-1, 0), 8)
                    ],
                    outputs: vec![(Point::new(1, 0), 8, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Xor8 => {
                IntermediateComponent {
                    component_type: Xor(8),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 8),
                        (Point::new(-1, 0), 8)
                    ],
                    outputs: vec![(Point::new(1, 0), 8, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Equal8 => {
                IntermediateComponent {
                    component_type: Equal(8),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 8),
                        (Point::new(-1, 0), 8)
                    ],
                    outputs: vec![(Point::new(1, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Deleted2 => {panic!("Not Implemented")}
            ComponentType::Deleted3 => {panic!("Not Implemented")}
            ComponentType::Neg8 => {
                IntermediateComponent {
                    component_type: Neg(8),
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 8)],
                    outputs: vec![(Point::new(1, 0), 8, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Add8 => {
                IntermediateComponent {
                    component_type: Adder(8),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 1),
                        (Point::new(-1, 0), 8),
                        (Point::new(-1, 1), 8)
                    ],
                    outputs: vec![
                        (Point::new(1, -1), 8, false),
                        (Point::new(1, 0), 1, false)
                    ],
                    bidirectional: vec![]
                }
            }
            ComponentType::Mul8 => {
                IntermediateComponent {
                    component_type: Mul(8),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 8),
                        (Point::new(-1, 0), 8)
                    ],
                    outputs: vec![
                        (Point::new(1, -1), 8, false),
                        (Point::new(1, 0), 8, false)
                    ],
                    bidirectional: vec![]
                }
            }
            ComponentType::Splitter8 => {
                IntermediateComponent {
                    component_type: ByteSplitter,
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 8)],
                    outputs: vec![
                        (Point::new(1, -3), 1, false),
                        (Point::new(1, -2), 1, false),
                        (Point::new(1, -1), 1, false),
                        (Point::new(1, 0), 1, false),
                        (Point::new(1, 1), 1, false),
                        (Point::new(1, 2), 1, false),
                        (Point::new(1, 3), 1, false),
                        (Point::new(1, 4), 1, false)
                    ],
                    bidirectional: vec![]
                }
            }
            ComponentType::Maker8 => {
                IntermediateComponent {
                    component_type: ByteMaker,
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -3), 1),
                        (Point::new(-1, -2), 1),
                        (Point::new(-1, -1), 1),
                        (Point::new(-1, 0), 1),
                        (Point::new(-1, 1), 1),
                        (Point::new(-1, 2), 1),
                        (Point::new(-1, 3), 1),
                        (Point::new(-1, 4), 1)
                    ],
                    outputs: vec![(Point::new(1, 0), 8, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Splitter64 => {
                IntermediateComponent {
                    component_type: ByteSplitter8,
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 64)],
                    outputs: vec![
                        (Point::new(1, -3), 8, false),
                        (Point::new(1, -2), 8, false),
                        (Point::new(1, -1), 8, false),
                        (Point::new(1, 0), 8, false),
                        (Point::new(1, 1), 8, false),
                        (Point::new(1, 2), 8, false),
                        (Point::new(1, 3), 8, false),
                        (Point::new(1, 4), 8, false)
                    ],
                    bidirectional: vec![]
                }
            }
            ComponentType::Maker64 => {
                IntermediateComponent {
                    component_type: ByteMaker8,
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -3), 8),
                        (Point::new(-1, -2), 8),
                        (Point::new(-1, -1), 8),
                        (Point::new(-1, 0), 8),
                        (Point::new(-1, 1), 8),
                        (Point::new(-1, 2), 8),
                        (Point::new(-1, 3), 8),
                        (Point::new(-1, 4), 8)
                    ],
                    outputs: vec![(Point::new(1, 0), 64, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::FullAdder => {
                IntermediateComponent {
                    component_type: Adder(1),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 1),
                        (Point::new(-1, 0), 1),
                        (Point::new(-1, 1), 1)
                    ],
                    outputs: vec![
                        (Point::new(1, 0), 1, false),
                        (Point::new(1, 1), 1, false)
                    ],
                    bidirectional: vec![]
                }
            }
            ComponentType::BitMemory => {
                IntermediateComponent {
                    component_type: BitMemory,
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![(Point::new(1, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::VirtualBitMemory => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::Deleted10 => {panic!("Not Implemented")}
            ComponentType::Decoder2 => {
                IntermediateComponent {
                    component_type: Dec2,
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 1),
                        (Point::new(-1, 0), 1)
                    ],
                    outputs: vec![
                        (Point::new(1, -1), 1, false),
                        (Point::new(1, 0), 1, false),
                        (Point::new(1, 1), 1, false),
                        (Point::new(1, 2), 1, false)
                    ],
                    bidirectional: vec![]
                }
            }
            ComponentType::Timing => {
                IntermediateComponent {
                    component_type: Time,
                    position: c.position,
                    inputs: vec![(Point::new(0, -1), 1)],
                    outputs: vec![(Point::new(1, 0), 64, true)],
                    bidirectional: vec![]
                }
            }
            ComponentType::NoteSound => {
                IntermediateComponent {
                    component_type: Sound,
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 8),
                        (Point::new(-2, 0), 8),
                        (Point::new(-2, 1), 8)
                    ],
                    outputs: vec![],
                    bidirectional: vec![]
                }
            }
            ComponentType::Deleted4 => {panic!("Not Implemented")}
            ComponentType::Deleted5 => {panic!("Not Implemented")}
            ComponentType::Keyboard => {panic!("Not Implemented")}
            ComponentType::FileLoader => {panic!("Not Implemented")}
            ComponentType::Halt => {panic!("Not Implemented")}
            ComponentType::WireCluster => {panic!("Not Implemented")}
            ComponentType::LevelScreen => {panic!("Not Implemented")}
            ComponentType::Program8_1 => {panic!("Not Implemented")}
            ComponentType::Program8_1Red => {panic!("Not Implemented")}
            ComponentType::Deleted6 => {panic!("Not Implemented")}
            ComponentType::Deleted7 => {panic!("Not Implemented")}
            ComponentType::Program8_4 => {panic!("Not Implemented")}
            ComponentType::LevelGate => {panic!("Not Implemented")}
            ComponentType::Input1 => {
                IntermediateComponent {
                    component_type: Input(c.custom_string.clone(), 1),
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![(Point::new(1, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::LevelInput2Pin => {panic!("Not Implemented")}
            ComponentType::LevelInput3Pin => {panic!("Not Implemented")}
            ComponentType::LevelInput4Pin => {panic!("Not Implemented")}
            ComponentType::LevelInputConditions => {panic!("Not Implemented")}
            ComponentType::Input8 => {
                IntermediateComponent {
                    component_type: Input(c.custom_string.clone(), 8),
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![(Point::new(1, 0), 8, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Input64 => {panic!("Not Implemented")}
            ComponentType::LevelInputCode => {panic!("Not Implemented")}
            ComponentType::LevelInputArch => {panic!("Not Implemented")}
            ComponentType::Output1 => {
                IntermediateComponent {
                    component_type: Output(Rc::from(c.custom_string.clone()), 1),
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 1)],
                    outputs: vec![],
                    bidirectional: vec![]
                }
            }
            ComponentType::LevelOutput1Sum => {panic!("Not Implemented")}
            ComponentType::LevelOutput1Car => {
                IntermediateComponent {
                    component_type: Output(Rc::from(c.custom_string.clone()), 1),
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 1)],
                    outputs: vec![],
                    bidirectional: vec![]
                }
            }
            ComponentType::Deleted8 => {panic!("Not Implemented")}
            ComponentType::Deleted9 => {panic!("Not Implemented")}
            ComponentType::LevelOutput2Pin => {panic!("Not Implemented")}
            ComponentType::LevelOutput3Pin => {panic!("Not Implemented")}
            ComponentType::LevelOutput4Pin => {panic!("Not Implemented")}
            ComponentType::Output8 => {
                IntermediateComponent {
                    component_type: Output(Rc::from(c.custom_string.clone()), 8),
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 8)],
                    outputs: vec![],
                    bidirectional: vec![]
                }
            }
            ComponentType::Output64 => {
                IntermediateComponent {
                    component_type: Output(Rc::from(c.custom_string.clone()), 64),
                    position: c.position,
                    inputs: vec![(Point::new(-3, 0), 64)],
                    outputs: vec![],
                    bidirectional: vec![]
                }
            }
            ComponentType::LevelOutputArch => {panic!("Not Implemented")}
            ComponentType::LevelOutputCounter => {panic!("Not Implemented")}
            ComponentType::Deleted11 => {panic!("Not Implemented")}
            ComponentType::Custom => {panic!("Not Implemented")}
            ComponentType::VirtualCustom => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::Program => {panic!("Not Implemented")}
            ComponentType::DelayLine1 => {
                IntermediateComponent {
                    component_type: DelayLine(1),
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![(Point::new(1, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::VirtualDelayLine1 => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::Console => {panic!("Not Implemented")}
            ComponentType::Shl8 => {panic!("Not Implemented")}
            ComponentType::Shr8 => {panic!("Not Implemented")}
            ComponentType::Constant64 => {panic!("Not Implemented")}
            ComponentType::Not64 => {panic!("Not Implemented")}
            ComponentType::Or64 => {panic!("Not Implemented")}
            ComponentType::And64 => {panic!("Not Implemented")}
            ComponentType::Xor64 => {panic!("Not Implemented")}
            ComponentType::Neg64 => {panic!("Not Implemented")}
            ComponentType::Add64 => {panic!("Not Implemented")}
            ComponentType::Mul64 => {panic!("Not Implemented")}
            ComponentType::Equal64 => {panic!("Not Implemented")}
            ComponentType::LessU64 => {panic!("Not Implemented")}
            ComponentType::LessI64 => {panic!("Not Implemented")}
            ComponentType::Shl64 => {panic!("Not Implemented")}
            ComponentType::Shr64 => {panic!("Not Implemented")}
            ComponentType::Mux64 => {panic!("Not Implemented")}
            ComponentType::Switch64 => {
                IntermediateComponent {
                    component_type: Switch(64),
                    position: c.position,
                    inputs: vec![
                        (Point::new(0, -1), 1),
                        (Point::new(-1, 0), 64)
                    ],
                    outputs: vec![(Point::new(1, 0), 64, true)],
                    bidirectional: vec![]
                }
            }
            ComponentType::ProbeMemoryBit => {
                IntermediateComponent {
                    component_type: MemoryProbe(1),
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 1)],
                    outputs: vec![],
                    bidirectional: vec![]
                }
            }
            ComponentType::ProbeMemoryWord => {
                IntermediateComponent {
                    component_type: MemoryProbe(64),
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 1)],
                    outputs: vec![],
                    bidirectional: vec![]
                }
            }
            ComponentType::AndOrLatch => {panic!("Not Implemented")}
            ComponentType::NandNandLatch => {panic!("Not Implemented")}
            ComponentType::NorNorLatch => {panic!("Not Implemented")}
            ComponentType::LessU8 => {panic!("Not Implemented")}
            ComponentType::LessI8 => {panic!("Not Implemented")}
            ComponentType::DotMatrixDisplay => {panic!("Not Implemented")}
            ComponentType::SegmentDisplay => {panic!("Not Implemented")}
            ComponentType::Input16 => {panic!("Not Implemented")}
            ComponentType::Input32 => {panic!("Not Implemented")}
            ComponentType::Output16 => {
                IntermediateComponent {
                    component_type: Output(Rc::from(c.custom_string.clone()), 16),
                    position: c.position,
                    inputs: vec![(Point::new(-2, 0), 16)],
                    outputs: vec![],
                    bidirectional: vec![]
                }
            }
            ComponentType::Output32 => {
                IntermediateComponent {
                    component_type: Output(Rc::from(c.custom_string.clone()), 32),
                    position: c.position,
                    inputs: vec![(Point::new(-2, 0), 32)],
                    outputs: vec![],
                    bidirectional: vec![]
                }
            }
            ComponentType::Deleted12 => {panic!("Not Implemented")}
            ComponentType::Deleted13 => {panic!("Not Implemented")}
            ComponentType::Deleted14 => {panic!("Not Implemented")}
            ComponentType::Deleted15 => {panic!("Not Implemented")}
            ComponentType::Deleted16 => {panic!("Not Implemented")}
            ComponentType::Buffer8 => {panic!("Not Implemented")}
            ComponentType::Buffer16 => {panic!("Not Implemented")}
            ComponentType::Buffer32 => {panic!("Not Implemented")}
            ComponentType::Buffer64 => {panic!("Not Implemented")}
            ComponentType::ProbeWireBit => {panic!("Not Implemented")}
            ComponentType::ProbeWireWord => {panic!("Not Implemented")}
            ComponentType::Switch1 => {
                IntermediateComponent {
                    component_type: Switch(1),
                    position: c.position,
                    inputs: vec![
                        (Point::new(0, -1), 1),
                        (Point::new(-1, 0), 1)
                    ],
                    outputs: vec![(Point::new(1, 0), 1, true)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Output1z => {panic!("Not Implemented")}
            ComponentType::Output8z => {panic!("Not Implemented")}
            ComponentType::Output16z => {panic!("Not Implemented")}
            ComponentType::Output32z => {panic!("Not Implemented")}
            ComponentType::Output64z => {panic!("Not Implemented")}
            ComponentType::Constant16 => {panic!("Not Implemented")}
            ComponentType::Not16 => {panic!("Not Implemented")}
            ComponentType::Or16 => {panic!("Not Implemented")}
            ComponentType::And16 => {panic!("Not Implemented")}
            ComponentType::Xor16 => {panic!("Not Implemented")}
            ComponentType::Neg16 => {panic!("Not Implemented")}
            ComponentType::Add16 => {panic!("Not Implemented")}
            ComponentType::Mul16 => {panic!("Not Implemented")}
            ComponentType::Equal16 => {panic!("Not Implemented")}
            ComponentType::LessU16 => {panic!("Not Implemented")}
            ComponentType::LessI16 => {panic!("Not Implemented")}
            ComponentType::Shl16 => {panic!("Not Implemented")}
            ComponentType::Shr16 => {panic!("Not Implemented")}
            ComponentType::Mux16 => {panic!("Not Implemented")}
            ComponentType::Switch16 => {
                IntermediateComponent {
                    component_type: Switch(16),
                    position: c.position,
                    inputs: vec![
                        (Point::new(0, -1), 1),
                        (Point::new(-1, 0), 16)
                    ],
                    outputs: vec![(Point::new(1, 0), 16, true)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Splitter16 => {panic!("Not Implemented")}
            ComponentType::Maker16 => {panic!("Not Implemented")}
            ComponentType::Register16 => {panic!("Not Implemented")}
            ComponentType::VirtualRegister16 => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::Counter16 => {panic!("Not Implemented")}
            ComponentType::VirtualCounter16 => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::Constant32 => {panic!("Not Implemented")}
            ComponentType::Not32 => {panic!("Not Implemented")}
            ComponentType::Or32 => {panic!("Not Implemented")}
            ComponentType::And32 => {panic!("Not Implemented")}
            ComponentType::Xor32 => {panic!("Not Implemented")}
            ComponentType::Neg32 => {panic!("Not Implemented")}
            ComponentType::Add32 => {panic!("Not Implemented")}
            ComponentType::Mul32 => {panic!("Not Implemented")}
            ComponentType::Equal32 => {panic!("Not Implemented")}
            ComponentType::LessU32 => {panic!("Not Implemented")}
            ComponentType::LessI32 => {panic!("Not Implemented")}
            ComponentType::Shl32 => {panic!("Not Implemented")}
            ComponentType::Shr32 => {panic!("Not Implemented")}
            ComponentType::Mux32 => {panic!("Not Implemented")}
            ComponentType::Switch32 => {
                IntermediateComponent {
                    component_type: Switch(32),
                    position: c.position,
                    inputs: vec![
                        (Point::new(0, -1), 1),
                        (Point::new(-1, 0), 32)
                    ],
                    outputs: vec![(Point::new(1, 0), 32, true)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Splitter32 => {panic!("Not Implemented")}
            ComponentType::Maker32 => {
                IntermediateComponent {
                    component_type: ByteMaker4,
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 8),
                        (Point::new(-1, 0), 8),
                        (Point::new(-1, 1), 8),
                        (Point::new(-1, 2), 8)
                    ],
                    outputs: vec![(Point::new(1, 0), 32, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Register32 => {panic!("Not Implemented")}
            ComponentType::VirtualRegister32 => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::Counter32 => {panic!("Not Implemented")}
            ComponentType::VirtualCounter32 => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::LevelOutput8z => {panic!("Not Implemented")}
            ComponentType::Nand8 => {panic!("Not Implemented")}
            ComponentType::Nor8 => {panic!("Not Implemented")}
            ComponentType::Xnor8 => {panic!("Not Implemented")}
            ComponentType::Nand16 => {panic!("Not Implemented")}
            ComponentType::Nor16 => {panic!("Not Implemented")}
            ComponentType::Xnor16 => {panic!("Not Implemented")}
            ComponentType::Nand32 => {panic!("Not Implemented")}
            ComponentType::Nor32 => {panic!("Not Implemented")}
            ComponentType::Xnor32 => {panic!("Not Implemented")}
            ComponentType::Nand64 => {panic!("Not Implemented")}
            ComponentType::Nor64 => {panic!("Not Implemented")}
            ComponentType::Xnor64 => {panic!("Not Implemented")}
            ComponentType::Ram => {panic!("Not Implemented")}
            ComponentType::VirtualRam =>{panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::RamLatency => {panic!("Not Implemented")}
            ComponentType::VirtualRamLatency => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::RamFast => {panic!("Not Implemented")}
            ComponentType::VirtualRamFast => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::Rom => {panic!("Not Implemented")}
            ComponentType::VirtualRom => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::SolutionRom => {panic!("Not Implemented")}
            ComponentType::VirtualSolutionRom => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::DelayLine8 => {
                IntermediateComponent {
                    component_type: DelayLine(8),
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![(Point::new(1, 0), 8, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::VirtualDelayLine8 => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::DelayLine16 => {panic!("Not Implemented")}
            ComponentType::VirtualDelayLine16 => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::DelayLine32 => {panic!("Not Implemented")}
            ComponentType::VirtualDelayLine32 => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::DelayLine64 => {panic!("Not Implemented")}
            ComponentType::VirtualDelayLine64 => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::RamDualLoad => {panic!("Not Implemented")}
            ComponentType::VirtualRamDualLoad => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::Hdd => {panic!("Not Implemented")}
            ComponentType::VirtualHdd => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::Network => {panic!("Not Implemented")}
            ComponentType::Rol8 => {panic!("Not Implemented")}
            ComponentType::Rol16 => {panic!("Not Implemented")}
            ComponentType::Rol32 => {panic!("Not Implemented")}
            ComponentType::Rol64 => {panic!("Not Implemented")}
            ComponentType::Ror8 => {panic!("Not Implemented")}
            ComponentType::Ror16 => {panic!("Not Implemented")}
            ComponentType::Ror32 => {panic!("Not Implemented")}
            ComponentType::Ror64 => {panic!("Not Implemented")}
            ComponentType::IndexerBit => {panic!("Not Implemented")}
            ComponentType::IndexerByte => {panic!("Not Implemented")}
            ComponentType::DivMod8 => {panic!("Not Implemented")}
            ComponentType::DivMod16 => {panic!("Not Implemented")}
            ComponentType::DivMod32 => {panic!("Not Implemented")}
            ComponentType::DivMod64 => {panic!("Not Implemented")}
            ComponentType::SpriteDisplay => {panic!("Not Implemented")}
            ComponentType::ConfigDelay => {panic!("Not Implemented")}
            ComponentType::Clock => {panic!("Not Implemented")}
            ComponentType::LevelInput1 => {
                IntermediateComponent {
                    component_type: Input(c.custom_string.clone(), 1),
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![(Point::new(1, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::LevelInput8 => {
                IntermediateComponent {
                    component_type: Input(c.custom_string.clone(), 8),
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![(Point::new(1, 0), 8, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::LevelOutput1 => {
                IntermediateComponent {
                    component_type: Output(Rc::from(c.custom_string.clone()), 1),
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 1)],
                    outputs: vec![],
                    bidirectional: vec![]
                }
            }
            ComponentType::LevelOutput8 => {
                IntermediateComponent {
                    component_type: Output(Rc::from(c.custom_string.clone()), 8),
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 8)],
                    outputs: vec![],
                    bidirectional: vec![]
                }
            }
            ComponentType::Ashr8 => {panic!("Not Implemented")}
            ComponentType::Ashr16 => {panic!("Not Implemented")}
            ComponentType::Ashr32 => {panic!("Not Implemented")}
            ComponentType::Ashr64 => {panic!("Not Implemented")}
            ComponentType::Bidirectional1 => {panic!("Not Implemented")}
            ComponentType::VirtualBidirectional1 => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::Bidirectional8 => {panic!("Not Implemented")}
            ComponentType::VirtualBidirectional8 => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::Bidirectional16 => {panic!("Not Implemented")}
            ComponentType::VirtualBidirectional16 => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::Bidirectional32 => {panic!("Not Implemented")}
            ComponentType::VirtualBidirectional32 => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::Bidirectional64 => {panic!("Not Implemented")}
            ComponentType::VirtualBidirectional64 => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
        };

        if component.component_type.has_virtual() {
            match component.component_type {
                DelayLine(size) => {
                    let virtual_component = IntermediateComponent {
                        component_type: VirtualDelayLine(size),
                        inputs: vec![(Point::new(-1, 0), size)],
                        outputs: vec![],
                        ..component.clone()
                    };
                    components.push(virtual_component.rotate(c.rotation))
                }
                Register(size) => {
                    panic!("Unimplemented!");
                }
                Counter(_, _) => {
                    panic!("Unimplemented!");
                }
                BitMemory => {
                    panic!("Unimplemented!");
                }
                Ram(_, _) => {
                    panic!("Unimplemented!");
                }
                LatencyRam(_, _) => {
                    panic!("Unimplemented!");
                }
                DualLoadRam(_, _) => {
                    panic!("Unimplemented!");
                }
                Rom(_, _) => {
                    panic!("Unimplemented!");
                }
                HDD(_) => {
                    panic!("Unimplemented!");
                }
                c_type => {
                    panic!("Unhandled component with virtual components {:?}", c_type);
                }
            }
        }

        components.push(component.rotate(c.rotation));
    });

    components
}

#[cfg(test)]
mod tests {
    use std::time::Instant;
    use crate::{DEBUG, read_from_save};
    use crate::simulator::ComponentType::{Input, Output};
    use crate::simulator::simulate;

    #[test]
    fn test_byte_adder_naive_ripple() {
        let (mut components, num_wires, data_bytes_needed, delay) = read_from_save("test/resources/byte_adder/standard-ripple-carry.data");

        for c in components.iter_mut() {
            if DEBUG {
                println!("{:?}", c)
            }
        }

        let latency_ram_delay = if delay > 0 {
            (1024f64 / (delay as f64)).ceil() as u64
        } else {
            1024
        };

        let input_function = |tick: u64, input_index: usize| -> u64 {
            match input_index {
                0 => {
                    tick & 0xFF
                },
                1 => {
                    (tick >> 8) & 0xFF
                },
                2 => {
                    tick >> 16
                },
                _ => {
                    panic!("Unexpected Input Node");
                }
            }
        };

        let output_check_function = |tick: u64, outputs: &Vec<Option<u64>>| -> bool {
            let input_a = input_function(tick, 0);
            let input_b = input_function(tick, 1);
            let carry_in = input_function(tick, 2);
            let expected_sum = (input_a + input_b + carry_in) & 0xFF;
            let expected_carry = (input_a + input_b + carry_in) >> 8;
            let actual_sum = outputs[0].unwrap_or(u64::MAX);
            let actual_carry = outputs[1].unwrap_or(u64::MAX);

            expected_sum == actual_sum && expected_carry == actual_carry
        };

        let start = Instant::now();
        let result = simulate(components, num_wires, latency_ram_delay, data_bytes_needed, false, |tick| tick < 1 << 17, input_function, output_check_function);
        let end = Instant::now();
        println!("Simulation took {} seconds", (end - start).as_secs_f32());

        match &result {
            Err(error) => {
                println!("{}", error);
            },
            Ok(num_ticks) => {
                println!("Simulation successfully exited after {} ticks", num_ticks);
            }
        }

        assert!(result.is_ok());
    }

    #[test]
    fn test_byte_adder_64_20() {
        let (mut components, num_wires, data_bytes_needed, delay) = read_from_save("test/resources/byte_adder/decomposed-ripple-switch-carry.data");

        for c in components.iter_mut() {
            if DEBUG {
                println!("{:?}", c)
            }
        }

        let latency_ram_delay = if delay > 0 {
            (1024f64 / (delay as f64)).ceil() as u64
        } else {
            1024
        };

        let input_function = |tick: u64, input_index: usize| -> u64 {
            match input_index {
                0 => {
                    tick & 0xFF
                },
                1 => {
                    (tick >> 8) & 0xFF
                },
                2 => {
                    tick >> 16
                },
                _ => {
                    panic!("Unexpected Input Node");
                }
            }
        };

        let output_check_function = |tick: u64, outputs: &Vec<Option<u64>>| -> bool {
            let input_a = input_function(tick, 0);
            let input_b = input_function(tick, 1);
            let carry_in = input_function(tick, 2);
            let expected_sum = (input_a + input_b + carry_in) & 0xFF;
            let expected_carry = (input_a + input_b + carry_in) >> 8;
            let actual_sum = outputs[0].unwrap_or(u64::MAX);
            let actual_carry = outputs[1].unwrap_or(u64::MAX);

            expected_sum == actual_sum && expected_carry == actual_carry
        };

        let start = Instant::now();
        let result = simulate(components, num_wires, latency_ram_delay, data_bytes_needed, false, |tick| tick < 1 << 17, input_function, output_check_function);
        let end = Instant::now();
        println!("Simulation took {} seconds", (end - start).as_secs_f32());

        match &result {
            Err(error) => {
                println!("{}", error);
            },
            Ok(num_ticks) => {
                println!("Simulation successfully exited after {} ticks", num_ticks);
            }
        }

        assert!(result.is_ok());
    }

    #[test]
    fn test_5bit_decoder() {
        let (mut components, num_wires, data_bytes_needed, delay) = read_from_save("test/resources/5-bit-decoder.data");

        for c in components.iter_mut() {
            if DEBUG {
                println!("{:?}", c)
            }
        }

        let latency_ram_delay = if delay > 0 {
            (1024f64 / (delay as f64)).ceil() as u64
        } else {
            1024
        };

        let input_function = |tick: u64, input_index: usize| -> u64 {
            match input_index {
                0 => {
                    tick & 0x1F
                },
                1 => {
                    tick >> 5
                },
                _ => {
                    panic!("Unexpected Input Node");
                }
            }
        };

        let output_check_function = |tick: u64, outputs: &Vec<Option<u64>>| -> bool {
            let input = input_function(tick, 0);
            let disable = input_function(tick, 1);
            let expected_output = if disable != 0 {0u64} else {1 << input};
            let actual_output = outputs[0];

            expected_output == actual_output.unwrap_or(u64::MAX)
        };

        let result = simulate(components, num_wires, latency_ram_delay, data_bytes_needed, false, |tick| tick < 64, input_function, output_check_function);
        match &result {
            Err(error) => {
                println!("{}", error);
            },
            Ok(num_ticks) => {
                println!("Simulation successfully exited after {} ticks", num_ticks);
            }
        }
        assert!(result.is_ok());
    }
}