use std::collections::{HashMap, HashSet};
use std::ops::Not;
use crate::DEBUG;
use crate::save_loader::Point;

#[derive(Debug, PartialEq, Eq, Clone)]
pub enum ComponentType {
    Input(String, u8),
    SwitchedInput(String, u8),
    Output(String, u8),
    SwitchedOutput(String, u8),
    BidirectionalIO(String, u8),
    Buffer(u8),
    Not(u8),
    Switch(u8),
    And(u8),
    Or(u8),
    Nand(u8),
    Nor(u8),
    Xor(u8),
    Xnor(u8),
    Adder(u8),
    DelayLine(u8),
    VirtualDelayLine(u8),
    Register(u8),
    VirtualRegister(u8),
    Shl(u8),
    Shr(u8),
    Rol(u8),
    Ror(u8),
    Ashr(u8),
    Neg(u8),
    Mul(u8),
    Div(u8),
    Equal(u8),
    ULess(u8),
    SLess(u8),
    Mux(u8),
    Counter(u64, u8),
    VirtualCounter(u64, u8),
    Constant(u64, u8),
    And3,
    Or3,
    Dec1,
    Dec2,
    Dec3,
    BitMemory,
    VirtualBitMemory,
    ByteSplitter,
    ByteMaker,
    ByteSplitter2,
    ByteSplitter4,
    ByteSplitter8,
    ByteMaker2,
    ByteMaker4,
    ByteMaker8,
    FileRom(String),
    Keyboard,
    Time,
    Network,
    Console(u8, bool),
    DotMatrix(bool),
    SevenSegment,
    SpriteDisplay,
    WireProbe(u8),
    MemoryProbe(u8),
    LevelScreen,
    Ram(u64, u16),
    VirtualRam(u64, u16),
    LatencyRam(u64, u16),
    VirtualLatencyRam(u64, u16),
    DualLoadRam(u64, u16),
    VirtualDualLoadRam(u64, u16),
    VirtualDualLoadRam2(u64, u16),
    Rom(u64, u8),
    VirtualRom(u64, u8),
    ConfigurableDelay(u8),
    Sound,
    Halt,
    BitIndexer(u8),
    ByteIndexer(u8),
    Program(String, u8),
    HDD(u64),
    VirtualHDD(u64),
    Custom(u64)
}

impl ComponentType {
    pub fn has_virtual(&self) -> bool {
        match self {
            ComponentType::DelayLine(_) | ComponentType::VirtualDelayLine(_) |
            ComponentType::Register(_) | ComponentType::VirtualRegister(_) |
            ComponentType::Counter(_, _) | ComponentType::VirtualCounter(_, _) |
            ComponentType::BitMemory | ComponentType::VirtualBitMemory |
            ComponentType::Ram(_, _) | ComponentType::VirtualRam(_, _) |
            ComponentType::LatencyRam(_, _) | ComponentType::VirtualLatencyRam(_, _) |
            ComponentType::DualLoadRam(_, _) | ComponentType::VirtualDualLoadRam(_, _) | ComponentType::VirtualDualLoadRam2(_, _) |
            ComponentType::Rom(_, _) | ComponentType::VirtualRom(_, _) |
            ComponentType::HDD(_) | ComponentType::VirtualHDD(_) => {
                true
            }
            _ => false
        }
    }
}

#[derive(Debug, PartialEq, Eq, Clone)]
pub struct Component {
    pub component_type: ComponentType,
    pub inputs: Vec<(Option<usize>, u8)>,
    pub outputs: Vec<(Option<usize>, u8, bool)>,
    pub bidirectional: Vec<(Option<usize>, u8)>,
    pub data_offset: usize
}

#[derive(Debug, Clone)]
pub struct IntermediateComponent {
    pub component_type: ComponentType,
    pub position: Point,
    pub inputs: Vec<(Point, u8)>,
    pub outputs: Vec<(Point, u8, bool)>,
    pub bidirectional: Vec<(Point, u8)>
}

impl IntermediateComponent {
    pub fn rotate(self, rotation: u8) -> IntermediateComponent {
        let inputs = self.inputs.iter().map( |(p, s)| {
            let (mut x, mut y) = (p.x, p.y);
            if rotation & 1 != 0 {
                (x, y) = (-y, x);
            }
            if rotation & 2 != 0 {
                (x, y) = (-x, -y);
            }
            (Point {x, y}, *s)
        }).collect();
        let outputs = self.outputs.iter().map( |(p, s, b)| {
            let (mut x, mut y) = (p.x, p.y);
            if rotation & 1 != 0 {
                (x, y) = (-y, x);
            }
            if rotation & 2 != 0 {
                (x, y) = (-x, -y);
            }
            (Point {x, y}, *s, *b)
        }).collect();
        let bidirectional = self.bidirectional.iter().map( |(p, s)| {
            let (mut x, mut y) = (p.x, p.y);
            if rotation & 1 != 0 {
                (x, y) = (-y, x);
            }
            if rotation & 2 != 0 {
                (x, y) = (-x, -y);
            }
            (Point {x, y}, *s)
        }).collect();

        IntermediateComponent {
            component_type: self.component_type,
            position: self.position,
            inputs,
            outputs,
            bidirectional
        }
    }
}

fn remove_matching<T>(vec: &mut Vec<T>, p: impl Fn(&T) -> bool) -> Vec<T> {
    let mut removed = Vec::new();
    let mut i = vec.len();
    while i > 0 {
        if p(&vec[i - 1]) {
            removed.push(vec.remove(i - 1));
        }
        i -= 1;
    }
    removed.reverse();

    return removed;
}

fn dag_sort(mut remaining_components: Vec<Component>, num_wires: usize) -> Vec<Component> {
    let mut sorted = remove_matching(&mut remaining_components, |c| {
        c.inputs.is_empty()
    });

    // force all sinks, namely virtual components, to be processed last.
    let process_last = remove_matching(&mut remaining_components, |c| {
        c.outputs.is_empty() && c.bidirectional.is_empty()
    });

    while !remaining_components.is_empty() {
        let remaining_components_clone = remaining_components.clone();
        let matching = remove_matching(&mut remaining_components, |c| {
            let c_clone = c.clone();
            let out_edges = remaining_components_clone.clone().into_iter().map(|c2| {
                if c_clone != c2 {
                    let x = c2.outputs.iter().filter_map(|t| { t.0 }).collect::<Vec<usize>>();
                    x
                } else {
                    Vec::new()
                }
            }).fold(HashSet::<usize>::new(), |mut h, i| {
                h.extend(i);
                h
            });

            !c.inputs.iter().filter_map(|t| {t.0}).any(|n| {out_edges.contains(&n)})
        });
        if matching.is_empty() {
            println!("{:?}", remaining_components);
            panic!("Circular dependency detected");
        }
        sorted.extend(matching);
    }

    sorted.extend(process_last);

    return sorted;
}

fn read_wire(wires: &Vec<(u64, u64)>, index: usize, size: u8) -> u64 {
    let (wire, driven) = wires[index];
    wire & driven & (u64::MAX >> (64 - size))
}

fn write_wire(wires: &mut Vec<(u64, u64)>, index: usize, size: u8, new_value: u64, new_driven: u64) -> Result<(), String>{
    let (wire, driven) = wires[index];
    let size_mask = u64::MAX >> (64 - size);
    let new_value = new_value & size_mask;
    let new_driven = new_driven & size_mask;
    let conflict_mask = driven & new_driven;
    return if wire & conflict_mask != new_value & conflict_mask {
        Err("Value conflict".to_string())
    } else {
        wires[index] = ((wire & driven) | (new_value & new_driven), driven | new_driven);
        Ok(())
    }
}

pub fn simulate(components: Vec<Component>, num_wires: usize, data_needed_bytes: usize, tick_limit: u64, print_output: bool, input_fn: impl Fn(u64, &str) -> u64) -> Result<Vec<HashMap<String, u64>>, String> {
    let mut data = vec![0u8; data_needed_bytes];
    let components = dag_sort(components, num_wires);

    if DEBUG {
        println!();
        components.iter().for_each(|c| {
            println!("{:?}", c);
        });
    }

    let mut iteration = 0u64;
    let mut output_list = Vec::<HashMap<String, u64>>::new();

    while iteration < tick_limit {
        let mut wires = vec![(0, 0); num_wires + 1];
        let mut tick_outputs = HashMap::<String, u64>::new();

        for c in &components {
            match &c.component_type {
                ComponentType::Input(name, x) => {
                    let value = input_fn(iteration, name);
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, value, u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                }
                ComponentType::SwitchedInput(name, x) => {
                    let value = input_fn(iteration, name);
                    let enable = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), 1);
                    if enable != 0 {
                        c.outputs[0].0.map(|i| { write_wire(&mut wires, i, *x, value, u64::MAX >> (64 - *x)) }).unwrap_or(Ok(()))?;
                    }
                }
                ComponentType::Output(name, x) => {
                    let v = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    tick_outputs.insert(name.clone(), v);
                }
                ComponentType::SwitchedOutput(name, x) => {
                    let enable = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), 1);
                    if enable != 0 {
                        let v = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), *x);
                        tick_outputs.insert(name.clone(), v);
                    }
                }
                ComponentType::BidirectionalIO(name, x) => {
                    let v = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    tick_outputs.insert(name.clone(), v);
                }
                ComponentType::Buffer(x) => {
                    let input = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, input, u64::MAX >> (64 - *x))});
                }
                ComponentType::Not(x) => {
                    let input = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, input.not(), u64::MAX >> (64 - *x))});
                }
                ComponentType::Switch(x) => {
                    let enable = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), 1);
                    if enable != 0 {
                        let input = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), *x);
                        c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, input, u64::MAX >> (64 - *x))});
                    }
                }
                ComponentType::And(x) => {
                    let input0 = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    let input1 = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), *x);
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, input0 & input1, u64::MAX >> (64 - *x))});
                }
                ComponentType::Or(x) => {
                    let input0 = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    let input1 = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), *x);
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, input0 | input1, u64::MAX >> (64 - *x))});
                }
                ComponentType::Nand(x) => {
                    let input0 = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    let input1 = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), *x);
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, (input0 & input1).not(), u64::MAX >> (64 - *x))});
                }
                ComponentType::Nor(x) => {
                    let input0 = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    let input1 = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), *x);
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, (input0 | input1).not(), u64::MAX >> (64 - *x))});
                }
                ComponentType::Xor(x) => {
                    let input0 = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    let input1 = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), *x);
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, input0 ^ input1, u64::MAX >> (64 - *x))});
                }
                ComponentType::Xnor(x) => {
                    let input0 = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    let input1 = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), *x);
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, (input0 ^ input1).not(), u64::MAX >> (64 - *x))});
                }
                ComponentType::Adder(x) => {
                    let carry_in = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), 1);
                    let input_a = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), *x);
                    let input_b = read_wire(&wires, c.inputs[2].0.unwrap_or(num_wires), *x);

                    let result = input_a as u128 + input_b as u128 + carry_in as u128;
                    let sum = result as u64;
                    let carry_out = (result >> *x) as u64;
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, sum, u64::MAX >> (64 - *x))});
                    c.outputs[1].0.map(|i| {write_wire(&mut wires, i, 1, carry_out, 1)});
                }
                ComponentType::DelayLine(x) => {
                    let stored = u64::from_le_bytes(data[c.data_offset..(c.data_offset + 8)].try_into().unwrap());
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, stored, u64::MAX >> (64 - *x))});
                }
                ComponentType::VirtualDelayLine(x) => {
                    let new_value = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    let to_store = u64::to_le_bytes(new_value);
                    data[c.data_offset..(c.data_offset + 8)].copy_from_slice(&to_store[0..8])
                }
                ComponentType::Register(_) => {}
                ComponentType::VirtualRegister(_) => {}
                ComponentType::Shl(_) => {}
                ComponentType::Shr(_) => {}
                ComponentType::Rol(_) => {}
                ComponentType::Ror(_) => {}
                ComponentType::Ashr(_) => {}
                ComponentType::Neg(_) => {}
                ComponentType::Mul(_) => {}
                ComponentType::Div(_) => {}
                ComponentType::Equal(_) => {}
                ComponentType::ULess(_) => {}
                ComponentType::SLess(_) => {}
                ComponentType::Mux(_) => {}
                ComponentType::Counter(_, _) => {}
                ComponentType::VirtualCounter(_, _) => {}
                ComponentType::Constant(_, _) => {}
                ComponentType::And3 => {}
                ComponentType::Or3 => {}
                ComponentType::Dec1 => {
                    let i = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), 1);
                    c.outputs[0].0.map(|x| {write_wire(&mut wires, x, 1, 1 - i, 1)}).unwrap_or(Ok(()))?;
                    c.outputs[1].0.map(|x| {write_wire(&mut wires, x, 1, i, 1)}).unwrap_or(Ok(()))?;
                }
                ComponentType::Dec2 => {
                    let i0 = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), 1);
                    let i1 = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), 1);
                    let on_idx = (i1 << 1) | i0;

                    let mut i = 0;
                    while i < 4 {
                        c.outputs[i].0.map(|x| {write_wire(&mut wires, x, 1, if i == on_idx as usize {1} else {0}, 1)}).unwrap_or(Ok(()))?;
                        i += 1;
                    }
                }
                ComponentType::Dec3 => {
                    let i0 = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), 1);
                    let i1 = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), 1);
                    let i2 = read_wire(&wires, c.inputs[2].0.unwrap_or(num_wires), 1);
                    let disable = read_wire(&wires, c.inputs[3].0.unwrap_or(num_wires), 1);
                    let on_idx = if disable == 1 {
                        u64::MAX
                    } else {
                        (i2 << 2) | (i1 << 1) | i0
                    };

                    let mut i = 0;
                    while i < 8 {
                        c.outputs[i].0.map(|x| {write_wire(&mut wires, x, 1, if i == on_idx as usize {1} else {0}, 1)}).unwrap_or(Ok(()))?;
                        i += 1;
                    }
                }
                ComponentType::BitMemory => {}
                ComponentType::VirtualBitMemory => {}
                ComponentType::ByteSplitter => {
                    let input = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), 8);
                    let mut i = 0;
                    while i < 8 {
                        let v = (input >> i) & 1;
                        c.outputs[i].0.map(|x| {write_wire(&mut wires, x, 1, v, 1)});
                        i += 1;
                    }
                }
                ComponentType::ByteMaker => {
                    let mut acc = 0;
                    let mut i = 0;
                    while i < 8 {
                        let input = read_wire(&wires, c.inputs[i].0.unwrap_or(num_wires), 1);
                        acc |= input << i;
                        i += 1;
                    }
                    c.outputs[0].0.map(|x| {write_wire(&mut wires, x, 8, acc, 0xFF)});
                }
                ComponentType::ByteSplitter2 => {
                    let input = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), 16);
                    let mut i = 0;
                    while i < 2 {
                        let v = (input >> (i << 3)) & 0xFF;
                        c.outputs[i].0.map(|x| {write_wire(&mut wires, x, 8, v, 0xFF)});
                        i += 1;
                    }
                }
                ComponentType::ByteSplitter4 => {
                    let input = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), 32);
                    let mut i = 0;
                    while i < 4 {
                        let v = (input >> (i << 3)) & 0xFF;
                        c.outputs[i].0.map(|x| {write_wire(&mut wires, x, 8, v, 0xFF)});
                        i += 1;
                    }
                }
                ComponentType::ByteSplitter8 => {
                    let input = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), 64);
                    let mut i = 0;
                    while i < 8 {
                        let v = (input >> (i << 3)) & 0xFF;
                        c.outputs[i].0.map(|x| {write_wire(&mut wires, x, 8, v, 0xFF)});
                        i += 1;
                    }
                }
                ComponentType::ByteMaker2 => {
                    let mut acc = 0u64;
                    let mut i = 0;
                    while i < 2 {
                        let input = read_wire(&wires, c.inputs[i].0.unwrap_or(num_wires), 8);
                        acc |= input << (i << 3);
                        i += 1;
                    }
                    c.outputs[0].0.map(|x| {write_wire(&mut wires, x, 16, acc, 0xFFFF)});
                }
                ComponentType::ByteMaker4 => {
                    let mut acc = 0u64;
                    let mut i = 0;
                    while i < 4 {
                        let input = read_wire(&wires, c.inputs[i].0.unwrap_or(num_wires), 8);
                        acc |= input << (i << 3);
                        i += 1;
                    }
                    c.outputs[0].0.map(|x| {write_wire(&mut wires, x, 32, acc, 0xFFFF_FFFF)});
                }
                ComponentType::ByteMaker8 => {
                    let mut acc = 0u64;
                    let mut i = 0;
                    while i < 8 {
                        let input = read_wire(&wires, c.inputs[i].0.unwrap_or(num_wires), 8);
                        acc |= input << (i << 3);
                        i += 1;
                    }
                    c.outputs[0].0.map(|x| {write_wire(&mut wires, x, 64, acc, 0xFFFF_FFFF_FFFF_FFFF)});
                }
                ComponentType::FileRom(_) => {}
                ComponentType::Keyboard => {}
                ComponentType::Time => {}
                ComponentType::Network => {}
                ComponentType::Console(_, _) => {}
                ComponentType::DotMatrix(_) => {}
                ComponentType::SevenSegment => {}
                ComponentType::SpriteDisplay => {}
                ComponentType::WireProbe(_) => {}
                ComponentType::MemoryProbe(_) => {}
                ComponentType::LevelScreen => {}
                ComponentType::Ram(_, _) => {}
                ComponentType::VirtualRam(_, _) => {}
                ComponentType::LatencyRam(_, _) => {}
                ComponentType::VirtualLatencyRam(_, _) => {}
                ComponentType::DualLoadRam(_, _) => {}
                ComponentType::VirtualDualLoadRam(_, _) => {}
                ComponentType::VirtualDualLoadRam2(_, _) => {}
                ComponentType::Rom(_, _) => {}
                ComponentType::VirtualRom(_, _) => {}
                ComponentType::ConfigurableDelay(_) => {}
                ComponentType::Sound => {}
                ComponentType::Halt => {}
                ComponentType::BitIndexer(_) => {}
                ComponentType::ByteIndexer(_) => {}
                ComponentType::Program(_, _) => {}
                ComponentType::HDD(_) => {}
                ComponentType::VirtualHDD(_) => {}
                ComponentType::Custom(_) => {}
            }
        }

        if print_output && !tick_outputs.is_empty() {
            println!("Tick: {}", iteration);
            for (name, output) in &tick_outputs {
                println!("\t{}: {}", name, output);
            }
        }

        output_list.push(tick_outputs);
        iteration += 1;
    }

    return Ok(output_list);
}