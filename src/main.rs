use std::path::{Path, PathBuf};
use crate::simulator::{DefaultSimIO, simulate};
use argparse::{ArgumentParser, IncrBy, Store, StoreOption};
use crate::save_loader::read_from_save;

mod save_parser;
mod versions;
mod simulator;
mod save_loader;

#[derive(Default)]
pub struct Options {
    schematic_path: PathBuf,
    verbosity: u64
}

const VERBOSITY_NONE: u64 = 0;
const VERBOSITY_LOW: u64 = 1;
const VERBOSITY_ALL: u64 = 2;

fn main() {
    let mut path = String::default();
    let mut options = Options::default();
    let mut max_ticks = u64::MAX;

    {
        let mut schematic_path: Option<String> = None;
        let mut ap = ArgumentParser::new();
        ap.set_description("Turing Complete Circuit Simulator");
        ap.refer(&mut path).add_argument("path", Store, "The path to the circuit.data file.").required();
        ap.refer(&mut max_ticks).add_option(&["-t", "--max-ticks"], Store, "Maximum ticks to run the simulation for");
        ap.refer(&mut schematic_path).add_option(&["-s", "--schematics"], StoreOption, "Custom path for looking for schematics when custom components are needed");
        ap.refer(&mut options.verbosity).add_option(&["-v", "--verbose"], IncrBy(1), "Display more verbose information");
        ap.parse_args_or_exit();

        // Explicitly dropping here removes the mutable references
        drop(ap);

        options.schematic_path = if let Some(schem_path) = schematic_path {
            PathBuf::from(schem_path)
        } else {
            let mut directory = dirs::data_dir().unwrap_or_else(|| PathBuf::from("."));
            directory.push("godot");
            if !Path::exists(directory.as_path()) {
                directory.pop();
                directory.push("Godot");
                if !Path::exists(directory.as_path()) {
                    panic!("Cannot find Turing Complete on this system. Use the -s parameter to specify the schematic folder location");
                }
            }
            directory.push("app_userdata");
            directory.push("Turing Complete");
            directory.push("schematics");
            if !Path::exists(directory.as_path()) {
                panic!("Cannot find Turing Complete on this system. Use the -s parameter to specify the schematic folder location");
            }

            directory
        }
    }

    let (mut components, num_wires, data_bytes_needed, delay) = read_from_save(&path, &options);

    for c in components.iter_mut() {
        if options.verbosity >= VERBOSITY_ALL {
            println!("{:?}", c)
        }
    }

    let latency_ram_delay = if delay > 0 {
        (1024f64 / (delay as f64)).ceil() as u64
    } else {
        1024
    };

    let result = simulate(components, num_wires, latency_ram_delay, data_bytes_needed, true, &mut DefaultSimIO::new(max_ticks), &options);
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
    use std::path::PathBuf;
    use crate::{Options, VERBOSITY_ALL, VERBOSITY_LOW};
    use crate::save_loader::read_from_save;
    use crate::simulator::{simulate, SimulatorIO, Wire};

    const TEST_VERBOSITY: u64 = VERBOSITY_LOW;

    struct ByteAdderIOHandler;

    impl SimulatorIO for ByteAdderIOHandler {
        fn continue_simulation(&mut self, tick: u64) -> bool {
            tick < 1 << 17
        }

        fn handle_input(&mut self, tick: u64, input_index: usize) -> Wire {
            match input_index {
                0 => {
                    Wire::new(tick, 0xFF)
                },
                1 => {
                    Wire::new(tick >> 8, 0xFF)
                },
                2 => {
                    Wire::new(tick >> 16, 1)
                },
                _ => {
                    panic!("Unexpected Input Node");
                }
            }
        }

        fn check_output(&mut self, tick: u64, outputs: &[Wire]) -> bool {
            let input_a = self.handle_input(tick, 0).value();
            let input_b = self.handle_input(tick, 1).value();
            let carry_in = self.handle_input(tick, 2).value();
            let expected_sum = (input_a + input_b + carry_in) & 0xFF;
            let expected_carry = (input_a + input_b + carry_in) >> 8;
            let actual_sum = outputs[0].value();
            let actual_carry = outputs[1].value();

            expected_sum == actual_sum && expected_carry == actual_carry
        }
    }

    struct Decoder5BitIOHandler;

    impl SimulatorIO for Decoder5BitIOHandler {
        fn continue_simulation(&mut self, tick: u64) -> bool {
            tick < 64
        }

        fn handle_input(&mut self, tick: u64, input_index: usize) -> Wire {
            match input_index {
                0 => {
                    Wire::new(tick, 0x1F)
                },
                1 => {
                    Wire::new(tick >> 5, 1)
                },
                _ => {
                    panic!("Unexpected Input Node");
                }
            }
        }

        fn check_output(&mut self, tick: u64, outputs: &[Wire]) -> bool {
            let input = self.handle_input(tick, 0).value();
            let disable = self.handle_input(tick, 1).value();
            let expected_output = if disable != 0 {0u64} else {1 << input};
            let actual_output = outputs[0];

            expected_output == actual_output.value()
        }
    }

    #[test]
    fn test_byte_adder_naive_ripple() {
        let options = Options {
            schematic_path: PathBuf::from("test/resources"),
            verbosity: TEST_VERBOSITY
        };

        let (components, num_wires, data_bytes_needed, delay) = read_from_save("test/resources/byte_adder/standard-ripple-carry/circuit.data", &options);

        if options.verbosity >= VERBOSITY_ALL {
            for c in components.iter() {
                println!("{:?}", c)
            }
        }

        let latency_ram_delay = if delay > 0 {
            (1024f64 / (delay as f64)).ceil() as u64
        } else {
            1024
        };

        let result = simulate(components, num_wires, latency_ram_delay, data_bytes_needed, false, &mut ByteAdderIOHandler, &options);

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
        let options = Options {
            schematic_path: PathBuf::from("test/resources"),
            verbosity: TEST_VERBOSITY
        };

        let (components, num_wires, data_bytes_needed, delay) = read_from_save("test/resources/byte_adder/decomposed-ripple-switch-carry/circuit.data", &options);

        if options.verbosity >= VERBOSITY_ALL {
            for c in components.iter() {
                println!("{:?}", c)
            }
        }

        let latency_ram_delay = if delay > 0 {
            (1024f64 / (delay as f64)).ceil() as u64
        } else {
            1024
        };

        let result = simulate(components, num_wires, latency_ram_delay, data_bytes_needed, false, &mut ByteAdderIOHandler, &options);

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
        let options = Options {
            schematic_path: PathBuf::from("test/resources"),
            verbosity: TEST_VERBOSITY
        };

        let (components, num_wires, data_bytes_needed, delay) = read_from_save("test/resources/5-bit-decoder/circuit.data", &options);

        if options.verbosity >= VERBOSITY_ALL {
            for c in components.iter() {
                println!("{:?}", c)
            }
        }

        let latency_ram_delay = if delay > 0 {
            (1024f64 / (delay as f64)).ceil() as u64
        } else {
            1024
        };

        let result = simulate(components, num_wires, latency_ram_delay, data_bytes_needed, false, &mut Decoder5BitIOHandler, &options);
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