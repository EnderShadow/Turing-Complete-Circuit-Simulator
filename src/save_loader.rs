use std::collections::{HashMap, HashSet, VecDeque};
use std::ops::{Not, Sub};
use std::path::PathBuf;
use std::rc::Rc;
use walkdir::WalkDir;
use crate::{Options, VERBOSITY_ALL};
use crate::save_parser::{parse_save, Point, Wire, Component as SaveComponent, ComponentType, SaveFile, AllData, HeadersOnly};
use crate::simulator::{Component, IntermediateComponent};
use crate::simulator::ComponentType::*;

pub fn read_from_save(path: &str, options: &Options) -> (Vec<Component>, usize, usize, u64) {
    let save = parse_save(PathBuf::from(path).as_path());
    let save = save.unwrap();
    let save_id = save.save_id;

    let mut all_components = read_all_circuit_data_files(options);
    all_components.insert(save.save_id, save);


    let mut needed_ids = HashSet::<u64>::new();
    needed_ids.insert(save_id);
    let mut ids_to_check = needed_ids.clone();
    while !ids_to_check.is_empty() {
        let mut ids_to_add = HashSet::<u64>::new();
        all_components.iter().filter(|(id, _)| ids_to_check.contains(id)).for_each(|(_, s)| ids_to_add.extend(s.dependencies.iter()));

        needed_ids.extend(ids_to_add.iter());
        ids_to_check = ids_to_add;
    }

    let all_components: HashMap<u64, SaveFile<AllData>> = all_components.into_iter().filter_map(|(id, save)| {
        if needed_ids.contains(&id) {
            save.parse_remaining().map(|s| (id, s))
        } else {
            None
        }
    }).collect();

    let save = all_components.get(&save_id).unwrap();

    if options.verbosity >= VERBOSITY_ALL {
        for c in save.components() {
            println!("{:?}", c.component_type)
        }
    }

    let wire_clusters = merge_wires(save.wires(), options);
    let components = resolve_components(save.components(), &save.dependencies, options);

    let components = optimize_components(components, options);
    let wire_clusters = remove_unused_wire_clusters(wire_clusters, &components, options);

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
                Input(_, _) | SwitchedInput(_, _) | InputMultiBitPin => {
                    let i_index = input_index;
                    input_index += 1;
                    i_index
                }
                Output(_, _) | SwitchedOutput(_, _) | OutputMultiBitPin | BidirectionalIO(_, _) => {
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

fn read_all_circuit_data_files(options: &Options) -> HashMap<u64, SaveFile<HeadersOnly>> {
    let mut save_files = HashMap::new();

    let path = options.schematic_path.as_path();
    let walker = WalkDir::new(path).max_depth(usize::MAX);
    for entry in walker {
        let entry = entry.unwrap();
        if entry.file_type().is_file() && entry.file_name().to_string_lossy() == "circuit.data" {
            let save_file = parse_save(entry.path());
            if let Ok(save_file) = save_file {
                save_files.insert(save_file.save_id, save_file);
            }
        }
    }

    save_files
}

fn merge_wires(wire_segments: &Vec<Wire>, options: &Options) -> Vec<HashSet<Point>> {
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

fn resolve_components(save_components: &[SaveComponent], dependencies: &[u64], options: &Options) -> Vec<IntermediateComponent> {
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
            ComponentType::Keyboard => {
                IntermediateComponent {
                    component_type: Keyboard,
                    position: c.position,
                    inputs: vec![(Point::new(-2, -2), 1)],
                    outputs: vec![
                        (Point::new(1, -3), 1, false),
                        (Point::new(2, -2), 8, false),
                        (Point::new(2, -1), 1, false)
                    ],
                    bidirectional: vec![]
                }
            }
            ComponentType::FileLoader => {
                IntermediateComponent {
                    component_type: FileRom(c.custom_string.clone()),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-3, -1), 1),
                        (Point::new(-4, 0), 64)
                    ],
                    outputs: vec![(Point::new(4, 0), 64, true)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Halt => {
                IntermediateComponent {
                    component_type: Halt(c.custom_string.clone()),
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 1)],
                    outputs: vec![],
                    bidirectional: vec![]
                }
            }
            ComponentType::WireCluster => {panic!("Not Implemented")}
            ComponentType::LevelScreen => {
                IntermediateComponent {
                    component_type: LevelScreen,
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![],
                    bidirectional: vec![]
                }
            }
            ComponentType::Program8_1 | ComponentType::Program8_4 => {
                IntermediateComponent {
                    component_type: Program(c.selected_programs[&c.setting_1].clone(), 8),
                    position: c.position,
                    inputs: vec![(Point::new(-13, -7), 8)],
                    outputs: vec![
                        (Point::new(13, -7), 8, false),
                        (Point::new(13, -6), 8, false),
                        (Point::new(13, -5), 8, false),
                        (Point::new(13, -4), 8, false)
                    ],
                    bidirectional: vec![]
                }
            }
            ComponentType::Program8_1Red => {
                todo!("Implement Program data");
                IntermediateComponent {
                    component_type: LevelProgram(Vec::default()),
                    position: c.position,
                    inputs: vec![(Point::new(-13, -7), 8)],
                    outputs: vec![(Point::new(13, -7), 8, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Deleted6 => {panic!("Not Implemented")}
            ComponentType::Deleted7 => {panic!("Not Implemented")}
            ComponentType::LevelGate => {panic!("Not Implemented")}
            ComponentType::Input1 | ComponentType::LevelInput1 => {
                IntermediateComponent {
                    component_type: Input(c.custom_string.clone(), 1),
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![(Point::new(1, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::LevelInput2Pin => {
                IntermediateComponent {
                    component_type: InputMultiBitPin,
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![
                        (Point::new(0, -1), 1, false),
                        (Point::new(0, 1), 1, false)
                    ],
                    bidirectional: vec![]
                }
            }
            ComponentType::LevelInput3Pin => {
                IntermediateComponent {
                    component_type: InputMultiBitPin,
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![
                        (Point::new(1, -2), 1, false),
                        (Point::new(1, -1), 1, false),
                        (Point::new(1, 0), 1, false)
                    ],
                    bidirectional: vec![]
                }
            }
            ComponentType::LevelInput4Pin => {
                IntermediateComponent {
                    component_type: InputMultiBitPin,
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![
                        (Point::new(1, -2), 1, false),
                        (Point::new(1, -1), 1, false),
                        (Point::new(1, 0), 1, false),
                        (Point::new(1, 1), 1, false)
                    ],
                    bidirectional: vec![]
                }
            }
            ComponentType::LevelInputConditions | ComponentType::Input8 | ComponentType::LevelInputCode | ComponentType::LevelInput8 => {
                IntermediateComponent {
                    component_type: Input(c.custom_string.clone(), 8),
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![(Point::new(1, 0), 8, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Input64 => {
                IntermediateComponent {
                    component_type: Input(c.custom_string.clone(), 64),
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![(Point::new(3, 0), 64, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::LevelInputArch => {
                IntermediateComponent {
                    component_type: SwitchedInput(c.custom_string.clone(), 8),
                    position: c.position,
                    inputs: vec![(Point::new(0, 1), 1)],
                    outputs: vec![(Point::new(1, 0), 8, true)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Output1 | ComponentType::LevelOutput1Sum | ComponentType::LevelOutput1Car | ComponentType::LevelOutput1 => {
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
            ComponentType::LevelOutput2Pin => {
                IntermediateComponent {
                    component_type: OutputMultiBitPin,
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 1),
                        (Point::new(-1, 0), 1)
                    ],
                    outputs: vec![],
                    bidirectional: vec![]
                }
            }
            ComponentType::LevelOutput3Pin => {
                IntermediateComponent {
                    component_type: OutputMultiBitPin,
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -2), 1),
                        (Point::new(-1, -1), 1),
                        (Point::new(-1, 0), 1)
                    ],
                    outputs: vec![],
                    bidirectional: vec![]
                }
            }
            ComponentType::LevelOutput4Pin => {
                IntermediateComponent {
                    component_type: OutputMultiBitPin,
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -2), 1),
                        (Point::new(-1, -1), 1),
                        (Point::new(-1, 0), 1),
                        (Point::new(-1, 1), 1)
                    ],
                    outputs: vec![],
                    bidirectional: vec![]
                }
            }
            ComponentType::Output8 | ComponentType::LevelOutput8 => {
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
            ComponentType::LevelOutputArch => {
                IntermediateComponent {
                    component_type: SwitchedOutput(Rc::from(c.custom_string.clone()), 8),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, 0), 8),
                        (Point::new(0, 1), 1)
                    ],
                    outputs: vec![],
                    bidirectional: vec![]
                }
            }
            ComponentType::LevelOutputCounter => {
                IntermediateComponent {
                    component_type: OutputMultiBitPin,
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 1),
                        (Point::new(-1, 0), 1),
                        (Point::new(-1, 1), 1)
                    ],
                    outputs: vec![],
                    bidirectional: vec![]
                }
            }
            ComponentType::Deleted11 => {panic!("Not Implemented")}
            ComponentType::Custom => {
                println!("{:?}", c);
                todo!("Not Implemented")
            }
            ComponentType::VirtualCustom => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::Program => {
                println!("{:?}", c);
                IntermediateComponent {
                    component_type: Program(c.selected_programs[&c.setting_1].clone(), c.setting_2 as u8),
                    position: c.position,
                    inputs: vec![(Point::new(-13, -7), 16)],
                    outputs: vec![
                        (Point::new(13, -7), 64, false),
                        (Point::new(13, -6), 64, false),
                        (Point::new(13, -5), 64, false),
                        (Point::new(13, -4), 64, false)
                    ],
                    bidirectional: vec![]
                }
            }
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
            ComponentType::Console => {
                todo!("Not Implemented")
            }
            ComponentType::Shl8 => {
                IntermediateComponent {
                    component_type: Shl(8),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 8),
                        (Point::new(-1, 0), 3)
                    ],
                    outputs: vec![(Point::new(1, -1), 8, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Shr8 => {
                IntermediateComponent {
                    component_type: Shr(8),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 8),
                        (Point::new(-1, 0), 3)
                    ],
                    outputs: vec![(Point::new(1, -1), 8, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Constant64 => {
                IntermediateComponent {
                    component_type: Constant(c.setting_1, 64),
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![(Point::new(3, 0), 64, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Not64 => {
                IntermediateComponent {
                    component_type: Not(64),
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 64)],
                    outputs: vec![(Point::new(1, 0), 64, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Or64 => {
                IntermediateComponent {
                    component_type: Or(64),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 64),
                        (Point::new(-1, 0), 64)
                    ],
                    outputs: vec![(Point::new(1, 0), 64, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::And64 => {
                IntermediateComponent {
                    component_type: And(64),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 64),
                        (Point::new(-1, 0), 64)
                    ],
                    outputs: vec![(Point::new(1, 0), 64, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Xor64 => {
                IntermediateComponent {
                    component_type: Xor(64),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 64),
                        (Point::new(-1, 0), 64)
                    ],
                    outputs: vec![(Point::new(1, 0), 64, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Neg64 => {
                IntermediateComponent {
                    component_type: Neg(64),
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 64)],
                    outputs: vec![(Point::new(1, 0), 64, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Add64 => {
                IntermediateComponent {
                    component_type: Adder(64),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 1),
                        (Point::new(-1, 0), 64),
                        (Point::new(-1, 1), 64)
                    ],
                    outputs: vec![
                        (Point::new(1, -1), 64, false),
                        (Point::new(1, 0), 1, false)
                    ],
                    bidirectional: vec![]
                }
            }
            ComponentType::Mul64 => {
                IntermediateComponent {
                    component_type: Mul(64),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 64),
                        (Point::new(-1, 0), 64)
                    ],
                    outputs: vec![
                        (Point::new(1, -1), 64, false),
                        (Point::new(1, 0), 64, false)
                    ],
                    bidirectional: vec![]
                }
            }
            ComponentType::Equal64 => {
                IntermediateComponent {
                    component_type: Equal(64),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 64),
                        (Point::new(-1, 0), 64)
                    ],
                    outputs: vec![(Point::new(1, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::LessU64 => {
                IntermediateComponent {
                    component_type: ULess(64),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 64),
                        (Point::new(-1, 0), 64)
                    ],
                    outputs: vec![(Point::new(1, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::LessI64 => {
                IntermediateComponent {
                    component_type: SLess(64),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 64),
                        (Point::new(-1, 0), 64)
                    ],
                    outputs: vec![(Point::new(1, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Shl64 => {
                IntermediateComponent {
                    component_type: Shl(64),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 64),
                        (Point::new(-1, 0), 6)
                    ],
                    outputs: vec![(Point::new(1, -1), 64, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Shr64 => {
                IntermediateComponent {
                    component_type: Shr(64),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 64),
                        (Point::new(-1, 0), 6)
                    ],
                    outputs: vec![(Point::new(1, -1), 64, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Mux64 => {
                IntermediateComponent {
                    component_type: Mux(64),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 1),
                        (Point::new(-1, 0), 64),
                        (Point::new(-1, 1), 64)
                    ],
                    outputs: vec![(Point::new(1, 0), 64, false)],
                    bidirectional: vec![]
                }
            }
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
            ComponentType::LessU8 => {
                IntermediateComponent {
                    component_type: ULess(8),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 8),
                        (Point::new(-1, 0), 8)
                    ],
                    outputs: vec![(Point::new(1, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::LessI8 => {
                IntermediateComponent {
                    component_type: SLess(8),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 8),
                        (Point::new(-1, 0), 8)
                    ],
                    outputs: vec![(Point::new(1, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::DotMatrixDisplay => {
                todo!("Not Implemented")
            }
            ComponentType::SegmentDisplay => {
                todo!("Not Implemented")
            }
            ComponentType::Input16 => {
                IntermediateComponent {
                    component_type: Input(c.custom_string.clone(), 16),
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![(Point::new(2, 0), 16, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Input32 => {
                IntermediateComponent {
                    component_type: Input(c.custom_string.clone(), 32),
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![(Point::new(2, 0), 32, false)],
                    bidirectional: vec![]
                }
            }
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
            ComponentType::Buffer8 => {
                IntermediateComponent {
                    component_type: Buffer(8),
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 8)],
                    outputs: vec![(Point::new(1, 0), 8, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Buffer16 => {
                IntermediateComponent {
                    component_type: Buffer(16),
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 16)],
                    outputs: vec![(Point::new(1, 0), 16, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Buffer32 => {
                IntermediateComponent {
                    component_type: Buffer(32),
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 32)],
                    outputs: vec![(Point::new(1, 0), 32, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Buffer64 => {
                IntermediateComponent {
                    component_type: Buffer(64),
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 64)],
                    outputs: vec![(Point::new(1, 0), 64, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::ProbeWireBit => {
                IntermediateComponent {
                    component_type: WireProbe(1),
                    position: c.position,
                    inputs: vec![(Point::new(0, -1), 1)],
                    outputs: vec![],
                    bidirectional: vec![]
                }
            }
            ComponentType::ProbeWireWord => {
                IntermediateComponent {
                    component_type: WireProbe(64),
                    position: c.position,
                    inputs: vec![(Point::new(0, -1), 64)],
                    outputs: vec![],
                    bidirectional: vec![]
                }
            }
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
            ComponentType::Output1z => {
                IntermediateComponent {
                    component_type: SwitchedOutput(Rc::from(c.custom_string.clone()), 1),
                    position: c.position,
                    inputs: vec![
                        (Point::new(0, 1), 1),
                        (Point::new(-1, 0), 1)
                    ],
                    outputs: vec![],
                    bidirectional: vec![]
                }
            }
            ComponentType::Output8z | ComponentType::LevelOutput8z => {
                IntermediateComponent {
                    component_type: SwitchedOutput(Rc::from(c.custom_string.clone()), 8),
                    position: c.position,
                    inputs: vec![
                        (Point::new(0, 1), 1),
                        (Point::new(-1, 0), 8)
                    ],
                    outputs: vec![],
                    bidirectional: vec![]
                }
            }
            ComponentType::Output16z => {
                IntermediateComponent {
                    component_type: SwitchedOutput(Rc::from(c.custom_string.clone()), 16),
                    position: c.position,
                    inputs: vec![
                        (Point::new(0, 2), 1),
                        (Point::new(-2, 0), 16)
                    ],
                    outputs: vec![],
                    bidirectional: vec![]
                }
            }
            ComponentType::Output32z => {
                IntermediateComponent {
                    component_type: SwitchedOutput(Rc::from(c.custom_string.clone()), 32),
                    position: c.position,
                    inputs: vec![
                        (Point::new(0, 2), 1),
                        (Point::new(-2, 0), 32)
                    ],
                    outputs: vec![],
                    bidirectional: vec![]
                }
            }
            ComponentType::Output64z => {
                IntermediateComponent {
                    component_type: SwitchedOutput(Rc::from(c.custom_string.clone()), 64),
                    position: c.position,
                    inputs: vec![
                        (Point::new(0, 2), 1),
                        (Point::new(-3, 0), 64)
                    ],
                    outputs: vec![],
                    bidirectional: vec![]
                }
            }
            ComponentType::Constant16 => {
                IntermediateComponent {
                    component_type: Constant(c.setting_1, 16),
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![(Point::new(2, 0), 16, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Not16 => {
                IntermediateComponent {
                    component_type: Not(16),
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 16)],
                    outputs: vec![(Point::new(1, 0), 16, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Or16 => {
                IntermediateComponent {
                    component_type: Or(16),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 16),
                        (Point::new(-1, 0), 16)
                    ],
                    outputs: vec![(Point::new(1, 0), 16, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::And16 => {
                IntermediateComponent {
                    component_type: And(16),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 16),
                        (Point::new(-1, 0), 16)
                    ],
                    outputs: vec![(Point::new(1, 0), 16, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Xor16 => {
                IntermediateComponent {
                    component_type: Xor(16),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 16),
                        (Point::new(-1, 0), 16)
                    ],
                    outputs: vec![(Point::new(1, 0), 16, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Neg16 => {
                IntermediateComponent {
                    component_type: Neg(16),
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 16)],
                    outputs: vec![(Point::new(1, 0), 16, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Add16 => {
                IntermediateComponent {
                    component_type: Adder(16),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 1),
                        (Point::new(-1, 0), 16),
                        (Point::new(-1, 1), 16)
                    ],
                    outputs: vec![
                        (Point::new(1, -1), 16, false),
                        (Point::new(1, 0), 1, false)
                    ],
                    bidirectional: vec![]
                }
            }
            ComponentType::Mul16 => {
                IntermediateComponent {
                    component_type: Mul(16),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 16),
                        (Point::new(-1, 0), 16)
                    ],
                    outputs: vec![
                        (Point::new(1, -1), 16, false),
                        (Point::new(1, 0), 16, false)
                    ],
                    bidirectional: vec![]
                }
            }
            ComponentType::Equal16 => {
                IntermediateComponent {
                    component_type: Equal(16),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 16),
                        (Point::new(-1, 0), 16)
                    ],
                    outputs: vec![(Point::new(1, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::LessU16 => {
                IntermediateComponent {
                    component_type: ULess(16),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 16),
                        (Point::new(-1, 0), 16)
                    ],
                    outputs: vec![(Point::new(1, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::LessI16 => {
                IntermediateComponent {
                    component_type: SLess(16),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 16),
                        (Point::new(-1, 0), 16)
                    ],
                    outputs: vec![(Point::new(1, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Shl16 => {
                IntermediateComponent {
                    component_type: Shl(16),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 16),
                        (Point::new(-1, 0), 4)
                    ],
                    outputs: vec![(Point::new(1, -1), 16, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Shr16 => {
                IntermediateComponent {
                    component_type: Shr(16),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 16),
                        (Point::new(-1, 0), 4)
                    ],
                    outputs: vec![(Point::new(1, -1), 16, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Mux16 => {
                IntermediateComponent {
                    component_type: Mux(16),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 1),
                        (Point::new(-1, 0), 16),
                        (Point::new(-1, 1), 16)
                    ],
                    outputs: vec![(Point::new(1, 0), 16, false)],
                    bidirectional: vec![]
                }
            }
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
            ComponentType::Splitter16 => {
                IntermediateComponent {
                    component_type: ByteSplitter2,
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 16)],
                    outputs: vec![
                        (Point::new(1, -1), 8, false),
                        (Point::new(1, 0), 8, false)
                    ],
                    bidirectional: vec![]
                }
            }
            ComponentType::Maker16 => {
                IntermediateComponent {
                    component_type: ByteMaker2,
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 8),
                        (Point::new(-1, 0), 8)
                    ],
                    outputs: vec![(Point::new(1, 0), 16, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Register16 => {
                IntermediateComponent {
                    component_type: Register(16),
                    position: c.position,
                    inputs: vec![(Point::new(-2, -1), 1)],
                    outputs: vec![(Point::new(2, 0), 16, true)],
                    bidirectional: vec![]
                }
            }
            ComponentType::VirtualRegister16 => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::Counter16 => {
                IntermediateComponent {
                    component_type: Counter(c.setting_1, 16),
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![(Point::new(2, 0), 16, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::VirtualCounter16 => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::Constant32 => {
                IntermediateComponent {
                    component_type: Constant(c.setting_1, 32),
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![(Point::new(2, 0), 32, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Not32 => {
                IntermediateComponent {
                    component_type: Not(32),
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 32)],
                    outputs: vec![(Point::new(1, 0), 32, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Or32 => {
                IntermediateComponent {
                    component_type: Or(32),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 32),
                        (Point::new(-1, 0), 32)
                    ],
                    outputs: vec![(Point::new(1, 0), 32, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::And32 => {
                IntermediateComponent {
                    component_type: And(32),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 32),
                        (Point::new(-1, 0), 32)
                    ],
                    outputs: vec![(Point::new(1, 0), 32, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Xor32 => {
                IntermediateComponent {
                    component_type: Xor(32),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 32),
                        (Point::new(-1, 0), 32)
                    ],
                    outputs: vec![(Point::new(1, 0), 32, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Neg32 => {
                IntermediateComponent {
                    component_type: Neg(32),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 32),
                        (Point::new(-1, 0), 32)
                    ],
                    outputs: vec![(Point::new(1, 0), 32, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Add32 => {
                IntermediateComponent {
                    component_type: Adder(32),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 1),
                        (Point::new(-1, 0), 32),
                        (Point::new(-1, 1), 32)
                    ],
                    outputs: vec![
                        (Point::new(1, -1), 32, false),
                        (Point::new(1, 0), 1, false)
                    ],
                    bidirectional: vec![]
                }
            }
            ComponentType::Mul32 => {
                IntermediateComponent {
                    component_type: Mul(32),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 32),
                        (Point::new(-1, 0), 32)
                    ],
                    outputs: vec![
                        (Point::new(1, -1), 32, false),
                        (Point::new(1, 0), 32, false)
                    ],
                    bidirectional: vec![]
                }
            }
            ComponentType::Equal32 => {
                IntermediateComponent {
                    component_type: Equal(32),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 32),
                        (Point::new(-1, 0), 32)
                    ],
                    outputs: vec![(Point::new(1, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::LessU32 => {
                IntermediateComponent {
                    component_type: ULess(32),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 32),
                        (Point::new(-1, 0), 32)
                    ],
                    outputs: vec![(Point::new(1, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::LessI32 => {
                IntermediateComponent {
                    component_type: SLess(32),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 32),
                        (Point::new(-1, 0), 32)
                    ],
                    outputs: vec![(Point::new(1, 0), 1, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Shl32 => {
                IntermediateComponent {
                    component_type: Shl(32),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 32),
                        (Point::new(-1, 0), 5)
                    ],
                    outputs: vec![(Point::new(1, -1), 32, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Shr32 => {
                IntermediateComponent {
                    component_type: Shr(32),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 32),
                        (Point::new(-1, 0), 5)
                    ],
                    outputs: vec![(Point::new(1, -1), 32, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Mux32 => {
                IntermediateComponent {
                    component_type: Mux(32),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 1),
                        (Point::new(-1, 0), 32),
                        (Point::new(-1, 1), 32)
                    ],
                    outputs: vec![(Point::new(1, 0), 32, false)],
                    bidirectional: vec![]
                }
            }
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
            ComponentType::Splitter32 => {
                IntermediateComponent {
                    component_type: ByteSplitter4,
                    position: c.position,
                    inputs: vec![(Point::new(-1, 0), 32)],
                    outputs: vec![
                        (Point::new(1, -1), 8, false),
                        (Point::new(1, 0), 8, false),
                        (Point::new(1, 1), 8, false),
                        (Point::new(1, 2), 8, false)
                    ],
                    bidirectional: vec![]
                }
            }
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
            ComponentType::Register32 => {
                IntermediateComponent {
                    component_type: Register(32),
                    position: c.position,
                    inputs: vec![(Point::new(-2, -1), 1)],
                    outputs: vec![(Point::new(2, 0), 32, true)],
                    bidirectional: vec![]
                }
            }
            ComponentType::VirtualRegister32 => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::Counter32 => {
                IntermediateComponent {
                    component_type: Counter(c.setting_1, 32),
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![(Point::new(2, 0), 32, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::VirtualCounter32 => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::Nand8 => {
                IntermediateComponent {
                    component_type: Nand(8),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 8),
                        (Point::new(-1, 0), 8)
                    ],
                    outputs: vec![(Point::new(1, 0), 8, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Nor8 => {
                IntermediateComponent {
                    component_type: Nor(8),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 8),
                        (Point::new(-1, 0), 8)
                    ],
                    outputs: vec![(Point::new(1, 0), 8, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Xnor8 => {
                IntermediateComponent {
                    component_type: Xnor(8),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 8),
                        (Point::new(-1, 0), 8)
                    ],
                    outputs: vec![(Point::new(1, 0), 8, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Nand16 => {
                IntermediateComponent {
                    component_type: Nand(16),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 16),
                        (Point::new(-1, 0), 16)
                    ],
                    outputs: vec![(Point::new(1, 0), 16, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Nor16 => {
                IntermediateComponent {
                    component_type: Nor(16),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 16),
                        (Point::new(-1, 0), 16)
                    ],
                    outputs: vec![(Point::new(1, 0), 16, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Xnor16 => {
                IntermediateComponent {
                    component_type: Xnor(16),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 16),
                        (Point::new(-1, 0), 16)
                    ],
                    outputs: vec![(Point::new(1, 0), 16, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Nand32 => {
                IntermediateComponent {
                    component_type: Nand(32),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 32),
                        (Point::new(-1, 0), 32)
                    ],
                    outputs: vec![(Point::new(1, 0), 32, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Nor32 => {
                IntermediateComponent {
                    component_type: Nor(32),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 32),
                        (Point::new(-1, 0), 32)
                    ],
                    outputs: vec![(Point::new(1, 0), 32, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Xnor32 => {
                IntermediateComponent {
                    component_type: Xnor(32),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 32),
                        (Point::new(-1, 0), 32)
                    ],
                    outputs: vec![(Point::new(1, 0), 32, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Nand64 => {
                IntermediateComponent {
                    component_type: Nand(64),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 64),
                        (Point::new(-1, 0), 64)
                    ],
                    outputs: vec![(Point::new(1, 0), 64, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Nor64 => {
                IntermediateComponent {
                    component_type: Nor(64),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 64),
                        (Point::new(-1, 0), 64)
                    ],
                    outputs: vec![(Point::new(1, 0), 64, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::Xnor64 => {
                IntermediateComponent {
                    component_type: Xnor(64),
                    position: c.position,
                    inputs: vec![
                        (Point::new(-1, -1), 64),
                        (Point::new(-1, 0), 64)
                    ],
                    outputs: vec![(Point::new(1, 0), 64, false)],
                    bidirectional: vec![]
                }
            }
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
            ComponentType::DelayLine16 => {
                IntermediateComponent {
                    component_type: DelayLine(16),
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![(Point::new(2, 0), 16, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::VirtualDelayLine16 => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::DelayLine32 => {
                IntermediateComponent {
                    component_type: DelayLine(32),
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![(Point::new(2, 0), 32, false)],
                    bidirectional: vec![]
                }
            }
            ComponentType::VirtualDelayLine32 => {panic!("Virtual components should not appear in a save file. Found {:?}", c.component_type)}
            ComponentType::DelayLine64 => {
                IntermediateComponent {
                    component_type: DelayLine(64),
                    position: c.position,
                    inputs: vec![],
                    outputs: vec![(Point::new(3, 0), 64, false)],
                    bidirectional: vec![]
                }
            }
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
                    let x_offset = match size {
                        1..=8  => -1,
                        9..=16  => -2,
                        17..=32  => -2,
                        33..=64  => -3,
                        x => panic!("Invalid delay line size: {}", x)
                    };
                    let virtual_component = IntermediateComponent {
                        component_type: VirtualDelayLine(size),
                        inputs: vec![(Point::new(x_offset, 0), size)],
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
                component_type => {
                    panic!("Unhandled component with virtual components {:?}", component_type);
                }
            }
        }

        components.push(component.rotate(c.rotation));
    });

    components
}

// TODO
fn optimize_components(components: Vec<IntermediateComponent>, options: &Options) -> Vec<IntermediateComponent> {
    components
}

// TODO
fn remove_unused_wire_clusters(wire_clusters: Vec<HashSet<Point>>, components: &[IntermediateComponent], options: &Options) -> Vec<HashSet<Point>> {
    wire_clusters
}