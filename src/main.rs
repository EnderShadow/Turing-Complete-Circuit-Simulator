use crate::simulator::{DefaultSimIO, simulate};
use argparse::{ArgumentParser, Store};
use crate::save_loader::read_from_save;

mod save_parser;
mod versions;
mod simulator;
mod save_loader;

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

    let result = simulate(components, num_wires, latency_ram_delay, data_bytes_needed, true, &mut DefaultSimIO);
    match result {
        Err(error) => {
            println!("{}", error);
        },
        Ok(num_ticks) => {
            println!("Simulation successfully exited after {} ticks", num_ticks);
        }
    }
}

#[cfg(test)]
mod tests {
    use std::time::Instant;
    use crate::DEBUG;
    use crate::save_loader::read_from_save;
    use crate::simulator::{simulate, SimulatorIO};

    struct ByteAdderIOHandler;

    impl SimulatorIO for ByteAdderIOHandler {
        fn continue_simulation(&mut self, tick: u64) -> bool {
            tick < 1 << 17
        }

        fn handle_input(&mut self, tick: u64, input_index: usize) -> u64 {
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
        }

        fn check_output(&mut self, tick: u64, outputs: &[Option<u64>]) -> bool {
            let input_a = self.handle_input(tick, 0);
            let input_b = self.handle_input(tick, 1);
            let carry_in = self.handle_input(tick, 2);
            let expected_sum = (input_a + input_b + carry_in) & 0xFF;
            let expected_carry = (input_a + input_b + carry_in) >> 8;
            let actual_sum = outputs[0].unwrap_or(u64::MAX);
            let actual_carry = outputs[1].unwrap_or(u64::MAX);

            expected_sum == actual_sum && expected_carry == actual_carry
        }
    }

    struct Decoder5BitIOHandler;

    impl SimulatorIO for Decoder5BitIOHandler {
        fn continue_simulation(&mut self, tick: u64) -> bool {
            tick < 64
        }

        fn handle_input(&mut self, tick: u64, input_index: usize) -> u64 {
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
        }

        fn check_output(&mut self, tick: u64, outputs: &[Option<u64>]) -> bool {
            let input = self.handle_input(tick, 0);
            let disable = self.handle_input(tick, 1);
            let expected_output = if disable != 0 {0u64} else {1 << input};
            let actual_output = outputs[0];

            expected_output == actual_output.unwrap_or(u64::MAX)
        }
    }

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

        let start = Instant::now();
        let result = simulate(components, num_wires, latency_ram_delay, data_bytes_needed, false, &mut ByteAdderIOHandler);
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

        let start = Instant::now();
        let result = simulate(components, num_wires, latency_ram_delay, data_bytes_needed, false, &mut ByteAdderIOHandler);
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

        let result = simulate(components, num_wires, latency_ram_delay, data_bytes_needed, false, &mut Decoder5BitIOHandler);
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