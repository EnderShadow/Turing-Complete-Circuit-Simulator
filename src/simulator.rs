use std::cmp::max;
use std::collections::HashSet;
use std::ops::Not;
use std::rc::Rc;
use std::time::Instant;
use crate::{Options, VERBOSITY_ALL, VERBOSITY_LOW, VERBOSITY_NONE};
use crate::save_parser::Point;

#[derive(Debug, PartialEq, Eq, Clone)]
pub enum ComponentType {
    Nop,
    Input(String, u8),
    SwitchedInput(String, u8),
    InputMultiBitPin,
    Output(Rc<str>, u8),
    SwitchedOutput(Rc<str>, u8),
    OutputMultiBitPin,
    BidirectionalIO(Rc<str>, u8),
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
    Register8Plus,
    VirtualRegister8Plus,
    VirtualRegister8Plus2,
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
    Halt(String),
    BitIndexer(u8),
    ByteIndexer(u8),
    Program(String, u8),
    LevelProgram(Vec<u8>),
    HDD(u64),
    VirtualHDD(u64),
    Custom(u64)
}

impl ComponentType {
    pub fn has_virtual(&self) -> bool {
        matches!(self,
            ComponentType::DelayLine(_) |
            ComponentType::Register(_) |
            ComponentType::Register8Plus |
            ComponentType::Counter(_, _) |
            ComponentType::BitMemory |
            ComponentType::Ram(_, _) |
            ComponentType::LatencyRam(_, _) |
            ComponentType::DualLoadRam(_, _) |
            ComponentType::Rom(_, _) |
            ComponentType::HDD(_)
        )
    }

    pub fn is_virtual(&self) -> bool {
        matches!(self,
            ComponentType::VirtualDelayLine(_) |
            ComponentType::VirtualRegister(_) |
            ComponentType::VirtualRegister8Plus | ComponentType::VirtualRegister8Plus2 |
            ComponentType::VirtualCounter(_, _) |
            ComponentType::VirtualBitMemory |
            ComponentType::VirtualRam(_, _) |
            ComponentType::VirtualLatencyRam(_, _) |
            ComponentType::VirtualDualLoadRam(_, _) | ComponentType::VirtualDualLoadRam2(_, _) |
            ComponentType::VirtualRom(_, _) |
            ComponentType::VirtualHDD(_)
        )
    }
}

#[derive(Debug, PartialEq, Eq, Clone)]
pub struct Component {
    pub component_type: ComponentType,
    pub inputs: Vec<(Option<usize>, u8)>,
    pub outputs: Vec<(Option<usize>, u8, bool)>,
    pub bidirectional: Vec<(Option<usize>, u8)>,
    pub data_offset: usize,
    pub numeric_id: usize
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

pub trait SimulatorIO {
    fn continue_simulation(&mut self, tick: u64) -> bool;
    fn handle_input(&mut self, tick: u64, input_index: usize) -> Wire;
    fn check_output(&mut self, tick: u64, outputs: &[Wire]) -> bool;
}

pub struct DefaultSimIO {
    max_ticks: u64
}

impl DefaultSimIO {
    pub fn new(max_ticks: u64) -> Self {
        Self {
            max_ticks
        }
    }
}

impl Default for DefaultSimIO {
    fn default() -> Self {
        DefaultSimIO {
            max_ticks: u64::MAX
        }
    }
}

impl SimulatorIO for DefaultSimIO {
    fn continue_simulation(&mut self, tick: u64) -> bool {
        tick < self.max_ticks
    }

    fn handle_input(&mut self, _tick: u64, _input_index: usize) -> Wire {
        Wire::default()
    }

    fn check_output(&mut self, _tick: u64, _outputs: &[Wire]) -> bool {
        true
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

    removed
}

fn dag_sort(mut remaining_components: Vec<Component>) -> Result<Vec<Component>, String> {
    let mut sorted = remove_matching(&mut remaining_components, |c| {
        c.inputs.is_empty()
    });

    // force all sinks, namely virtual components, to be processed last.
    let mut process_last = remove_matching(&mut remaining_components, |c| {
        c.outputs.is_empty() && c.bidirectional.is_empty()
    });

    // move all halt components to the end.
    let halts = remove_matching(&mut process_last, |c| {
        matches!(c.component_type, ComponentType::Halt(_))
    });
    process_last.extend(halts);

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
            return Err("Circular dependency detected.".to_string());
        }
        sorted.extend(matching);
    }

    sorted.extend(process_last);

    Ok(sorted)
}

#[derive(Clone, Copy, Debug, Default)]
pub struct Wire {
    pub data: u64,
    pub driven_mask: u64
}

impl Wire {
    pub fn new(value: u64, driven_mask: u64) -> Self {
        Wire { data: value, driven_mask}
    }

    pub fn value(&self) -> u64 {
        self.data & self.driven_mask
    }
}

fn read_wire(wires: &[Wire], index: usize, size: u8) -> u64 {
    wires[index].value() & (u64::MAX >> (64 - size))
}

fn read_wire1(wires: &[Wire], index: usize) -> bool {
    wires[index].value() & 1 != 0
}

fn read_wire8(wires: &[Wire], index: usize) -> u8 {
    wires[index].value() as u8
}

fn write_wire(wires: &mut [Wire], index: usize, size: u8, new_value: u64, new_driven: u64) -> Result<(), String> {
    let wire = wires.get_mut(index).unwrap();
    let data = &mut wire.data;
    let driven = &mut wire.driven_mask;
    let size_mask = u64::MAX >> (64 - size);
    let new_value = new_value & size_mask;
    let new_driven = new_driven & size_mask;
    let conflict_mask = *driven & new_driven;
    if *data & conflict_mask != new_value & conflict_mask {
        Err("Value conflict".to_string())
    } else {
        wire.data = (*data & *driven) | (new_value & new_driven);
        wire.driven_mask = *driven | new_driven;
        Ok(())
    }
}

#[inline]
fn write_wire2(wires: &mut [Wire], index: usize, size: u8, new_wire: Wire) -> Result<(), String> {
    write_wire(wires, index, size, new_wire.data, new_wire.driven_mask)
}

fn fast_read_wire(wires: &[Wire], index: usize, size: u8) -> u64 {
    wires[index].data & (u64::MAX >> (64 - size))
}

fn fast_read_wire1(wires: &[Wire], index: usize) -> bool {
    wires[index].data & 1 != 0
}

fn fast_read_wire8(wires: &[Wire], index: usize) -> u8 {
    wires[index].data as u8
}

fn fast_write_wire(wires: &mut [Wire], index: usize, size: u8, new_value: u64, _new_driven: u64) -> Result<(), String> {
    let wire = &mut wires[index].data;
    let size_mask = u64::MAX >> (64 - size);
    let new_value = new_value & size_mask;
    *wire |= new_value;
    Ok(())
}

pub fn simulate<T: SimulatorIO>(components: Vec<Component>, num_wires: usize, data_needed_bytes: usize, print_output: bool, sim_io_handler: &mut T, options: &Options) -> Result<u64, String> {
    let mut data = vec![0u8; data_needed_bytes];

    let start = Instant::now();
    let components = dag_sort(components)?;
    let end = Instant::now();

    if options.verbosity >= VERBOSITY_LOW {
        println!("DAG sort took {} seconds", (end - start).as_secs_f32());
    }

    let mut num_inputs: usize = 0;
    let mut num_outputs: usize = 0;
    let mut num_latency_ram: usize = 0;

    let start = Instant::now();

    for c in &components {
        match c.component_type {
            ComponentType::Input(_, _) | ComponentType::SwitchedInput(_, _) | ComponentType::InputMultiBitPin => {
                num_inputs = max(num_inputs, c.numeric_id);
            }
            ComponentType::Output(_, _) | ComponentType::SwitchedOutput(_, _) | ComponentType::OutputMultiBitPin | ComponentType::BidirectionalIO(_, _) => {
                num_outputs = max(num_outputs, c.numeric_id);
            }
            ComponentType::LatencyRam(_, _) => {
                num_latency_ram = max(num_latency_ram, c.numeric_id);
            }
            _ => {}
        }
    }

    num_inputs += 1;
    num_outputs += 1;
    num_latency_ram += 1;

    if options.verbosity >= VERBOSITY_ALL {
        println!();
        components.iter().for_each(|c| {
            println!("{:?}", c);
        });
    }

    let mut iteration = 0u64;
    let mut wires = vec![Wire::new(0, 0); num_wires + 1];
    let mut tick_outputs: Vec<Wire> = vec![Wire::default(); num_outputs];

    let end = Instant::now();
    if options.verbosity >= VERBOSITY_LOW {
        println!("Simulation prep took {} seconds", (end - start).as_secs_f32());
    }

    let start = Instant::now();

    while sim_io_handler.continue_simulation(iteration) {
        for c in &components {
            match &c.component_type {
                ComponentType::Nop => {}
                ComponentType::Input(name, x) => {
                    let value = sim_io_handler.handle_input(iteration, c.numeric_id);
                    c.outputs[0].0.map(|i| { write_wire2(&mut wires, i, *x, value) }).unwrap_or(Ok(()))?;
                }
                ComponentType::SwitchedInput(name, x) => {
                    let enable = read_wire1(&wires, c.inputs[0].0.unwrap_or(num_wires));
                    if enable {
                        let value = sim_io_handler.handle_input(iteration, c.numeric_id);
                        c.outputs[0].0.map(|i| { write_wire2(&mut wires, i, *x, value) }).unwrap_or(Ok(()))?;
                    }
                }
                ComponentType::InputMultiBitPin => {
                    let value = sim_io_handler.handle_input(iteration, c.numeric_id).data;
                    for (idx, output) in c.outputs.iter().enumerate() {
                        output.0.map(|i| { write_wire(&mut wires, i, 1, value >> idx, 1) }).unwrap_or(Ok(()))?;
                    }
                }
                ComponentType::Output(name, x) => {
                    let mut w = wires[c.inputs[0].0.unwrap_or(num_wires)];
                    let mask = u64::MAX >> (64 - *x);
                    w.data &= mask;
                    w.driven_mask &= mask;
                    tick_outputs[c.numeric_id] = w;
                }
                ComponentType::SwitchedOutput(name, x) => {
                    let enable = read_wire1(&wires, c.inputs[0].0.unwrap_or(num_wires));
                    if enable {
                        let mut w = wires[c.inputs[1].0.unwrap_or(num_wires)];
                        let mask = u64::MAX >> (64 - *x);
                        w.data &= mask;
                        w.driven_mask &= mask;
                        tick_outputs[c.numeric_id] = w;
                    } else {
                        tick_outputs[c.numeric_id] = Wire::default();
                    }
                }
                ComponentType::OutputMultiBitPin => {
                    let mut value: u64 = 0;
                    for (idx, input) in c.inputs.iter().enumerate() {
                        let pin_value = read_wire(&wires, input.0.unwrap_or(num_wires), 1);
                        value |= pin_value << idx
                    }
                    tick_outputs[c.numeric_id] = Wire::new(value, u64::MAX >> (64 - c.inputs.len()));
                }
                ComponentType::BidirectionalIO(name, x) => {
                    let mut w = wires[c.inputs[0].0.unwrap_or(num_wires)];
                    let mask = u64::MAX >> (64 - *x);
                    w.data &= mask;
                    w.driven_mask &= mask;
                    tick_outputs[c.numeric_id] = w;
                }
                ComponentType::Buffer(x) => {
                    let input = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, input, u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                }
                ComponentType::Not(x) => {
                    let input = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, input.not(), u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                }
                ComponentType::Switch(x) => {
                    let enable = read_wire1(&wires, c.inputs[0].0.unwrap_or(num_wires));
                    if enable {
                        let input = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), *x);
                        c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, input, u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                    }
                }
                ComponentType::And(x) => {
                    let input0 = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    let input1 = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), *x);
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, input0 & input1, u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                }
                ComponentType::Or(x) => {
                    let input0 = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    let input1 = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), *x);
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, input0 | input1, u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                }
                ComponentType::Nand(x) => {
                    let input0 = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    let input1 = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), *x);
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, (input0 & input1).not(), u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                }
                ComponentType::Nor(x) => {
                    let input0 = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    let input1 = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), *x);
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, (input0 | input1).not(), u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                }
                ComponentType::Xor(x) => {
                    let input0 = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    let input1 = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), *x);
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, input0 ^ input1, u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                }
                ComponentType::Xnor(x) => {
                    let input0 = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    let input1 = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), *x);
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, (input0 ^ input1).not(), u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                }
                ComponentType::Adder(x) => {
                    let carry_in = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), 1);
                    let input_a = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), *x);
                    let input_b = read_wire(&wires, c.inputs[2].0.unwrap_or(num_wires), *x);

                    let result = input_a as u128 + input_b as u128 + carry_in as u128;
                    let sum = result as u64;
                    let carry_out = (result >> *x) as u64;
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, sum, u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                    c.outputs[1].0.map(|i| {write_wire(&mut wires, i, 1, carry_out, 1)}).unwrap_or(Ok(()))?;
                }
                ComponentType::DelayLine(x) => {
                    let stored = u64::from_le_bytes(data[c.data_offset..(c.data_offset + 8)].try_into().unwrap());
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, stored, u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                }
                ComponentType::VirtualDelayLine(x) => {
                    let new_value = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    let to_store = u64::to_le_bytes(new_value);
                    data[c.data_offset..(c.data_offset + 8)].copy_from_slice(&to_store);
                }
                ComponentType::Register(x) => {
                    let read = read_wire1(&wires, c.inputs[0].0.unwrap_or(num_wires));
                    if read {
                        let stored = u64::from_le_bytes(data[c.data_offset..(c.data_offset + 8)].try_into().unwrap());
                        c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, stored, u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                    }
                }
                ComponentType::VirtualRegister(x) => {
                    let write = read_wire1(&wires, c.inputs[0].0.unwrap_or(num_wires));
                    if write {
                        let new_value = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), *x);
                        let to_store = u64::to_le_bytes(new_value);
                        data[c.data_offset..(c.data_offset + 8)].copy_from_slice(&to_store);
                    }
                }
                ComponentType::Register8Plus => {
                    let read = read_wire1(&wires, c.inputs[0].0.unwrap_or(num_wires));
                    if read {
                        let stored = data[c.data_offset] as u64;
                        c.outputs[0].0.map(|i| write_wire(&mut wires, i, 8, stored, 0xFF)).unwrap_or(Ok(()))?;
                    }
                }
                ComponentType::VirtualRegister8Plus => {
                    let write = read_wire1(&wires, c.inputs[0].0.unwrap_or(num_wires));
                    if write {
                        let new_value = read_wire8(&wires, c.inputs[1].0.unwrap_or(num_wires));
                        data[c.data_offset] = new_value;
                    }
                }
                ComponentType::VirtualRegister8Plus2 => {
                    let stored = data[c.data_offset] as u64;
                    c.outputs[0].0.map(|i| write_wire(&mut wires, i, 8, stored, 0xFF)).unwrap_or(Ok(()))?;
                }
                ComponentType::Shl(x) => {
                    let data = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    let amount = read_wire8(&wires, c.inputs[1].0.unwrap_or(num_wires)) & (x.next_power_of_two() - 1);
                    let result = data << amount;
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, result, u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                }
                ComponentType::Shr(x) => {
                    let data = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    let amount = read_wire8(&wires, c.inputs[1].0.unwrap_or(num_wires)) & (x.next_power_of_two() - 1);
                    let result = data >> amount;
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, result, u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                }
                ComponentType::Rol(x) => {
                    let data = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x) as u128;
                    let amount = read_wire8(&wires, c.inputs[1].0.unwrap_or(num_wires)) & (x.next_power_of_two() - 1);
                    let result = ((data << amount) | (data.wrapping_shr(*x as u32 - amount as u32))) as u64;
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, result, u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                }
                ComponentType::Ror(x) => {
                    let data = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x) as u128;
                    let amount = read_wire8(&wires, c.inputs[1].0.unwrap_or(num_wires)) & (x.next_power_of_two() - 1);
                    let result = ((data >> amount) | (data.wrapping_shl(*x as u32 - amount as u32))) as u64;
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, result, u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                }
                ComponentType::Ashr(x) => {
                    let data = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    let amount = read_wire8(&wires, c.inputs[1].0.unwrap_or(num_wires)) & (x.next_power_of_two() - 1);
                    let sign = data & (1 << (*x - 1)) != 0;
                    let result = if sign {
                        (data | (u64::MAX << *x)) as i64 >> amount
                    } else {
                        data as i64 >> amount
                    } as u64;
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, result, u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                }
                ComponentType::Neg(x) => {
                    let input = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    let result = -(input as i64) as u64;
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, result, u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                }
                ComponentType::Mul(x) => {
                    let input0 = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x) as u128;
                    let input1 = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), *x) as u128;
                    let result = input0 * input1;
                    let output0 = result as u64;
                    let output1 = (result >> *x) as u64;
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, output0, u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                    c.outputs[1].0.map(|i| {write_wire(&mut wires, i, *x, output1, u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                }
                ComponentType::Div(x) => {
                    let input0 = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    let input1 = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), *x);
                    if input1 == 0 {
                        return Err(format!("Divide by 0 on tick {}", iteration));
                    }
                    let output0 = input0 / input1;
                    let output1 = input0 % input1;
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, output0, u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                    c.outputs[1].0.map(|i| {write_wire(&mut wires, i, *x, output1, u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                }
                ComponentType::Equal(x) => {
                    let input0 = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    let input1 = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), *x);
                    let result = (input0 == input1) as u64;
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, 1, result, 1)}).unwrap_or(Ok(()))?;
                }
                ComponentType::ULess(x) => {
                    let input0 = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x);
                    let input1 = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), *x);
                    let result = (input0 < input1) as u64;
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, 1, result, 1)}).unwrap_or(Ok(()))?;
                }
                ComponentType::SLess(x) => {
                    let input0 = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), *x) as i64;
                    let input1 = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), *x) as i64;
                    let result = (input0 < input1) as u64;
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, 1, result, 1)}).unwrap_or(Ok(()))?;
                }
                ComponentType::Mux(x) => {
                    let select = read_wire1(&wires, c.inputs[0].0.unwrap_or(num_wires));
                    let input0 = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), *x);
                    let input1 = read_wire(&wires, c.inputs[2].0.unwrap_or(num_wires), *x);

                    let result = if select {
                        input1
                    } else {
                        input0
                    };

                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, result, u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                }
                ComponentType::Counter(_, x) => {
                    let stored = u64::from_le_bytes(data[c.data_offset..(c.data_offset + 8)].try_into().unwrap());
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, stored, u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                }
                ComponentType::VirtualCounter(increment, x) => {
                    let overwrite = read_wire1(&wires, c.inputs[0].0.unwrap_or(num_wires));
                    if overwrite {
                        let new_value = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), *x);
                        let to_store = u64::to_le_bytes(new_value);
                        data[c.data_offset..(c.data_offset + 8)].copy_from_slice(&to_store);
                    } else {
                        let stored = u64::from_le_bytes(data[c.data_offset..(c.data_offset + 8)].try_into().unwrap());
                        let new_value = stored.wrapping_add(*increment);
                        let to_store = u64::to_le_bytes(new_value);
                        data[c.data_offset..(c.data_offset + 8)].copy_from_slice(&to_store);
                    }
                }
                ComponentType::Constant(value, x) => {
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, *x, *value, u64::MAX >> (64 - *x))}).unwrap_or(Ok(()))?;
                }
                ComponentType::And3 => {
                    let input0 = read_wire1(&wires, c.inputs[0].0.unwrap_or(num_wires));
                    let input1 = read_wire1(&wires, c.inputs[1].0.unwrap_or(num_wires));
                    let input2 = read_wire1(&wires, c.inputs[2].0.unwrap_or(num_wires));

                    let result = input0 & input1 & input2;

                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, 1, result as u64, 1)}).unwrap_or(Ok(()))?;
                }
                ComponentType::Or3 => {
                    let input0 = read_wire1(&wires, c.inputs[0].0.unwrap_or(num_wires));
                    let input1 = read_wire1(&wires, c.inputs[1].0.unwrap_or(num_wires));
                    let input2 = read_wire1(&wires, c.inputs[2].0.unwrap_or(num_wires));

                    let result = input0 | input1 | input2;

                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, 1, result as u64, 1)}).unwrap_or(Ok(()))?;
                }
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
                        c.outputs[i].0.map(|x| {write_wire(&mut wires, x, 1, (i == on_idx as usize) as u64, 1)}).unwrap_or(Ok(()))?;
                        i += 1;
                    }
                }
                ComponentType::Dec3 => {
                    let i0 = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), 1);
                    let i1 = read_wire(&wires, c.inputs[1].0.unwrap_or(num_wires), 1);
                    let i2 = read_wire(&wires, c.inputs[2].0.unwrap_or(num_wires), 1);
                    let disable = read_wire1(&wires, c.inputs[3].0.unwrap_or(num_wires));
                    let on_idx = if disable {
                        u64::MAX
                    } else {
                        (i2 << 2) | (i1 << 1) | i0
                    };

                    let mut i = 0;
                    while i < 8 {
                        c.outputs[i].0.map(|x| {write_wire(&mut wires, x, 1, (i == on_idx as usize) as u64, 1)}).unwrap_or(Ok(()))?;
                        i += 1;
                    }
                }
                ComponentType::BitMemory => {
                    let stored = data[c.data_offset];
                    c.outputs[0].0.map(|i| {write_wire(&mut wires, i, 1, stored as u64, 1)}).unwrap_or(Ok(()))?;
                }
                ComponentType::VirtualBitMemory => {
                    let write = read_wire1(&wires, c.inputs[0].0.unwrap_or(num_wires));
                    if write {
                        let new_value = read_wire1(&wires, c.inputs[1].0.unwrap_or(num_wires));
                        data[c.data_offset] = new_value as u8;
                    }
                }
                ComponentType::ByteSplitter => {
                    let input = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), 8);
                    let mut i = 0;
                    while i < 8 {
                        let v = (input >> i) & 1;
                        c.outputs[i].0.map(|x| {write_wire(&mut wires, x, 1, v, 1)}).unwrap_or(Ok(()))?;
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
                    c.outputs[0].0.map(|x| {write_wire(&mut wires, x, 8, acc, 0xFF)}).unwrap_or(Ok(()))?;
                }
                ComponentType::ByteSplitter2 => {
                    let input = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), 16);
                    let mut i = 0;
                    while i < 2 {
                        let v = (input >> (i << 3)) & 0xFF;
                        c.outputs[i].0.map(|x| {write_wire(&mut wires, x, 8, v, 0xFF)}).unwrap_or(Ok(()))?;
                        i += 1;
                    }
                }
                ComponentType::ByteSplitter4 => {
                    let input = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), 32);
                    let mut i = 0;
                    while i < 4 {
                        let v = (input >> (i << 3)) & 0xFF;
                        c.outputs[i].0.map(|x| {write_wire(&mut wires, x, 8, v, 0xFF)}).unwrap_or(Ok(()))?;
                        i += 1;
                    }
                }
                ComponentType::ByteSplitter8 => {
                    let input = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), 64);
                    let mut i = 0;
                    while i < 8 {
                        let v = (input >> (i << 3)) & 0xFF;
                        c.outputs[i].0.map(|x| {write_wire(&mut wires, x, 8, v, 0xFF)}).unwrap_or(Ok(()))?;
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
                    c.outputs[0].0.map(|x| {write_wire(&mut wires, x, 16, acc, 0xFFFF)}).unwrap_or(Ok(()))?;
                }
                ComponentType::ByteMaker4 => {
                    let mut acc = 0u64;
                    let mut i = 0;
                    while i < 4 {
                        let input = read_wire(&wires, c.inputs[i].0.unwrap_or(num_wires), 8);
                        acc |= input << (i << 3);
                        i += 1;
                    }
                    c.outputs[0].0.map(|x| {write_wire(&mut wires, x, 32, acc, 0xFFFF_FFFF)}).unwrap_or(Ok(()))?;
                }
                ComponentType::ByteMaker8 => {
                    let mut acc = 0u64;
                    let mut i = 0;
                    while i < 8 {
                        let input = read_wire(&wires, c.inputs[i].0.unwrap_or(num_wires), 8);
                        acc |= input << (i << 3);
                        i += 1;
                    }
                    c.outputs[0].0.map(|x| {write_wire(&mut wires, x, 64, acc, 0xFFFF_FFFF_FFFF_FFFF)}).unwrap_or(Ok(()))?;
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
                ComponentType::Halt(message) => {
                    println!("{}", message);
                    return Ok(iteration)
                }
                ComponentType::BitIndexer(index) => {
                    let in_value = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), 64);
                    let out_value = in_value >> index;
                    c.outputs[0].0.map(|x| {write_wire(&mut wires, x, 1, out_value, 1)}).unwrap_or(Ok(()))?;
                }
                ComponentType::ByteIndexer(index) => {
                    let in_value = read_wire(&wires, c.inputs[0].0.unwrap_or(num_wires), 64);
                    let out_value = in_value >> (index << 3);
                    c.outputs[0].0.map(|x| {write_wire(&mut wires, x, 8, out_value, 0xFF)}).unwrap_or(Ok(()))?;
                }
                ComponentType::Program(_, _) => {}
                ComponentType::LevelProgram(_) => {}
                ComponentType::HDD(_) => {}
                ComponentType::VirtualHDD(_) => {}
                ComponentType::Custom(_) => {}
            }
        }

        if print_output && !tick_outputs.iter().any(|o| o.driven_mask != 0) {
            println!("Tick: {}", iteration);
            for (index, output) in tick_outputs.iter().enumerate() {
                if output.driven_mask != 0 {
                    if options.verbosity == VERBOSITY_NONE {
                        println!("\tOutput {}: {}", index, output.value());
                    } else {
                        println!("\tOutput {}: {:X}/{:X}", index, output.data, output.driven_mask);
                    }
                }
            }
        }

        let passed = sim_io_handler.check_output(iteration, &tick_outputs);

        iteration += 1;

        if !passed {
            return Err(format!("Failed after {} ticks.", iteration))
        }

        wires.fill(Wire::new(0, 0));
    }

    let end = Instant::now();

    if options.verbosity >= VERBOSITY_LOW {
        println!("Simulation took {} seconds", (end - start).as_secs_f32());
    }

    Ok(iteration)
}