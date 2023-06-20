use std::collections::{HashMap, HashSet, VecDeque};
use std::env;
use std::ops::Not;
use std::rc::Rc;
use crate::save_loader::{load_save, Wire, Point, Component as SaveComponent, ComponentType};
use crate::simulator::{Component, IntermediateComponent, simulate};
use crate::simulator::ComponentType::*;

mod save_loader;
mod versions;
mod simulator;

const DEBUG: bool = false;

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        println!("Missing circuit.data file. Pass the circuit.data file to simulate as an argument.");
        return;
    }

    let (mut components, num_wires, data_bytes_needed) = read_from_save(&args[1]);

    for c in components.iter_mut() {
        if DEBUG {
            println!("{:?}", c)
        }
    }

    let result = simulate(components, num_wires, data_bytes_needed, u64::MAX, true, |_, _| {0});
    match result {
        Err(error) => {
            panic!("Error: {}", error);
        },
        Ok(output_list) => {
            println!("Simulation successfully exited after {} ticks", output_list.len());
        }
    }
}

fn read_from_save(path: &str) -> (Vec<Component>, usize, usize) {
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
            DelayLine(size) | VirtualDelayLine(size) | Register(size) | VirtualRegister(size) | Counter(_, size) | VirtualCounter(_, size) => {
                if !required_data.contains_key(&component.position) {
                    required_data.insert(component.position, 8);
                }
            }
            BitMemory | VirtualBitMemory => {
                if !required_data.contains_key(&component.position) {
                    required_data.insert(component.position, 1);
                }
            }
            Ram(size, _) | VirtualRam(size, _) | LatencyRam(size, _) | VirtualLatencyRam(size, _) | DualLoadRam(size, _) | VirtualDualLoadRam(size, _) | VirtualDualLoadRam2(size, _) | Rom(size, _) | VirtualRom(size, _) => {
                if !required_data.contains_key(&component.position) {
                    required_data.insert(component.position, (size as usize + 31) & 31usize.not());
                }
            }
            HDD(size) | VirtualHDD(size) => {
                if !required_data.contains_key(&component.position) {
                    required_data.insert(component.position, (size as usize) << 3);
                }
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

    let components: Vec<Component> = components.into_iter().map(|c| {
        Component {
            component_type: c.component_type,
            inputs: c.inputs.iter().map(|(p, s)| {(map_point_to_wire_index(&wire_clusters, &(p + &c.position)), *s)}).collect(),
            outputs: c.outputs.iter().map(|(p, s, z)| {(map_point_to_wire_index(&wire_clusters, &(p + &c.position)), *s, *z)}).collect(),
            bidirectional: c.bidirectional.iter().map(|(p, s)| {(map_point_to_wire_index(&wire_clusters, &(p + &c.position)), *s)}).collect(),
            data_offset: *data_offsets.get(&c.position).unwrap_or(&offset)
        }
    }).collect();

    return (components, wire_clusters.len(), offset);
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

    return wire_clusters.into();
}

fn map_point_to_wire_index(wire_clusters: &Vec<HashSet<Point>>, point: &Point) -> Option<usize> {
    for (i, cluster) in wire_clusters.iter().enumerate() {
        if cluster.contains(point) {
            return Some(i);
        }
    }
    return None;
}

fn resolve_components(save_components: &Vec<SaveComponent>, dependencies: &Vec<u64>) -> Vec<IntermediateComponent> {
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
                    inputs: Vec::new(),
                    outputs: vec![(Point {x: 1, y: 0}, 1, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::On => {
                IntermediateComponent {
                    component_type: Constant(1, 1),
                    position: c.position,
                    inputs: Vec::new(),
                    outputs: vec![(Point {x: 1, y: 0}, 1, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Buffer1 => {
                IntermediateComponent {
                    component_type: Buffer(1),
                    position: c.position,
                    inputs: vec![(Point {x: -1, y: 0}, 1)],
                    outputs: vec![(Point {x: 1, y: 0}, 1, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Not => {
                IntermediateComponent {
                    component_type: Not(1),
                    position: c.position,
                    inputs: vec![(Point {x: -1, y: 0}, 1)],
                    outputs: vec![(Point {x: 1, y: 0}, 1, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::And => {
                IntermediateComponent {
                    component_type: And(1),
                    position: c.position,
                    inputs: vec![
                        (Point {x: -1, y: -1}, 1),
                        (Point {x: -1, y: 1}, 1)
                    ],
                    outputs: vec![(Point {x: 2, y: 0}, 1, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::And3 => {
                IntermediateComponent {
                    component_type: And3,
                    position: c.position,
                    inputs: vec![
                        (Point {x: -1, y: -1}, 1),
                        (Point {x: -1, y: 0}, 1),
                        (Point {x: -1, y: 1}, 1)
                    ],
                    outputs: vec![(Point {x: 2, y: 0}, 1, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Nand => {
                IntermediateComponent {
                    component_type: Nand(1),
                    position: c.position,
                    inputs: vec![
                        (Point {x: -1, y: -1}, 1),
                        (Point {x: -1, y: 1}, 1)
                    ],
                    outputs: vec![(Point {x: 2, y: 0}, 1, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Or => {
                IntermediateComponent {
                    component_type: Or(1),
                    position: c.position,
                    inputs: vec![
                        (Point {x: -1, y: -1}, 1),
                        (Point {x: -1, y: 1}, 1)
                    ],
                    outputs: vec![(Point {x: 2, y: 0}, 1, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Or3 => {
                IntermediateComponent {
                    component_type: Or3,
                    position: c.position,
                    inputs: vec![
                        (Point {x: -1, y: -1}, 1),
                        (Point {x: -1, y: 0}, 1),
                        (Point {x: -1, y: 1}, 1)
                    ],
                    outputs: vec![(Point {x: 2, y: 0}, 1, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Nor => {
                IntermediateComponent {
                    component_type: Nor(1),
                    position: c.position,
                    inputs: vec![
                        (Point {x: -1, y: -1}, 1),
                        (Point {x: -1, y: 1}, 1)
                    ],
                    outputs: vec![(Point {x: 2, y: 0}, 1, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Xor => {
                IntermediateComponent {
                    component_type: Xor(1),
                    position: c.position,
                    inputs: vec![
                        (Point {x: -1, y: -1}, 1),
                        (Point {x: -1, y: 1}, 1)
                    ],
                    outputs: vec![(Point {x: 2, y: 0}, 1, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Xnor => {
                IntermediateComponent {
                    component_type: Xnor(1),
                    position: c.position,
                    inputs: vec![
                        (Point {x: -1, y: -1}, 1),
                        (Point {x: -1, y: 1}, 1)
                    ],
                    outputs: vec![(Point {x: 2, y: 0}, 1, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Counter8 => {
                IntermediateComponent {
                    component_type: Counter(c.setting_1, 8),
                    position: c.position,
                    inputs: Vec::new(),
                    outputs: vec![(Point {x: 1, y: 0}, 8, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::VirtualCounter8 => {
                IntermediateComponent {
                    component_type: VirtualCounter(c.setting_1, 8),
                    position: c.position,
                    inputs: vec![
                        (Point {x: -1, y: -1}, 1),
                        (Point {x: -1, y: 0}, 8)
                    ],
                    outputs: Vec::new(),
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Counter64 => {
                IntermediateComponent {
                    component_type: Counter(c.setting_1, 64),
                    position: c.position,
                    inputs: Vec::new(),
                    outputs: vec![(Point {x: 2, y: 0}, 64, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::VirtualCounter64 => {
                IntermediateComponent {
                    component_type: VirtualCounter(c.setting_1, 64),
                    position: c.position,
                    inputs: vec![
                        (Point {x: -3, y: 0}, 1),
                        (Point {x: -3, y: 1}, 64)
                    ],
                    outputs: Vec::new(),
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Ram8 => {
                IntermediateComponent {
                    component_type: Ram(256, 8),
                    position: c.position,
                    inputs: vec![
                        (Point {x: -13, y: -7}, 1),
                        (Point {x: -13, y: -5}, 8)
                    ],
                    outputs: vec![(Point {x: 13, y: -7}, 8, true)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::VirtualRam8 => {
                IntermediateComponent {
                    component_type: Ram(256, 8),
                    position: c.position,
                    inputs: vec![
                        (Point {x: -13, y: -6}, 1),
                        (Point {x: -13, y: -5}, 8),
                        (Point {x: -13, y: -4}, 8)
                    ],
                    outputs: Vec::new(),
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Deleted0 => {panic!("Not Implemented")}
            ComponentType::Deleted1 => {panic!("Not Implemented")}
            ComponentType::Deleted17 => {panic!("Not Implemented")}
            ComponentType::Deleted18 => {panic!("Not Implemented")}
            ComponentType::Register8 | ComponentType::Register8Red => {
                IntermediateComponent {
                    component_type: Register(8),
                    position: c.position,
                    inputs: vec![(Point {x: -1, y: -1}, 1)],
                    outputs: vec![(Point {x: 1, y: 0}, 8, true)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::VirtualRegister8 | ComponentType::VirtualRegister8Red => {
                IntermediateComponent {
                    component_type: Register(8),
                    position: c.position,
                    inputs: vec![
                        (Point {x: -1, y: 0}, 1),
                        (Point {x: -1, y: 1}, 8)
                    ],
                    outputs: Vec::new(),
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Register8RedPlus => {panic!("Not Implemented")}
            ComponentType::VirtualRegister8RedPlus => {panic!("Not Implemented")}
            ComponentType::Register64 => {
                IntermediateComponent {
                    component_type: Register(64),
                    position: c.position,
                    inputs: vec![(Point {x: -3, y: -1}, 1)],
                    outputs: vec![(Point {x: 3, y: 0}, 8, true)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::VirtualRegister64 => {
                IntermediateComponent {
                    component_type: Register(64),
                    position: c.position,
                    inputs: vec![
                        (Point {x: -3, y: 0}, 1),
                        (Point {x: -3, y: 1}, 8)
                    ],
                    outputs: Vec::new(),
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Switch8 => {
                IntermediateComponent {
                    component_type: Switch(8),
                    position: c.position,
                    inputs: vec![
                        (Point {x: 0, y: -1}, 1),
                        (Point {x: -1, y: 0}, 8)
                    ],
                    outputs: vec![(Point {x: 1, y: 0}, 8, true)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Mux8 => {
                IntermediateComponent {
                    component_type: Mux(8),
                    position: c.position,
                    inputs: vec![
                        (Point {x: -1, y: -1}, 1),
                        (Point {x: -1, y: 0}, 8),
                        (Point {x: -1, y: 1}, 8)
                    ],
                    outputs: vec![(Point {x: 1, y: 0}, 8, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Decoder1 => {
                IntermediateComponent {
                    component_type: Dec1,
                    position: c.position,
                    inputs: vec![(Point {x: -1, y: 0}, 1)],
                    outputs: vec![
                        (Point {x: 1, y: 0}, 1, false),
                        (Point {x: 1, y: 1}, 1, false)
                    ],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Decoder3 => {
                IntermediateComponent {
                    component_type: Dec3,
                    position: c.position,
                    inputs: vec![
                        (Point {x: -1, y: -3}, 1),
                        (Point {x: -1, y: -2}, 1),
                        (Point {x: -1, y: -1}, 1),
                        (Point {x: 0, y: -4}, 1)
                    ],
                    outputs: vec![
                        (Point {x: 1, y: -3}, 1, false),
                        (Point {x: 1, y: -2}, 1, false),
                        (Point {x: 1, y: -1}, 1, false),
                        (Point {x: 1, y: 0}, 1, false),
                        (Point {x: 1, y: 1}, 1, false),
                        (Point {x: 1, y: 2}, 1, false),
                        (Point {x: 1, y: 3}, 1, false),
                        (Point {x: 1, y: 4}, 1, false)
                    ],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Constant8 => {
                IntermediateComponent {
                    component_type: Constant(c.setting_1, 8),
                    position: c.position,
                    inputs: Vec::new(),
                    outputs: vec![(Point {x: 1, y: 0}, 8, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Not8 => {
                IntermediateComponent {
                    component_type: Not(8),
                    position: c.position,
                    inputs: vec![(Point {x: -1, y: 0}, 8)],
                    outputs: vec![(Point {x: 1, y: 0}, 8, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Or8 => {
                IntermediateComponent {
                    component_type: Or(8),
                    position: c.position,
                    inputs: vec![
                        (Point {x: -1, y: -1}, 8),
                        (Point {x: -1, y: 0}, 8)
                    ],
                    outputs: vec![(Point {x: 1, y: 0}, 8, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::And8 => {
                IntermediateComponent {
                    component_type: And(8),
                    position: c.position,
                    inputs: vec![
                        (Point {x: -1, y: -1}, 8),
                        (Point {x: -1, y: 0}, 8)
                    ],
                    outputs: vec![(Point {x: 1, y: 0}, 8, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Xor8 => {
                IntermediateComponent {
                    component_type: Xor(8),
                    position: c.position,
                    inputs: vec![
                        (Point {x: -1, y: -1}, 8),
                        (Point {x: -1, y: 0}, 8)
                    ],
                    outputs: vec![(Point {x: 1, y: 0}, 8, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Equal8 => {
                IntermediateComponent {
                    component_type: Equal(8),
                    position: c.position,
                    inputs: vec![
                        (Point {x: -1, y: -1}, 8),
                        (Point {x: -1, y: 0}, 8)
                    ],
                    outputs: vec![(Point {x: 1, y: 0}, 1, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Deleted2 => {panic!("Not Implemented")}
            ComponentType::Deleted3 => {panic!("Not Implemented")}
            ComponentType::Neg8 => {
                IntermediateComponent {
                    component_type: Neg(8),
                    position: c.position,
                    inputs: vec![(Point {x: -1, y: 0}, 8)],
                    outputs: vec![(Point {x: 1, y: 0}, 8, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Add8 => {
                IntermediateComponent {
                    component_type: Adder(8),
                    position: c.position,
                    inputs: vec![
                        (Point {x: -1, y: -1}, 1),
                        (Point {x: -1, y: 0}, 8),
                        (Point {x: -1, y: 1}, 8)
                    ],
                    outputs: vec![
                        (Point {x: 1, y: -1}, 8, false),
                        (Point {x: 1, y: 0}, 1, false)
                    ],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Mul8 => {
                IntermediateComponent {
                    component_type: Mul(8),
                    position: c.position,
                    inputs: vec![
                        (Point {x: -1, y: -1}, 8),
                        (Point {x: -1, y: 0}, 8)
                    ],
                    outputs: vec![
                        (Point {x: 1, y: -1}, 8, false),
                        (Point {x: 1, y: 0}, 8, false)
                    ],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Splitter8 => {
                IntermediateComponent {
                    component_type: ByteSplitter,
                    position: c.position,
                    inputs: vec![(Point {x: -1, y: 0}, 8)],
                    outputs: vec![
                        (Point {x: 1, y: -3}, 1, false),
                        (Point {x: 1, y: -2}, 1, false),
                        (Point {x: 1, y: -1}, 1, false),
                        (Point {x: 1, y: 0}, 1, false),
                        (Point {x: 1, y: 1}, 1, false),
                        (Point {x: 1, y: 2}, 1, false),
                        (Point {x: 1, y: 3}, 1, false),
                        (Point {x: 1, y: 4}, 1, false)
                    ],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Maker8 => {
                IntermediateComponent {
                    component_type: ByteMaker,
                    position: c.position,
                    inputs: vec![
                        (Point {x: -1, y: -3}, 1),
                        (Point {x: -1, y: -2}, 1),
                        (Point {x: -1, y: -1}, 1),
                        (Point {x: -1, y: 0}, 1),
                        (Point {x: -1, y: 1}, 1),
                        (Point {x: -1, y: 2}, 1),
                        (Point {x: -1, y: 3}, 1),
                        (Point {x: -1, y: 4}, 1)
                    ],
                    outputs: vec![(Point {x: 1, y: 0}, 8, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Splitter64 => {
                IntermediateComponent {
                    component_type: ByteSplitter8,
                    position: c.position,
                    inputs: vec![(Point {x: -1, y: 0}, 64)],
                    outputs: vec![
                        (Point {x: 1, y: -3}, 8, false),
                        (Point {x: 1, y: -2}, 8, false),
                        (Point {x: 1, y: -1}, 8, false),
                        (Point {x: 1, y: 0}, 8, false),
                        (Point {x: 1, y: 1}, 8, false),
                        (Point {x: 1, y: 2}, 8, false),
                        (Point {x: 1, y: 3}, 8, false),
                        (Point {x: 1, y: 4}, 8, false)
                    ],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Maker64 => {
                IntermediateComponent {
                    component_type: ByteMaker8,
                    position: c.position,
                    inputs: vec![
                        (Point {x: -1, y: -3}, 8),
                        (Point {x: -1, y: -2}, 8),
                        (Point {x: -1, y: -1}, 8),
                        (Point {x: -1, y: 0}, 8),
                        (Point {x: -1, y: 1}, 8),
                        (Point {x: -1, y: 2}, 8),
                        (Point {x: -1, y: 3}, 8),
                        (Point {x: -1, y: 4}, 8)
                    ],
                    outputs: vec![(Point {x: 1, y: 0}, 64, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::FullAdder => {
                IntermediateComponent {
                    component_type: Adder(1),
                    position: c.position,
                    inputs: vec![
                        (Point {x: -1, y: -1}, 1),
                        (Point {x: -1, y: 0}, 1),
                        (Point {x: -1, y: 1}, 1)
                    ],
                    outputs: vec![
                        (Point {x: 1, y: 0}, 1, false),
                        (Point {x: 1, y: 1}, 1, false)
                    ],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::BitMemory => {
                IntermediateComponent {
                    component_type: BitMemory,
                    position: c.position,
                    inputs: Vec::new(),
                    outputs: vec![(Point {x: 1, y: 0}, 1, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::VirtualBitMemory => {
                IntermediateComponent {
                    component_type: BitMemory,
                    position: c.position,
                    inputs: vec![
                        (Point {x: -1, y: -1}, 1),
                        (Point {x: -1, y: 1}, 1)
                    ],
                    outputs: Vec::new(),
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Deleted10 => {panic!("Not Implemented")}
            ComponentType::Decoder2 => {
                IntermediateComponent {
                    component_type: Dec2,
                    position: c.position,
                    inputs: vec![
                        (Point {x: -1, y: -1}, 1),
                        (Point {x: -1, y: 0}, 1)
                    ],
                    outputs: vec![
                        (Point {x: 1, y: -1}, 1, false),
                        (Point {x: 1, y: 0}, 1, false),
                        (Point {x: 1, y: 1}, 1, false),
                        (Point {x: 1, y: 2}, 1, false)
                    ],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Timing => {panic!("Not Implemented")}
            ComponentType::NoteSound => {panic!("Not Implemented")}
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
                    component_type: Input(*c.custom_string.clone(), 1),
                    position: c.position,
                    inputs: Vec::new(),
                    outputs: vec![(Point {x: 1, y: 0}, 1, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::LevelInput2Pin => {panic!("Not Implemented")}
            ComponentType::LevelInput3Pin => {panic!("Not Implemented")}
            ComponentType::LevelInput4Pin => {panic!("Not Implemented")}
            ComponentType::LevelInputConditions => {panic!("Not Implemented")}
            ComponentType::Input8 => {
                IntermediateComponent {
                    component_type: Input(*c.custom_string.clone(), 8),
                    position: c.position,
                    inputs: Vec::new(),
                    outputs: vec![(Point {x: 1, y: 0}, 8, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Input64 => {panic!("Not Implemented")}
            ComponentType::LevelInputCode => {panic!("Not Implemented")}
            ComponentType::LevelInputArch => {panic!("Not Implemented")}
            ComponentType::Output1 => {
                IntermediateComponent {
                    component_type: Output(Rc::from(*c.custom_string.clone()), 1),
                    position: c.position,
                    inputs: vec![(Point {x: -1, y: 0}, 1)],
                    outputs: Vec::new(),
                    bidirectional: Vec::new()
                }
            }
            ComponentType::LevelOutput1Sum => {panic!("Not Implemented")}
            ComponentType::LevelOutput1Car => {
                IntermediateComponent {
                    component_type: Output(Rc::from(*c.custom_string.clone()), 1),
                    position: c.position,
                    inputs: vec![(Point {x: -1, y: 0}, 1)],
                    outputs: Vec::new(),
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Deleted8 => {panic!("Not Implemented")}
            ComponentType::Deleted9 => {panic!("Not Implemented")}
            ComponentType::LevelOutput2Pin => {panic!("Not Implemented")}
            ComponentType::LevelOutput3Pin => {panic!("Not Implemented")}
            ComponentType::LevelOutput4Pin => {panic!("Not Implemented")}
            ComponentType::Output8 => {
                IntermediateComponent {
                    component_type: Output(Rc::from(*c.custom_string.clone()), 8),
                    position: c.position,
                    inputs: vec![(Point {x: -1, y: 0}, 8)],
                    outputs: Vec::new(),
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Output64 => {
                IntermediateComponent {
                    component_type: Output(Rc::from(*c.custom_string.clone()), 64),
                    position: c.position,
                    inputs: vec![(Point {x: -3, y: 0}, 64)],
                    outputs: Vec::new(),
                    bidirectional: Vec::new()
                }
            }
            ComponentType::LevelOutputArch => {panic!("Not Implemented")}
            ComponentType::LevelOutputCounter => {panic!("Not Implemented")}
            ComponentType::Deleted11 => {panic!("Not Implemented")}
            ComponentType::Custom => {panic!("Not Implemented")}
            ComponentType::VirtualCustom => {panic!("Not Implemented")}
            ComponentType::Program => {panic!("Not Implemented")}
            ComponentType::DelayLine1 => {
                IntermediateComponent {
                    component_type: DelayLine(1),
                    position: c.position,
                    inputs: Vec::new(),
                    outputs: vec![(Point {x: 1, y: 0}, 1, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::VirtualDelayLine1 => {panic!("Not Implemented")}
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
                        (Point {x: 0, y: -1}, 1),
                        (Point {x: -1, y: 0}, 64)
                    ],
                    outputs: vec![(Point {x: 1, y: 0}, 64, true)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::ProbeMemoryBit => {
                IntermediateComponent {
                    component_type: MemoryProbe(1),
                    position: c.position,
                    inputs: vec![(Point {x: -1, y: 0}, 1)],
                    outputs: Vec::new(),
                    bidirectional: Vec::new()
                }
            }
            ComponentType::ProbeMemoryWord => {
                IntermediateComponent {
                    component_type: MemoryProbe(64),
                    position: c.position,
                    inputs: vec![(Point {x: -1, y: 0}, 1)],
                    outputs: Vec::new(),
                    bidirectional: Vec::new()
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
                    component_type: Output(Rc::from(*c.custom_string.clone()), 16),
                    position: c.position,
                    inputs: vec![(Point {x: -2, y: 0}, 16)],
                    outputs: Vec::new(),
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Output32 => {
                IntermediateComponent {
                    component_type: Output(Rc::from(*c.custom_string.clone()), 32),
                    position: c.position,
                    inputs: vec![(Point {x: -2, y: 0}, 32)],
                    outputs: Vec::new(),
                    bidirectional: Vec::new()
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
                        (Point {x: 0, y: -1}, 1),
                        (Point {x: -1, y: 0}, 1)
                    ],
                    outputs: vec![(Point {x: 1, y: 0}, 1, true)],
                    bidirectional: Vec::new()
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
                        (Point {x: 0, y: -1}, 1),
                        (Point {x: -1, y: 0}, 16)
                    ],
                    outputs: vec![(Point {x: 1, y: 0}, 16, true)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Splitter16 => {panic!("Not Implemented")}
            ComponentType::Maker16 => {panic!("Not Implemented")}
            ComponentType::Register16 => {panic!("Not Implemented")}
            ComponentType::VirtualRegister16 => {panic!("Not Implemented")}
            ComponentType::Counter16 => {panic!("Not Implemented")}
            ComponentType::VirtualCounter16 => {panic!("Not Implemented")}
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
                        (Point {x: 0, y: -1}, 1),
                        (Point {x: -1, y: 0}, 32)
                    ],
                    outputs: vec![(Point {x: 1, y: 0}, 32, true)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Splitter32 => {panic!("Not Implemented")}
            ComponentType::Maker32 => {
                IntermediateComponent {
                    component_type: ByteMaker4,
                    position: c.position,
                    inputs: vec![
                        (Point {x: -1, y: -1}, 8),
                        (Point {x: -1, y: 0}, 8),
                        (Point {x: -1, y: 1}, 8),
                        (Point {x: -1, y: 2}, 8)
                    ],
                    outputs: vec![(Point {x: 1, y: 0}, 32, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Register32 => {panic!("Not Implemented")}
            ComponentType::VirtualRegister32 => {panic!("Not Implemented")}
            ComponentType::Counter32 => {panic!("Not Implemented")}
            ComponentType::VirtualCounter32 => {panic!("Not Implemented")}
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
            ComponentType::VirtualRam => {panic!("Not Implemented")}
            ComponentType::RamLatency => {panic!("Not Implemented")}
            ComponentType::VirtualRamLatency => {panic!("Not Implemented")}
            ComponentType::RamFast => {panic!("Not Implemented")}
            ComponentType::VirtualRamFast => {panic!("Not Implemented")}
            ComponentType::Rom => {panic!("Not Implemented")}
            ComponentType::VirtualRom => {panic!("Not Implemented")}
            ComponentType::SolutionRom => {panic!("Not Implemented")}
            ComponentType::VirtualSolutionRom => {panic!("Not Implemented")}
            ComponentType::DelayLine8 => {
                IntermediateComponent {
                    component_type: DelayLine(8),
                    position: c.position,
                    inputs: Vec::new(),
                    outputs: vec![(Point {x: 1, y: 0}, 8, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::VirtualDelayLine8 => {panic!("Not Implemented")}
            ComponentType::DelayLine16 => {panic!("Not Implemented")}
            ComponentType::VirtualDelayLine16 => {panic!("Not Implemented")}
            ComponentType::DelayLine32 => {panic!("Not Implemented")}
            ComponentType::VirtualDelayLine32 => {panic!("Not Implemented")}
            ComponentType::DelayLine64 => {panic!("Not Implemented")}
            ComponentType::VirtualDelayLine64 => {panic!("Not Implemented")}
            ComponentType::RamDualLoad => {panic!("Not Implemented")}
            ComponentType::VirtualRamDualLoad => {panic!("Not Implemented")}
            ComponentType::Hdd => {panic!("Not Implemented")}
            ComponentType::VirtualHdd => {panic!("Not Implemented")}
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
                    component_type: Input(*c.custom_string.clone(), 1),
                    position: c.position,
                    inputs: Vec::new(),
                    outputs: vec![(Point {x: 1, y: 0}, 1, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::LevelInput8 => {
                IntermediateComponent {
                    component_type: Input(*c.custom_string.clone(), 8),
                    position: c.position,
                    inputs: Vec::new(),
                    outputs: vec![(Point {x: 1, y: 0}, 8, false)],
                    bidirectional: Vec::new()
                }
            }
            ComponentType::LevelOutput1 => {
                IntermediateComponent {
                    component_type: Output(Rc::from(*c.custom_string.clone()), 1),
                    position: c.position,
                    inputs: vec![(Point {x: -1, y: 0}, 1)],
                    outputs: Vec::new(),
                    bidirectional: Vec::new()
                }
            }
            ComponentType::LevelOutput8 => {
                IntermediateComponent {
                    component_type: Output(Rc::from(*c.custom_string.clone()), 8),
                    position: c.position,
                    inputs: vec![(Point {x: -1, y: 0}, 8)],
                    outputs: Vec::new(),
                    bidirectional: Vec::new()
                }
            }
            ComponentType::Ashr8 => {panic!("Not Implemented")}
            ComponentType::Ashr16 => {panic!("Not Implemented")}
            ComponentType::Ashr32 => {panic!("Not Implemented")}
            ComponentType::Ashr64 => {panic!("Not Implemented")}
            ComponentType::Bidirectional1 => {panic!("Not Implemented")}
            ComponentType::VirtualBidirectional1 => {panic!("Not Implemented")}
            ComponentType::Bidirectional8 => {panic!("Not Implemented")}
            ComponentType::VirtualBidirectional8 => {panic!("Not Implemented")}
            ComponentType::Bidirectional16 => {panic!("Not Implemented")}
            ComponentType::VirtualBidirectional16 => {panic!("Not Implemented")}
            ComponentType::Bidirectional32 => {panic!("Not Implemented")}
            ComponentType::VirtualBidirectional32 => {panic!("Not Implemented")}
            ComponentType::Bidirectional64 => {panic!("Not Implemented")}
            ComponentType::VirtualBidirectional64 => {panic!("Not Implemented")}
        };

        if component.component_type.has_virtual() {
            match component.component_type {
                DelayLine(size) => {
                    let virtual_component = IntermediateComponent {
                        component_type: VirtualDelayLine(size),
                        inputs: vec![(Point {x: -1, y: 0}, size)],
                        outputs: Vec::new(),
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
                _ => {
                    panic!("Invalid Virtual Component!");
                }
            }
        }

        components.push(component.rotate(c.rotation));
    });

    components
}

#[cfg(test)]
mod tests {
    use std::collections::HashMap;
    use std::rc::Rc;
    use std::time::Instant;
    use crate::{DEBUG, read_from_save};
    use crate::simulator::ComponentType::{Input, Output};
    use crate::simulator::simulate;

    #[test]
    fn test_byte_adder_naive_ripple() {
        let (mut components, num_wires, data_bytes_needed) = read_from_save("test/resources/byte_adder/standard-ripple-carry.data");

        let mut first_input = true;
        for c in components.iter_mut() {
            match &c.component_type {
                Input(_, 8) => {
                    if first_input {
                        c.component_type = Input("Input A".to_string(), 8);
                        first_input = false
                    } else {
                        c.component_type = Input("Input B".to_string(), 8);
                    }
                },
                Input(_, 1) => {
                    c.component_type = Input("Carry In".to_string(), 1);
                },
                Output(_, 8) => {
                    c.component_type = Output(Rc::from("Sum"), 8)
                },
                Output(_, 1) => {
                    c.component_type = Output(Rc::from("Carry Out"), 1)
                },
                _ => {}
            }

            if DEBUG {
                println!("{:?}", c)
            }
        }

        let input_function = |tick: u64, input_name: &str| -> u64 {
            match input_name {
                "Input A" => {
                    tick & 0xFF
                },
                "Input B" => {
                    (tick >> 8) & 0xFF
                },
                "Carry In" => {
                    tick >> 16
                },
                _ => {
                    panic!("Unexpected Input Node");
                }
            }
        };

        let start = Instant::now();
        let result = simulate(components, num_wires, data_bytes_needed, 1 << 17, false, input_function);
        let end = Instant::now();
        println!("Simulation took {} seconds", (end - start).as_secs_f32());

        match result {
            Err(error) => {
                panic!("Error: {}", error);
            },
            Ok(output_list) => {
                println!("Simulation successfully exited after {} ticks", output_list.len());
                for (tick, outputs) in output_list.into_iter().enumerate() {
                    let outputs = outputs.into_iter().collect::<HashMap<_, _>>();

                    let input_a = input_function(tick as u64, "Input A");
                    let input_b = input_function(tick as u64, "Input B");
                    let carry_in = input_function(tick as u64, "Carry In");
                    let expected_sum = (input_a + input_b + carry_in) & 0xFF;
                    let expected_carry = (input_a + input_b + carry_in) >> 8;
                    let actual_sum = outputs["Sum"];
                    let actual_carry = outputs["Carry Out"];
                    assert_eq!(expected_sum, actual_sum);
                    assert_eq!(expected_carry, actual_carry);
                }
            }
        }
    }

    #[test]
    fn test_byte_adder_64_20() {
        let (mut components, num_wires, data_bytes_needed) = read_from_save("test/resources/byte_adder/decomposed-ripple-switch-carry.data");

        let mut first_input = true;
        for c in components.iter_mut() {
            match &c.component_type {
                Input(_, 8) => {
                    if first_input {
                        c.component_type = Input("Input A".to_string(), 8);
                        first_input = false
                    } else {
                        c.component_type = Input("Input B".to_string(), 8);
                    }
                },
                Input(_, 1) => {
                    c.component_type = Input("Carry In".to_string(), 1);
                },
                Output(_, 8) => {
                    c.component_type = Output(Rc::from("Sum"), 8)
                },
                Output(_, 1) => {
                    c.component_type = Output(Rc::from("Carry Out"), 1)
                },
                _ => {}
            }

            if DEBUG {
                println!("{:?}", c)
            }
        }

        let input_function = |tick: u64, input_name: &str| -> u64 {
            match input_name {
                "Input A" => {
                    tick & 0xFF
                },
                "Input B" => {
                    (tick >> 8) & 0xFF
                },
                "Carry In" => {
                    tick >> 16
                },
                _ => {
                    panic!("Unexpected Input Node");
                }
            }
        };

        let start = Instant::now();
        let result = simulate(components, num_wires, data_bytes_needed, 1 << 17, false, input_function);
        let end = Instant::now();
        println!("Simulation took {} seconds", (end - start).as_secs_f32());

        match result {
            Err(error) => {
                panic!("Error: {}", error);
            },
            Ok(output_list) => {
                println!("Simulation successfully exited after {} ticks", output_list.len());
                for (tick, outputs) in output_list.into_iter().enumerate() {
                    let outputs = outputs.into_iter().collect::<HashMap<_, _>>();

                    let input_a = input_function(tick as u64, "Input A");
                    let input_b = input_function(tick as u64, "Input B");
                    let carry_in = input_function(tick as u64, "Carry In");
                    let expected_sum = (input_a + input_b + carry_in) & 0xFF;
                    let expected_carry = (input_a + input_b + carry_in) >> 8;
                    let actual_sum = outputs["Sum"];
                    let actual_carry = outputs["Carry Out"];
                    assert_eq!(expected_sum, actual_sum);
                    assert_eq!(expected_carry, actual_carry);
                }
            }
        }
    }

    #[test]
    fn test_5bit_decoder() {
        let (mut components, num_wires, data_bytes_needed) = read_from_save("test/resources/5-bit-decoder.data");

        for c in components.iter_mut() {
            match &c.component_type {
                Input(_, 8) => {
                    c.component_type = Input("Input".to_string(), 8)
                },
                Input(_, 1) => {
                    c.component_type = Input("Disable".to_string(), 1);
                },
                Output(_, 32) => {
                    c.component_type = Output(Rc::from("Output"), 32)
                },
                _ => {}
            }

            if DEBUG {
                println!("{:?}", c)
            }
        }

        let input_function = |tick: u64, input_name: &str| -> u64 {
            match input_name {
                "Input" => {
                    tick & 0x1F
                },
                "Disable" => {
                    tick >> 5
                },
                _ => {
                    panic!("Unexpected Input Node");
                }
            }
        };

        let result = simulate(components, num_wires, data_bytes_needed, 64, false, input_function);
        match result {
            Err(error) => {
                panic!("Error: {}", error);
            },
            Ok(output_list) => {
                println!("Simulation successfully exited after {} ticks", output_list.len());
                for (tick, outputs) in output_list.into_iter().enumerate() {
                    let outputs = outputs.into_iter().collect::<HashMap<_, _>>();

                    let input = input_function(tick as u64, "Input");
                    let disable = input_function(tick as u64, "Disable");
                    let expected_output = if disable != 0 {0u64} else {1 << input};
                    let actual_output = outputs["Output"];
                    assert_eq!(expected_output, actual_output);
                }
            }
        }
    }
}