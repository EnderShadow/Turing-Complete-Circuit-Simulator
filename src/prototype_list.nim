import tables, segfaults
import types
when declared(GC_step): import ../godot/godot
#[

  RULE: if a prorotype has_virtual, next kind must be the corresponding virtual kind

]#

const main_category_order* = ["1bit", "8bit", "16bit", "32bit", "64bit", "IO"]

const CAT_1_BIT                = (3133732778241216484, "1bit")
const CAT_8_BIT                = (3133753900277352031, "8bit")
const CAT_16_BIT               = (3133731787377521276, "16bit")
const CAT_32_BIT               = (3133793805543475022, "32bit")
const CAT_64_BIT               = (3133769195385009785, "64bit")
const CAT_IO                   = (3133760495775939951, "IO")
const CAT_RAM                  = (3133746598465325525, "RAM")
const CAT_DISPLAYS             = (3133712972244522540, "Displays")
const CAT_BIDIRECTIONAL_PINS   = (3133777408777382636, "Bidirectional Pins")
const CAT_LOGIC                = (3133726316545288606, "Logic")
const CAT_MATH                 = (3133749451948914812, "Math")
const CAT_PROBES               = (3133769169839562869, "Probes")
const CAT_LEVELS               = (3133736744990871521, "Levels")
const CAT_INPUT_PINS           = (3133779029955304279, "Input Pins")
const CAT_OUTPUT_PINS          = (3133774397786006652, "Output Pins")
const SWITCH_OUTPUT_PINS       = (3133773356117817137, "Switch Output Pins")
const CAT_CUST*                = (3133756684378975952, "Custom")
const CAT_SANDBOX_ONLY         = (3133790490391067117, "Sandbox Only")

const prototypes* = {
  Off: prototype(
    sandbox: true,
    menu_order: 0.uint8,
    area: @[point(x: 0, y: 0)],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0)),
    ],
    category: @[CAT_1_BIT],
  ),
  On: prototype(
    sandbox: true,
    menu_order: 1.uint8,
    area: @[point(x: 0, y: 0)],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0)),
    ],
    category: @[CAT_1_BIT],
  ),
  Buffer1: prototype(
    backend_only: true,
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0)),
    ],
    category: @[CAT_1_BIT],
  ),
  Buffer8: prototype(
    backend_only: true,
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8),
    ],
    category: @[CAT_1_BIT],
  ),
  Buffer16: prototype(
    backend_only: true,
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), kind: wk_16),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_16),
    ],
    category: @[CAT_1_BIT],
  ),
  Buffer32: prototype(
    backend_only: true,
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), kind: wk_32),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_32),
    ],
    category: @[CAT_1_BIT],
  ),
  Buffer64: prototype(
    backend_only: true,
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), kind: wk_64),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_64),
    ],
    category: @[CAT_1_BIT],
  ),
  Not: prototype(
    sandbox: true,
    menu_order: 2.uint8,
    area: @[point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0)),
    ],
    category: @[CAT_1_BIT],
  ),
  And: prototype(
    sandbox: true,
    menu_order: 4.uint8,
    area: @[point(x: 0, y: 0), point(x: 0, y: -1), point(x: 0, y: 1), point(x: 1, y: 0), point(x: 1, y: 1), point(x: 1, y: -1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1)),
      prototype_pin(position: point(x: -1, y: 1)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 2, y: 0)),
    ],
    category: @[CAT_1_BIT],
  ),
  And3: prototype(
    sandbox: true,
    sandbox_score: score(gate: 3, delay: 3),
    menu_order: 5.uint8,
    area: @[point(x: 0, y: 0), point(x: 0, y: -1), point(x: 0, y: 1), point(x: 1, y: 0), point(x: 1, y: 1), point(x: 1, y: -1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1)),
      prototype_pin(position: point(x: -1, y: 0)),
      prototype_pin(position: point(x: -1, y: 1)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 2, y: 0)),
    ],
    category: @[CAT_1_BIT],
  ),
  Or: prototype(
    sandbox: true,
    menu_order: 6.uint8,
    area: @[point(x: 0, y: 0), point(x: 0, y: -1), point(x: 0, y: 1), point(x: 1, y: 0), point(x: 1, y: 1), point(x: 1, y: -1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1)),
      prototype_pin(position: point(x: -1, y: 1)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 2, y: 0)),
    ],
    category: @[CAT_1_BIT],
  ),
  Or3: prototype(
    sandbox: true,
    sandbox_score: score(gate: 2, delay: 2),
    menu_order: 7.uint8,
    area: @[point(x: 0, y: 0), point(x: 0, y: -1), point(x: 0, y: 1), point(x: 1, y: 0), point(x: 1, y: 1), point(x: 1, y: -1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1)),
      prototype_pin(position: point(x: -1, y: 0)),
      prototype_pin(position: point(x: -1, y: 1)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 2, y: 0)),
    ],
    category: @[CAT_1_BIT],
  ),
  Nand: prototype(
    sandbox: true,
    menu_order: 8.uint8,
    area: @[point(x: 0, y: 0), point(x: 0, y: -1), point(x: 0, y: 1), point(x: 1, y: 0), point(x: 1, y: 1), point(x: 1, y: -1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1)),
      prototype_pin(position: point(x: -1, y: 1)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 2, y: 0)),
    ],
    category: @[CAT_1_BIT],
  ),
  Nor: prototype(
    sandbox: true,
    menu_order: 9.uint8,
    area: @[point(x: 0, y: 0), point(x: 0, y: -1), point(x: 0, y: 1), point(x: 1, y: 0), point(x: 1, y: 1), point(x: 1, y: -1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1)),
      prototype_pin(position: point(x: -1, y: 1)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 2, y: 0)),
    ],
    category: @[CAT_1_BIT],
  ),
  Xor: prototype(
    sandbox: true,
    sandbox_score: score(gate: 3, delay: 4),
    menu_order: 10.uint8,
    area: @[point(x: 0, y: 0), point(x: 0, y: -1), point(x: 0, y: 1), point(x: 1, y: 0), point(x: 1, y: 1), point(x: 1, y: -1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1)),
      prototype_pin(position: point(x: -1, y: 1)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 2, y: 0)),
    ],
    category: @[CAT_1_BIT],
  ),
  Xnor: prototype(
    sandbox: true,
    sandbox_score: score(gate: 3, delay: 4),
    menu_order: 11.uint8,
    area: @[point(x: 0, y: 0), point(x: 0, y: -1), point(x: 0, y: 1), point(x: 1, y: 0), point(x: 1, y: 1), point(x: 1, y: -1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1)),
      prototype_pin(position: point(x: -1, y: 1)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 2, y: 0)),
    ],
    category: @[CAT_1_BIT],
  ),
  Counter64: prototype(
    sandbox: true,
    menu_order: 22.uint8,
    default_setting_1: 1,
    area: @[
      point(x: -3, y: -1), point(x: -2, y: -1), point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1),
      point(x: -2, y: 0), point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0),
      point(x: -2, y: 1), point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 2, y: 0), kind: wk_64),
    ],
    has_virtual: true,
    category: @[CAT_64_BIT],
    memory: 1,
  ),
  VirtualCounter64: prototype(
    input_pins: @[
      prototype_pin(position: point(x: -3, y: 0)),
      prototype_pin(position: point(x: -3, y: 1), kind: wk_64),
    ],
  ),
  FileLoader: prototype(
    sandbox_only: true,
    sandbox: true,
    area: @[
      point(x: -3, y: 0), point(x: -2, y: 0), point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0), point(x: 2, y: 0), point(x: 3, y: 0),
      point(x: -3, y: 1), point(x: -2, y: 1), point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1), point(x: 2, y: 1), point(x: 3, y: 1)
    ],
    input_pins: @[
      prototype_pin(position: point(x: -3, y: -1)),
      prototype_pin(position: point(x: -4, y: 0), kind: wk_64),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 4, y: 0), kind: wk_64, tri_state: true),
    ],
    category: @[CAT_IO, CAT_SANDBOX_ONLY],   
  ),
  Program8_1: prototype(
    area: @[
      point(x: -12, y: -8), point(x: -11, y: -8), point(x: -10, y: -8), point(x: -9, y: -8), point(x: -8, y: -8), point(x: -7, y: -8), point(x: -6, y: -8), point(x: -5, y: -8), point(x: -4, y: -8), point(x: -3, y: -8), point(x: -2, y: -8), point(x: -1, y: -8), point(x: 0, y: -8), point(x: 1, y: -8), point(x: 2, y: -8), point(x: 3, y: -8), point(x: 4, y: -8), point(x: 5, y: -8), point(x: 6,y: -8), point(x: 7, y: -8), point(x: 8, y: -8), point(x: 9, y: -8), point(x: 10, y: -8), point(x: 11, y: -8), point(x: 12, y: -8),
      point(x: -12, y: -7), point(x: -11, y: -7), point(x: -10, y: -7), point(x: -9, y: -7), point(x: -8, y: -7), point(x: -7, y: -7), point(x: -6, y: -7), point(x: -5, y: -7), point(x: -4, y: -7), point(x: -3, y: -7), point(x: -2, y: -7), point(x: -1, y: -7), point(x: 0, y: -7), point(x: 1, y: -7), point(x: 2, y: -7), point(x: 3, y: -7), point(x: 4, y: -7), point(x: 5, y: -7), point(x: 6,y: -7), point(x: 7, y: -7), point(x: 8, y: -7), point(x: 9, y: -7), point(x: 10, y: -7), point(x: 11, y: -7), point(x: 12, y: -7),
      point(x: -12, y: -6), point(x: -11, y: -6), point(x: -10, y: -6), point(x: -9, y: -6), point(x: -8, y: -6), point(x: -7, y: -6), point(x: -6, y: -6), point(x: -5, y: -6), point(x: -4, y: -6), point(x: -3, y: -6), point(x: -2, y: -6), point(x: -1, y: -6), point(x: 0, y: -6), point(x: 1, y: -6), point(x: 2, y: -6), point(x: 3, y: -6), point(x: 4, y: -6), point(x: 5, y: -6), point(x: 6,y: -6), point(x: 7, y: -6), point(x: 8, y: -6), point(x: 9, y: -6), point(x: 10, y: -6), point(x: 11, y: -6), point(x: 12, y: -6),
      point(x: -12, y: -5), point(x: -11, y: -5), point(x: -10, y: -5), point(x: -9, y: -5), point(x: -8, y: -5), point(x: -7, y: -5), point(x: -6, y: -5), point(x: -5, y: -5), point(x: -4, y: -5), point(x: -3, y: -5), point(x: -2, y: -5), point(x: -1, y: -5), point(x: 0, y: -5), point(x: 1, y: -5), point(x: 2, y: -5), point(x: 3, y: -5), point(x: 4, y: -5), point(x: 5, y: -5), point(x: 6,y: -5), point(x: 7, y: -5), point(x: 8, y: -5), point(x: 9, y: -5), point(x: 10, y: -5), point(x: 11, y: -5), point(x: 12, y: -5),
      point(x: -12, y: -4), point(x: -11, y: -4), point(x: -10, y: -4), point(x: -9, y: -4), point(x: -8, y: -4), point(x: -7, y: -4), point(x: -6, y: -4), point(x: -5, y: -4), point(x: -4, y: -4), point(x: -3, y: -4), point(x: -2, y: -4), point(x: -1, y: -4), point(x: 0, y: -4), point(x: 1, y: -4), point(x: 2, y: -4), point(x: 3, y: -4), point(x: 4, y: -4), point(x: 5, y: -4), point(x: 6,y: -4), point(x: 7, y: -4), point(x: 8, y: -4), point(x: 9, y: -4), point(x: 10, y: -4), point(x: 11, y: -4), point(x: 12, y: -4),
      point(x: -12, y: -3), point(x: -11, y: -3), point(x: -10, y: -3), point(x: -9, y: -3), point(x: -8, y: -3), point(x: -7, y: -3), point(x: -6, y: -3), point(x: -5, y: -3), point(x: -4, y: -3), point(x: -3, y: -3), point(x: -2, y: -3), point(x: -1, y: -3), point(x: 0, y: -3), point(x: 1, y: -3), point(x: 2, y: -3), point(x: 3, y: -3), point(x: 4, y: -3), point(x: 5, y: -3), point(x: 6,y: -3), point(x: 7, y: -3), point(x: 8, y: -3), point(x: 9, y: -3), point(x: 10, y: -3), point(x: 11, y: -3), point(x: 12, y: -3),
      point(x: -12, y: -2), point(x: -11, y: -2), point(x: -10, y: -2), point(x: -9, y: -2), point(x: -8, y: -2), point(x: -7, y: -2), point(x: -6, y: -2), point(x: -5, y: -2), point(x: -4, y: -2), point(x: -3, y: -2), point(x: -2, y: -2), point(x: -1, y: -2), point(x: 0, y: -2), point(x: 1, y: -2), point(x: 2, y: -2), point(x: 3, y: -2), point(x: 4, y: -2), point(x: 5, y: -2), point(x: 6,y: -2), point(x: 7, y: -2), point(x: 8, y: -2), point(x: 9, y: -2), point(x: 10, y: -2), point(x: 11, y: -2), point(x: 12, y: -2),
      point(x: -12, y: -1), point(x: -11, y: -1), point(x: -10, y: -1), point(x: -9, y: -1), point(x: -8, y: -1), point(x: -7, y: -1), point(x: -6, y: -1), point(x: -5, y: -1), point(x: -4, y: -1), point(x: -3, y: -1), point(x: -2, y: -1), point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1), point(x: 2, y: -1), point(x: 3, y: -1), point(x: 4, y: -1), point(x: 5, y: -1), point(x: 6,y: -1), point(x: 7, y: -1), point(x: 8, y: -1), point(x: 9, y: -1), point(x: 10, y: -1), point(x: 11, y: -1), point(x: 12, y: -1),
      point(x: -12, y: 0), point(x: -11, y: 0), point(x: -10, y: 0), point(x: -9, y: 0), point(x: -8, y: 0), point(x: -7, y: 0), point(x: -6, y: 0), point(x: -5, y: 0), point(x: -4, y: 0), point(x: -3, y: 0), point(x: -2, y: 0), point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0), point(x: 2, y: 0), point(x: 3, y: 0), point(x: 4, y: 0), point(x: 5, y: 0), point(x: 6,y: 0), point(x: 7, y: 0), point(x: 8, y: 0), point(x: 9, y: 0), point(x: 10, y: 0), point(x: 11, y: 0), point(x: 12, y: 0),
      point(x: -12, y: 1), point(x: -11, y: 1), point(x: -10, y: 1), point(x: -9, y: 1), point(x: -8, y: 1), point(x: -7, y: 1), point(x: -6, y: 1), point(x: -5, y: 1), point(x: -4, y: 1), point(x: -3, y: 1), point(x: -2, y: 1), point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1), point(x: 2, y: 1), point(x: 3, y: 1), point(x: 4, y: 1), point(x: 5, y: 1), point(x: 6,y: 1), point(x: 7, y: 1), point(x: 8, y: 1), point(x: 9, y: 1), point(x: 10, y: 1), point(x: 11, y: 1), point(x: 12, y: 1),
      point(x: -12, y: 2), point(x: -11, y: 2), point(x: -10, y: 2), point(x: -9, y: 2), point(x: -8, y: 2), point(x: -7, y: 2), point(x: -6, y: 2), point(x: -5, y: 2), point(x: -4, y: 2), point(x: -3, y: 2), point(x: -2, y: 2), point(x: -1, y: 2), point(x: 0, y: 2), point(x: 1, y: 2), point(x: 2, y: 2), point(x: 3, y: 2), point(x: 4, y: 2), point(x: 5, y: 2), point(x: 6,y: 2), point(x: 7, y: 2), point(x: 8, y: 2), point(x: 9, y: 2), point(x: 10, y: 2), point(x: 11, y: 2), point(x: 12, y: 2),
      point(x: -12, y: 3), point(x: -11, y: 3), point(x: -10, y: 3), point(x: -9, y: 3), point(x: -8, y: 3), point(x: -7, y: 3), point(x: -6, y: 3), point(x: -5, y: 3), point(x: -4, y: 3), point(x: -3, y: 3), point(x: -2, y: 3), point(x: -1, y: 3), point(x: 0, y: 3), point(x: 1, y: 3), point(x: 2, y: 3), point(x: 3, y: 3), point(x: 4, y: 3), point(x: 5, y: 3), point(x: 6,y: 3), point(x: 7, y: 3), point(x: 8, y: 3), point(x: 9, y: 3), point(x: 10, y: 3), point(x: 11, y: 3), point(x: 12, y: 3),
      point(x: -12, y: 4), point(x: -11, y: 4), point(x: -10, y: 4), point(x: -9, y: 4), point(x: -8, y: 4), point(x: -7, y: 4), point(x: -6, y: 4), point(x: -5, y: 4), point(x: -4, y: 4), point(x: -3, y: 4), point(x: -2, y: 4), point(x: -1, y: 4), point(x: 0, y: 4), point(x: 1, y: 4), point(x: 2, y: 4), point(x: 3, y: 4), point(x: 4, y: 4), point(x: 5, y: 4), point(x: 6,y: 4), point(x: 7, y: 4), point(x: 8, y: 4), point(x: 9, y: 4), point(x: 10, y: 4), point(x: 11, y: 4), point(x: 12, y: 4),
      point(x: -12, y: 5), point(x: -11, y: 5), point(x: -10, y: 5), point(x: -9, y: 5), point(x: -8, y: 5), point(x: -7, y: 5), point(x: -6, y: 5), point(x: -5, y: 5), point(x: -4, y: 5), point(x: -3, y: 5), point(x: -2, y: 5), point(x: -1, y: 5), point(x: 0, y: 5), point(x: 1, y: 5), point(x: 2, y: 5), point(x: 3, y: 5), point(x: 4, y: 5), point(x: 5, y: 5), point(x: 6,y: 5), point(x: 7, y: 5), point(x: 8, y: 5), point(x: 9, y: 5), point(x: 10, y: 5), point(x: 11, y: 5), point(x: 12, y: 5),
      point(x: -12, y: 6), point(x: -11, y: 6), point(x: -10, y: 6), point(x: -9, y: 6), point(x: -8, y: 6), point(x: -7, y: 6), point(x: -6, y: 6), point(x: -5, y: 6), point(x: -4, y: 6), point(x: -3, y: 6), point(x: -2, y: 6), point(x: -1, y: 6), point(x: 0, y: 6), point(x: 1, y: 6), point(x: 2, y: 6), point(x: 3, y: 6), point(x: 4, y: 6), point(x: 5, y: 6), point(x: 6,y: 6), point(x: 7, y: 6), point(x: 8, y: 6), point(x: 9, y: 6), point(x: 10, y: 6), point(x: 11, y: 6), point(x: 12, y: 6),
      point(x: -12, y: 7), point(x: -11, y: 7), point(x: -10, y: 7), point(x: -9, y: 7), point(x: -8, y: 7), point(x: -7, y: 7), point(x: -6, y: 7), point(x: -5, y: 7), point(x: -4, y: 7), point(x: -3, y: 7), point(x: -2, y: 7), point(x: -1, y: 7), point(x: 0, y: 7), point(x: 1, y: 7), point(x: 2, y: 7), point(x: 3, y: 7), point(x: 4, y: 7), point(x: 5, y: 7), point(x: 6,y: 7), point(x: 7, y: 7), point(x: 8, y: 7), point(x: 9, y: 7), point(x: 10, y: 7), point(x: 11, y: 7), point(x: 12, y: 7),
      point(x: 13, y: -6), point(x: 13, y: -5), point(x: 13, y: -4),

    ],
    input_pins: @[
      prototype_pin(position: point(x: -13, y: -7), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 13, y: -7), kind: wk_8),
    ],
    category: @[CAT_IO],
  ),

  Program8_1Red: prototype(
    area: @[
      point(x: -12, y: -8), point(x: -11, y: -8), point(x: -10, y: -8), point(x: -9, y: -8), point(x: -8, y: -8), point(x: -7, y: -8), point(x: -6, y: -8), point(x: -5, y: -8), point(x: -4, y: -8), point(x: -3, y: -8), point(x: -2, y: -8), point(x: -1, y: -8), point(x: 0, y: -8), point(x: 1, y: -8), point(x: 2, y: -8), point(x: 3, y: -8), point(x: 4, y: -8), point(x: 5, y: -8), point(x: 6,y: -8), point(x: 7, y: -8), point(x: 8, y: -8), point(x: 9, y: -8), point(x: 10, y: -8), point(x: 11, y: -8), point(x: 12, y: -8),
      point(x: -12, y: -7), point(x: -11, y: -7), point(x: -10, y: -7), point(x: -9, y: -7), point(x: -8, y: -7), point(x: -7, y: -7), point(x: -6, y: -7), point(x: -5, y: -7), point(x: -4, y: -7), point(x: -3, y: -7), point(x: -2, y: -7), point(x: -1, y: -7), point(x: 0, y: -7), point(x: 1, y: -7), point(x: 2, y: -7), point(x: 3, y: -7), point(x: 4, y: -7), point(x: 5, y: -7), point(x: 6,y: -7), point(x: 7, y: -7), point(x: 8, y: -7), point(x: 9, y: -7), point(x: 10, y: -7), point(x: 11, y: -7), point(x: 12, y: -7),
      point(x: -12, y: -6), point(x: -11, y: -6), point(x: -10, y: -6), point(x: -9, y: -6), point(x: -8, y: -6), point(x: -7, y: -6), point(x: -6, y: -6), point(x: -5, y: -6), point(x: -4, y: -6), point(x: -3, y: -6), point(x: -2, y: -6), point(x: -1, y: -6), point(x: 0, y: -6), point(x: 1, y: -6), point(x: 2, y: -6), point(x: 3, y: -6), point(x: 4, y: -6), point(x: 5, y: -6), point(x: 6,y: -6), point(x: 7, y: -6), point(x: 8, y: -6), point(x: 9, y: -6), point(x: 10, y: -6), point(x: 11, y: -6), point(x: 12, y: -6),
      point(x: -12, y: -5), point(x: -11, y: -5), point(x: -10, y: -5), point(x: -9, y: -5), point(x: -8, y: -5), point(x: -7, y: -5), point(x: -6, y: -5), point(x: -5, y: -5), point(x: -4, y: -5), point(x: -3, y: -5), point(x: -2, y: -5), point(x: -1, y: -5), point(x: 0, y: -5), point(x: 1, y: -5), point(x: 2, y: -5), point(x: 3, y: -5), point(x: 4, y: -5), point(x: 5, y: -5), point(x: 6,y: -5), point(x: 7, y: -5), point(x: 8, y: -5), point(x: 9, y: -5), point(x: 10, y: -5), point(x: 11, y: -5), point(x: 12, y: -5),
      point(x: -12, y: -4), point(x: -11, y: -4), point(x: -10, y: -4), point(x: -9, y: -4), point(x: -8, y: -4), point(x: -7, y: -4), point(x: -6, y: -4), point(x: -5, y: -4), point(x: -4, y: -4), point(x: -3, y: -4), point(x: -2, y: -4), point(x: -1, y: -4), point(x: 0, y: -4), point(x: 1, y: -4), point(x: 2, y: -4), point(x: 3, y: -4), point(x: 4, y: -4), point(x: 5, y: -4), point(x: 6,y: -4), point(x: 7, y: -4), point(x: 8, y: -4), point(x: 9, y: -4), point(x: 10, y: -4), point(x: 11, y: -4), point(x: 12, y: -4),
      point(x: -12, y: -3), point(x: -11, y: -3), point(x: -10, y: -3), point(x: -9, y: -3), point(x: -8, y: -3), point(x: -7, y: -3), point(x: -6, y: -3), point(x: -5, y: -3), point(x: -4, y: -3), point(x: -3, y: -3), point(x: -2, y: -3), point(x: -1, y: -3), point(x: 0, y: -3), point(x: 1, y: -3), point(x: 2, y: -3), point(x: 3, y: -3), point(x: 4, y: -3), point(x: 5, y: -3), point(x: 6,y: -3), point(x: 7, y: -3), point(x: 8, y: -3), point(x: 9, y: -3), point(x: 10, y: -3), point(x: 11, y: -3), point(x: 12, y: -3),
      point(x: -12, y: -2), point(x: -11, y: -2), point(x: -10, y: -2), point(x: -9, y: -2), point(x: -8, y: -2), point(x: -7, y: -2), point(x: -6, y: -2), point(x: -5, y: -2), point(x: -4, y: -2), point(x: -3, y: -2), point(x: -2, y: -2), point(x: -1, y: -2), point(x: 0, y: -2), point(x: 1, y: -2), point(x: 2, y: -2), point(x: 3, y: -2), point(x: 4, y: -2), point(x: 5, y: -2), point(x: 6,y: -2), point(x: 7, y: -2), point(x: 8, y: -2), point(x: 9, y: -2), point(x: 10, y: -2), point(x: 11, y: -2), point(x: 12, y: -2),
      point(x: -12, y: -1), point(x: -11, y: -1), point(x: -10, y: -1), point(x: -9, y: -1), point(x: -8, y: -1), point(x: -7, y: -1), point(x: -6, y: -1), point(x: -5, y: -1), point(x: -4, y: -1), point(x: -3, y: -1), point(x: -2, y: -1), point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1), point(x: 2, y: -1), point(x: 3, y: -1), point(x: 4, y: -1), point(x: 5, y: -1), point(x: 6,y: -1), point(x: 7, y: -1), point(x: 8, y: -1), point(x: 9, y: -1), point(x: 10, y: -1), point(x: 11, y: -1), point(x: 12, y: -1),
      point(x: -12, y: 0), point(x: -11, y: 0), point(x: -10, y: 0), point(x: -9, y: 0), point(x: -8, y: 0), point(x: -7, y: 0), point(x: -6, y: 0), point(x: -5, y: 0), point(x: -4, y: 0), point(x: -3, y: 0), point(x: -2, y: 0), point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0), point(x: 2, y: 0), point(x: 3, y: 0), point(x: 4, y: 0), point(x: 5, y: 0), point(x: 6,y: 0), point(x: 7, y: 0), point(x: 8, y: 0), point(x: 9, y: 0), point(x: 10, y: 0), point(x: 11, y: 0), point(x: 12, y: 0),
      point(x: -12, y: 1), point(x: -11, y: 1), point(x: -10, y: 1), point(x: -9, y: 1), point(x: -8, y: 1), point(x: -7, y: 1), point(x: -6, y: 1), point(x: -5, y: 1), point(x: -4, y: 1), point(x: -3, y: 1), point(x: -2, y: 1), point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1), point(x: 2, y: 1), point(x: 3, y: 1), point(x: 4, y: 1), point(x: 5, y: 1), point(x: 6,y: 1), point(x: 7, y: 1), point(x: 8, y: 1), point(x: 9, y: 1), point(x: 10, y: 1), point(x: 11, y: 1), point(x: 12, y: 1),
      point(x: -12, y: 2), point(x: -11, y: 2), point(x: -10, y: 2), point(x: -9, y: 2), point(x: -8, y: 2), point(x: -7, y: 2), point(x: -6, y: 2), point(x: -5, y: 2), point(x: -4, y: 2), point(x: -3, y: 2), point(x: -2, y: 2), point(x: -1, y: 2), point(x: 0, y: 2), point(x: 1, y: 2), point(x: 2, y: 2), point(x: 3, y: 2), point(x: 4, y: 2), point(x: 5, y: 2), point(x: 6,y: 2), point(x: 7, y: 2), point(x: 8, y: 2), point(x: 9, y: 2), point(x: 10, y: 2), point(x: 11, y: 2), point(x: 12, y: 2),
      point(x: -12, y: 3), point(x: -11, y: 3), point(x: -10, y: 3), point(x: -9, y: 3), point(x: -8, y: 3), point(x: -7, y: 3), point(x: -6, y: 3), point(x: -5, y: 3), point(x: -4, y: 3), point(x: -3, y: 3), point(x: -2, y: 3), point(x: -1, y: 3), point(x: 0, y: 3), point(x: 1, y: 3), point(x: 2, y: 3), point(x: 3, y: 3), point(x: 4, y: 3), point(x: 5, y: 3), point(x: 6,y: 3), point(x: 7, y: 3), point(x: 8, y: 3), point(x: 9, y: 3), point(x: 10, y: 3), point(x: 11, y: 3), point(x: 12, y: 3),
      point(x: -12, y: 4), point(x: -11, y: 4), point(x: -10, y: 4), point(x: -9, y: 4), point(x: -8, y: 4), point(x: -7, y: 4), point(x: -6, y: 4), point(x: -5, y: 4), point(x: -4, y: 4), point(x: -3, y: 4), point(x: -2, y: 4), point(x: -1, y: 4), point(x: 0, y: 4), point(x: 1, y: 4), point(x: 2, y: 4), point(x: 3, y: 4), point(x: 4, y: 4), point(x: 5, y: 4), point(x: 6,y: 4), point(x: 7, y: 4), point(x: 8, y: 4), point(x: 9, y: 4), point(x: 10, y: 4), point(x: 11, y: 4), point(x: 12, y: 4),
      point(x: -12, y: 5), point(x: -11, y: 5), point(x: -10, y: 5), point(x: -9, y: 5), point(x: -8, y: 5), point(x: -7, y: 5), point(x: -6, y: 5), point(x: -5, y: 5), point(x: -4, y: 5), point(x: -3, y: 5), point(x: -2, y: 5), point(x: -1, y: 5), point(x: 0, y: 5), point(x: 1, y: 5), point(x: 2, y: 5), point(x: 3, y: 5), point(x: 4, y: 5), point(x: 5, y: 5), point(x: 6,y: 5), point(x: 7, y: 5), point(x: 8, y: 5), point(x: 9, y: 5), point(x: 10, y: 5), point(x: 11, y: 5), point(x: 12, y: 5),
      point(x: -12, y: 6), point(x: -11, y: 6), point(x: -10, y: 6), point(x: -9, y: 6), point(x: -8, y: 6), point(x: -7, y: 6), point(x: -6, y: 6), point(x: -5, y: 6), point(x: -4, y: 6), point(x: -3, y: 6), point(x: -2, y: 6), point(x: -1, y: 6), point(x: 0, y: 6), point(x: 1, y: 6), point(x: 2, y: 6), point(x: 3, y: 6), point(x: 4, y: 6), point(x: 5, y: 6), point(x: 6,y: 6), point(x: 7, y: 6), point(x: 8, y: 6), point(x: 9, y: 6), point(x: 10, y: 6), point(x: 11, y: 6), point(x: 12, y: 6),
      point(x: -12, y: 7), point(x: -11, y: 7), point(x: -10, y: 7), point(x: -9, y: 7), point(x: -8, y: 7), point(x: -7, y: 7), point(x: -6, y: 7), point(x: -5, y: 7), point(x: -4, y: 7), point(x: -3, y: 7), point(x: -2, y: 7), point(x: -1, y: 7), point(x: 0, y: 7), point(x: 1, y: 7), point(x: 2, y: 7), point(x: 3, y: 7), point(x: 4, y: 7), point(x: 5, y: 7), point(x: 6,y: 7), point(x: 7, y: 7), point(x: 8, y: 7), point(x: 9, y: 7), point(x: 10, y: 7), point(x: 11, y: 7), point(x: 12, y: 7),
      point(x: 13, y: -6), point(x: 13, y: -5), point(x: 13, y: -4),
    ],
    input_pins: @[
      prototype_pin(position: point(x: -13, y: -7), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 13, y: -7), kind: wk_8),
    ],
    category: @[CAT_IO],
    immutable: true,
  ),
  Program8_4: prototype(
    area: @[
      point(x: -12, y: -8), point(x: -11, y: -8), point(x: -10, y: -8), point(x: -9, y: -8), point(x: -8, y: -8), point(x: -7, y: -8), point(x: -6, y: -8), point(x: -5, y: -8), point(x: -4, y: -8), point(x: -3, y: -8), point(x: -2, y: -8), point(x: -1, y: -8), point(x: 0, y: -8), point(x: 1, y: -8), point(x: 2, y: -8), point(x: 3, y: -8), point(x: 4, y: -8), point(x: 5, y: -8), point(x: 6,y: -8), point(x: 7, y: -8), point(x: 8, y: -8), point(x: 9, y: -8), point(x: 10, y: -8), point(x: 11, y: -8), point(x: 12, y: -8),
      point(x: -12, y: -7), point(x: -11, y: -7), point(x: -10, y: -7), point(x: -9, y: -7), point(x: -8, y: -7), point(x: -7, y: -7), point(x: -6, y: -7), point(x: -5, y: -7), point(x: -4, y: -7), point(x: -3, y: -7), point(x: -2, y: -7), point(x: -1, y: -7), point(x: 0, y: -7), point(x: 1, y: -7), point(x: 2, y: -7), point(x: 3, y: -7), point(x: 4, y: -7), point(x: 5, y: -7), point(x: 6,y: -7), point(x: 7, y: -7), point(x: 8, y: -7), point(x: 9, y: -7), point(x: 10, y: -7), point(x: 11, y: -7), point(x: 12, y: -7),
      point(x: -12, y: -6), point(x: -11, y: -6), point(x: -10, y: -6), point(x: -9, y: -6), point(x: -8, y: -6), point(x: -7, y: -6), point(x: -6, y: -6), point(x: -5, y: -6), point(x: -4, y: -6), point(x: -3, y: -6), point(x: -2, y: -6), point(x: -1, y: -6), point(x: 0, y: -6), point(x: 1, y: -6), point(x: 2, y: -6), point(x: 3, y: -6), point(x: 4, y: -6), point(x: 5, y: -6), point(x: 6,y: -6), point(x: 7, y: -6), point(x: 8, y: -6), point(x: 9, y: -6), point(x: 10, y: -6), point(x: 11, y: -6), point(x: 12, y: -6),
      point(x: -12, y: -5), point(x: -11, y: -5), point(x: -10, y: -5), point(x: -9, y: -5), point(x: -8, y: -5), point(x: -7, y: -5), point(x: -6, y: -5), point(x: -5, y: -5), point(x: -4, y: -5), point(x: -3, y: -5), point(x: -2, y: -5), point(x: -1, y: -5), point(x: 0, y: -5), point(x: 1, y: -5), point(x: 2, y: -5), point(x: 3, y: -5), point(x: 4, y: -5), point(x: 5, y: -5), point(x: 6,y: -5), point(x: 7, y: -5), point(x: 8, y: -5), point(x: 9, y: -5), point(x: 10, y: -5), point(x: 11, y: -5), point(x: 12, y: -5),
      point(x: -12, y: -4), point(x: -11, y: -4), point(x: -10, y: -4), point(x: -9, y: -4), point(x: -8, y: -4), point(x: -7, y: -4), point(x: -6, y: -4), point(x: -5, y: -4), point(x: -4, y: -4), point(x: -3, y: -4), point(x: -2, y: -4), point(x: -1, y: -4), point(x: 0, y: -4), point(x: 1, y: -4), point(x: 2, y: -4), point(x: 3, y: -4), point(x: 4, y: -4), point(x: 5, y: -4), point(x: 6,y: -4), point(x: 7, y: -4), point(x: 8, y: -4), point(x: 9, y: -4), point(x: 10, y: -4), point(x: 11, y: -4), point(x: 12, y: -4),
      point(x: -12, y: -3), point(x: -11, y: -3), point(x: -10, y: -3), point(x: -9, y: -3), point(x: -8, y: -3), point(x: -7, y: -3), point(x: -6, y: -3), point(x: -5, y: -3), point(x: -4, y: -3), point(x: -3, y: -3), point(x: -2, y: -3), point(x: -1, y: -3), point(x: 0, y: -3), point(x: 1, y: -3), point(x: 2, y: -3), point(x: 3, y: -3), point(x: 4, y: -3), point(x: 5, y: -3), point(x: 6,y: -3), point(x: 7, y: -3), point(x: 8, y: -3), point(x: 9, y: -3), point(x: 10, y: -3), point(x: 11, y: -3), point(x: 12, y: -3),
      point(x: -12, y: -2), point(x: -11, y: -2), point(x: -10, y: -2), point(x: -9, y: -2), point(x: -8, y: -2), point(x: -7, y: -2), point(x: -6, y: -2), point(x: -5, y: -2), point(x: -4, y: -2), point(x: -3, y: -2), point(x: -2, y: -2), point(x: -1, y: -2), point(x: 0, y: -2), point(x: 1, y: -2), point(x: 2, y: -2), point(x: 3, y: -2), point(x: 4, y: -2), point(x: 5, y: -2), point(x: 6,y: -2), point(x: 7, y: -2), point(x: 8, y: -2), point(x: 9, y: -2), point(x: 10, y: -2), point(x: 11, y: -2), point(x: 12, y: -2),
      point(x: -12, y: -1), point(x: -11, y: -1), point(x: -10, y: -1), point(x: -9, y: -1), point(x: -8, y: -1), point(x: -7, y: -1), point(x: -6, y: -1), point(x: -5, y: -1), point(x: -4, y: -1), point(x: -3, y: -1), point(x: -2, y: -1), point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1), point(x: 2, y: -1), point(x: 3, y: -1), point(x: 4, y: -1), point(x: 5, y: -1), point(x: 6,y: -1), point(x: 7, y: -1), point(x: 8, y: -1), point(x: 9, y: -1), point(x: 10, y: -1), point(x: 11, y: -1), point(x: 12, y: -1),
      point(x: -12, y: 0), point(x: -11, y: 0), point(x: -10, y: 0), point(x: -9, y: 0), point(x: -8, y: 0), point(x: -7, y: 0), point(x: -6, y: 0), point(x: -5, y: 0), point(x: -4, y: 0), point(x: -3, y: 0), point(x: -2, y: 0), point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0), point(x: 2, y: 0), point(x: 3, y: 0), point(x: 4, y: 0), point(x: 5, y: 0), point(x: 6,y: 0), point(x: 7, y: 0), point(x: 8, y: 0), point(x: 9, y: 0), point(x: 10, y: 0), point(x: 11, y: 0), point(x: 12, y: 0),
      point(x: -12, y: 1), point(x: -11, y: 1), point(x: -10, y: 1), point(x: -9, y: 1), point(x: -8, y: 1), point(x: -7, y: 1), point(x: -6, y: 1), point(x: -5, y: 1), point(x: -4, y: 1), point(x: -3, y: 1), point(x: -2, y: 1), point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1), point(x: 2, y: 1), point(x: 3, y: 1), point(x: 4, y: 1), point(x: 5, y: 1), point(x: 6,y: 1), point(x: 7, y: 1), point(x: 8, y: 1), point(x: 9, y: 1), point(x: 10, y: 1), point(x: 11, y: 1), point(x: 12, y: 1),
      point(x: -12, y: 2), point(x: -11, y: 2), point(x: -10, y: 2), point(x: -9, y: 2), point(x: -8, y: 2), point(x: -7, y: 2), point(x: -6, y: 2), point(x: -5, y: 2), point(x: -4, y: 2), point(x: -3, y: 2), point(x: -2, y: 2), point(x: -1, y: 2), point(x: 0, y: 2), point(x: 1, y: 2), point(x: 2, y: 2), point(x: 3, y: 2), point(x: 4, y: 2), point(x: 5, y: 2), point(x: 6,y: 2), point(x: 7, y: 2), point(x: 8, y: 2), point(x: 9, y: 2), point(x: 10, y: 2), point(x: 11, y: 2), point(x: 12, y: 2),
      point(x: -12, y: 3), point(x: -11, y: 3), point(x: -10, y: 3), point(x: -9, y: 3), point(x: -8, y: 3), point(x: -7, y: 3), point(x: -6, y: 3), point(x: -5, y: 3), point(x: -4, y: 3), point(x: -3, y: 3), point(x: -2, y: 3), point(x: -1, y: 3), point(x: 0, y: 3), point(x: 1, y: 3), point(x: 2, y: 3), point(x: 3, y: 3), point(x: 4, y: 3), point(x: 5, y: 3), point(x: 6,y: 3), point(x: 7, y: 3), point(x: 8, y: 3), point(x: 9, y: 3), point(x: 10, y: 3), point(x: 11, y: 3), point(x: 12, y: 3),
      point(x: -12, y: 4), point(x: -11, y: 4), point(x: -10, y: 4), point(x: -9, y: 4), point(x: -8, y: 4), point(x: -7, y: 4), point(x: -6, y: 4), point(x: -5, y: 4), point(x: -4, y: 4), point(x: -3, y: 4), point(x: -2, y: 4), point(x: -1, y: 4), point(x: 0, y: 4), point(x: 1, y: 4), point(x: 2, y: 4), point(x: 3, y: 4), point(x: 4, y: 4), point(x: 5, y: 4), point(x: 6,y: 4), point(x: 7, y: 4), point(x: 8, y: 4), point(x: 9, y: 4), point(x: 10, y: 4), point(x: 11, y: 4), point(x: 12, y: 4),
      point(x: -12, y: 5), point(x: -11, y: 5), point(x: -10, y: 5), point(x: -9, y: 5), point(x: -8, y: 5), point(x: -7, y: 5), point(x: -6, y: 5), point(x: -5, y: 5), point(x: -4, y: 5), point(x: -3, y: 5), point(x: -2, y: 5), point(x: -1, y: 5), point(x: 0, y: 5), point(x: 1, y: 5), point(x: 2, y: 5), point(x: 3, y: 5), point(x: 4, y: 5), point(x: 5, y: 5), point(x: 6,y: 5), point(x: 7, y: 5), point(x: 8, y: 5), point(x: 9, y: 5), point(x: 10, y: 5), point(x: 11, y: 5), point(x: 12, y: 5),
      point(x: -12, y: 6), point(x: -11, y: 6), point(x: -10, y: 6), point(x: -9, y: 6), point(x: -8, y: 6), point(x: -7, y: 6), point(x: -6, y: 6), point(x: -5, y: 6), point(x: -4, y: 6), point(x: -3, y: 6), point(x: -2, y: 6), point(x: -1, y: 6), point(x: 0, y: 6), point(x: 1, y: 6), point(x: 2, y: 6), point(x: 3, y: 6), point(x: 4, y: 6), point(x: 5, y: 6), point(x: 6,y: 6), point(x: 7, y: 6), point(x: 8, y: 6), point(x: 9, y: 6), point(x: 10, y: 6), point(x: 11, y: 6), point(x: 12, y: 6),
      point(x: -12, y: 7), point(x: -11, y: 7), point(x: -10, y: 7), point(x: -9, y: 7), point(x: -8, y: 7), point(x: -7, y: 7), point(x: -6, y: 7), point(x: -5, y: 7), point(x: -4, y: 7), point(x: -3, y: 7), point(x: -2, y: 7), point(x: -1, y: 7), point(x: 0, y: 7), point(x: 1, y: 7), point(x: 2, y: 7), point(x: 3, y: 7), point(x: 4, y: 7), point(x: 5, y: 7), point(x: 6,y: 7), point(x: 7, y: 7), point(x: 8, y: 7), point(x: 9, y: 7), point(x: 10, y: 7), point(x: 11, y: 7), point(x: 12, y: 7),
    ],
    input_pins: @[
      prototype_pin(position: point(x: -13, y: -7), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 13, y: -7), kind: wk_8),
      prototype_pin(position: point(x: 13, y: -6), kind: wk_8),
      prototype_pin(position: point(x: 13, y: -5), kind: wk_8),
      prototype_pin(position: point(x: 13, y: -4), kind: wk_8),
    ],
    category: @[CAT_IO],
  ),
  Program: prototype(
    sandbox: true,
    area: @[
      point(x: -12, y: -8), point(x: -11, y: -8), point(x: -10, y: -8), point(x: -9, y: -8), point(x: -8, y: -8), point(x: -7, y: -8), point(x: -6, y: -8), point(x: -5, y: -8), point(x: -4, y: -8), point(x: -3, y: -8), point(x: -2, y: -8), point(x: -1, y: -8), point(x: 0, y: -8), point(x: 1, y: -8), point(x: 2, y: -8), point(x: 3, y: -8), point(x: 4, y: -8), point(x: 5, y: -8), point(x: 6,y: -8), point(x: 7, y: -8), point(x: 8, y: -8), point(x: 9, y: -8), point(x: 10, y: -8), point(x: 11, y: -8), point(x: 12, y: -8),
      point(x: -12, y: -7), point(x: -11, y: -7), point(x: -10, y: -7), point(x: -9, y: -7), point(x: -8, y: -7), point(x: -7, y: -7), point(x: -6, y: -7), point(x: -5, y: -7), point(x: -4, y: -7), point(x: -3, y: -7), point(x: -2, y: -7), point(x: -1, y: -7), point(x: 0, y: -7), point(x: 1, y: -7), point(x: 2, y: -7), point(x: 3, y: -7), point(x: 4, y: -7), point(x: 5, y: -7), point(x: 6,y: -7), point(x: 7, y: -7), point(x: 8, y: -7), point(x: 9, y: -7), point(x: 10, y: -7), point(x: 11, y: -7), point(x: 12, y: -7),
      point(x: -12, y: -6), point(x: -11, y: -6), point(x: -10, y: -6), point(x: -9, y: -6), point(x: -8, y: -6), point(x: -7, y: -6), point(x: -6, y: -6), point(x: -5, y: -6), point(x: -4, y: -6), point(x: -3, y: -6), point(x: -2, y: -6), point(x: -1, y: -6), point(x: 0, y: -6), point(x: 1, y: -6), point(x: 2, y: -6), point(x: 3, y: -6), point(x: 4, y: -6), point(x: 5, y: -6), point(x: 6,y: -6), point(x: 7, y: -6), point(x: 8, y: -6), point(x: 9, y: -6), point(x: 10, y: -6), point(x: 11, y: -6), point(x: 12, y: -6),
      point(x: -12, y: -5), point(x: -11, y: -5), point(x: -10, y: -5), point(x: -9, y: -5), point(x: -8, y: -5), point(x: -7, y: -5), point(x: -6, y: -5), point(x: -5, y: -5), point(x: -4, y: -5), point(x: -3, y: -5), point(x: -2, y: -5), point(x: -1, y: -5), point(x: 0, y: -5), point(x: 1, y: -5), point(x: 2, y: -5), point(x: 3, y: -5), point(x: 4, y: -5), point(x: 5, y: -5), point(x: 6,y: -5), point(x: 7, y: -5), point(x: 8, y: -5), point(x: 9, y: -5), point(x: 10, y: -5), point(x: 11, y: -5), point(x: 12, y: -5),
      point(x: -12, y: -4), point(x: -11, y: -4), point(x: -10, y: -4), point(x: -9, y: -4), point(x: -8, y: -4), point(x: -7, y: -4), point(x: -6, y: -4), point(x: -5, y: -4), point(x: -4, y: -4), point(x: -3, y: -4), point(x: -2, y: -4), point(x: -1, y: -4), point(x: 0, y: -4), point(x: 1, y: -4), point(x: 2, y: -4), point(x: 3, y: -4), point(x: 4, y: -4), point(x: 5, y: -4), point(x: 6,y: -4), point(x: 7, y: -4), point(x: 8, y: -4), point(x: 9, y: -4), point(x: 10, y: -4), point(x: 11, y: -4), point(x: 12, y: -4),
      point(x: -12, y: -3), point(x: -11, y: -3), point(x: -10, y: -3), point(x: -9, y: -3), point(x: -8, y: -3), point(x: -7, y: -3), point(x: -6, y: -3), point(x: -5, y: -3), point(x: -4, y: -3), point(x: -3, y: -3), point(x: -2, y: -3), point(x: -1, y: -3), point(x: 0, y: -3), point(x: 1, y: -3), point(x: 2, y: -3), point(x: 3, y: -3), point(x: 4, y: -3), point(x: 5, y: -3), point(x: 6,y: -3), point(x: 7, y: -3), point(x: 8, y: -3), point(x: 9, y: -3), point(x: 10, y: -3), point(x: 11, y: -3), point(x: 12, y: -3),
      point(x: -12, y: -2), point(x: -11, y: -2), point(x: -10, y: -2), point(x: -9, y: -2), point(x: -8, y: -2), point(x: -7, y: -2), point(x: -6, y: -2), point(x: -5, y: -2), point(x: -4, y: -2), point(x: -3, y: -2), point(x: -2, y: -2), point(x: -1, y: -2), point(x: 0, y: -2), point(x: 1, y: -2), point(x: 2, y: -2), point(x: 3, y: -2), point(x: 4, y: -2), point(x: 5, y: -2), point(x: 6,y: -2), point(x: 7, y: -2), point(x: 8, y: -2), point(x: 9, y: -2), point(x: 10, y: -2), point(x: 11, y: -2), point(x: 12, y: -2),
      point(x: -12, y: -1), point(x: -11, y: -1), point(x: -10, y: -1), point(x: -9, y: -1), point(x: -8, y: -1), point(x: -7, y: -1), point(x: -6, y: -1), point(x: -5, y: -1), point(x: -4, y: -1), point(x: -3, y: -1), point(x: -2, y: -1), point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1), point(x: 2, y: -1), point(x: 3, y: -1), point(x: 4, y: -1), point(x: 5, y: -1), point(x: 6,y: -1), point(x: 7, y: -1), point(x: 8, y: -1), point(x: 9, y: -1), point(x: 10, y: -1), point(x: 11, y: -1), point(x: 12, y: -1),
      point(x: -12, y: 0), point(x: -11, y: 0), point(x: -10, y: 0), point(x: -9, y: 0), point(x: -8, y: 0), point(x: -7, y: 0), point(x: -6, y: 0), point(x: -5, y: 0), point(x: -4, y: 0), point(x: -3, y: 0), point(x: -2, y: 0), point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0), point(x: 2, y: 0), point(x: 3, y: 0), point(x: 4, y: 0), point(x: 5, y: 0), point(x: 6,y: 0), point(x: 7, y: 0), point(x: 8, y: 0), point(x: 9, y: 0), point(x: 10, y: 0), point(x: 11, y: 0), point(x: 12, y: 0),
      point(x: -12, y: 1), point(x: -11, y: 1), point(x: -10, y: 1), point(x: -9, y: 1), point(x: -8, y: 1), point(x: -7, y: 1), point(x: -6, y: 1), point(x: -5, y: 1), point(x: -4, y: 1), point(x: -3, y: 1), point(x: -2, y: 1), point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1), point(x: 2, y: 1), point(x: 3, y: 1), point(x: 4, y: 1), point(x: 5, y: 1), point(x: 6,y: 1), point(x: 7, y: 1), point(x: 8, y: 1), point(x: 9, y: 1), point(x: 10, y: 1), point(x: 11, y: 1), point(x: 12, y: 1),
      point(x: -12, y: 2), point(x: -11, y: 2), point(x: -10, y: 2), point(x: -9, y: 2), point(x: -8, y: 2), point(x: -7, y: 2), point(x: -6, y: 2), point(x: -5, y: 2), point(x: -4, y: 2), point(x: -3, y: 2), point(x: -2, y: 2), point(x: -1, y: 2), point(x: 0, y: 2), point(x: 1, y: 2), point(x: 2, y: 2), point(x: 3, y: 2), point(x: 4, y: 2), point(x: 5, y: 2), point(x: 6,y: 2), point(x: 7, y: 2), point(x: 8, y: 2), point(x: 9, y: 2), point(x: 10, y: 2), point(x: 11, y: 2), point(x: 12, y: 2),
      point(x: -12, y: 3), point(x: -11, y: 3), point(x: -10, y: 3), point(x: -9, y: 3), point(x: -8, y: 3), point(x: -7, y: 3), point(x: -6, y: 3), point(x: -5, y: 3), point(x: -4, y: 3), point(x: -3, y: 3), point(x: -2, y: 3), point(x: -1, y: 3), point(x: 0, y: 3), point(x: 1, y: 3), point(x: 2, y: 3), point(x: 3, y: 3), point(x: 4, y: 3), point(x: 5, y: 3), point(x: 6,y: 3), point(x: 7, y: 3), point(x: 8, y: 3), point(x: 9, y: 3), point(x: 10, y: 3), point(x: 11, y: 3), point(x: 12, y: 3),
      point(x: -12, y: 4), point(x: -11, y: 4), point(x: -10, y: 4), point(x: -9, y: 4), point(x: -8, y: 4), point(x: -7, y: 4), point(x: -6, y: 4), point(x: -5, y: 4), point(x: -4, y: 4), point(x: -3, y: 4), point(x: -2, y: 4), point(x: -1, y: 4), point(x: 0, y: 4), point(x: 1, y: 4), point(x: 2, y: 4), point(x: 3, y: 4), point(x: 4, y: 4), point(x: 5, y: 4), point(x: 6,y: 4), point(x: 7, y: 4), point(x: 8, y: 4), point(x: 9, y: 4), point(x: 10, y: 4), point(x: 11, y: 4), point(x: 12, y: 4),
      point(x: -12, y: 5), point(x: -11, y: 5), point(x: -10, y: 5), point(x: -9, y: 5), point(x: -8, y: 5), point(x: -7, y: 5), point(x: -6, y: 5), point(x: -5, y: 5), point(x: -4, y: 5), point(x: -3, y: 5), point(x: -2, y: 5), point(x: -1, y: 5), point(x: 0, y: 5), point(x: 1, y: 5), point(x: 2, y: 5), point(x: 3, y: 5), point(x: 4, y: 5), point(x: 5, y: 5), point(x: 6,y: 5), point(x: 7, y: 5), point(x: 8, y: 5), point(x: 9, y: 5), point(x: 10, y: 5), point(x: 11, y: 5), point(x: 12, y: 5),
      point(x: -12, y: 6), point(x: -11, y: 6), point(x: -10, y: 6), point(x: -9, y: 6), point(x: -8, y: 6), point(x: -7, y: 6), point(x: -6, y: 6), point(x: -5, y: 6), point(x: -4, y: 6), point(x: -3, y: 6), point(x: -2, y: 6), point(x: -1, y: 6), point(x: 0, y: 6), point(x: 1, y: 6), point(x: 2, y: 6), point(x: 3, y: 6), point(x: 4, y: 6), point(x: 5, y: 6), point(x: 6,y: 6), point(x: 7, y: 6), point(x: 8, y: 6), point(x: 9, y: 6), point(x: 10, y: 6), point(x: 11, y: 6), point(x: 12, y: 6),
      point(x: -12, y: 7), point(x: -11, y: 7), point(x: -10, y: 7), point(x: -9, y: 7), point(x: -8, y: 7), point(x: -7, y: 7), point(x: -6, y: 7), point(x: -5, y: 7), point(x: -4, y: 7), point(x: -3, y: 7), point(x: -2, y: 7), point(x: -1, y: 7), point(x: 0, y: 7), point(x: 1, y: 7), point(x: 2, y: 7), point(x: 3, y: 7), point(x: 4, y: 7), point(x: 5, y: 7), point(x: 6,y: 7), point(x: 7, y: 7), point(x: 8, y: 7), point(x: 9, y: 7), point(x: 10, y: 7), point(x: 11, y: 7), point(x: 12, y: 7),
    ],
    input_pins: @[
      prototype_pin(position: point(x: -13, y: -7), kind: wk_16),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 13, y: -7), kind: wk_64),
      prototype_pin(position: point(x: 13, y: -6), kind: wk_64),
      prototype_pin(position: point(x: 13, y: -5), kind: wk_64),
      prototype_pin(position: point(x: 13, y: -4), kind: wk_64),
    ],
    memory: 256,
    category: @[CAT_IO],
  ),

  Ram8: prototype(
    menu_order: 6.uint8,
    area: @[
      point(x: -12, y: -8), point(x: -11, y: -8), point(x: -10, y: -8), point(x: -9, y: -8), point(x: -8, y: -8), point(x: -7, y: -8), point(x: -6, y: -8), point(x: -5, y: -8), point(x: -4, y: -8), point(x: -3, y: -8), point(x: -2, y: -8), point(x: -1, y: -8), point(x: 0, y: -8), point(x: 1, y: -8), point(x: 2, y: -8), point(x: 3, y: -8), point(x: 4, y: -8), point(x: 5, y: -8), point(x: 6,y: -8), point(x: 7, y: -8), point(x: 8, y: -8), point(x: 9, y: -8), point(x: 10, y: -8), point(x: 11, y: -8), point(x: 12, y: -8),
      point(x: -12, y: -7), point(x: -11, y: -7), point(x: -10, y: -7), point(x: -9, y: -7), point(x: -8, y: -7), point(x: -7, y: -7), point(x: -6, y: -7), point(x: -5, y: -7), point(x: -4, y: -7), point(x: -3, y: -7), point(x: -2, y: -7), point(x: -1, y: -7), point(x: 0, y: -7), point(x: 1, y: -7), point(x: 2, y: -7), point(x: 3, y: -7), point(x: 4, y: -7), point(x: 5, y: -7), point(x: 6,y: -7), point(x: 7, y: -7), point(x: 8, y: -7), point(x: 9, y: -7), point(x: 10, y: -7), point(x: 11, y: -7), point(x: 12, y: -7),
      point(x: -12, y: -6), point(x: -11, y: -6), point(x: -10, y: -6), point(x: -9, y: -6), point(x: -8, y: -6), point(x: -7, y: -6), point(x: -6, y: -6), point(x: -5, y: -6), point(x: -4, y: -6), point(x: -3, y: -6), point(x: -2, y: -6), point(x: -1, y: -6), point(x: 0, y: -6), point(x: 1, y: -6), point(x: 2, y: -6), point(x: 3, y: -6), point(x: 4, y: -6), point(x: 5, y: -6), point(x: 6,y: -6), point(x: 7, y: -6), point(x: 8, y: -6), point(x: 9, y: -6), point(x: 10, y: -6), point(x: 11, y: -6), point(x: 12, y: -6),
      point(x: -12, y: -5), point(x: -11, y: -5), point(x: -10, y: -5), point(x: -9, y: -5), point(x: -8, y: -5), point(x: -7, y: -5), point(x: -6, y: -5), point(x: -5, y: -5), point(x: -4, y: -5), point(x: -3, y: -5), point(x: -2, y: -5), point(x: -1, y: -5), point(x: 0, y: -5), point(x: 1, y: -5), point(x: 2, y: -5), point(x: 3, y: -5), point(x: 4, y: -5), point(x: 5, y: -5), point(x: 6,y: -5), point(x: 7, y: -5), point(x: 8, y: -5), point(x: 9, y: -5), point(x: 10, y: -5), point(x: 11, y: -5), point(x: 12, y: -5),
      point(x: -12, y: -4), point(x: -11, y: -4), point(x: -10, y: -4), point(x: -9, y: -4), point(x: -8, y: -4), point(x: -7, y: -4), point(x: -6, y: -4), point(x: -5, y: -4), point(x: -4, y: -4), point(x: -3, y: -4), point(x: -2, y: -4), point(x: -1, y: -4), point(x: 0, y: -4), point(x: 1, y: -4), point(x: 2, y: -4), point(x: 3, y: -4), point(x: 4, y: -4), point(x: 5, y: -4), point(x: 6,y: -4), point(x: 7, y: -4), point(x: 8, y: -4), point(x: 9, y: -4), point(x: 10, y: -4), point(x: 11, y: -4), point(x: 12, y: -4),
      point(x: -12, y: -3), point(x: -11, y: -3), point(x: -10, y: -3), point(x: -9, y: -3), point(x: -8, y: -3), point(x: -7, y: -3), point(x: -6, y: -3), point(x: -5, y: -3), point(x: -4, y: -3), point(x: -3, y: -3), point(x: -2, y: -3), point(x: -1, y: -3), point(x: 0, y: -3), point(x: 1, y: -3), point(x: 2, y: -3), point(x: 3, y: -3), point(x: 4, y: -3), point(x: 5, y: -3), point(x: 6,y: -3), point(x: 7, y: -3), point(x: 8, y: -3), point(x: 9, y: -3), point(x: 10, y: -3), point(x: 11, y: -3), point(x: 12, y: -3),
      point(x: -12, y: -2), point(x: -11, y: -2), point(x: -10, y: -2), point(x: -9, y: -2), point(x: -8, y: -2), point(x: -7, y: -2), point(x: -6, y: -2), point(x: -5, y: -2), point(x: -4, y: -2), point(x: -3, y: -2), point(x: -2, y: -2), point(x: -1, y: -2), point(x: 0, y: -2), point(x: 1, y: -2), point(x: 2, y: -2), point(x: 3, y: -2), point(x: 4, y: -2), point(x: 5, y: -2), point(x: 6,y: -2), point(x: 7, y: -2), point(x: 8, y: -2), point(x: 9, y: -2), point(x: 10, y: -2), point(x: 11, y: -2), point(x: 12, y: -2),
      point(x: -12, y: -1), point(x: -11, y: -1), point(x: -10, y: -1), point(x: -9, y: -1), point(x: -8, y: -1), point(x: -7, y: -1), point(x: -6, y: -1), point(x: -5, y: -1), point(x: -4, y: -1), point(x: -3, y: -1), point(x: -2, y: -1), point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1), point(x: 2, y: -1), point(x: 3, y: -1), point(x: 4, y: -1), point(x: 5, y: -1), point(x: 6,y: -1), point(x: 7, y: -1), point(x: 8, y: -1), point(x: 9, y: -1), point(x: 10, y: -1), point(x: 11, y: -1), point(x: 12, y: -1),
      point(x: -12, y: 0), point(x: -11, y: 0), point(x: -10, y: 0), point(x: -9, y: 0), point(x: -8, y: 0), point(x: -7, y: 0), point(x: -6, y: 0), point(x: -5, y: 0), point(x: -4, y: 0), point(x: -3, y: 0), point(x: -2, y: 0), point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0), point(x: 2, y: 0), point(x: 3, y: 0), point(x: 4, y: 0), point(x: 5, y: 0), point(x: 6,y: 0), point(x: 7, y: 0), point(x: 8, y: 0), point(x: 9, y: 0), point(x: 10, y: 0), point(x: 11, y: 0), point(x: 12, y: 0),
      point(x: -12, y: 1), point(x: -11, y: 1), point(x: -10, y: 1), point(x: -9, y: 1), point(x: -8, y: 1), point(x: -7, y: 1), point(x: -6, y: 1), point(x: -5, y: 1), point(x: -4, y: 1), point(x: -3, y: 1), point(x: -2, y: 1), point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1), point(x: 2, y: 1), point(x: 3, y: 1), point(x: 4, y: 1), point(x: 5, y: 1), point(x: 6,y: 1), point(x: 7, y: 1), point(x: 8, y: 1), point(x: 9, y: 1), point(x: 10, y: 1), point(x: 11, y: 1), point(x: 12, y: 1),
      point(x: -12, y: 2), point(x: -11, y: 2), point(x: -10, y: 2), point(x: -9, y: 2), point(x: -8, y: 2), point(x: -7, y: 2), point(x: -6, y: 2), point(x: -5, y: 2), point(x: -4, y: 2), point(x: -3, y: 2), point(x: -2, y: 2), point(x: -1, y: 2), point(x: 0, y: 2), point(x: 1, y: 2), point(x: 2, y: 2), point(x: 3, y: 2), point(x: 4, y: 2), point(x: 5, y: 2), point(x: 6,y: 2), point(x: 7, y: 2), point(x: 8, y: 2), point(x: 9, y: 2), point(x: 10, y: 2), point(x: 11, y: 2), point(x: 12, y: 2),
      point(x: -12, y: 3), point(x: -11, y: 3), point(x: -10, y: 3), point(x: -9, y: 3), point(x: -8, y: 3), point(x: -7, y: 3), point(x: -6, y: 3), point(x: -5, y: 3), point(x: -4, y: 3), point(x: -3, y: 3), point(x: -2, y: 3), point(x: -1, y: 3), point(x: 0, y: 3), point(x: 1, y: 3), point(x: 2, y: 3), point(x: 3, y: 3), point(x: 4, y: 3), point(x: 5, y: 3), point(x: 6,y: 3), point(x: 7, y: 3), point(x: 8, y: 3), point(x: 9, y: 3), point(x: 10, y: 3), point(x: 11, y: 3), point(x: 12, y: 3),
      point(x: -12, y: 4), point(x: -11, y: 4), point(x: -10, y: 4), point(x: -9, y: 4), point(x: -8, y: 4), point(x: -7, y: 4), point(x: -6, y: 4), point(x: -5, y: 4), point(x: -4, y: 4), point(x: -3, y: 4), point(x: -2, y: 4), point(x: -1, y: 4), point(x: 0, y: 4), point(x: 1, y: 4), point(x: 2, y: 4), point(x: 3, y: 4), point(x: 4, y: 4), point(x: 5, y: 4), point(x: 6,y: 4), point(x: 7, y: 4), point(x: 8, y: 4), point(x: 9, y: 4), point(x: 10, y: 4), point(x: 11, y: 4), point(x: 12, y: 4),
      point(x: -12, y: 5), point(x: -11, y: 5), point(x: -10, y: 5), point(x: -9, y: 5), point(x: -8, y: 5), point(x: -7, y: 5), point(x: -6, y: 5), point(x: -5, y: 5), point(x: -4, y: 5), point(x: -3, y: 5), point(x: -2, y: 5), point(x: -1, y: 5), point(x: 0, y: 5), point(x: 1, y: 5), point(x: 2, y: 5), point(x: 3, y: 5), point(x: 4, y: 5), point(x: 5, y: 5), point(x: 6,y: 5), point(x: 7, y: 5), point(x: 8, y: 5), point(x: 9, y: 5), point(x: 10, y: 5), point(x: 11, y: 5), point(x: 12, y: 5),
      point(x: -12, y: 6), point(x: -11, y: 6), point(x: -10, y: 6), point(x: -9, y: 6), point(x: -8, y: 6), point(x: -7, y: 6), point(x: -6, y: 6), point(x: -5, y: 6), point(x: -4, y: 6), point(x: -3, y: 6), point(x: -2, y: 6), point(x: -1, y: 6), point(x: 0, y: 6), point(x: 1, y: 6), point(x: 2, y: 6), point(x: 3, y: 6), point(x: 4, y: 6), point(x: 5, y: 6), point(x: 6,y: 6), point(x: 7, y: 6), point(x: 8, y: 6), point(x: 9, y: 6), point(x: 10, y: 6), point(x: 11, y: 6), point(x: 12, y: 6),
      point(x: -12, y: 7), point(x: -11, y: 7), point(x: -10, y: 7), point(x: -9, y: 7), point(x: -8, y: 7), point(x: -7, y: 7), point(x: -6, y: 7), point(x: -5, y: 7), point(x: -4, y: 7), point(x: -3, y: 7), point(x: -2, y: 7), point(x: -1, y: 7), point(x: 0, y: 7), point(x: 1, y: 7), point(x: 2, y: 7), point(x: 3, y: 7), point(x: 4, y: 7), point(x: 5, y: 7), point(x: 6,y: 7), point(x: 7, y: 7), point(x: 8, y: 7), point(x: 9, y: 7), point(x: 10, y: 7), point(x: 11, y: 7), point(x: 12, y: 7),
      point(x: 13, y: -6), point(x: 13, y: -5), point(x: 13, y: -4),
      point(x: -13, y: -3), point(x: -13, y: -2), point(x: -13, y: -1),
    ],
    input_pins: @[
      prototype_pin(position: point(x: -13, y: -7)),
      #prototype_pin(position: point(x: -13, y: -6)),
      prototype_pin(position: point(x: -13, y: -5), kind: wk_8),
      #prototype_pin(position: point(x: -13, y: -4), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 13, y: -7), kind: wk_8, tri_state: true),
    ],
    dyn_mem_reset_on_level_reset: true,
    has_virtual: true,
    category: @[CAT_IO, CAT_RAM],
    memory: 256,
  ),

  VirtualRam8: prototype(
    input_pins: @[
      #prototype_pin(position: point(x: -13, y: -7)),
      prototype_pin(position: point(x: -13, y: -6)),
      prototype_pin(position: point(x: -13, y: -5), kind: wk_8),
      prototype_pin(position: point(x: -13, y: -4), kind: wk_8),
    ],
  ),

  Hdd: prototype(
    sandbox: true,
    menu_order: 8.uint8,
    default_setting_1: 256,
    has_virtual: true,
    area: @[
      point(x: -12, y: -8), point(x: -11, y: -8), point(x: -10, y: -8), point(x: -9, y: -8), point(x: -8, y: -8), point(x: -7, y: -8), point(x: -6, y: -8), point(x: -5, y: -8), point(x: -4, y: -8), point(x: -3, y: -8), point(x: -2, y: -8), point(x: -1, y: -8), point(x: 0, y: -8), point(x: 1, y: -8), point(x: 2, y: -8), point(x: 3, y: -8), point(x: 4, y: -8), point(x: 5, y: -8), point(x: 6,y: -8), point(x: 7, y: -8), point(x: 8, y: -8), point(x: 9, y: -8), point(x: 10, y: -8), point(x: 11, y: -8), point(x: 12, y: -8),
      point(x: -12, y: -7), point(x: -11, y: -7), point(x: -10, y: -7), point(x: -9, y: -7), point(x: -8, y: -7), point(x: -7, y: -7), point(x: -6, y: -7), point(x: -5, y: -7), point(x: -4, y: -7), point(x: -3, y: -7), point(x: -2, y: -7), point(x: -1, y: -7), point(x: 0, y: -7), point(x: 1, y: -7), point(x: 2, y: -7), point(x: 3, y: -7), point(x: 4, y: -7), point(x: 5, y: -7), point(x: 6,y: -7), point(x: 7, y: -7), point(x: 8, y: -7), point(x: 9, y: -7), point(x: 10, y: -7), point(x: 11, y: -7), point(x: 12, y: -7),
      point(x: -12, y: -6), point(x: -11, y: -6), point(x: -10, y: -6), point(x: -9, y: -6), point(x: -8, y: -6), point(x: -7, y: -6), point(x: -6, y: -6), point(x: -5, y: -6), point(x: -4, y: -6), point(x: -3, y: -6), point(x: -2, y: -6), point(x: -1, y: -6), point(x: 0, y: -6), point(x: 1, y: -6), point(x: 2, y: -6), point(x: 3, y: -6), point(x: 4, y: -6), point(x: 5, y: -6), point(x: 6,y: -6), point(x: 7, y: -6), point(x: 8, y: -6), point(x: 9, y: -6), point(x: 10, y: -6), point(x: 11, y: -6), point(x: 12, y: -6),
      point(x: -12, y: -5), point(x: -11, y: -5), point(x: -10, y: -5), point(x: -9, y: -5), point(x: -8, y: -5), point(x: -7, y: -5), point(x: -6, y: -5), point(x: -5, y: -5), point(x: -4, y: -5), point(x: -3, y: -5), point(x: -2, y: -5), point(x: -1, y: -5), point(x: 0, y: -5), point(x: 1, y: -5), point(x: 2, y: -5), point(x: 3, y: -5), point(x: 4, y: -5), point(x: 5, y: -5), point(x: 6,y: -5), point(x: 7, y: -5), point(x: 8, y: -5), point(x: 9, y: -5), point(x: 10, y: -5), point(x: 11, y: -5), point(x: 12, y: -5),
      point(x: -12, y: -4), point(x: -11, y: -4), point(x: -10, y: -4), point(x: -9, y: -4), point(x: -8, y: -4), point(x: -7, y: -4), point(x: -6, y: -4), point(x: -5, y: -4), point(x: -4, y: -4), point(x: -3, y: -4), point(x: -2, y: -4), point(x: -1, y: -4), point(x: 0, y: -4), point(x: 1, y: -4), point(x: 2, y: -4), point(x: 3, y: -4), point(x: 4, y: -4), point(x: 5, y: -4), point(x: 6,y: -4), point(x: 7, y: -4), point(x: 8, y: -4), point(x: 9, y: -4), point(x: 10, y: -4), point(x: 11, y: -4), point(x: 12, y: -4),
      point(x: -12, y: -3), point(x: -11, y: -3), point(x: -10, y: -3), point(x: -9, y: -3), point(x: -8, y: -3), point(x: -7, y: -3), point(x: -6, y: -3), point(x: -5, y: -3), point(x: -4, y: -3), point(x: -3, y: -3), point(x: -2, y: -3), point(x: -1, y: -3), point(x: 0, y: -3), point(x: 1, y: -3), point(x: 2, y: -3), point(x: 3, y: -3), point(x: 4, y: -3), point(x: 5, y: -3), point(x: 6,y: -3), point(x: 7, y: -3), point(x: 8, y: -3), point(x: 9, y: -3), point(x: 10, y: -3), point(x: 11, y: -3), point(x: 12, y: -3),
      point(x: -12, y: -2), point(x: -11, y: -2), point(x: -10, y: -2), point(x: -9, y: -2), point(x: -8, y: -2), point(x: -7, y: -2), point(x: -6, y: -2), point(x: -5, y: -2), point(x: -4, y: -2), point(x: -3, y: -2), point(x: -2, y: -2), point(x: -1, y: -2), point(x: 0, y: -2), point(x: 1, y: -2), point(x: 2, y: -2), point(x: 3, y: -2), point(x: 4, y: -2), point(x: 5, y: -2), point(x: 6,y: -2), point(x: 7, y: -2), point(x: 8, y: -2), point(x: 9, y: -2), point(x: 10, y: -2), point(x: 11, y: -2), point(x: 12, y: -2),
      point(x: -12, y: -1), point(x: -11, y: -1), point(x: -10, y: -1), point(x: -9, y: -1), point(x: -8, y: -1), point(x: -7, y: -1), point(x: -6, y: -1), point(x: -5, y: -1), point(x: -4, y: -1), point(x: -3, y: -1), point(x: -2, y: -1), point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1), point(x: 2, y: -1), point(x: 3, y: -1), point(x: 4, y: -1), point(x: 5, y: -1), point(x: 6,y: -1), point(x: 7, y: -1), point(x: 8, y: -1), point(x: 9, y: -1), point(x: 10, y: -1), point(x: 11, y: -1), point(x: 12, y: -1),
      point(x: -12, y: 0), point(x: -11, y: 0), point(x: -10, y: 0), point(x: -9, y: 0), point(x: -8, y: 0), point(x: -7, y: 0), point(x: -6, y: 0), point(x: -5, y: 0), point(x: -4, y: 0), point(x: -3, y: 0), point(x: -2, y: 0), point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0), point(x: 2, y: 0), point(x: 3, y: 0), point(x: 4, y: 0), point(x: 5, y: 0), point(x: 6,y: 0), point(x: 7, y: 0), point(x: 8, y: 0), point(x: 9, y: 0), point(x: 10, y: 0), point(x: 11, y: 0), point(x: 12, y: 0),
      point(x: -12, y: 1), point(x: -11, y: 1), point(x: -10, y: 1), point(x: -9, y: 1), point(x: -8, y: 1), point(x: -7, y: 1), point(x: -6, y: 1), point(x: -5, y: 1), point(x: -4, y: 1), point(x: -3, y: 1), point(x: -2, y: 1), point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1), point(x: 2, y: 1), point(x: 3, y: 1), point(x: 4, y: 1), point(x: 5, y: 1), point(x: 6,y: 1), point(x: 7, y: 1), point(x: 8, y: 1), point(x: 9, y: 1), point(x: 10, y: 1), point(x: 11, y: 1), point(x: 12, y: 1),
      point(x: -12, y: 2), point(x: -11, y: 2), point(x: -10, y: 2), point(x: -9, y: 2), point(x: -8, y: 2), point(x: -7, y: 2), point(x: -6, y: 2), point(x: -5, y: 2), point(x: -4, y: 2), point(x: -3, y: 2), point(x: -2, y: 2), point(x: -1, y: 2), point(x: 0, y: 2), point(x: 1, y: 2), point(x: 2, y: 2), point(x: 3, y: 2), point(x: 4, y: 2), point(x: 5, y: 2), point(x: 6,y: 2), point(x: 7, y: 2), point(x: 8, y: 2), point(x: 9, y: 2), point(x: 10, y: 2), point(x: 11, y: 2), point(x: 12, y: 2),
      point(x: -12, y: 3), point(x: -11, y: 3), point(x: -10, y: 3), point(x: -9, y: 3), point(x: -8, y: 3), point(x: -7, y: 3), point(x: -6, y: 3), point(x: -5, y: 3), point(x: -4, y: 3), point(x: -3, y: 3), point(x: -2, y: 3), point(x: -1, y: 3), point(x: 0, y: 3), point(x: 1, y: 3), point(x: 2, y: 3), point(x: 3, y: 3), point(x: 4, y: 3), point(x: 5, y: 3), point(x: 6,y: 3), point(x: 7, y: 3), point(x: 8, y: 3), point(x: 9, y: 3), point(x: 10, y: 3), point(x: 11, y: 3), point(x: 12, y: 3),
      point(x: -12, y: 4), point(x: -11, y: 4), point(x: -10, y: 4), point(x: -9, y: 4), point(x: -8, y: 4), point(x: -7, y: 4), point(x: -6, y: 4), point(x: -5, y: 4), point(x: -4, y: 4), point(x: -3, y: 4), point(x: -2, y: 4), point(x: -1, y: 4), point(x: 0, y: 4), point(x: 1, y: 4), point(x: 2, y: 4), point(x: 3, y: 4), point(x: 4, y: 4), point(x: 5, y: 4), point(x: 6,y: 4), point(x: 7, y: 4), point(x: 8, y: 4), point(x: 9, y: 4), point(x: 10, y: 4), point(x: 11, y: 4), point(x: 12, y: 4),
      point(x: -12, y: 5), point(x: -11, y: 5), point(x: -10, y: 5), point(x: -9, y: 5), point(x: -8, y: 5), point(x: -7, y: 5), point(x: -6, y: 5), point(x: -5, y: 5), point(x: -4, y: 5), point(x: -3, y: 5), point(x: -2, y: 5), point(x: -1, y: 5), point(x: 0, y: 5), point(x: 1, y: 5), point(x: 2, y: 5), point(x: 3, y: 5), point(x: 4, y: 5), point(x: 5, y: 5), point(x: 6,y: 5), point(x: 7, y: 5), point(x: 8, y: 5), point(x: 9, y: 5), point(x: 10, y: 5), point(x: 11, y: 5), point(x: 12, y: 5),
      point(x: -12, y: 6), point(x: -11, y: 6), point(x: -10, y: 6), point(x: -9, y: 6), point(x: -8, y: 6), point(x: -7, y: 6), point(x: -6, y: 6), point(x: -5, y: 6), point(x: -4, y: 6), point(x: -3, y: 6), point(x: -2, y: 6), point(x: -1, y: 6), point(x: 0, y: 6), point(x: 1, y: 6), point(x: 2, y: 6), point(x: 3, y: 6), point(x: 4, y: 6), point(x: 5, y: 6), point(x: 6,y: 6), point(x: 7, y: 6), point(x: 8, y: 6), point(x: 9, y: 6), point(x: 10, y: 6), point(x: 11, y: 6), point(x: 12, y: 6),
      point(x: -12, y: 7), point(x: -11, y: 7), point(x: -10, y: 7), point(x: -9, y: 7), point(x: -8, y: 7), point(x: -7, y: 7), point(x: -6, y: 7), point(x: -5, y: 7), point(x: -4, y: 7), point(x: -3, y: 7), point(x: -2, y: 7), point(x: -1, y: 7), point(x: 0, y: 7), point(x: 1, y: 7), point(x: 2, y: 7), point(x: 3, y: 7), point(x: 4, y: 7), point(x: 5, y: 7), point(x: 6,y: 7), point(x: 7, y: 7), point(x: 8, y: 7), point(x: 9, y: 7), point(x: 10, y: 7), point(x: 11, y: 7), point(x: 12, y: 7),
    ],
    input_pins: @[
      prototype_pin(position: point(x: -13, y: -7), kind: wk_8),
      prototype_pin(position: point(x: -13, y: -6)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 13, y: -7), kind: wk_64, tri_state: true),
    ],
    reset: proc(node: var node, memory_store: var openArray[uint64]) =
      node.node_set_memory(memory_store, 256, 0.uint64)
    ,
    memory: 257,
    category: @[CAT_IO],
  ),

  VirtualHdd: prototype(
    input_pins: @[
      prototype_pin(position: point(x: -13, y: -5)),
      prototype_pin(position: point(x: -13, y: -4), kind: wk_64),
    ],
  ),

  Rom: prototype(
    sandbox: true,
    menu_order: 8.uint8,
    default_setting_1: 256,
    has_virtual: true,
    area: @[
      point(x: -12, y: -8), point(x: -11, y: -8), point(x: -10, y: -8), point(x: -9, y: -8), point(x: -8, y: -8), point(x: -7, y: -8), point(x: -6, y: -8), point(x: -5, y: -8), point(x: -4, y: -8), point(x: -3, y: -8), point(x: -2, y: -8), point(x: -1, y: -8), point(x: 0, y: -8), point(x: 1, y: -8), point(x: 2, y: -8), point(x: 3, y: -8), point(x: 4, y: -8), point(x: 5, y: -8), point(x: 6,y: -8), point(x: 7, y: -8), point(x: 8, y: -8), point(x: 9, y: -8), point(x: 10, y: -8), point(x: 11, y: -8), point(x: 12, y: -8),
      point(x: -12, y: -7), point(x: -11, y: -7), point(x: -10, y: -7), point(x: -9, y: -7), point(x: -8, y: -7), point(x: -7, y: -7), point(x: -6, y: -7), point(x: -5, y: -7), point(x: -4, y: -7), point(x: -3, y: -7), point(x: -2, y: -7), point(x: -1, y: -7), point(x: 0, y: -7), point(x: 1, y: -7), point(x: 2, y: -7), point(x: 3, y: -7), point(x: 4, y: -7), point(x: 5, y: -7), point(x: 6,y: -7), point(x: 7, y: -7), point(x: 8, y: -7), point(x: 9, y: -7), point(x: 10, y: -7), point(x: 11, y: -7), point(x: 12, y: -7),
      point(x: -12, y: -6), point(x: -11, y: -6), point(x: -10, y: -6), point(x: -9, y: -6), point(x: -8, y: -6), point(x: -7, y: -6), point(x: -6, y: -6), point(x: -5, y: -6), point(x: -4, y: -6), point(x: -3, y: -6), point(x: -2, y: -6), point(x: -1, y: -6), point(x: 0, y: -6), point(x: 1, y: -6), point(x: 2, y: -6), point(x: 3, y: -6), point(x: 4, y: -6), point(x: 5, y: -6), point(x: 6,y: -6), point(x: 7, y: -6), point(x: 8, y: -6), point(x: 9, y: -6), point(x: 10, y: -6), point(x: 11, y: -6), point(x: 12, y: -6),
      point(x: -12, y: -5), point(x: -11, y: -5), point(x: -10, y: -5), point(x: -9, y: -5), point(x: -8, y: -5), point(x: -7, y: -5), point(x: -6, y: -5), point(x: -5, y: -5), point(x: -4, y: -5), point(x: -3, y: -5), point(x: -2, y: -5), point(x: -1, y: -5), point(x: 0, y: -5), point(x: 1, y: -5), point(x: 2, y: -5), point(x: 3, y: -5), point(x: 4, y: -5), point(x: 5, y: -5), point(x: 6,y: -5), point(x: 7, y: -5), point(x: 8, y: -5), point(x: 9, y: -5), point(x: 10, y: -5), point(x: 11, y: -5), point(x: 12, y: -5),
      point(x: -12, y: -4), point(x: -11, y: -4), point(x: -10, y: -4), point(x: -9, y: -4), point(x: -8, y: -4), point(x: -7, y: -4), point(x: -6, y: -4), point(x: -5, y: -4), point(x: -4, y: -4), point(x: -3, y: -4), point(x: -2, y: -4), point(x: -1, y: -4), point(x: 0, y: -4), point(x: 1, y: -4), point(x: 2, y: -4), point(x: 3, y: -4), point(x: 4, y: -4), point(x: 5, y: -4), point(x: 6,y: -4), point(x: 7, y: -4), point(x: 8, y: -4), point(x: 9, y: -4), point(x: 10, y: -4), point(x: 11, y: -4), point(x: 12, y: -4),
      point(x: -12, y: -3), point(x: -11, y: -3), point(x: -10, y: -3), point(x: -9, y: -3), point(x: -8, y: -3), point(x: -7, y: -3), point(x: -6, y: -3), point(x: -5, y: -3), point(x: -4, y: -3), point(x: -3, y: -3), point(x: -2, y: -3), point(x: -1, y: -3), point(x: 0, y: -3), point(x: 1, y: -3), point(x: 2, y: -3), point(x: 3, y: -3), point(x: 4, y: -3), point(x: 5, y: -3), point(x: 6,y: -3), point(x: 7, y: -3), point(x: 8, y: -3), point(x: 9, y: -3), point(x: 10, y: -3), point(x: 11, y: -3), point(x: 12, y: -3),
      point(x: -12, y: -2), point(x: -11, y: -2), point(x: -10, y: -2), point(x: -9, y: -2), point(x: -8, y: -2), point(x: -7, y: -2), point(x: -6, y: -2), point(x: -5, y: -2), point(x: -4, y: -2), point(x: -3, y: -2), point(x: -2, y: -2), point(x: -1, y: -2), point(x: 0, y: -2), point(x: 1, y: -2), point(x: 2, y: -2), point(x: 3, y: -2), point(x: 4, y: -2), point(x: 5, y: -2), point(x: 6,y: -2), point(x: 7, y: -2), point(x: 8, y: -2), point(x: 9, y: -2), point(x: 10, y: -2), point(x: 11, y: -2), point(x: 12, y: -2),
      point(x: -12, y: -1), point(x: -11, y: -1), point(x: -10, y: -1), point(x: -9, y: -1), point(x: -8, y: -1), point(x: -7, y: -1), point(x: -6, y: -1), point(x: -5, y: -1), point(x: -4, y: -1), point(x: -3, y: -1), point(x: -2, y: -1), point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1), point(x: 2, y: -1), point(x: 3, y: -1), point(x: 4, y: -1), point(x: 5, y: -1), point(x: 6,y: -1), point(x: 7, y: -1), point(x: 8, y: -1), point(x: 9, y: -1), point(x: 10, y: -1), point(x: 11, y: -1), point(x: 12, y: -1),
      point(x: -12, y: 0), point(x: -11, y: 0), point(x: -10, y: 0), point(x: -9, y: 0), point(x: -8, y: 0), point(x: -7, y: 0), point(x: -6, y: 0), point(x: -5, y: 0), point(x: -4, y: 0), point(x: -3, y: 0), point(x: -2, y: 0), point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0), point(x: 2, y: 0), point(x: 3, y: 0), point(x: 4, y: 0), point(x: 5, y: 0), point(x: 6,y: 0), point(x: 7, y: 0), point(x: 8, y: 0), point(x: 9, y: 0), point(x: 10, y: 0), point(x: 11, y: 0), point(x: 12, y: 0),
      point(x: -12, y: 1), point(x: -11, y: 1), point(x: -10, y: 1), point(x: -9, y: 1), point(x: -8, y: 1), point(x: -7, y: 1), point(x: -6, y: 1), point(x: -5, y: 1), point(x: -4, y: 1), point(x: -3, y: 1), point(x: -2, y: 1), point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1), point(x: 2, y: 1), point(x: 3, y: 1), point(x: 4, y: 1), point(x: 5, y: 1), point(x: 6,y: 1), point(x: 7, y: 1), point(x: 8, y: 1), point(x: 9, y: 1), point(x: 10, y: 1), point(x: 11, y: 1), point(x: 12, y: 1),
      point(x: -12, y: 2), point(x: -11, y: 2), point(x: -10, y: 2), point(x: -9, y: 2), point(x: -8, y: 2), point(x: -7, y: 2), point(x: -6, y: 2), point(x: -5, y: 2), point(x: -4, y: 2), point(x: -3, y: 2), point(x: -2, y: 2), point(x: -1, y: 2), point(x: 0, y: 2), point(x: 1, y: 2), point(x: 2, y: 2), point(x: 3, y: 2), point(x: 4, y: 2), point(x: 5, y: 2), point(x: 6,y: 2), point(x: 7, y: 2), point(x: 8, y: 2), point(x: 9, y: 2), point(x: 10, y: 2), point(x: 11, y: 2), point(x: 12, y: 2),
      point(x: -12, y: 3), point(x: -11, y: 3), point(x: -10, y: 3), point(x: -9, y: 3), point(x: -8, y: 3), point(x: -7, y: 3), point(x: -6, y: 3), point(x: -5, y: 3), point(x: -4, y: 3), point(x: -3, y: 3), point(x: -2, y: 3), point(x: -1, y: 3), point(x: 0, y: 3), point(x: 1, y: 3), point(x: 2, y: 3), point(x: 3, y: 3), point(x: 4, y: 3), point(x: 5, y: 3), point(x: 6,y: 3), point(x: 7, y: 3), point(x: 8, y: 3), point(x: 9, y: 3), point(x: 10, y: 3), point(x: 11, y: 3), point(x: 12, y: 3),
      point(x: -12, y: 4), point(x: -11, y: 4), point(x: -10, y: 4), point(x: -9, y: 4), point(x: -8, y: 4), point(x: -7, y: 4), point(x: -6, y: 4), point(x: -5, y: 4), point(x: -4, y: 4), point(x: -3, y: 4), point(x: -2, y: 4), point(x: -1, y: 4), point(x: 0, y: 4), point(x: 1, y: 4), point(x: 2, y: 4), point(x: 3, y: 4), point(x: 4, y: 4), point(x: 5, y: 4), point(x: 6,y: 4), point(x: 7, y: 4), point(x: 8, y: 4), point(x: 9, y: 4), point(x: 10, y: 4), point(x: 11, y: 4), point(x: 12, y: 4),
      point(x: -12, y: 5), point(x: -11, y: 5), point(x: -10, y: 5), point(x: -9, y: 5), point(x: -8, y: 5), point(x: -7, y: 5), point(x: -6, y: 5), point(x: -5, y: 5), point(x: -4, y: 5), point(x: -3, y: 5), point(x: -2, y: 5), point(x: -1, y: 5), point(x: 0, y: 5), point(x: 1, y: 5), point(x: 2, y: 5), point(x: 3, y: 5), point(x: 4, y: 5), point(x: 5, y: 5), point(x: 6,y: 5), point(x: 7, y: 5), point(x: 8, y: 5), point(x: 9, y: 5), point(x: 10, y: 5), point(x: 11, y: 5), point(x: 12, y: 5),
      point(x: -12, y: 6), point(x: -11, y: 6), point(x: -10, y: 6), point(x: -9, y: 6), point(x: -8, y: 6), point(x: -7, y: 6), point(x: -6, y: 6), point(x: -5, y: 6), point(x: -4, y: 6), point(x: -3, y: 6), point(x: -2, y: 6), point(x: -1, y: 6), point(x: 0, y: 6), point(x: 1, y: 6), point(x: 2, y: 6), point(x: 3, y: 6), point(x: 4, y: 6), point(x: 5, y: 6), point(x: 6,y: 6), point(x: 7, y: 6), point(x: 8, y: 6), point(x: 9, y: 6), point(x: 10, y: 6), point(x: 11, y: 6), point(x: 12, y: 6),
      point(x: -12, y: 7), point(x: -11, y: 7), point(x: -10, y: 7), point(x: -9, y: 7), point(x: -8, y: 7), point(x: -7, y: 7), point(x: -6, y: 7), point(x: -5, y: 7), point(x: -4, y: 7), point(x: -3, y: 7), point(x: -2, y: 7), point(x: -1, y: 7), point(x: 0, y: 7), point(x: 1, y: 7), point(x: 2, y: 7), point(x: 3, y: 7), point(x: 4, y: 7), point(x: 5, y: 7), point(x: 6,y: 7), point(x: 7, y: 7), point(x: 8, y: 7), point(x: 9, y: 7), point(x: 10, y: 7), point(x: 11, y: 7), point(x: 12, y: 7),
    ],
    input_pins: @[
      prototype_pin(position: point(x: -13, y: -7)),
      prototype_pin(position: point(x: -13, y: -5), kind: wk_32),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 13, y: -7), kind: wk_64, tri_state: true),
    ],
    memory: 256,
    category: @[CAT_IO, CAT_RAM],
  ),

  VirtualRom: prototype(
    input_pins: @[
      prototype_pin(position: point(x: -13, y: -6)),
      prototype_pin(position: point(x: -13, y: -5), kind: wk_32),
      prototype_pin(position: point(x: -13, y: -4), kind: wk_64),
    ],
  ),

  SolutionRom: prototype(
    menu_order: 8.uint8,
    has_virtual: true,
    area: @[
      point(x: -12, y: -8), point(x: -11, y: -8), point(x: -10, y: -8), point(x: -9, y: -8), point(x: -8, y: -8), point(x: -7, y: -8), point(x: -6, y: -8), point(x: -5, y: -8), point(x: -4, y: -8), point(x: -3, y: -8), point(x: -2, y: -8), point(x: -1, y: -8), point(x: 0, y: -8), point(x: 1, y: -8), point(x: 2, y: -8), point(x: 3, y: -8), point(x: 4, y: -8), point(x: 5, y: -8), point(x: 6,y: -8), point(x: 7, y: -8), point(x: 8, y: -8), point(x: 9, y: -8), point(x: 10, y: -8), point(x: 11, y: -8), point(x: 12, y: -8),
      point(x: -12, y: -7), point(x: -11, y: -7), point(x: -10, y: -7), point(x: -9, y: -7), point(x: -8, y: -7), point(x: -7, y: -7), point(x: -6, y: -7), point(x: -5, y: -7), point(x: -4, y: -7), point(x: -3, y: -7), point(x: -2, y: -7), point(x: -1, y: -7), point(x: 0, y: -7), point(x: 1, y: -7), point(x: 2, y: -7), point(x: 3, y: -7), point(x: 4, y: -7), point(x: 5, y: -7), point(x: 6,y: -7), point(x: 7, y: -7), point(x: 8, y: -7), point(x: 9, y: -7), point(x: 10, y: -7), point(x: 11, y: -7), point(x: 12, y: -7),
      point(x: -12, y: -6), point(x: -11, y: -6), point(x: -10, y: -6), point(x: -9, y: -6), point(x: -8, y: -6), point(x: -7, y: -6), point(x: -6, y: -6), point(x: -5, y: -6), point(x: -4, y: -6), point(x: -3, y: -6), point(x: -2, y: -6), point(x: -1, y: -6), point(x: 0, y: -6), point(x: 1, y: -6), point(x: 2, y: -6), point(x: 3, y: -6), point(x: 4, y: -6), point(x: 5, y: -6), point(x: 6,y: -6), point(x: 7, y: -6), point(x: 8, y: -6), point(x: 9, y: -6), point(x: 10, y: -6), point(x: 11, y: -6), point(x: 12, y: -6),
      point(x: -12, y: -5), point(x: -11, y: -5), point(x: -10, y: -5), point(x: -9, y: -5), point(x: -8, y: -5), point(x: -7, y: -5), point(x: -6, y: -5), point(x: -5, y: -5), point(x: -4, y: -5), point(x: -3, y: -5), point(x: -2, y: -5), point(x: -1, y: -5), point(x: 0, y: -5), point(x: 1, y: -5), point(x: 2, y: -5), point(x: 3, y: -5), point(x: 4, y: -5), point(x: 5, y: -5), point(x: 6,y: -5), point(x: 7, y: -5), point(x: 8, y: -5), point(x: 9, y: -5), point(x: 10, y: -5), point(x: 11, y: -5), point(x: 12, y: -5),
      point(x: -12, y: -4), point(x: -11, y: -4), point(x: -10, y: -4), point(x: -9, y: -4), point(x: -8, y: -4), point(x: -7, y: -4), point(x: -6, y: -4), point(x: -5, y: -4), point(x: -4, y: -4), point(x: -3, y: -4), point(x: -2, y: -4), point(x: -1, y: -4), point(x: 0, y: -4), point(x: 1, y: -4), point(x: 2, y: -4), point(x: 3, y: -4), point(x: 4, y: -4), point(x: 5, y: -4), point(x: 6,y: -4), point(x: 7, y: -4), point(x: 8, y: -4), point(x: 9, y: -4), point(x: 10, y: -4), point(x: 11, y: -4), point(x: 12, y: -4),
      point(x: -12, y: -3), point(x: -11, y: -3), point(x: -10, y: -3), point(x: -9, y: -3), point(x: -8, y: -3), point(x: -7, y: -3), point(x: -6, y: -3), point(x: -5, y: -3), point(x: -4, y: -3), point(x: -3, y: -3), point(x: -2, y: -3), point(x: -1, y: -3), point(x: 0, y: -3), point(x: 1, y: -3), point(x: 2, y: -3), point(x: 3, y: -3), point(x: 4, y: -3), point(x: 5, y: -3), point(x: 6,y: -3), point(x: 7, y: -3), point(x: 8, y: -3), point(x: 9, y: -3), point(x: 10, y: -3), point(x: 11, y: -3), point(x: 12, y: -3),
      point(x: -12, y: -2), point(x: -11, y: -2), point(x: -10, y: -2), point(x: -9, y: -2), point(x: -8, y: -2), point(x: -7, y: -2), point(x: -6, y: -2), point(x: -5, y: -2), point(x: -4, y: -2), point(x: -3, y: -2), point(x: -2, y: -2), point(x: -1, y: -2), point(x: 0, y: -2), point(x: 1, y: -2), point(x: 2, y: -2), point(x: 3, y: -2), point(x: 4, y: -2), point(x: 5, y: -2), point(x: 6,y: -2), point(x: 7, y: -2), point(x: 8, y: -2), point(x: 9, y: -2), point(x: 10, y: -2), point(x: 11, y: -2), point(x: 12, y: -2),
      point(x: -12, y: -1), point(x: -11, y: -1), point(x: -10, y: -1), point(x: -9, y: -1), point(x: -8, y: -1), point(x: -7, y: -1), point(x: -6, y: -1), point(x: -5, y: -1), point(x: -4, y: -1), point(x: -3, y: -1), point(x: -2, y: -1), point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1), point(x: 2, y: -1), point(x: 3, y: -1), point(x: 4, y: -1), point(x: 5, y: -1), point(x: 6,y: -1), point(x: 7, y: -1), point(x: 8, y: -1), point(x: 9, y: -1), point(x: 10, y: -1), point(x: 11, y: -1), point(x: 12, y: -1),
      point(x: -12, y: 0), point(x: -11, y: 0), point(x: -10, y: 0), point(x: -9, y: 0), point(x: -8, y: 0), point(x: -7, y: 0), point(x: -6, y: 0), point(x: -5, y: 0), point(x: -4, y: 0), point(x: -3, y: 0), point(x: -2, y: 0), point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0), point(x: 2, y: 0), point(x: 3, y: 0), point(x: 4, y: 0), point(x: 5, y: 0), point(x: 6,y: 0), point(x: 7, y: 0), point(x: 8, y: 0), point(x: 9, y: 0), point(x: 10, y: 0), point(x: 11, y: 0), point(x: 12, y: 0),
      point(x: -12, y: 1), point(x: -11, y: 1), point(x: -10, y: 1), point(x: -9, y: 1), point(x: -8, y: 1), point(x: -7, y: 1), point(x: -6, y: 1), point(x: -5, y: 1), point(x: -4, y: 1), point(x: -3, y: 1), point(x: -2, y: 1), point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1), point(x: 2, y: 1), point(x: 3, y: 1), point(x: 4, y: 1), point(x: 5, y: 1), point(x: 6,y: 1), point(x: 7, y: 1), point(x: 8, y: 1), point(x: 9, y: 1), point(x: 10, y: 1), point(x: 11, y: 1), point(x: 12, y: 1),
      point(x: -12, y: 2), point(x: -11, y: 2), point(x: -10, y: 2), point(x: -9, y: 2), point(x: -8, y: 2), point(x: -7, y: 2), point(x: -6, y: 2), point(x: -5, y: 2), point(x: -4, y: 2), point(x: -3, y: 2), point(x: -2, y: 2), point(x: -1, y: 2), point(x: 0, y: 2), point(x: 1, y: 2), point(x: 2, y: 2), point(x: 3, y: 2), point(x: 4, y: 2), point(x: 5, y: 2), point(x: 6,y: 2), point(x: 7, y: 2), point(x: 8, y: 2), point(x: 9, y: 2), point(x: 10, y: 2), point(x: 11, y: 2), point(x: 12, y: 2),
      point(x: -12, y: 3), point(x: -11, y: 3), point(x: -10, y: 3), point(x: -9, y: 3), point(x: -8, y: 3), point(x: -7, y: 3), point(x: -6, y: 3), point(x: -5, y: 3), point(x: -4, y: 3), point(x: -3, y: 3), point(x: -2, y: 3), point(x: -1, y: 3), point(x: 0, y: 3), point(x: 1, y: 3), point(x: 2, y: 3), point(x: 3, y: 3), point(x: 4, y: 3), point(x: 5, y: 3), point(x: 6,y: 3), point(x: 7, y: 3), point(x: 8, y: 3), point(x: 9, y: 3), point(x: 10, y: 3), point(x: 11, y: 3), point(x: 12, y: 3),
      point(x: -12, y: 4), point(x: -11, y: 4), point(x: -10, y: 4), point(x: -9, y: 4), point(x: -8, y: 4), point(x: -7, y: 4), point(x: -6, y: 4), point(x: -5, y: 4), point(x: -4, y: 4), point(x: -3, y: 4), point(x: -2, y: 4), point(x: -1, y: 4), point(x: 0, y: 4), point(x: 1, y: 4), point(x: 2, y: 4), point(x: 3, y: 4), point(x: 4, y: 4), point(x: 5, y: 4), point(x: 6,y: 4), point(x: 7, y: 4), point(x: 8, y: 4), point(x: 9, y: 4), point(x: 10, y: 4), point(x: 11, y: 4), point(x: 12, y: 4),
      point(x: -12, y: 5), point(x: -11, y: 5), point(x: -10, y: 5), point(x: -9, y: 5), point(x: -8, y: 5), point(x: -7, y: 5), point(x: -6, y: 5), point(x: -5, y: 5), point(x: -4, y: 5), point(x: -3, y: 5), point(x: -2, y: 5), point(x: -1, y: 5), point(x: 0, y: 5), point(x: 1, y: 5), point(x: 2, y: 5), point(x: 3, y: 5), point(x: 4, y: 5), point(x: 5, y: 5), point(x: 6,y: 5), point(x: 7, y: 5), point(x: 8, y: 5), point(x: 9, y: 5), point(x: 10, y: 5), point(x: 11, y: 5), point(x: 12, y: 5),
      point(x: -12, y: 6), point(x: -11, y: 6), point(x: -10, y: 6), point(x: -9, y: 6), point(x: -8, y: 6), point(x: -7, y: 6), point(x: -6, y: 6), point(x: -5, y: 6), point(x: -4, y: 6), point(x: -3, y: 6), point(x: -2, y: 6), point(x: -1, y: 6), point(x: 0, y: 6), point(x: 1, y: 6), point(x: 2, y: 6), point(x: 3, y: 6), point(x: 4, y: 6), point(x: 5, y: 6), point(x: 6,y: 6), point(x: 7, y: 6), point(x: 8, y: 6), point(x: 9, y: 6), point(x: 10, y: 6), point(x: 11, y: 6), point(x: 12, y: 6),
      point(x: -12, y: 7), point(x: -11, y: 7), point(x: -10, y: 7), point(x: -9, y: 7), point(x: -8, y: 7), point(x: -7, y: 7), point(x: -6, y: 7), point(x: -5, y: 7), point(x: -4, y: 7), point(x: -3, y: 7), point(x: -2, y: 7), point(x: -1, y: 7), point(x: 0, y: 7), point(x: 1, y: 7), point(x: 2, y: 7), point(x: 3, y: 7), point(x: 4, y: 7), point(x: 5, y: 7), point(x: 6,y: 7), point(x: 7, y: 7), point(x: 8, y: 7), point(x: 9, y: 7), point(x: 10, y: 7), point(x: 11, y: 7), point(x: 12, y: 7),
    ],
    input_pins: @[
      prototype_pin(position: point(x: -13, y: -7)),
      prototype_pin(position: point(x: -13, y: -5), kind: wk_32),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 13, y: -7), kind: wk_64, tri_state: true),
    ],
    memory: 256,
    category: @[CAT_IO, CAT_RAM],
  ),

  VirtualSolutionRom: prototype(
    input_pins: @[
      prototype_pin(position: point(x: -13, y: -6)),
      prototype_pin(position: point(x: -13, y: -5), kind: wk_32),
      prototype_pin(position: point(x: -13, y: -4), kind: wk_64),
    ],
  ),

  RamFast: prototype(
    sandbox: true,
    dyn_mem_reset_on_level_reset: true,
    menu_order: 8.uint8,
    area: @[
      point(x: -12, y: -8), point(x: -11, y: -8), point(x: -10, y: -8), point(x: -9, y: -8), point(x: -8, y: -8), point(x: -7, y: -8), point(x: -6, y: -8), point(x: -5, y: -8), point(x: -4, y: -8), point(x: -3, y: -8), point(x: -2, y: -8), point(x: -1, y: -8), point(x: 0, y: -8), point(x: 1, y: -8), point(x: 2, y: -8), point(x: 3, y: -8), point(x: 4, y: -8), point(x: 5, y: -8), point(x: 6,y: -8), point(x: 7, y: -8), point(x: 8, y: -8), point(x: 9, y: -8), point(x: 10, y: -8), point(x: 11, y: -8), point(x: 12, y: -8),
      point(x: -12, y: -7), point(x: -11, y: -7), point(x: -10, y: -7), point(x: -9, y: -7), point(x: -8, y: -7), point(x: -7, y: -7), point(x: -6, y: -7), point(x: -5, y: -7), point(x: -4, y: -7), point(x: -3, y: -7), point(x: -2, y: -7), point(x: -1, y: -7), point(x: 0, y: -7), point(x: 1, y: -7), point(x: 2, y: -7), point(x: 3, y: -7), point(x: 4, y: -7), point(x: 5, y: -7), point(x: 6,y: -7), point(x: 7, y: -7), point(x: 8, y: -7), point(x: 9, y: -7), point(x: 10, y: -7), point(x: 11, y: -7), point(x: 12, y: -7),
      point(x: -12, y: -6), point(x: -11, y: -6), point(x: -10, y: -6), point(x: -9, y: -6), point(x: -8, y: -6), point(x: -7, y: -6), point(x: -6, y: -6), point(x: -5, y: -6), point(x: -4, y: -6), point(x: -3, y: -6), point(x: -2, y: -6), point(x: -1, y: -6), point(x: 0, y: -6), point(x: 1, y: -6), point(x: 2, y: -6), point(x: 3, y: -6), point(x: 4, y: -6), point(x: 5, y: -6), point(x: 6,y: -6), point(x: 7, y: -6), point(x: 8, y: -6), point(x: 9, y: -6), point(x: 10, y: -6), point(x: 11, y: -6), point(x: 12, y: -6),
      point(x: -12, y: -5), point(x: -11, y: -5), point(x: -10, y: -5), point(x: -9, y: -5), point(x: -8, y: -5), point(x: -7, y: -5), point(x: -6, y: -5), point(x: -5, y: -5), point(x: -4, y: -5), point(x: -3, y: -5), point(x: -2, y: -5), point(x: -1, y: -5), point(x: 0, y: -5), point(x: 1, y: -5), point(x: 2, y: -5), point(x: 3, y: -5), point(x: 4, y: -5), point(x: 5, y: -5), point(x: 6,y: -5), point(x: 7, y: -5), point(x: 8, y: -5), point(x: 9, y: -5), point(x: 10, y: -5), point(x: 11, y: -5), point(x: 12, y: -5),
      point(x: -12, y: -4), point(x: -11, y: -4), point(x: -10, y: -4), point(x: -9, y: -4), point(x: -8, y: -4), point(x: -7, y: -4), point(x: -6, y: -4), point(x: -5, y: -4), point(x: -4, y: -4), point(x: -3, y: -4), point(x: -2, y: -4), point(x: -1, y: -4), point(x: 0, y: -4), point(x: 1, y: -4), point(x: 2, y: -4), point(x: 3, y: -4), point(x: 4, y: -4), point(x: 5, y: -4), point(x: 6,y: -4), point(x: 7, y: -4), point(x: 8, y: -4), point(x: 9, y: -4), point(x: 10, y: -4), point(x: 11, y: -4), point(x: 12, y: -4),
      point(x: -12, y: -3), point(x: -11, y: -3), point(x: -10, y: -3), point(x: -9, y: -3), point(x: -8, y: -3), point(x: -7, y: -3), point(x: -6, y: -3), point(x: -5, y: -3), point(x: -4, y: -3), point(x: -3, y: -3), point(x: -2, y: -3), point(x: -1, y: -3), point(x: 0, y: -3), point(x: 1, y: -3), point(x: 2, y: -3), point(x: 3, y: -3), point(x: 4, y: -3), point(x: 5, y: -3), point(x: 6,y: -3), point(x: 7, y: -3), point(x: 8, y: -3), point(x: 9, y: -3), point(x: 10, y: -3), point(x: 11, y: -3), point(x: 12, y: -3),
      point(x: -12, y: -2), point(x: -11, y: -2), point(x: -10, y: -2), point(x: -9, y: -2), point(x: -8, y: -2), point(x: -7, y: -2), point(x: -6, y: -2), point(x: -5, y: -2), point(x: -4, y: -2), point(x: -3, y: -2), point(x: -2, y: -2), point(x: -1, y: -2), point(x: 0, y: -2), point(x: 1, y: -2), point(x: 2, y: -2), point(x: 3, y: -2), point(x: 4, y: -2), point(x: 5, y: -2), point(x: 6,y: -2), point(x: 7, y: -2), point(x: 8, y: -2), point(x: 9, y: -2), point(x: 10, y: -2), point(x: 11, y: -2), point(x: 12, y: -2),
      point(x: -12, y: -1), point(x: -11, y: -1), point(x: -10, y: -1), point(x: -9, y: -1), point(x: -8, y: -1), point(x: -7, y: -1), point(x: -6, y: -1), point(x: -5, y: -1), point(x: -4, y: -1), point(x: -3, y: -1), point(x: -2, y: -1), point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1), point(x: 2, y: -1), point(x: 3, y: -1), point(x: 4, y: -1), point(x: 5, y: -1), point(x: 6,y: -1), point(x: 7, y: -1), point(x: 8, y: -1), point(x: 9, y: -1), point(x: 10, y: -1), point(x: 11, y: -1), point(x: 12, y: -1),
      point(x: -12, y: 0), point(x: -11, y: 0), point(x: -10, y: 0), point(x: -9, y: 0), point(x: -8, y: 0), point(x: -7, y: 0), point(x: -6, y: 0), point(x: -5, y: 0), point(x: -4, y: 0), point(x: -3, y: 0), point(x: -2, y: 0), point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0), point(x: 2, y: 0), point(x: 3, y: 0), point(x: 4, y: 0), point(x: 5, y: 0), point(x: 6,y: 0), point(x: 7, y: 0), point(x: 8, y: 0), point(x: 9, y: 0), point(x: 10, y: 0), point(x: 11, y: 0), point(x: 12, y: 0),
      point(x: -12, y: 1), point(x: -11, y: 1), point(x: -10, y: 1), point(x: -9, y: 1), point(x: -8, y: 1), point(x: -7, y: 1), point(x: -6, y: 1), point(x: -5, y: 1), point(x: -4, y: 1), point(x: -3, y: 1), point(x: -2, y: 1), point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1), point(x: 2, y: 1), point(x: 3, y: 1), point(x: 4, y: 1), point(x: 5, y: 1), point(x: 6,y: 1), point(x: 7, y: 1), point(x: 8, y: 1), point(x: 9, y: 1), point(x: 10, y: 1), point(x: 11, y: 1), point(x: 12, y: 1),
      point(x: -12, y: 2), point(x: -11, y: 2), point(x: -10, y: 2), point(x: -9, y: 2), point(x: -8, y: 2), point(x: -7, y: 2), point(x: -6, y: 2), point(x: -5, y: 2), point(x: -4, y: 2), point(x: -3, y: 2), point(x: -2, y: 2), point(x: -1, y: 2), point(x: 0, y: 2), point(x: 1, y: 2), point(x: 2, y: 2), point(x: 3, y: 2), point(x: 4, y: 2), point(x: 5, y: 2), point(x: 6,y: 2), point(x: 7, y: 2), point(x: 8, y: 2), point(x: 9, y: 2), point(x: 10, y: 2), point(x: 11, y: 2), point(x: 12, y: 2),
      point(x: -12, y: 3), point(x: -11, y: 3), point(x: -10, y: 3), point(x: -9, y: 3), point(x: -8, y: 3), point(x: -7, y: 3), point(x: -6, y: 3), point(x: -5, y: 3), point(x: -4, y: 3), point(x: -3, y: 3), point(x: -2, y: 3), point(x: -1, y: 3), point(x: 0, y: 3), point(x: 1, y: 3), point(x: 2, y: 3), point(x: 3, y: 3), point(x: 4, y: 3), point(x: 5, y: 3), point(x: 6,y: 3), point(x: 7, y: 3), point(x: 8, y: 3), point(x: 9, y: 3), point(x: 10, y: 3), point(x: 11, y: 3), point(x: 12, y: 3),
      point(x: -12, y: 4), point(x: -11, y: 4), point(x: -10, y: 4), point(x: -9, y: 4), point(x: -8, y: 4), point(x: -7, y: 4), point(x: -6, y: 4), point(x: -5, y: 4), point(x: -4, y: 4), point(x: -3, y: 4), point(x: -2, y: 4), point(x: -1, y: 4), point(x: 0, y: 4), point(x: 1, y: 4), point(x: 2, y: 4), point(x: 3, y: 4), point(x: 4, y: 4), point(x: 5, y: 4), point(x: 6,y: 4), point(x: 7, y: 4), point(x: 8, y: 4), point(x: 9, y: 4), point(x: 10, y: 4), point(x: 11, y: 4), point(x: 12, y: 4),
      point(x: -12, y: 5), point(x: -11, y: 5), point(x: -10, y: 5), point(x: -9, y: 5), point(x: -8, y: 5), point(x: -7, y: 5), point(x: -6, y: 5), point(x: -5, y: 5), point(x: -4, y: 5), point(x: -3, y: 5), point(x: -2, y: 5), point(x: -1, y: 5), point(x: 0, y: 5), point(x: 1, y: 5), point(x: 2, y: 5), point(x: 3, y: 5), point(x: 4, y: 5), point(x: 5, y: 5), point(x: 6,y: 5), point(x: 7, y: 5), point(x: 8, y: 5), point(x: 9, y: 5), point(x: 10, y: 5), point(x: 11, y: 5), point(x: 12, y: 5),
      point(x: -12, y: 6), point(x: -11, y: 6), point(x: -10, y: 6), point(x: -9, y: 6), point(x: -8, y: 6), point(x: -7, y: 6), point(x: -6, y: 6), point(x: -5, y: 6), point(x: -4, y: 6), point(x: -3, y: 6), point(x: -2, y: 6), point(x: -1, y: 6), point(x: 0, y: 6), point(x: 1, y: 6), point(x: 2, y: 6), point(x: 3, y: 6), point(x: 4, y: 6), point(x: 5, y: 6), point(x: 6,y: 6), point(x: 7, y: 6), point(x: 8, y: 6), point(x: 9, y: 6), point(x: 10, y: 6), point(x: 11, y: 6), point(x: 12, y: 6),
      point(x: -12, y: 7), point(x: -11, y: 7), point(x: -10, y: 7), point(x: -9, y: 7), point(x: -8, y: 7), point(x: -7, y: 7), point(x: -6, y: 7), point(x: -5, y: 7), point(x: -4, y: 7), point(x: -3, y: 7), point(x: -2, y: 7), point(x: -1, y: 7), point(x: 0, y: 7), point(x: 1, y: 7), point(x: 2, y: 7), point(x: 3, y: 7), point(x: 4, y: 7), point(x: 5, y: 7), point(x: 6,y: 7), point(x: 7, y: 7), point(x: 8, y: 7), point(x: 9, y: 7), point(x: 10, y: 7), point(x: 11, y: 7), point(x: 12, y: 7),
    ],
    input_pins: @[
      prototype_pin(position: point(x: -13, y: -7)),
      prototype_pin(position: point(x: -13, y: -5), kind: wk_32),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 13, y: -7), kind: wk_64),
      prototype_pin(position: point(x: 13, y: -6), kind: wk_64),
      prototype_pin(position: point(x: 13, y: -5), kind: wk_64),
      prototype_pin(position: point(x: 13, y: -4), kind: wk_64),
    ],
    has_virtual: true,
    memory: 256,
    category: @[CAT_IO, CAT_RAM],
  ),

  VirtualRamFast: prototype(
    input_pins: @[
      prototype_pin(position: point(x: -13, y: -6)),
      prototype_pin(position: point(x: -13, y: -5), kind: wk_32),
      prototype_pin(position: point(x: -13, y: -4), kind: wk_64),
      prototype_pin(position: point(x: -13, y: -3), kind: wk_64),
      prototype_pin(position: point(x: -13, y: -2), kind: wk_64),
      prototype_pin(position: point(x: -13, y: -1), kind: wk_64),
    ],
  ),


  Ram: prototype(
    sandbox: true,
    dyn_mem_reset_on_level_reset: true,
    menu_order: 8.uint8,
    area: @[
      point(x: -12, y: -8), point(x: -11, y: -8), point(x: -10, y: -8), point(x: -9, y: -8), point(x: -8, y: -8), point(x: -7, y: -8), point(x: -6, y: -8), point(x: -5, y: -8), point(x: -4, y: -8), point(x: -3, y: -8), point(x: -2, y: -8), point(x: -1, y: -8), point(x: 0, y: -8), point(x: 1, y: -8), point(x: 2, y: -8), point(x: 3, y: -8), point(x: 4, y: -8), point(x: 5, y: -8), point(x: 6,y: -8), point(x: 7, y: -8), point(x: 8, y: -8), point(x: 9, y: -8), point(x: 10, y: -8), point(x: 11, y: -8), point(x: 12, y: -8),
      point(x: -12, y: -7), point(x: -11, y: -7), point(x: -10, y: -7), point(x: -9, y: -7), point(x: -8, y: -7), point(x: -7, y: -7), point(x: -6, y: -7), point(x: -5, y: -7), point(x: -4, y: -7), point(x: -3, y: -7), point(x: -2, y: -7), point(x: -1, y: -7), point(x: 0, y: -7), point(x: 1, y: -7), point(x: 2, y: -7), point(x: 3, y: -7), point(x: 4, y: -7), point(x: 5, y: -7), point(x: 6,y: -7), point(x: 7, y: -7), point(x: 8, y: -7), point(x: 9, y: -7), point(x: 10, y: -7), point(x: 11, y: -7), point(x: 12, y: -7),
      point(x: -12, y: -6), point(x: -11, y: -6), point(x: -10, y: -6), point(x: -9, y: -6), point(x: -8, y: -6), point(x: -7, y: -6), point(x: -6, y: -6), point(x: -5, y: -6), point(x: -4, y: -6), point(x: -3, y: -6), point(x: -2, y: -6), point(x: -1, y: -6), point(x: 0, y: -6), point(x: 1, y: -6), point(x: 2, y: -6), point(x: 3, y: -6), point(x: 4, y: -6), point(x: 5, y: -6), point(x: 6,y: -6), point(x: 7, y: -6), point(x: 8, y: -6), point(x: 9, y: -6), point(x: 10, y: -6), point(x: 11, y: -6), point(x: 12, y: -6),
      point(x: -12, y: -5), point(x: -11, y: -5), point(x: -10, y: -5), point(x: -9, y: -5), point(x: -8, y: -5), point(x: -7, y: -5), point(x: -6, y: -5), point(x: -5, y: -5), point(x: -4, y: -5), point(x: -3, y: -5), point(x: -2, y: -5), point(x: -1, y: -5), point(x: 0, y: -5), point(x: 1, y: -5), point(x: 2, y: -5), point(x: 3, y: -5), point(x: 4, y: -5), point(x: 5, y: -5), point(x: 6,y: -5), point(x: 7, y: -5), point(x: 8, y: -5), point(x: 9, y: -5), point(x: 10, y: -5), point(x: 11, y: -5), point(x: 12, y: -5),
      point(x: -12, y: -4), point(x: -11, y: -4), point(x: -10, y: -4), point(x: -9, y: -4), point(x: -8, y: -4), point(x: -7, y: -4), point(x: -6, y: -4), point(x: -5, y: -4), point(x: -4, y: -4), point(x: -3, y: -4), point(x: -2, y: -4), point(x: -1, y: -4), point(x: 0, y: -4), point(x: 1, y: -4), point(x: 2, y: -4), point(x: 3, y: -4), point(x: 4, y: -4), point(x: 5, y: -4), point(x: 6,y: -4), point(x: 7, y: -4), point(x: 8, y: -4), point(x: 9, y: -4), point(x: 10, y: -4), point(x: 11, y: -4), point(x: 12, y: -4),
      point(x: -12, y: -3), point(x: -11, y: -3), point(x: -10, y: -3), point(x: -9, y: -3), point(x: -8, y: -3), point(x: -7, y: -3), point(x: -6, y: -3), point(x: -5, y: -3), point(x: -4, y: -3), point(x: -3, y: -3), point(x: -2, y: -3), point(x: -1, y: -3), point(x: 0, y: -3), point(x: 1, y: -3), point(x: 2, y: -3), point(x: 3, y: -3), point(x: 4, y: -3), point(x: 5, y: -3), point(x: 6,y: -3), point(x: 7, y: -3), point(x: 8, y: -3), point(x: 9, y: -3), point(x: 10, y: -3), point(x: 11, y: -3), point(x: 12, y: -3),
      point(x: -12, y: -2), point(x: -11, y: -2), point(x: -10, y: -2), point(x: -9, y: -2), point(x: -8, y: -2), point(x: -7, y: -2), point(x: -6, y: -2), point(x: -5, y: -2), point(x: -4, y: -2), point(x: -3, y: -2), point(x: -2, y: -2), point(x: -1, y: -2), point(x: 0, y: -2), point(x: 1, y: -2), point(x: 2, y: -2), point(x: 3, y: -2), point(x: 4, y: -2), point(x: 5, y: -2), point(x: 6,y: -2), point(x: 7, y: -2), point(x: 8, y: -2), point(x: 9, y: -2), point(x: 10, y: -2), point(x: 11, y: -2), point(x: 12, y: -2),
      point(x: -12, y: -1), point(x: -11, y: -1), point(x: -10, y: -1), point(x: -9, y: -1), point(x: -8, y: -1), point(x: -7, y: -1), point(x: -6, y: -1), point(x: -5, y: -1), point(x: -4, y: -1), point(x: -3, y: -1), point(x: -2, y: -1), point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1), point(x: 2, y: -1), point(x: 3, y: -1), point(x: 4, y: -1), point(x: 5, y: -1), point(x: 6,y: -1), point(x: 7, y: -1), point(x: 8, y: -1), point(x: 9, y: -1), point(x: 10, y: -1), point(x: 11, y: -1), point(x: 12, y: -1),
      point(x: -12, y: 0), point(x: -11, y: 0), point(x: -10, y: 0), point(x: -9, y: 0), point(x: -8, y: 0), point(x: -7, y: 0), point(x: -6, y: 0), point(x: -5, y: 0), point(x: -4, y: 0), point(x: -3, y: 0), point(x: -2, y: 0), point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0), point(x: 2, y: 0), point(x: 3, y: 0), point(x: 4, y: 0), point(x: 5, y: 0), point(x: 6,y: 0), point(x: 7, y: 0), point(x: 8, y: 0), point(x: 9, y: 0), point(x: 10, y: 0), point(x: 11, y: 0), point(x: 12, y: 0),
      point(x: -12, y: 1), point(x: -11, y: 1), point(x: -10, y: 1), point(x: -9, y: 1), point(x: -8, y: 1), point(x: -7, y: 1), point(x: -6, y: 1), point(x: -5, y: 1), point(x: -4, y: 1), point(x: -3, y: 1), point(x: -2, y: 1), point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1), point(x: 2, y: 1), point(x: 3, y: 1), point(x: 4, y: 1), point(x: 5, y: 1), point(x: 6,y: 1), point(x: 7, y: 1), point(x: 8, y: 1), point(x: 9, y: 1), point(x: 10, y: 1), point(x: 11, y: 1), point(x: 12, y: 1),
      point(x: -12, y: 2), point(x: -11, y: 2), point(x: -10, y: 2), point(x: -9, y: 2), point(x: -8, y: 2), point(x: -7, y: 2), point(x: -6, y: 2), point(x: -5, y: 2), point(x: -4, y: 2), point(x: -3, y: 2), point(x: -2, y: 2), point(x: -1, y: 2), point(x: 0, y: 2), point(x: 1, y: 2), point(x: 2, y: 2), point(x: 3, y: 2), point(x: 4, y: 2), point(x: 5, y: 2), point(x: 6,y: 2), point(x: 7, y: 2), point(x: 8, y: 2), point(x: 9, y: 2), point(x: 10, y: 2), point(x: 11, y: 2), point(x: 12, y: 2),
      point(x: -12, y: 3), point(x: -11, y: 3), point(x: -10, y: 3), point(x: -9, y: 3), point(x: -8, y: 3), point(x: -7, y: 3), point(x: -6, y: 3), point(x: -5, y: 3), point(x: -4, y: 3), point(x: -3, y: 3), point(x: -2, y: 3), point(x: -1, y: 3), point(x: 0, y: 3), point(x: 1, y: 3), point(x: 2, y: 3), point(x: 3, y: 3), point(x: 4, y: 3), point(x: 5, y: 3), point(x: 6,y: 3), point(x: 7, y: 3), point(x: 8, y: 3), point(x: 9, y: 3), point(x: 10, y: 3), point(x: 11, y: 3), point(x: 12, y: 3),
      point(x: -12, y: 4), point(x: -11, y: 4), point(x: -10, y: 4), point(x: -9, y: 4), point(x: -8, y: 4), point(x: -7, y: 4), point(x: -6, y: 4), point(x: -5, y: 4), point(x: -4, y: 4), point(x: -3, y: 4), point(x: -2, y: 4), point(x: -1, y: 4), point(x: 0, y: 4), point(x: 1, y: 4), point(x: 2, y: 4), point(x: 3, y: 4), point(x: 4, y: 4), point(x: 5, y: 4), point(x: 6,y: 4), point(x: 7, y: 4), point(x: 8, y: 4), point(x: 9, y: 4), point(x: 10, y: 4), point(x: 11, y: 4), point(x: 12, y: 4),
      point(x: -12, y: 5), point(x: -11, y: 5), point(x: -10, y: 5), point(x: -9, y: 5), point(x: -8, y: 5), point(x: -7, y: 5), point(x: -6, y: 5), point(x: -5, y: 5), point(x: -4, y: 5), point(x: -3, y: 5), point(x: -2, y: 5), point(x: -1, y: 5), point(x: 0, y: 5), point(x: 1, y: 5), point(x: 2, y: 5), point(x: 3, y: 5), point(x: 4, y: 5), point(x: 5, y: 5), point(x: 6,y: 5), point(x: 7, y: 5), point(x: 8, y: 5), point(x: 9, y: 5), point(x: 10, y: 5), point(x: 11, y: 5), point(x: 12, y: 5),
      point(x: -12, y: 6), point(x: -11, y: 6), point(x: -10, y: 6), point(x: -9, y: 6), point(x: -8, y: 6), point(x: -7, y: 6), point(x: -6, y: 6), point(x: -5, y: 6), point(x: -4, y: 6), point(x: -3, y: 6), point(x: -2, y: 6), point(x: -1, y: 6), point(x: 0, y: 6), point(x: 1, y: 6), point(x: 2, y: 6), point(x: 3, y: 6), point(x: 4, y: 6), point(x: 5, y: 6), point(x: 6,y: 6), point(x: 7, y: 6), point(x: 8, y: 6), point(x: 9, y: 6), point(x: 10, y: 6), point(x: 11, y: 6), point(x: 12, y: 6),
      point(x: -12, y: 7), point(x: -11, y: 7), point(x: -10, y: 7), point(x: -9, y: 7), point(x: -8, y: 7), point(x: -7, y: 7), point(x: -6, y: 7), point(x: -5, y: 7), point(x: -4, y: 7), point(x: -3, y: 7), point(x: -2, y: 7), point(x: -1, y: 7), point(x: 0, y: 7), point(x: 1, y: 7), point(x: 2, y: 7), point(x: 3, y: 7), point(x: 4, y: 7), point(x: 5, y: 7), point(x: 6,y: 7), point(x: 7, y: 7), point(x: 8, y: 7), point(x: 9, y: 7), point(x: 10, y: 7), point(x: 11, y: 7), point(x: 12, y: 7),
    ],
    input_pins: @[
      prototype_pin(position: point(x: -13, y: -7)),
      prototype_pin(position: point(x: -13, y: -5), kind: wk_32),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 13, y: -7), kind: wk_64),
      prototype_pin(position: point(x: 13, y: -6), kind: wk_64),
      prototype_pin(position: point(x: 13, y: -5), kind: wk_64),
      prototype_pin(position: point(x: 13, y: -4), kind: wk_64),
    ],
    has_virtual: true,
    memory: 256,
    category: @[CAT_IO, CAT_RAM],
  ),

  VirtualRam: prototype(
    input_pins: @[
      prototype_pin(position: point(x: -13, y: -6)),
      prototype_pin(position: point(x: -13, y: -5), kind: wk_32),
      prototype_pin(position: point(x: -13, y: -4), kind: wk_64),
      prototype_pin(position: point(x: -13, y: -3), kind: wk_64),
      prototype_pin(position: point(x: -13, y: -2), kind: wk_64),
      prototype_pin(position: point(x: -13, y: -1), kind: wk_64),
    ],
  ),

  RamLatency: prototype(
    sandbox: true,
    dyn_mem_reset_on_level_reset: true,
    menu_order: 8.uint8,
    area: @[
      point(x: -12, y: -8), point(x: -11, y: -8), point(x: -10, y: -8), point(x: -9, y: -8), point(x: -8, y: -8), point(x: -7, y: -8), point(x: -6, y: -8), point(x: -5, y: -8), point(x: -4, y: -8), point(x: -3, y: -8), point(x: -2, y: -8), point(x: -1, y: -8), point(x: 0, y: -8), point(x: 1, y: -8), point(x: 2, y: -8), point(x: 3, y: -8), point(x: 4, y: -8), point(x: 5, y: -8), point(x: 6,y: -8), point(x: 7, y: -8), point(x: 8, y: -8), point(x: 9, y: -8), point(x: 10, y: -8), point(x: 11, y: -8), point(x: 12, y: -8),
      point(x: -12, y: -7), point(x: -11, y: -7), point(x: -10, y: -7), point(x: -9, y: -7), point(x: -8, y: -7), point(x: -7, y: -7), point(x: -6, y: -7), point(x: -5, y: -7), point(x: -4, y: -7), point(x: -3, y: -7), point(x: -2, y: -7), point(x: -1, y: -7), point(x: 0, y: -7), point(x: 1, y: -7), point(x: 2, y: -7), point(x: 3, y: -7), point(x: 4, y: -7), point(x: 5, y: -7), point(x: 6,y: -7), point(x: 7, y: -7), point(x: 8, y: -7), point(x: 9, y: -7), point(x: 10, y: -7), point(x: 11, y: -7), point(x: 12, y: -7),
      point(x: -12, y: -6), point(x: -11, y: -6), point(x: -10, y: -6), point(x: -9, y: -6), point(x: -8, y: -6), point(x: -7, y: -6), point(x: -6, y: -6), point(x: -5, y: -6), point(x: -4, y: -6), point(x: -3, y: -6), point(x: -2, y: -6), point(x: -1, y: -6), point(x: 0, y: -6), point(x: 1, y: -6), point(x: 2, y: -6), point(x: 3, y: -6), point(x: 4, y: -6), point(x: 5, y: -6), point(x: 6,y: -6), point(x: 7, y: -6), point(x: 8, y: -6), point(x: 9, y: -6), point(x: 10, y: -6), point(x: 11, y: -6), point(x: 12, y: -6),
      point(x: -12, y: -5), point(x: -11, y: -5), point(x: -10, y: -5), point(x: -9, y: -5), point(x: -8, y: -5), point(x: -7, y: -5), point(x: -6, y: -5), point(x: -5, y: -5), point(x: -4, y: -5), point(x: -3, y: -5), point(x: -2, y: -5), point(x: -1, y: -5), point(x: 0, y: -5), point(x: 1, y: -5), point(x: 2, y: -5), point(x: 3, y: -5), point(x: 4, y: -5), point(x: 5, y: -5), point(x: 6,y: -5), point(x: 7, y: -5), point(x: 8, y: -5), point(x: 9, y: -5), point(x: 10, y: -5), point(x: 11, y: -5), point(x: 12, y: -5),
      point(x: -12, y: -4), point(x: -11, y: -4), point(x: -10, y: -4), point(x: -9, y: -4), point(x: -8, y: -4), point(x: -7, y: -4), point(x: -6, y: -4), point(x: -5, y: -4), point(x: -4, y: -4), point(x: -3, y: -4), point(x: -2, y: -4), point(x: -1, y: -4), point(x: 0, y: -4), point(x: 1, y: -4), point(x: 2, y: -4), point(x: 3, y: -4), point(x: 4, y: -4), point(x: 5, y: -4), point(x: 6,y: -4), point(x: 7, y: -4), point(x: 8, y: -4), point(x: 9, y: -4), point(x: 10, y: -4), point(x: 11, y: -4), point(x: 12, y: -4),
      point(x: -12, y: -3), point(x: -11, y: -3), point(x: -10, y: -3), point(x: -9, y: -3), point(x: -8, y: -3), point(x: -7, y: -3), point(x: -6, y: -3), point(x: -5, y: -3), point(x: -4, y: -3), point(x: -3, y: -3), point(x: -2, y: -3), point(x: -1, y: -3), point(x: 0, y: -3), point(x: 1, y: -3), point(x: 2, y: -3), point(x: 3, y: -3), point(x: 4, y: -3), point(x: 5, y: -3), point(x: 6,y: -3), point(x: 7, y: -3), point(x: 8, y: -3), point(x: 9, y: -3), point(x: 10, y: -3), point(x: 11, y: -3), point(x: 12, y: -3),
      point(x: -12, y: -2), point(x: -11, y: -2), point(x: -10, y: -2), point(x: -9, y: -2), point(x: -8, y: -2), point(x: -7, y: -2), point(x: -6, y: -2), point(x: -5, y: -2), point(x: -4, y: -2), point(x: -3, y: -2), point(x: -2, y: -2), point(x: -1, y: -2), point(x: 0, y: -2), point(x: 1, y: -2), point(x: 2, y: -2), point(x: 3, y: -2), point(x: 4, y: -2), point(x: 5, y: -2), point(x: 6,y: -2), point(x: 7, y: -2), point(x: 8, y: -2), point(x: 9, y: -2), point(x: 10, y: -2), point(x: 11, y: -2), point(x: 12, y: -2),
      point(x: -12, y: -1), point(x: -11, y: -1), point(x: -10, y: -1), point(x: -9, y: -1), point(x: -8, y: -1), point(x: -7, y: -1), point(x: -6, y: -1), point(x: -5, y: -1), point(x: -4, y: -1), point(x: -3, y: -1), point(x: -2, y: -1), point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1), point(x: 2, y: -1), point(x: 3, y: -1), point(x: 4, y: -1), point(x: 5, y: -1), point(x: 6,y: -1), point(x: 7, y: -1), point(x: 8, y: -1), point(x: 9, y: -1), point(x: 10, y: -1), point(x: 11, y: -1), point(x: 12, y: -1),
      point(x: -12, y: 0), point(x: -11, y: 0), point(x: -10, y: 0), point(x: -9, y: 0), point(x: -8, y: 0), point(x: -7, y: 0), point(x: -6, y: 0), point(x: -5, y: 0), point(x: -4, y: 0), point(x: -3, y: 0), point(x: -2, y: 0), point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0), point(x: 2, y: 0), point(x: 3, y: 0), point(x: 4, y: 0), point(x: 5, y: 0), point(x: 6,y: 0), point(x: 7, y: 0), point(x: 8, y: 0), point(x: 9, y: 0), point(x: 10, y: 0), point(x: 11, y: 0), point(x: 12, y: 0),
      point(x: -12, y: 1), point(x: -11, y: 1), point(x: -10, y: 1), point(x: -9, y: 1), point(x: -8, y: 1), point(x: -7, y: 1), point(x: -6, y: 1), point(x: -5, y: 1), point(x: -4, y: 1), point(x: -3, y: 1), point(x: -2, y: 1), point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1), point(x: 2, y: 1), point(x: 3, y: 1), point(x: 4, y: 1), point(x: 5, y: 1), point(x: 6,y: 1), point(x: 7, y: 1), point(x: 8, y: 1), point(x: 9, y: 1), point(x: 10, y: 1), point(x: 11, y: 1), point(x: 12, y: 1),
      point(x: -12, y: 2), point(x: -11, y: 2), point(x: -10, y: 2), point(x: -9, y: 2), point(x: -8, y: 2), point(x: -7, y: 2), point(x: -6, y: 2), point(x: -5, y: 2), point(x: -4, y: 2), point(x: -3, y: 2), point(x: -2, y: 2), point(x: -1, y: 2), point(x: 0, y: 2), point(x: 1, y: 2), point(x: 2, y: 2), point(x: 3, y: 2), point(x: 4, y: 2), point(x: 5, y: 2), point(x: 6,y: 2), point(x: 7, y: 2), point(x: 8, y: 2), point(x: 9, y: 2), point(x: 10, y: 2), point(x: 11, y: 2), point(x: 12, y: 2),
      point(x: -12, y: 3), point(x: -11, y: 3), point(x: -10, y: 3), point(x: -9, y: 3), point(x: -8, y: 3), point(x: -7, y: 3), point(x: -6, y: 3), point(x: -5, y: 3), point(x: -4, y: 3), point(x: -3, y: 3), point(x: -2, y: 3), point(x: -1, y: 3), point(x: 0, y: 3), point(x: 1, y: 3), point(x: 2, y: 3), point(x: 3, y: 3), point(x: 4, y: 3), point(x: 5, y: 3), point(x: 6,y: 3), point(x: 7, y: 3), point(x: 8, y: 3), point(x: 9, y: 3), point(x: 10, y: 3), point(x: 11, y: 3), point(x: 12, y: 3),
      point(x: -12, y: 4), point(x: -11, y: 4), point(x: -10, y: 4), point(x: -9, y: 4), point(x: -8, y: 4), point(x: -7, y: 4), point(x: -6, y: 4), point(x: -5, y: 4), point(x: -4, y: 4), point(x: -3, y: 4), point(x: -2, y: 4), point(x: -1, y: 4), point(x: 0, y: 4), point(x: 1, y: 4), point(x: 2, y: 4), point(x: 3, y: 4), point(x: 4, y: 4), point(x: 5, y: 4), point(x: 6,y: 4), point(x: 7, y: 4), point(x: 8, y: 4), point(x: 9, y: 4), point(x: 10, y: 4), point(x: 11, y: 4), point(x: 12, y: 4),
      point(x: -12, y: 5), point(x: -11, y: 5), point(x: -10, y: 5), point(x: -9, y: 5), point(x: -8, y: 5), point(x: -7, y: 5), point(x: -6, y: 5), point(x: -5, y: 5), point(x: -4, y: 5), point(x: -3, y: 5), point(x: -2, y: 5), point(x: -1, y: 5), point(x: 0, y: 5), point(x: 1, y: 5), point(x: 2, y: 5), point(x: 3, y: 5), point(x: 4, y: 5), point(x: 5, y: 5), point(x: 6,y: 5), point(x: 7, y: 5), point(x: 8, y: 5), point(x: 9, y: 5), point(x: 10, y: 5), point(x: 11, y: 5), point(x: 12, y: 5),
      point(x: -12, y: 6), point(x: -11, y: 6), point(x: -10, y: 6), point(x: -9, y: 6), point(x: -8, y: 6), point(x: -7, y: 6), point(x: -6, y: 6), point(x: -5, y: 6), point(x: -4, y: 6), point(x: -3, y: 6), point(x: -2, y: 6), point(x: -1, y: 6), point(x: 0, y: 6), point(x: 1, y: 6), point(x: 2, y: 6), point(x: 3, y: 6), point(x: 4, y: 6), point(x: 5, y: 6), point(x: 6,y: 6), point(x: 7, y: 6), point(x: 8, y: 6), point(x: 9, y: 6), point(x: 10, y: 6), point(x: 11, y: 6), point(x: 12, y: 6),
      point(x: -12, y: 7), point(x: -11, y: 7), point(x: -10, y: 7), point(x: -9, y: 7), point(x: -8, y: 7), point(x: -7, y: 7), point(x: -6, y: 7), point(x: -5, y: 7), point(x: -4, y: 7), point(x: -3, y: 7), point(x: -2, y: 7), point(x: -1, y: 7), point(x: 0, y: 7), point(x: 1, y: 7), point(x: 2, y: 7), point(x: 3, y: 7), point(x: 4, y: 7), point(x: 5, y: 7), point(x: 6,y: 7), point(x: 7, y: 7), point(x: 8, y: 7), point(x: 9, y: 7), point(x: 10, y: 7), point(x: 11, y: 7), point(x: 12, y: 7),
    ],
    input_pins: @[
    ],
    output_pins: @[
      prototype_pin(position: point(x: 13, y: -7)),
      prototype_pin(position: point(x: 13, y: -6), kind: wk_64),
      prototype_pin(position: point(x: 13, y: -5), kind: wk_64),
      prototype_pin(position: point(x: 13, y: -4), kind: wk_64),
      prototype_pin(position: point(x: 13, y: -3), kind: wk_64),
    ],
    has_virtual: true,
    memory: 256 + 6,
    category: @[CAT_IO, CAT_RAM],
  ),

  VirtualRamLatency: prototype(
    input_pins: @[
      prototype_pin(position: point(x: -13, y: -7)),
      prototype_pin(position: point(x: -13, y: -6)),
      prototype_pin(position: point(x: -13, y: -5), kind: wk_32),
      prototype_pin(position: point(x: -13, y: -4), kind: wk_64),
      prototype_pin(position: point(x: -13, y: -3), kind: wk_64),
      prototype_pin(position: point(x: -13, y: -2), kind: wk_64),
      prototype_pin(position: point(x: -13, y: -1), kind: wk_64),
    ],
  ),

  RamDualLoad: prototype(
    sandbox: true,
    dyn_mem_reset_on_level_reset: true,
    default_setting_1: 256,
    menu_order: 8.uint8,
    area: @[
      point(x: -12, y: -8), point(x: -11, y: -8), point(x: -10, y: -8), point(x: -9, y: -8), point(x: -8, y: -8), point(x: -7, y: -8), point(x: -6, y: -8), point(x: -5, y: -8), point(x: -4, y: -8), point(x: -3, y: -8), point(x: -2, y: -8), point(x: -1, y: -8), point(x: 0, y: -8), point(x: 1, y: -8), point(x: 2, y: -8), point(x: 3, y: -8), point(x: 4, y: -8), point(x: 5, y: -8), point(x: 6,y: -8), point(x: 7, y: -8), point(x: 8, y: -8), point(x: 9, y: -8), point(x: 10, y: -8), point(x: 11, y: -8), point(x: 12, y: -8),
      point(x: -12, y: -7), point(x: -11, y: -7), point(x: -10, y: -7), point(x: -9, y: -7), point(x: -8, y: -7), point(x: -7, y: -7), point(x: -6, y: -7), point(x: -5, y: -7), point(x: -4, y: -7), point(x: -3, y: -7), point(x: -2, y: -7), point(x: -1, y: -7), point(x: 0, y: -7), point(x: 1, y: -7), point(x: 2, y: -7), point(x: 3, y: -7), point(x: 4, y: -7), point(x: 5, y: -7), point(x: 6,y: -7), point(x: 7, y: -7), point(x: 8, y: -7), point(x: 9, y: -7), point(x: 10, y: -7), point(x: 11, y: -7), point(x: 12, y: -7),
      point(x: -12, y: -6), point(x: -11, y: -6), point(x: -10, y: -6), point(x: -9, y: -6), point(x: -8, y: -6), point(x: -7, y: -6), point(x: -6, y: -6), point(x: -5, y: -6), point(x: -4, y: -6), point(x: -3, y: -6), point(x: -2, y: -6), point(x: -1, y: -6), point(x: 0, y: -6), point(x: 1, y: -6), point(x: 2, y: -6), point(x: 3, y: -6), point(x: 4, y: -6), point(x: 5, y: -6), point(x: 6,y: -6), point(x: 7, y: -6), point(x: 8, y: -6), point(x: 9, y: -6), point(x: 10, y: -6), point(x: 11, y: -6), point(x: 12, y: -6),
      point(x: -12, y: -5), point(x: -11, y: -5), point(x: -10, y: -5), point(x: -9, y: -5), point(x: -8, y: -5), point(x: -7, y: -5), point(x: -6, y: -5), point(x: -5, y: -5), point(x: -4, y: -5), point(x: -3, y: -5), point(x: -2, y: -5), point(x: -1, y: -5), point(x: 0, y: -5), point(x: 1, y: -5), point(x: 2, y: -5), point(x: 3, y: -5), point(x: 4, y: -5), point(x: 5, y: -5), point(x: 6,y: -5), point(x: 7, y: -5), point(x: 8, y: -5), point(x: 9, y: -5), point(x: 10, y: -5), point(x: 11, y: -5), point(x: 12, y: -5),
      point(x: -12, y: -4), point(x: -11, y: -4), point(x: -10, y: -4), point(x: -9, y: -4), point(x: -8, y: -4), point(x: -7, y: -4), point(x: -6, y: -4), point(x: -5, y: -4), point(x: -4, y: -4), point(x: -3, y: -4), point(x: -2, y: -4), point(x: -1, y: -4), point(x: 0, y: -4), point(x: 1, y: -4), point(x: 2, y: -4), point(x: 3, y: -4), point(x: 4, y: -4), point(x: 5, y: -4), point(x: 6,y: -4), point(x: 7, y: -4), point(x: 8, y: -4), point(x: 9, y: -4), point(x: 10, y: -4), point(x: 11, y: -4), point(x: 12, y: -4),
      point(x: -12, y: -3), point(x: -11, y: -3), point(x: -10, y: -3), point(x: -9, y: -3), point(x: -8, y: -3), point(x: -7, y: -3), point(x: -6, y: -3), point(x: -5, y: -3), point(x: -4, y: -3), point(x: -3, y: -3), point(x: -2, y: -3), point(x: -1, y: -3), point(x: 0, y: -3), point(x: 1, y: -3), point(x: 2, y: -3), point(x: 3, y: -3), point(x: 4, y: -3), point(x: 5, y: -3), point(x: 6,y: -3), point(x: 7, y: -3), point(x: 8, y: -3), point(x: 9, y: -3), point(x: 10, y: -3), point(x: 11, y: -3), point(x: 12, y: -3),
      point(x: -12, y: -2), point(x: -11, y: -2), point(x: -10, y: -2), point(x: -9, y: -2), point(x: -8, y: -2), point(x: -7, y: -2), point(x: -6, y: -2), point(x: -5, y: -2), point(x: -4, y: -2), point(x: -3, y: -2), point(x: -2, y: -2), point(x: -1, y: -2), point(x: 0, y: -2), point(x: 1, y: -2), point(x: 2, y: -2), point(x: 3, y: -2), point(x: 4, y: -2), point(x: 5, y: -2), point(x: 6,y: -2), point(x: 7, y: -2), point(x: 8, y: -2), point(x: 9, y: -2), point(x: 10, y: -2), point(x: 11, y: -2), point(x: 12, y: -2),
      point(x: -12, y: -1), point(x: -11, y: -1), point(x: -10, y: -1), point(x: -9, y: -1), point(x: -8, y: -1), point(x: -7, y: -1), point(x: -6, y: -1), point(x: -5, y: -1), point(x: -4, y: -1), point(x: -3, y: -1), point(x: -2, y: -1), point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1), point(x: 2, y: -1), point(x: 3, y: -1), point(x: 4, y: -1), point(x: 5, y: -1), point(x: 6,y: -1), point(x: 7, y: -1), point(x: 8, y: -1), point(x: 9, y: -1), point(x: 10, y: -1), point(x: 11, y: -1), point(x: 12, y: -1),
      point(x: -12, y: 0), point(x: -11, y: 0), point(x: -10, y: 0), point(x: -9, y: 0), point(x: -8, y: 0), point(x: -7, y: 0), point(x: -6, y: 0), point(x: -5, y: 0), point(x: -4, y: 0), point(x: -3, y: 0), point(x: -2, y: 0), point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0), point(x: 2, y: 0), point(x: 3, y: 0), point(x: 4, y: 0), point(x: 5, y: 0), point(x: 6,y: 0), point(x: 7, y: 0), point(x: 8, y: 0), point(x: 9, y: 0), point(x: 10, y: 0), point(x: 11, y: 0), point(x: 12, y: 0),
      point(x: -12, y: 1), point(x: -11, y: 1), point(x: -10, y: 1), point(x: -9, y: 1), point(x: -8, y: 1), point(x: -7, y: 1), point(x: -6, y: 1), point(x: -5, y: 1), point(x: -4, y: 1), point(x: -3, y: 1), point(x: -2, y: 1), point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1), point(x: 2, y: 1), point(x: 3, y: 1), point(x: 4, y: 1), point(x: 5, y: 1), point(x: 6,y: 1), point(x: 7, y: 1), point(x: 8, y: 1), point(x: 9, y: 1), point(x: 10, y: 1), point(x: 11, y: 1), point(x: 12, y: 1),
      point(x: -12, y: 2), point(x: -11, y: 2), point(x: -10, y: 2), point(x: -9, y: 2), point(x: -8, y: 2), point(x: -7, y: 2), point(x: -6, y: 2), point(x: -5, y: 2), point(x: -4, y: 2), point(x: -3, y: 2), point(x: -2, y: 2), point(x: -1, y: 2), point(x: 0, y: 2), point(x: 1, y: 2), point(x: 2, y: 2), point(x: 3, y: 2), point(x: 4, y: 2), point(x: 5, y: 2), point(x: 6,y: 2), point(x: 7, y: 2), point(x: 8, y: 2), point(x: 9, y: 2), point(x: 10, y: 2), point(x: 11, y: 2), point(x: 12, y: 2),
      point(x: -12, y: 3), point(x: -11, y: 3), point(x: -10, y: 3), point(x: -9, y: 3), point(x: -8, y: 3), point(x: -7, y: 3), point(x: -6, y: 3), point(x: -5, y: 3), point(x: -4, y: 3), point(x: -3, y: 3), point(x: -2, y: 3), point(x: -1, y: 3), point(x: 0, y: 3), point(x: 1, y: 3), point(x: 2, y: 3), point(x: 3, y: 3), point(x: 4, y: 3), point(x: 5, y: 3), point(x: 6,y: 3), point(x: 7, y: 3), point(x: 8, y: 3), point(x: 9, y: 3), point(x: 10, y: 3), point(x: 11, y: 3), point(x: 12, y: 3),
      point(x: -12, y: 4), point(x: -11, y: 4), point(x: -10, y: 4), point(x: -9, y: 4), point(x: -8, y: 4), point(x: -7, y: 4), point(x: -6, y: 4), point(x: -5, y: 4), point(x: -4, y: 4), point(x: -3, y: 4), point(x: -2, y: 4), point(x: -1, y: 4), point(x: 0, y: 4), point(x: 1, y: 4), point(x: 2, y: 4), point(x: 3, y: 4), point(x: 4, y: 4), point(x: 5, y: 4), point(x: 6,y: 4), point(x: 7, y: 4), point(x: 8, y: 4), point(x: 9, y: 4), point(x: 10, y: 4), point(x: 11, y: 4), point(x: 12, y: 4),
      point(x: -12, y: 5), point(x: -11, y: 5), point(x: -10, y: 5), point(x: -9, y: 5), point(x: -8, y: 5), point(x: -7, y: 5), point(x: -6, y: 5), point(x: -5, y: 5), point(x: -4, y: 5), point(x: -3, y: 5), point(x: -2, y: 5), point(x: -1, y: 5), point(x: 0, y: 5), point(x: 1, y: 5), point(x: 2, y: 5), point(x: 3, y: 5), point(x: 4, y: 5), point(x: 5, y: 5), point(x: 6,y: 5), point(x: 7, y: 5), point(x: 8, y: 5), point(x: 9, y: 5), point(x: 10, y: 5), point(x: 11, y: 5), point(x: 12, y: 5),
      point(x: -12, y: 6), point(x: -11, y: 6), point(x: -10, y: 6), point(x: -9, y: 6), point(x: -8, y: 6), point(x: -7, y: 6), point(x: -6, y: 6), point(x: -5, y: 6), point(x: -4, y: 6), point(x: -3, y: 6), point(x: -2, y: 6), point(x: -1, y: 6), point(x: 0, y: 6), point(x: 1, y: 6), point(x: 2, y: 6), point(x: 3, y: 6), point(x: 4, y: 6), point(x: 5, y: 6), point(x: 6,y: 6), point(x: 7, y: 6), point(x: 8, y: 6), point(x: 9, y: 6), point(x: 10, y: 6), point(x: 11, y: 6), point(x: 12, y: 6),
      point(x: -12, y: 7), point(x: -11, y: 7), point(x: -10, y: 7), point(x: -9, y: 7), point(x: -8, y: 7), point(x: -7, y: 7), point(x: -6, y: 7), point(x: -5, y: 7), point(x: -4, y: 7), point(x: -3, y: 7), point(x: -2, y: 7), point(x: -1, y: 7), point(x: 0, y: 7), point(x: 1, y: 7), point(x: 2, y: 7), point(x: 3, y: 7), point(x: 4, y: 7), point(x: 5, y: 7), point(x: 6,y: 7), point(x: 7, y: 7), point(x: 8, y: 7), point(x: 9, y: 7), point(x: 10, y: 7), point(x: 11, y: 7), point(x: 12, y: 7),
    ],
    input_pins: @[
      prototype_pin(position: point(x: -13, y: -7)),
      prototype_pin(position: point(x: -13, y: -5), kind: wk_32),
      prototype_pin(position: point(x: -13, y: -3)),
      prototype_pin(position: point(x: -13, y: -2), kind: wk_32),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 13, y: -7), kind: wk_64),
      prototype_pin(position: point(x: 13, y: -6), kind: wk_64),
    ],
    has_virtual: true,
    memory: 256 + 1, # padding
    category: @[CAT_IO, CAT_RAM],
  ),

  VirtualRamDualLoad: prototype(
    input_pins: @[
      prototype_pin(position: point(x: -13, y: -6)),
      prototype_pin(position: point(x: -13, y: -5), kind: wk_32),
      prototype_pin(position: point(x: -13, y: -4), kind: wk_64),
    ],
  ),

  Register64: prototype(
    sandbox: true,
    menu_order: 21.uint8,
    area: @[
      point(x: -2, y: -1), point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1), point(x: 2, y: -1),
      point(x: -2, y: 0), point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0), point(x: 2, y: 0),
      point(x: -2, y: 1), point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1), point(x: 2, y: 1),
    ],
    input_pins: @[
      prototype_pin(position: point(x: -3, y: -1)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 3, y: 0), kind: wk_64, tri_state: true),
    ],
    has_virtual: true,
    category: @[CAT_64_BIT],
    memory: 1,
  ),
  VirtualRegister64: prototype(
    input_pins: @[
      prototype_pin(position: point(x: -3, y: 0)),
      prototype_pin(position: point(x: -3, y: 1), kind: wk_64),
    ],
  ),
  Switch1: prototype(
    sandbox: true,
    menu_order: 3.uint8,
    area: @[point(x: 0, y: 0)],
    #condition_pin: point(x: 0, y: -1),
    input_pins: @[
      prototype_pin(position: point(x: 0, y: -1)),
      prototype_pin(position: point(x: -1, y: 0)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), tri_state: true),
    ],
    category: @[CAT_1_BIT],
  ),

  Switch64: prototype(
    sandbox: true,
    menu_order: 4.uint8,
    area: @[point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: 0, y: -1)),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_64),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_64, tri_state: true),
    ],
    category: @[CAT_64_BIT],
  ),

  Mux64: prototype(
    sandbox: true,
    menu_order: 5.uint8,
    area: @[point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1)),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_64),
      prototype_pin(position: point(x: -1, y: 1), kind: wk_64),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_64),
    ],
    category: @[CAT_64_BIT],
  ),

  Decoder1: prototype(
    sandbox: true,
    sandbox_score: score(gate: 1, delay: 2),
    menu_order: 12.uint8,
    area: @[point(x: 0, y: 0), point(x: 0, y: 1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0)),
      prototype_pin(position: point(x: 1, y: 1)),
    ],
    category: @[CAT_1_BIT],
  ),

  Decoder2: prototype(
    sandbox: true,
    menu_order: 13.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1), point(x: 0, y: 2)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1)),
      prototype_pin(position: point(x: -1, y: 0)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1)),
      prototype_pin(position: point(x: 1, y: 0)),
      prototype_pin(position: point(x: 1, y: 1)),
      prototype_pin(position: point(x: 1, y: 2)),
    ],
    category: @[CAT_1_BIT],
  ),

  Decoder3: prototype(
    sandbox: true,
    sandbox_score: score(gate: 20, delay: 6),
    menu_order: 14.uint8,
    area: @[point(x: 0, y: -3), point(x: 0, y: -2), point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1), point(x: 0, y: 2), point(x: 0, y: 3)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -3)),
      prototype_pin(position: point(x: -1, y: -2)),
      prototype_pin(position: point(x: -1, y: -1)),
      prototype_pin(position: point(x: 0,  y: -4)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -3)),
      prototype_pin(position: point(x: 1, y: -2)),
      prototype_pin(position: point(x: 1, y: -1)),
      prototype_pin(position: point(x: 1, y: 0)),
      prototype_pin(position: point(x: 1, y: 1)),
      prototype_pin(position: point(x: 1, y: 2)),
      prototype_pin(position: point(x: 1, y: 3)),
      prototype_pin(position: point(x: 1, y: 4)),
    ],
    category: @[CAT_1_BIT],
  ),

  Halt: prototype(
    sandbox: true,
    effectual: true,
    area: @[point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0)),
    ],
    output_pins: @[],
    category: @[CAT_IO],
  ),
  Timing: prototype(
    sandbox_only: true,
    sandbox: true,
    area: @[point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: 0, y: -1)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_64, tri_state: true),
    ],
    category: @[CAT_IO, CAT_SANDBOX_ONLY],
  ),
  Clock: prototype(
    area: @[point(x: 0, y: 0)],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0)),
    ],
    category: @[CAT_IO],
  ),
  NoteSound: prototype(
    sandbox: true,
    effectual: true,
    area: @[
      point(x: -1, y: 0),point(x: 0, y: 0),
      point(x: -1, y: 1),point(x: 0, y: 1),
    ],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: -2, y: 0), kind: wk_8),
      prototype_pin(position: point(x: -2, y: 1), kind: wk_8),
    ],
    output_pins: @[],
    category: @[CAT_IO],
  ),

  Console: prototype(
    sandbox: true,
    effectual: true,
    area: @[
      point(x: -15, y: -8), point(x: -14, y: -8), point(x: -13, y: -8), point(x: -12, y: -8), point(x: -11, y: -8), point(x: -10, y: -8), point(x: -9, y: -8), point(x: -8, y: -8), point(x: -7, y: -8), point(x: -6, y: -8), point(x: -5, y: -8), point(x: -4, y: -8), point(x: -3, y: -8), point(x: -2, y: -8), point(x: -1, y: -8), point(x: 0, y: -8), point(x: 1, y: -8), point(x: 2, y: -8), point(x: 3, y: -8), point(x: 4, y: -8), point(x: 5, y: -8), point(x: 6, y: -8), point(x: 7, y: -8), point(x: 8, y: -8), point(x: 9, y: -8), point(x: 10, y: -8), point(x: 11, y: -8), point(x: 12, y: -8), point(x: 13, y: -8), point(x: 14, y: -8), point(x: 15, y: -8), point(x: 16, y: -8),
      point(x: -15, y: -7), point(x: -14, y: -7), point(x: -13, y: -7), point(x: -12, y: -7), point(x: -11, y: -7), point(x: -10, y: -7), point(x: -9, y: -7), point(x: -8, y: -7), point(x: -7, y: -7), point(x: -6, y: -7), point(x: -5, y: -7), point(x: -4, y: -7), point(x: -3, y: -7), point(x: -2, y: -7), point(x: -1, y: -7), point(x: 0, y: -7), point(x: 1, y: -7), point(x: 2, y: -7), point(x: 3, y: -7), point(x: 4, y: -7), point(x: 5, y: -7), point(x: 6, y: -7), point(x: 7, y: -7), point(x: 8, y: -7), point(x: 9, y: -7), point(x: 10, y: -7), point(x: 11, y: -7), point(x: 12, y: -7), point(x: 13, y: -7), point(x: 14, y: -7), point(x: 15, y: -7), point(x: 16, y: -7),
      point(x: -15, y: -6), point(x: -14, y: -6), point(x: -13, y: -6), point(x: -12, y: -6), point(x: -11, y: -6), point(x: -10, y: -6), point(x: -9, y: -6), point(x: -8, y: -6), point(x: -7, y: -6), point(x: -6, y: -6), point(x: -5, y: -6), point(x: -4, y: -6), point(x: -3, y: -6), point(x: -2, y: -6), point(x: -1, y: -6), point(x: 0, y: -6), point(x: 1, y: -6), point(x: 2, y: -6), point(x: 3, y: -6), point(x: 4, y: -6), point(x: 5, y: -6), point(x: 6, y: -6), point(x: 7, y: -6), point(x: 8, y: -6), point(x: 9, y: -6), point(x: 10, y: -6), point(x: 11, y: -6), point(x: 12, y: -6), point(x: 13, y: -6), point(x: 14, y: -6), point(x: 15, y: -6), point(x: 16, y: -6),
      point(x: -15, y: -5), point(x: -14, y: -5), point(x: -13, y: -5), point(x: -12, y: -5), point(x: -11, y: -5), point(x: -10, y: -5), point(x: -9, y: -5), point(x: -8, y: -5), point(x: -7, y: -5), point(x: -6, y: -5), point(x: -5, y: -5), point(x: -4, y: -5), point(x: -3, y: -5), point(x: -2, y: -5), point(x: -1, y: -5), point(x: 0, y: -5), point(x: 1, y: -5), point(x: 2, y: -5), point(x: 3, y: -5), point(x: 4, y: -5), point(x: 5, y: -5), point(x: 6, y: -5), point(x: 7, y: -5), point(x: 8, y: -5), point(x: 9, y: -5), point(x: 10, y: -5), point(x: 11, y: -5), point(x: 12, y: -5), point(x: 13, y: -5), point(x: 14, y: -5), point(x: 15, y: -5), point(x: 16, y: -5),
      point(x: -15, y: -4), point(x: -14, y: -4), point(x: -13, y: -4), point(x: -12, y: -4), point(x: -11, y: -4), point(x: -10, y: -4), point(x: -9, y: -4), point(x: -8, y: -4), point(x: -7, y: -4), point(x: -6, y: -4), point(x: -5, y: -4), point(x: -4, y: -4), point(x: -3, y: -4), point(x: -2, y: -4), point(x: -1, y: -4), point(x: 0, y: -4), point(x: 1, y: -4), point(x: 2, y: -4), point(x: 3, y: -4), point(x: 4, y: -4), point(x: 5, y: -4), point(x: 6, y: -4), point(x: 7, y: -4), point(x: 8, y: -4), point(x: 9, y: -4), point(x: 10, y: -4), point(x: 11, y: -4), point(x: 12, y: -4), point(x: 13, y: -4), point(x: 14, y: -4), point(x: 15, y: -4), point(x: 16, y: -4),
      point(x: -15, y: -3), point(x: -14, y: -3), point(x: -13, y: -3), point(x: -12, y: -3), point(x: -11, y: -3), point(x: -10, y: -3), point(x: -9, y: -3), point(x: -8, y: -3), point(x: -7, y: -3), point(x: -6, y: -3), point(x: -5, y: -3), point(x: -4, y: -3), point(x: -3, y: -3), point(x: -2, y: -3), point(x: -1, y: -3), point(x: 0, y: -3), point(x: 1, y: -3), point(x: 2, y: -3), point(x: 3, y: -3), point(x: 4, y: -3), point(x: 5, y: -3), point(x: 6, y: -3), point(x: 7, y: -3), point(x: 8, y: -3), point(x: 9, y: -3), point(x: 10, y: -3), point(x: 11, y: -3), point(x: 12, y: -3), point(x: 13, y: -3), point(x: 14, y: -3), point(x: 15, y: -3), point(x: 16, y: -3),
      point(x: -15, y: -2), point(x: -14, y: -2), point(x: -13, y: -2), point(x: -12, y: -2), point(x: -11, y: -2), point(x: -10, y: -2), point(x: -9, y: -2), point(x: -8, y: -2), point(x: -7, y: -2), point(x: -6, y: -2), point(x: -5, y: -2), point(x: -4, y: -2), point(x: -3, y: -2), point(x: -2, y: -2), point(x: -1, y: -2), point(x: 0, y: -2), point(x: 1, y: -2), point(x: 2, y: -2), point(x: 3, y: -2), point(x: 4, y: -2), point(x: 5, y: -2), point(x: 6, y: -2), point(x: 7, y: -2), point(x: 8, y: -2), point(x: 9, y: -2), point(x: 10, y: -2), point(x: 11, y: -2), point(x: 12, y: -2), point(x: 13, y: -2), point(x: 14, y: -2), point(x: 15, y: -2), point(x: 16, y: -2),
      point(x: -15, y: -1), point(x: -14, y: -1), point(x: -13, y: -1), point(x: -12, y: -1), point(x: -11, y: -1), point(x: -10, y: -1), point(x: -9, y: -1), point(x: -8, y: -1), point(x: -7, y: -1), point(x: -6, y: -1), point(x: -5, y: -1), point(x: -4, y: -1), point(x: -3, y: -1), point(x: -2, y: -1), point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1), point(x: 2, y: -1), point(x: 3, y: -1), point(x: 4, y: -1), point(x: 5, y: -1), point(x: 6, y: -1), point(x: 7, y: -1), point(x: 8, y: -1), point(x: 9, y: -1), point(x: 10, y: -1), point(x: 11, y: -1), point(x: 12, y: -1), point(x: 13, y: -1), point(x: 14, y: -1), point(x: 15, y: -1), point(x: 16, y: -1),
      point(x: -15, y: -0), point(x: -14, y: 0), point(x: -13, y: 0), point(x: -12, y: 0), point(x: -11, y: 0), point(x: -10, y: 0), point(x: -9, y: 0), point(x: -8, y: 0), point(x: -7, y: 0), point(x: -6, y: 0), point(x: -5, y: 0), point(x: -4, y: 0), point(x: -3, y: 0), point(x: -2, y: 0), point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0), point(x: 2, y: 0), point(x: 3, y: 0), point(x: 4, y: 0), point(x: 5, y: 0), point(x: 6, y: 0), point(x: 7, y: 0), point(x: 8, y: 0), point(x: 9, y: 0), point(x: 10, y: 0), point(x: 11, y: 0), point(x: 12, y: 0), point(x: 13, y: 0), point(x: 14, y: 0), point(x: 15, y: 0), point(x: 16, y: 0),
      point(x: -15, y: 1), point(x: -14, y: 1), point(x: -13, y: 1), point(x: -12, y: 1), point(x: -11, y: 1), point(x: -10, y: 1), point(x: -9, y: 1), point(x: -8, y: 1), point(x: -7, y: 1), point(x: -6, y: 1), point(x: -5, y: 1), point(x: -4, y: 1), point(x: -3, y: 1), point(x: -2, y: 1), point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1), point(x: 2, y: 1), point(x: 3, y: 1), point(x: 4, y: 1), point(x: 5, y: 1), point(x: 6, y: 1), point(x: 7, y: 1), point(x: 8, y: 1), point(x: 9, y: 1), point(x: 10, y: 1), point(x: 11, y: 1), point(x: 12, y: 1), point(x: 13, y: 1), point(x: 14, y: 1), point(x: 15, y: 1), point(x: 16, y: 1),
      point(x: -15, y: 2), point(x: -14, y: 2), point(x: -13, y: 2), point(x: -12, y: 2), point(x: -11, y: 2), point(x: -10, y: 2), point(x: -9, y: 2), point(x: -8, y: 2), point(x: -7, y: 2), point(x: -6, y: 2), point(x: -5, y: 2), point(x: -4, y: 2), point(x: -3, y: 2), point(x: -2, y: 2), point(x: -1, y: 2), point(x: 0, y: 2), point(x: 1, y: 2), point(x: 2, y: 2), point(x: 3, y: 2), point(x: 4, y: 2), point(x: 5, y: 2), point(x: 6, y: 2), point(x: 7, y: 2), point(x: 8, y: 2), point(x: 9, y: 2), point(x: 10, y: 2), point(x: 11, y: 2), point(x: 12, y: 2), point(x: 13, y: 2), point(x: 14, y: 2), point(x: 15, y: 2), point(x: 16, y: 2),
      point(x: -15, y: 3), point(x: -14, y: 3), point(x: -13, y: 3), point(x: -12, y: 3), point(x: -11, y: 3), point(x: -10, y: 3), point(x: -9, y: 3), point(x: -8, y: 3), point(x: -7, y: 3), point(x: -6, y: 3), point(x: -5, y: 3), point(x: -4, y: 3), point(x: -3, y: 3), point(x: -2, y: 3), point(x: -1, y: 3), point(x: 0, y: 3), point(x: 1, y: 3), point(x: 2, y: 3), point(x: 3, y: 3), point(x: 4, y: 3), point(x: 5, y: 3), point(x: 6, y: 3), point(x: 7, y: 3), point(x: 8, y: 3), point(x: 9, y: 3), point(x: 10, y: 3), point(x: 11, y: 3), point(x: 12, y: 3), point(x: 13, y: 3), point(x: 14, y: 3), point(x: 15, y: 3), point(x: 16, y: 3),
      point(x: -15, y: 4), point(x: -14, y: 4), point(x: -13, y: 4), point(x: -12, y: 4), point(x: -11, y: 4), point(x: -10, y: 4), point(x: -9, y: 4), point(x: -8, y: 4), point(x: -7, y: 4), point(x: -6, y: 4), point(x: -5, y: 4), point(x: -4, y: 4), point(x: -3, y: 4), point(x: -2, y: 4), point(x: -1, y: 4), point(x: 0, y: 4), point(x: 1, y: 4), point(x: 2, y: 4), point(x: 3, y: 4), point(x: 4, y: 4), point(x: 5, y: 4), point(x: 6, y: 4), point(x: 7, y: 4), point(x: 8, y: 4), point(x: 9, y: 4), point(x: 10, y: 4), point(x: 11, y: 4), point(x: 12, y: 4), point(x: 13, y: 4), point(x: 14, y: 4), point(x: 15, y: 4), point(x: 16, y: 4),
      point(x: -15, y: 5), point(x: -14, y: 5), point(x: -13, y: 5), point(x: -12, y: 5), point(x: -11, y: 5), point(x: -10, y: 5), point(x: -9, y: 5), point(x: -8, y: 5), point(x: -7, y: 5), point(x: -6, y: 5), point(x: -5, y: 5), point(x: -4, y: 5), point(x: -3, y: 5), point(x: -2, y: 5), point(x: -1, y: 5), point(x: 0, y: 5), point(x: 1, y: 5), point(x: 2, y: 5), point(x: 3, y: 5), point(x: 4, y: 5), point(x: 5, y: 5), point(x: 6, y: 5), point(x: 7, y: 5), point(x: 8, y: 5), point(x: 9, y: 5), point(x: 10, y: 5), point(x: 11, y: 5), point(x: 12, y: 5), point(x: 13, y: 5), point(x: 14, y: 5), point(x: 15, y: 5), point(x: 16, y: 5),
      point(x: -15, y: 6), point(x: -14, y: 6), point(x: -13, y: 6), point(x: -12, y: 6), point(x: -11, y: 6), point(x: -10, y: 6), point(x: -9, y: 6), point(x: -8, y: 6), point(x: -7, y: 6), point(x: -6, y: 6), point(x: -5, y: 6), point(x: -4, y: 6), point(x: -3, y: 6), point(x: -2, y: 6), point(x: -1, y: 6), point(x: 0, y: 6), point(x: 1, y: 6), point(x: 2, y: 6), point(x: 3, y: 6), point(x: 4, y: 6), point(x: 5, y: 6), point(x: 6, y: 6), point(x: 7, y: 6), point(x: 8, y: 6), point(x: 9, y: 6), point(x: 10, y: 6), point(x: 11, y: 6), point(x: 12, y: 6), point(x: 13, y: 6), point(x: 14, y: 6), point(x: 15, y: 6), point(x: 16, y: 6),
      point(x: -15, y: 7), point(x: -14, y: 7), point(x: -13, y: 7), point(x: -12, y: 7), point(x: -11, y: 7), point(x: -10, y: 7), point(x: -9, y: 7), point(x: -8, y: 7), point(x: -7, y: 7), point(x: -6, y: 7), point(x: -5, y: 7), point(x: -4, y: 7), point(x: -3, y: 7), point(x: -2, y: 7), point(x: -1, y: 7), point(x: 0, y: 7), point(x: 1, y: 7), point(x: 2, y: 7), point(x: 3, y: 7), point(x: 4, y: 7), point(x: 5, y: 7), point(x: 6, y: 7), point(x: 7, y: 7), point(x: 8, y: 7), point(x: 9, y: 7), point(x: 10, y: 7), point(x: 11, y: 7), point(x: 12, y: 7), point(x: 13, y: 7), point(x: 14, y: 7), point(x: 15, y: 7), point(x: 16, y: 7),
      point(x: -15, y: 8), point(x: -14, y: 8), point(x: -13, y: 8), point(x: -12, y: 8), point(x: -11, y: 8), point(x: -10, y: 8), point(x: -9, y: 8), point(x: -8, y: 8), point(x: -7, y: 8), point(x: -6, y: 8), point(x: -5, y: 8), point(x: -4, y: 8), point(x: -3, y: 8), point(x: -2, y: 8), point(x: -1, y: 8), point(x: 0, y: 8), point(x: 1, y: 8), point(x: 2, y: 8), point(x: 3, y: 8), point(x: 4, y: 8), point(x: 5, y: 8), point(x: 6, y: 8), point(x: 7, y: 8), point(x: 8, y: 8), point(x: 9, y: 8), point(x: 10, y: 8), point(x: 11, y: 8), point(x: 12, y: 8), point(x: 13, y: 8), point(x: 14, y: 8), point(x: 15, y: 8), point(x: 16, y: 8),
      point(x: -15, y: 9), point(x: -14, y: 9), point(x: -13, y: 9), point(x: -12, y: 9), point(x: -11, y: 9), point(x: -10, y: 9), point(x: -9, y: 9), point(x: -8, y: 9), point(x: -7, y: 9), point(x: -6, y: 9), point(x: -5, y: 9), point(x: -4, y: 9), point(x: -3, y: 9), point(x: -2, y: 9), point(x: -1, y: 9), point(x: 0, y: 9), point(x: 1, y: 9), point(x: 2, y: 9), point(x: 3, y: 9), point(x: 4, y: 9), point(x: 5, y: 9), point(x: 6, y: 9), point(x: 7, y: 9), point(x: 8, y: 9), point(x: 9, y: 9), point(x: 10, y: 9), point(x: 11, y: 9), point(x: 12, y: 9), point(x: 13, y: 9), point(x: 14, y: 9), point(x: 15, y: 9), point(x: 16, y: 9),
      point(x: -15, y: 10), point(x: -14, y: 10), point(x: -13, y: 10), point(x: -12, y: 10), point(x: -11, y: 10), point(x: -10, y: 10), point(x: -9, y: 10), point(x: -8, y: 10), point(x: -7, y: 10), point(x: -6, y: 10), point(x: -5, y: 10), point(x: -4, y: 10), point(x: -3, y: 10), point(x: -2, y: 10), point(x: -1, y: 10), point(x: 0, y: 10), point(x: 1, y: 10), point(x: 2, y: 10), point(x: 3, y: 10), point(x: 4, y: 10), point(x: 5, y: 10), point(x: 6, y: 10), point(x: 7, y: 10), point(x: 8, y: 10), point(x: 9, y: 10), point(x: 10, y: 10), point(x: 11, y: 10), point(x: 12, y: 10), point(x: 13, y: 10), point(x: 14, y: 10), point(x: 15, y: 10), point(x: 16, y: 10),
    ],
    input_pins: @[
      prototype_pin(position: point(x: -16, y: -8), kind: wk_32),
    ],
    memory: CONSOLE_BUFFER.int * 2 + 3, # Char, color, cursor, cursor color, bg color
    category: @[CAT_IO, CAT_DISPLAYS],
    custom_memory_export: proc(node: var node, memory_store: var openArray[uint64]): seq[uint64] =
      let has_color = node.setting_1 == 1
      
      iterator get_next(node: node): uint8 =
        case node.data_kind:
          of ld_none: discard
          of ld_component_data:
            let read_data = node.data_reference[]
            var j = node.read_offset
            if node.kind == FileLoader:
              j += 8 # This is where we store the length of the file

            if not has_color:
              var remainder = j mod 8
              j = j div 8

              if remainder != 0 and j < read_data.high.uint64:
                let v = read_data[j]
                remainder = (8 - remainder) * 8
                j += 1

                while remainder > 0:
                  yield ((v shr (64 - remainder)) and 255).uint8
                  remainder -= 8

            while j < read_data.high.uint64:
              let v = read_data[j]
              yield ((v shr  0) and 255).uint8
              yield ((v shr  8) and 255).uint8
              yield ((v shr 16) and 255).uint8
              yield ((v shr 24) and 255).uint8
              yield ((v shr 32) and 255).uint8
              yield ((v shr 40) and 255).uint8
              yield ((v shr 48) and 255).uint8
              yield ((v shr 56) and 255).uint8
              j += 1

          of ld_persistent_data:
            let size = node.persistent_reference[].size
            var i = 0
            while i < size:
              yield cast[ptr uint8](cast[int](node.persistent_reference.mem) + i)[]
              i += 1

          of ld_value:
            if node.read_offset == 0:
              let v = get_linked_value(node.node_index)
              yield ((v shr  0) and 255).uint8
              yield ((v shr  8) and 255).uint8
              yield ((v shr 16) and 255).uint8
              yield ((v shr 24) and 255).uint8
              yield ((v shr 32) and 255).uint8
              yield ((v shr 40) and 255).uint8
              yield ((v shr 48) and 255).uint8
              yield ((v shr 56) and 255).uint8

      if not has_color:
        var c = 0'u64
        for byte in node.get_next():
          var chr = byte
          if chr in [0'u8,9,10,13,32,250]:
            chr = 32'u8
          
          result.add(0xFFFFFF00'u64 or (chr).uint64)

          c += 1

          if c == CONSOLE_BUFFER: break

      else:
        var c = 0'u64
        var fg_color = 0x000000'u64
        var bg_color = 0x000000'u64
        
        var i = 0
        var chr: uint8
        var new_fg_col: uint64
        var new_bg_col: uint64

        for byte in node.get_next():
          case i:
            of 0:
              chr = byte
              if chr in [0'u8,9,10,13,32,250]:
                chr = 32'u8
            of 1: new_fg_col = byte.uint64
            of 2: new_fg_col = new_fg_col or (byte.uint64 shl 8)
            of 3: new_fg_col = new_fg_col or (byte.uint64 shl 16)
            of 4: new_bg_col = byte.uint64
            of 5: new_bg_col = new_bg_col or (byte.uint64 shl 8)
            of 6: new_bg_col = new_bg_col or (byte.uint64 shl 16)
            of 7: 
              var new_stuff = (uint64(bg_color != new_bg_col) shl 57) or (uint64(fg_color != new_fg_col) shl 56)
              bg_color = new_bg_col
              fg_color = new_fg_col

              result.add(new_stuff or (new_bg_col shl 32) or (new_fg_col shl 8) or chr)
              c += 1
            else: assert false
          i = (i + 1) mod 8

          if c == CONSOLE_BUFFER:
            break

    ,
    reset: proc(node: var node, memory_store: var openArray[uint64]) =
      var i = 0.uint64
      while i < CONSOLE_BUFFER:
        node.node_set_memory(memory_store, i, 0'u64)
        inc i
      while i < CONSOLE_BUFFER * 2:
        node.node_set_memory(memory_store, i, 0xFFFFFF'u64)
        inc i
  ),

  Keyboard: prototype(
    sandbox_only: true,
    sandbox: true,
    area: @[
      point(x: -1, y: -2), point(x: 0, y: -2), point(x: 1, y: -2),
      point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1),
      point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0),
      point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1),
      point(x: -1, y: 2), point(x: 0, y: 2), point(x: 1, y: 2),
    ],
    input_pins: @[
      prototype_pin(position: point(x: -2, y: -2)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -3)),
      prototype_pin(position: point(x: 2, y: -2), kind: wk_8),
      prototype_pin(position: point(x: 2, y: -1)),
    ],
    memory: KEYBOARD_BUFFER + 2, # 0 save pointer, 1 read pointer
    category: @[CAT_IO, CAT_SANDBOX_ONLY],
    reset: proc(node: var node, memory_store: var openArray[uint64]) =
      node.setting_1 = 0
  ),

  Constant8: prototype(
    sandbox: true,
    menu_order: 0.uint8,
    area: @[point(x: 0, y: 0)],
    input_pins: @[],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8),
    ],
    memory: 1,
    category: @[CAT_8_BIT],
  ),

  Not8: prototype(
    sandbox: true,
    sandbox_score: score(gate: 8, delay: 2),
    menu_order: 6.uint8,
    area: @[point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8),
    ],
    category: @[CAT_8_BIT, CAT_LOGIC],
  ),

  Or8: prototype(
    sandbox: true,
    menu_order: 8.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8),
    ],
    category: @[CAT_8_BIT,CAT_LOGIC],
  ),

  And8: prototype(
    sandbox: true,
    menu_order: 7.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8),
    ],
    category: @[CAT_8_BIT,CAT_LOGIC],
  ),

  Nand8: prototype(
    sandbox: true,
    menu_order: 9.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8),
    ],
    category: @[CAT_8_BIT,CAT_LOGIC],
  ),

  Nor8: prototype(
    sandbox: true,
    menu_order: 10.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8),
    ],
    category: @[CAT_8_BIT,CAT_LOGIC],
  ),

  Xnor8: prototype(
    sandbox: true,
    menu_order: 12.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8),
    ],
    category: @[CAT_8_BIT,CAT_LOGIC],
  ),

  Xor8: prototype(
    sandbox: true,
    menu_order: 11.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8),
    ],
    category: @[CAT_8_BIT,CAT_LOGIC],
  ),

  Equal8: prototype(
    sandbox: true,
    sandbox_score: score(gate: 35, delay: 30),
    menu_order: 18.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0)),
    ],
    category: @[CAT_8_BIT,CAT_MATH],
  ),

  LessU8: prototype(
    sandbox: true,
    sandbox_score: score(gate: 100, delay: 35),
    menu_order: 19.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0)),
    ],
    category: @[CAT_8_BIT,CAT_MATH],
  ),

  LessI8: prototype(
    sandbox: true,
    sandbox_score: score(gate: 100, delay: 35),
    menu_order: 20.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0)),
    ],
    category: @[CAT_8_BIT,CAT_MATH],
  ),
  Neg8: prototype(
    sandbox: true,
    sandbox_score: score(gate: 100, delay: 50),
    menu_order: 15.uint8,
    area: @[point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8),
    ],
    category: @[CAT_8_BIT,CAT_MATH],
  ),

  Add8: prototype(
    sandbox: true,
    sandbox_score: score(gate: 100, delay: 100),
    menu_order: 16.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1)),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 1), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: 1, y: 0)),
    ],
    category: @[CAT_8_BIT,CAT_MATH],
  ),

  Mul8: prototype(
    sandbox: true,
    sandbox_score: score(gate: 400, delay: 400),
    menu_order: 17.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8),
    ],
    category: @[CAT_8_BIT,CAT_MATH],
  ),

  DivMod8: prototype(
    sandbox: true,
    sandbox_score: score(gate: 656, delay: 546),
    menu_order: 17.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8),
    ],
    category: @[CAT_8_BIT,CAT_MATH],
  ),

  Shl8: prototype(
    sandbox: true,
    sandbox_score: score(gate: 150, delay: 25),
    menu_order: 13.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_8),
    ],
    category: @[CAT_8_BIT,CAT_LOGIC],
  ),

  Shr8: prototype(
    sandbox: true,
    sandbox_score: score(gate: 150, delay: 25),
    menu_order: 14.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_8),
    ],
    category: @[CAT_8_BIT,CAT_LOGIC],
  ),

  Ashr8: prototype(
    sandbox: true,
    sandbox_score: score(gate: 150, delay: 25),
    menu_order: 14.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_8),
    ],
    category: @[CAT_8_BIT,CAT_MATH],
  ),

  Rol8: prototype(
    sandbox: true,
    sandbox_score: score(gate: 150, delay: 25),
    menu_order: 14.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_8),
    ],
    category: @[CAT_8_BIT,CAT_LOGIC],
  ),

  Ror8: prototype(
    sandbox: true,
    sandbox_score: score(gate: 150, delay: 25),
    menu_order: 14.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_8),
    ],
    category: @[CAT_8_BIT,CAT_LOGIC],
  ),

  Mux8: prototype(
    sandbox: true,
    sandbox_score: score(gate: 25, delay: 8),
    menu_order: 5.uint8,
    area: @[point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1)),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 1), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8),
    ],
    category: @[CAT_8_BIT],
  ),

  Switch8: prototype(
    sandbox: true,
    menu_order: 4.uint8,
    area: @[point(x: 0, y: 0)],
    #condition_pin: point(x: 0, y: -1),
    input_pins: @[
      prototype_pin(position: point(x: 0, y: -1)),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8, tri_state: true),
    ],
    category: @[CAT_8_BIT],
  ),

  Register8: prototype(
    sandbox: true,
    sandbox_score: score(gate: 50, delay: 10),
    menu_order: 21.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8, tri_state: true),
    ],
    has_virtual: true,
    category: @[CAT_8_BIT],
    memory: 1,
  ),
  VirtualRegister8: prototype(
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0)),
      prototype_pin(position: point(x: -1, y: 1), kind: wk_8),
    ],
  ),
  Register8Red: prototype(
    area: @[point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1), point(x: 1, y: 1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8, tri_state: true),
    ],
    has_virtual: true,
    category: @[CAT_IO],
    immutable: true,
    memory: 1,
  ),
  VirtualRegister8Red: prototype(
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0)),
      prototype_pin(position: point(x: -1, y: 1), kind: wk_8),
    ],
  ),
  Register8RedPlus: prototype(
    area: @[point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8, tri_state: true),
      prototype_pin(position: point(x: 1, y: 1), kind: wk_8),
    ],
    has_virtual: true,
    category: @[CAT_IO],
    immutable: true,
    memory: 1,
  ),
  VirtualRegister8RedPlus: prototype(
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0)),
      prototype_pin(position: point(x: -1, y: 1), kind: wk_8),
    ],
  ),
  Counter8: prototype(
    sandbox: true,
    sandbox_score: score(gate: 150, delay: 100),
    default_setting_1: 1,
    menu_order: 22.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1), point(x: -1, y: 1)],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8),
    ],
    has_virtual: true,
    category: @[CAT_8_BIT],
    memory: 1,
  ),
  VirtualCounter8: prototype(
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1)),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
  ),



  Constant16: prototype(
    sandbox: true,
    menu_order: 0.uint8,
    area: @[
      point(x: -1, y: -1), point(x: -1, y: 0), point(x: -1, y: 1),
      point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1),
      point(x: 1, y: -1), point(x: 1, y: 0), point(x: 1, y: 1),
    ],
    input_pins: @[],
    output_pins: @[
      prototype_pin(position: point(x: 2, y: 0), kind: wk_16),
    ],
    memory: 1,
    category: @[CAT_16_BIT],
  ),

  Not16: prototype(
    sandbox: true,
    menu_order: 6.uint8,
    area: @[point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), kind: wk_16),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_16),
    ],
    category: @[CAT_16_BIT,CAT_LOGIC],
  ),

  Or16: prototype(
    sandbox: true,
    menu_order: 8.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_16),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_16),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_16),
    ],
    category: @[CAT_16_BIT,CAT_LOGIC],
  ),

  And16: prototype(
    sandbox: true,
    menu_order: 7.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_16),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_16),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_16),
    ],
    category: @[CAT_16_BIT,CAT_LOGIC],
  ),

  Nand16: prototype(
    sandbox: true,
    menu_order: 9.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_16),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_16),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_16),
    ],
    category: @[CAT_16_BIT,CAT_LOGIC],
  ),

  Nor16: prototype(
    sandbox: true,
    menu_order: 10.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_16),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_16),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_16),
    ],
    category: @[CAT_16_BIT,CAT_LOGIC],
  ),

  Xnor16: prototype(
    sandbox: true,
    menu_order: 12.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_16),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_16),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_16),
    ],
    category: @[CAT_16_BIT,CAT_LOGIC],
  ),

  Xor16: prototype(
    sandbox: true,
    menu_order: 11.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_16),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_16),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_16),
    ],
    category: @[CAT_16_BIT,CAT_LOGIC],
  ),

  Equal16: prototype(
    sandbox: true,
    menu_order: 18.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_16),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_16),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0)),
    ],
    category: @[CAT_16_BIT,CAT_MATH],
  ),

  LessU16: prototype(
    sandbox: true,
    menu_order: 19.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_16),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_16),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0)),
    ],
    category: @[CAT_16_BIT,CAT_MATH],
  ),

  LessI16: prototype(
    sandbox: true,
    menu_order: 21.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_16),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_16),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0)),
    ],
    category: @[CAT_16_BIT,CAT_MATH],
  ),
  Neg16: prototype(
    sandbox: true,
    menu_order: 15.uint8,
    area: @[point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), kind: wk_16),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_16),
    ],
    category: @[CAT_16_BIT,CAT_MATH],
  ),

  Add16: prototype(
    sandbox: true,
    menu_order: 16.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1)),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_16),
      prototype_pin(position: point(x: -1, y: 1), kind: wk_16),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_16),
      prototype_pin(position: point(x: 1, y: 0)),
    ],
    category: @[CAT_16_BIT,CAT_MATH],
  ),

  Mul16: prototype(
    sandbox: true,
    menu_order: 17.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_16),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_16),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_16),
      prototype_pin(position: point(x: 1, y: 0), kind: wk_16),
    ],
    category: @[CAT_16_BIT,CAT_MATH],
  ),

  DivMod16: prototype(
    sandbox: true,
    sandbox_score: score(gate: 2016, delay: 1666),
    menu_order: 17.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_16),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_16),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_16),
      prototype_pin(position: point(x: 1, y: 0), kind: wk_16),
    ],
    category: @[CAT_16_BIT,CAT_MATH],
  ),

  Shl16: prototype(
    sandbox: true,
    menu_order: 13.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_16),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_16),
    ],
    category: @[CAT_16_BIT,CAT_LOGIC],
  ),

  Shr16: prototype(
    sandbox: true,
    menu_order: 14.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_16),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_16),
    ],
    category: @[CAT_16_BIT,CAT_LOGIC],
  ),

  Ashr16: prototype(
    sandbox: true,
    menu_order: 14.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_16),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_16),
    ],
    category: @[CAT_16_BIT,CAT_MATH],
  ),

  Rol16: prototype(
    sandbox: true,
    menu_order: 14.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_16),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_16),
    ],
    category: @[CAT_16_BIT,CAT_LOGIC],
  ),

  Ror16: prototype(
    sandbox: true,
    menu_order: 14.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_16),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_16),
    ],
    category: @[CAT_16_BIT,CAT_LOGIC],
  ),

  Mux16: prototype(
    sandbox: true,
    menu_order: 5.uint8,
    area: @[point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1)),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_16),
      prototype_pin(position: point(x: -1, y: 1), kind: wk_16),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_16),
    ],
    category: @[CAT_16_BIT],
  ),

  Switch16: prototype(
    sandbox: true,
    menu_order: 4.uint8,
    area: @[point(x: 0, y: 0)],
    #condition_pin: point(x: 0, y: -1),
    input_pins: @[
      prototype_pin(position: point(x: 0, y: -1)),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_16),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_16, tri_state: true),
    ],
    category: @[CAT_16_BIT],
  ),

  Splitter16: prototype(
    sandbox: true,
    menu_order: 2.uint8,
    area: @[point(x: 0, y: 0), point(x: 0, y: -1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), kind: wk_16),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8),
    ],
    category: @[CAT_16_BIT],
  ),

  Maker16: prototype(
    sandbox: true,
    menu_order: 1.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_16),
    ],
    category: @[CAT_16_BIT],
  ),
  Register16: prototype(
    sandbox: true,
    menu_order: 21.uint8,
    area: @[
      point(x: -1, y: -1), point(x: -1, y: 0), point(x: -1, y: 1),
      point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1),
      point(x: 1, y: -1), point(x: 1, y: 0), point(x: 1, y: 1),
    ],
    input_pins: @[
      prototype_pin(position: point(x: -2, y: -1)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 2, y: 0), kind: wk_16, tri_state: true),
    ],
    has_virtual: true,
    category: @[CAT_16_BIT],
    memory: 1,
  ),
  VirtualRegister16: prototype(
    input_pins: @[
      prototype_pin(position: point(x: -2, y: 0)),
      prototype_pin(position: point(x: -2, y: 1), kind: wk_16),
    ],
  ),
  Counter16: prototype(
    sandbox: true,
    default_setting_1: 1,
    menu_order: 22.uint8,
    area: @[
      point(x: -1, y: -1), point(x: -1, y: 0), point(x: -1, y: 1),
      point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1),
      point(x: 1, y: -1), point(x: 1, y: 0), point(x: 1, y: 1),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 2, y: 0), kind: wk_16),
    ],
    has_virtual: true,
    category: @[CAT_16_BIT],
    memory: 1,
  ),
  VirtualCounter16: prototype(
    input_pins: @[
      prototype_pin(position: point(x: -2, y: -1)),
      prototype_pin(position: point(x: -2, y: 0), kind: wk_16),
    ],
  ),



  Constant32: prototype(
    sandbox: true,
    menu_order: 0.uint8,
    area: @[
      point(x: -1, y: -1), point(x: -1, y: 0), point(x: -1, y: 1),
      point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1),
      point(x: 1, y: -1), point(x: 1, y: 0), point(x: 1, y: 1),
    ],
    input_pins: @[],
    output_pins: @[
      prototype_pin(position: point(x: 2, y: 0), kind: wk_32),
    ],
    memory: 1,
    category: @[CAT_32_BIT],
  ),

  Not32: prototype(
    sandbox: true,
    menu_order: 6.uint8,
    area: @[point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), kind: wk_32),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_32),
    ],
    category: @[CAT_32_BIT,CAT_LOGIC],
  ),

  Or32: prototype(
    sandbox: true,
    menu_order: 8.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_32),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_32),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_32),
    ],
    category: @[CAT_32_BIT,CAT_LOGIC],
  ),

  And32: prototype(
    sandbox: true,
    menu_order: 7.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_32),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_32),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_32),
    ],
    category: @[CAT_32_BIT,CAT_LOGIC],
  ),

  Nand32: prototype(
    sandbox: true,
    menu_order: 9.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_32),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_32),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_32),
    ],
    category: @[CAT_32_BIT,CAT_LOGIC],
  ),

  Nor32: prototype(
    sandbox: true,
    menu_order: 10.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_32),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_32),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_32),
    ],
    category: @[CAT_32_BIT,CAT_LOGIC],
  ),


  Xnor32: prototype(
    sandbox: true,
    menu_order: 12.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_32),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_32),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_32),
    ],
    category: @[CAT_32_BIT,CAT_LOGIC],
  ),

  Xor32: prototype(
    sandbox: true,
    menu_order: 11.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_32),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_32),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_32),
    ],
    category: @[CAT_32_BIT,CAT_LOGIC],
  ),

  Equal32: prototype(
    sandbox: true,
    menu_order: 18.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_32),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_32),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0)),
    ],
    category: @[CAT_32_BIT,CAT_MATH],
  ),

  LessU32: prototype(
    sandbox: true,
    menu_order: 19.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_32),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_32),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0)),
    ],
    category: @[CAT_32_BIT,CAT_MATH],
  ),

  LessI32: prototype(
    sandbox: true,
    menu_order: 20.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_32),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_32),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0)),
    ],
    category: @[CAT_32_BIT,CAT_MATH],
  ),
  Neg32: prototype(
    sandbox: true,
    menu_order: 15.uint8,
    area: @[point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), kind: wk_32),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_32),
    ],
    category: @[CAT_32_BIT,CAT_MATH],
  ),

  Add32: prototype(
    sandbox: true,
    menu_order: 16.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1)),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_32),
      prototype_pin(position: point(x: -1, y: 1), kind: wk_32),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_32),
      prototype_pin(position: point(x: 1, y: 0)),
    ],
    category: @[CAT_32_BIT,CAT_MATH],
  ),

  Mul32: prototype(
    sandbox: true,
    menu_order: 17.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_32),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_32),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_32),
      prototype_pin(position: point(x: 1, y: 0), kind: wk_32),
    ],
    category: @[CAT_32_BIT,CAT_MATH],
  ),

  DivMod32: prototype(
    sandbox: true,
    sandbox_score: score(gate: 4032, delay: 2466),
    menu_order: 17.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_32),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_32),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_32),
      prototype_pin(position: point(x: 1, y: 0), kind: wk_32),
    ],
    category: @[CAT_32_BIT,CAT_MATH],
  ),

  Shl32: prototype(
    sandbox: true,
    menu_order: 13.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_32),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_32),
    ],
    category: @[CAT_32_BIT,CAT_LOGIC],
  ),

  Shr32: prototype(
    sandbox: true,
    menu_order: 14.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_32),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_32),
    ],
    category: @[CAT_32_BIT,CAT_LOGIC],
  ),

  Ashr32: prototype(
    sandbox: true,
    menu_order: 14.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_32),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_32),
    ],
    category: @[CAT_32_BIT,CAT_MATH],
  ),

  Rol32: prototype(
    sandbox: true,
    menu_order: 14.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_32),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_32),
    ],
    category: @[CAT_32_BIT,CAT_LOGIC],
  ),

  Ror32: prototype(
    sandbox: true,
    menu_order: 14.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_32),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_32),
    ],
    category: @[CAT_32_BIT,CAT_LOGIC],
  ),

  Mux32: prototype(
    sandbox: true,
    menu_order: 5.uint8,
    area: @[point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1)),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_32),
      prototype_pin(position: point(x: -1, y: 1), kind: wk_32),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_32),
    ],
    category: @[CAT_32_BIT],
  ),

  Switch32: prototype(
    sandbox: true,
    menu_order: 4.uint8,
    area: @[point(x: 0, y: 0)],
    #condition_pin: point(x: 0, y: -1),
    input_pins: @[
      prototype_pin(position: point(x: 0, y: -1)),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_32),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_32, tri_state: true),
    ],
    category: @[CAT_32_BIT],
  ),

  Splitter32: prototype(
    sandbox: true,
    menu_order: 2.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1), point(x: 0, y: 2)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), kind: wk_32),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8),
      prototype_pin(position: point(x: 1, y: 1), kind: wk_8),
      prototype_pin(position: point(x: 1, y: 2), kind: wk_8),
    ],
    category: @[CAT_32_BIT],
  ),

  Maker32: prototype(
    sandbox: true,
    menu_order: 1.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1), point(x: 0, y: 2)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 1), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 2), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_32),
    ],
    category: @[CAT_32_BIT],
  ),
  Register32: prototype(
    sandbox: true,
    menu_order: 21.uint8,
    area: @[
      point(x: -1, y: -1), point(x: -1, y: 0), point(x: -1, y: 1),
      point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1),
      point(x: 1, y: -1), point(x: 1, y: 0), point(x: 1, y: 1),
    ],
    input_pins: @[
      prototype_pin(position: point(x: -2, y: -1)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 2, y: 0), kind: wk_32, tri_state: true),
    ],
    has_virtual: true,
    category: @[CAT_32_BIT],
    memory: 1,
  ),
  VirtualRegister32: prototype(
    input_pins: @[
      prototype_pin(position: point(x: -2, y: 0)),
      prototype_pin(position: point(x: -2, y: 1), kind: wk_32),
    ],
  ),
  Counter32: prototype(
    sandbox: true,
    default_setting_1: 1,
    menu_order: 22.uint8,
    area: @[
      point(x: -1, y: -1), point(x: -1, y: 0), point(x: -1, y: 1),
      point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1),
      point(x: 1, y: -1), point(x: 1, y: 0), point(x: 1, y: 1),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 2, y: 0), kind: wk_32),
    ],
    has_virtual: true,
    category: @[CAT_32_BIT],
    memory: 1,
  ),
  VirtualCounter32: prototype(
    input_pins: @[
      prototype_pin(position: point(x: -2, y: -1)),
      prototype_pin(position: point(x: -2, y: 0), kind: wk_32),
    ],
  ),






  Constant64: prototype(
    sandbox: true,
    menu_order: 0.uint8,
    area: @[
      point(x: -2, y: -1), point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1), point(x: 2, y: -1),
      point(x: -2, y: 0), point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0), point(x: 2, y: 0),
      point(x: -2, y: 1), point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1), point(x: 2, y: 1),
    ],
    input_pins: @[],
    output_pins: @[
      prototype_pin(position: point(x: 3, y: 0), kind: wk_64),
    ],
    memory: 1,
    category: @[CAT_64_BIT],
  ),

  Not64: prototype(
    sandbox: true,
    menu_order: 6.uint8,
    area: @[point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), kind: wk_64),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_64),
    ],
    category: @[CAT_64_BIT,CAT_LOGIC],
  ),

  Or64: prototype(
    sandbox: true,
    menu_order: 8.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_64),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_64),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_64),
    ],
    category: @[CAT_64_BIT,CAT_LOGIC],
  ),

  And64: prototype(
    sandbox: true,
    menu_order: 7.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_64),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_64),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_64),
    ],
    category: @[CAT_64_BIT,CAT_LOGIC],
  ),

  Nand64: prototype(
    sandbox: true,
    menu_order: 9.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_64),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_64),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_64),
    ],
    category: @[CAT_64_BIT,CAT_LOGIC],
  ),

  Nor64: prototype(
    sandbox: true,
    menu_order: 10.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_64),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_64),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_64),
    ],
    category: @[CAT_64_BIT,CAT_LOGIC],
  ),

  Xnor64: prototype(
    sandbox: true,
    menu_order: 12.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_64),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_64),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_64),
    ],
    category: @[CAT_64_BIT,CAT_LOGIC],
  ),

  Xor64: prototype(
    sandbox: true,
    menu_order: 11.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_64),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_64),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_64),
    ],
    category: @[CAT_64_BIT,CAT_LOGIC],
  ),

  Equal64: prototype(
    sandbox: true,
    menu_order: 18.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_64),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_64),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0)),
    ],
    category: @[CAT_64_BIT,CAT_MATH],
  ),

  LessU64: prototype(
    sandbox: true,
    menu_order: 19.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_64),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_64),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0)),
    ],
    category: @[CAT_64_BIT,CAT_MATH],
  ),

  LessI64: prototype(
    sandbox: true,
    menu_order: 20.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_64),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_64),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0)),
    ],
    category: @[CAT_64_BIT,CAT_MATH],
  ),

  Neg64: prototype(
    sandbox: true,
    menu_order: 15.uint8,
    area: @[point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), kind: wk_64),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_64),
    ],
    category: @[CAT_64_BIT,CAT_MATH],
  ),

  Add64: prototype(
    sandbox: true,
    menu_order: 16.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1)),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_64),
      prototype_pin(position: point(x: -1, y: 1), kind: wk_64),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_64),
      prototype_pin(position: point(x: 1, y: 0)),
    ],
    category: @[CAT_64_BIT,CAT_MATH],
  ),

  Mul64: prototype(
    sandbox: true,
    menu_order: 17.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_64),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_64),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_64),
      prototype_pin(position: point(x: 1, y: 0), kind: wk_64),
    ],
    category: @[CAT_64_BIT,CAT_MATH],
  ),

  DivMod64: prototype(
    sandbox: true,
    sandbox_score: score(gate: 7864, delay: 3266),
    menu_order: 17.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_64),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_64),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_64),
      prototype_pin(position: point(x: 1, y: 0), kind: wk_64),
    ],
    category: @[CAT_64_BIT,CAT_MATH],
  ),

  Shl64: prototype(
    sandbox: true,
    menu_order: 13.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_64),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_64),
    ],
    category: @[CAT_64_BIT,CAT_LOGIC],
  ),

  Shr64: prototype(
    sandbox: true,
    menu_order: 14.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_64),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_64),
    ],
    category: @[CAT_64_BIT,CAT_LOGIC],
  ),

  Ashr64: prototype(
    sandbox: true,
    menu_order: 14.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_64),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_64),
    ],
    category: @[CAT_64_BIT,CAT_MATH],
  ),

  Rol64: prototype(
    sandbox: true,
    menu_order: 14.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_64),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_64),
    ],
    category: @[CAT_64_BIT,CAT_LOGIC],
  ),


  Ror64: prototype(
    sandbox: true,
    menu_order: 14.uint8,
    area: @[point(x: 0, y: -1), point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), kind: wk_64),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -1), kind: wk_64),
    ],
    category: @[CAT_64_BIT,CAT_LOGIC],
  ),

  FullAdder: prototype(
    sandbox: true,
    sandbox_score: score(gate: 8, delay: 8),
    menu_order: 11.uint8,
    area: @[point(x: 0, y: 0), point(x: 0, y: 1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1)),
      prototype_pin(position: point(x: -1, y: 0)),
      prototype_pin(position: point(x: -1, y: 1)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0)),
      prototype_pin(position: point(x: 1, y: 1)),
    ],
    category: @[CAT_1_BIT],
  ),

  Splitter8: prototype(
    sandbox: true,
    menu_order: 2.uint8,
    area: @[point(x: 0, y: -3), point(x: 0, y: -2), point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1), point(x: 0, y: 2), point(x: 0, y: 3), point(x: 0, y: 4)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -3)),
      prototype_pin(position: point(x: 1, y: -2)),
      prototype_pin(position: point(x: 1, y: -1)),
      prototype_pin(position: point(x: 1, y: 0)),
      prototype_pin(position: point(x: 1, y: 1)),
      prototype_pin(position: point(x: 1, y: 2)),
      prototype_pin(position: point(x: 1, y: 3)),
      prototype_pin(position: point(x: 1, y: 4)),
    ],
    category: @[CAT_8_BIT],
  ),

  Maker8: prototype(
    sandbox: true,
    menu_order: 1.uint8,
    area: @[point(x: 0, y: -3), point(x: 0, y: -2), point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1), point(x: 0, y: 2), point(x: 0, y: 3), point(x: 0, y: 4)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -3)),
      prototype_pin(position: point(x: -1, y: -2)),
      prototype_pin(position: point(x: -1, y: -1)),
      prototype_pin(position: point(x: -1, y: 0)),
      prototype_pin(position: point(x: -1, y: 1)),
      prototype_pin(position: point(x: -1, y: 2)),
      prototype_pin(position: point(x: -1, y: 3)),
      prototype_pin(position: point(x: -1, y: 4)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8),
    ],
    category: @[CAT_8_BIT],
  ),

  Splitter64: prototype(
    sandbox: true,
    menu_order: 2.uint8,
    area: @[point(x: 0, y: -3), point(x: 0, y: -2), point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1), point(x: 0, y: 2), point(x: 0, y: 3), point(x: 0, y: 4)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), kind: wk_64),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -3), kind: wk_8),
      prototype_pin(position: point(x: 1, y: -2), kind: wk_8),
      prototype_pin(position: point(x: 1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8),
      prototype_pin(position: point(x: 1, y: 1), kind: wk_8),
      prototype_pin(position: point(x: 1, y: 2), kind: wk_8),
      prototype_pin(position: point(x: 1, y: 3), kind: wk_8),
      prototype_pin(position: point(x: 1, y: 4), kind: wk_8),
    ],
    category: @[CAT_64_BIT],
  ),

  Maker64: prototype(
    sandbox: true,
    menu_order: 1.uint8,
    area: @[point(x: 0, y: -3), point(x: 0, y: -2), point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1), point(x: 0, y: 2), point(x: 0, y: 3), point(x: 0, y: 4)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -3), kind: wk_8),
      prototype_pin(position: point(x: -1, y: -2), kind: wk_8),
      prototype_pin(position: point(x: -1, y: -1), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 1), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 2), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 3), kind: wk_8),
      prototype_pin(position: point(x: -1, y: 4), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_64),
    ],
    category: @[CAT_64_BIT],
  ),

  DelayLine1: prototype(
    sandbox: true,
    menu_order: 16.uint8,
    area: @[point(x: 0, y: 0)],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0)),
    ],
    has_virtual: true,
    memory: 1,
    category: @[CAT_1_BIT],
  ),

  VirtualDelayLine1: prototype(
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0)),
    ],
  ),

  DelayLine8: prototype(
    sandbox: true,
    menu_order: 23.uint8,
    area: @[point(x: 0, y: 0)],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8),
    ],
    has_virtual: true,
    category: @[CAT_8_BIT],
    memory: 1,
  ),
  VirtualDelayLine8: prototype(
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
  ),

  DelayLine16: prototype(
    sandbox: true,
    menu_order: 23.uint8,
    area: @[
      point(x: -1, y: -1), point(x: -1, y: 0), point(x: -1, y: 1),
      point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1),
      point(x: 1, y: -1), point(x: 1, y: 0), point(x: 1, y: 1),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 2, y: 0), kind: wk_16),
    ],
    has_virtual: true,
    category: @[CAT_16_BIT],
    memory: 1,
  ),
  VirtualDelayLine16: prototype(
    input_pins: @[
      prototype_pin(position: point(x: -2, y: 0), kind: wk_16),
    ],
  ),

  DelayLine32: prototype(
    sandbox: true,
    menu_order: 23.uint8,
    area: @[
      point(x: -1, y: -1), point(x: -1, y: 0), point(x: -1, y: 1),
      point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1),
      point(x: 1, y: -1), point(x: 1, y: 0), point(x: 1, y: 1),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 2, y: 0), kind: wk_32),
    ],
    has_virtual: true,
    category: @[CAT_32_BIT],
    memory: 1,
  ),
  VirtualDelayLine32: prototype(
    input_pins: @[
      prototype_pin(position: point(x: -2, y: 0), kind: wk_32),
    ],
  ),

  DelayLine64: prototype(
    sandbox: true,
    menu_order: 23.uint8,
    area: @[
      point(x: -2, y: -1), point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1), point(x: 2, y: -1),
      point(x: -2, y: 0), point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0), point(x: 2, y: 0),
      point(x: -2, y: 1), point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1), point(x: 2, y: 1),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 3, y: 0), kind: wk_64),
    ],
    has_virtual: true,
    category: @[CAT_64_BIT],
    memory: 1,
  ),
  VirtualDelayLine64: prototype(
    input_pins: @[
      prototype_pin(position: point(x: -3, y: 0), kind: wk_64),
    ],
  ),

  BitMemory: prototype(
    sandbox: true,
    sandbox_score: score(gate: 4, delay: 4),
    menu_order: 15.uint8,
    area: @[point(x: -1, y: 0), point(x: 0, y: 0), point(x: 0, y: -1), point(x: 0, y: 1)],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0)),
    ],
    has_virtual: true,
    memory: 1,
    category: @[CAT_1_BIT],
  ),
  VirtualBitMemory: prototype(
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1)),
      prototype_pin(position: point(x: -1, y: 1)),
    ],
  ),

  ProbeMemoryBit: prototype(
    sandbox: true,
    area: @[point(x: 0, y: 0)],
    input_pins: @[],
    output_pins: @[],
    category: @[CAT_IO, CAT_PROBES],
  ),

  ProbeMemoryWord: prototype(
    sandbox: true,
    area: @[point(x: 0, y: 0)],
    input_pins: @[],
    output_pins: @[],
    category: @[CAT_IO, CAT_PROBES],
  ),

  ProbeWireBit: prototype(
    sandbox: true,
    area: @[point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: 0, y: -1)),
    ],
    output_pins: @[],
    category: @[CAT_IO, CAT_PROBES],
  ),

  ProbeWireWord: prototype(
    sandbox: true,
    area: @[point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: 0, y: -1), kind: wk_64),
    ],
    output_pins: @[],
    category: @[CAT_IO, CAT_PROBES],
  ),
  LevelScreen: prototype(
    area: @[
      point(x: -15, y: -10), point(x: -14, y: -10), point(x: -13, y: -10), point(x: -12, y: -10), point(x: -11, y: -10), point(x: -10, y: -10), point(x: -9, y: -10), point(x: -8, y: -10), point(x: -7, y: -10), point(x: -6, y: -10), point(x: -5, y: -10), point(x: -4, y: -10), point(x: -3, y: -10), point(x: -2, y: -10), point(x: -1, y: -10), point(x: 0, y: -10), point(x: 1, y: -10), point(x: 2, y: -10), point(x: 3, y: -10), point(x: 4, y: -10), point(x: 5, y: -10), point(x: 6, y: -10), point(x: 7, y: -10), point(x: 8, y: -10), point(x: 9, y: -10), point(x: 10, y: -10), point(x: 11, y: -10), point(x: 12, y: -10), point(x: 13, y: -10), point(x: 14, y: -10), point(x: 15, y: -10),
      point(x: -15, y: -9), point(x: -14, y: -9), point(x: -13, y: -9), point(x: -12, y: -9), point(x: -11, y: -9), point(x: -10, y: -9), point(x: -9, y: -9), point(x: -8, y: -9), point(x: -7, y: -9), point(x: -6, y: -9), point(x: -5, y: -9), point(x: -4, y: -9), point(x: -3, y: -9), point(x: -2, y: -9), point(x: -1, y: -9), point(x: 0, y: -9), point(x: 1, y: -9), point(x: 2, y: -9), point(x: 3, y: -9), point(x: 4, y: -9), point(x: 5, y: -9), point(x: 6, y: -9), point(x: 7, y: -9), point(x: 8, y: -9), point(x: 9, y: -9), point(x: 10, y: -9), point(x: 11, y: -9), point(x: 12, y: -9), point(x: 13, y: -9), point(x: 14, y: -9), point(x: 15, y: -9),
      point(x: -15, y: -8), point(x: -14, y: -8), point(x: -13, y: -8), point(x: -12, y: -8), point(x: -11, y: -8), point(x: -10, y: -8), point(x: -9, y: -8), point(x: -8, y: -8), point(x: -7, y: -8), point(x: -6, y: -8), point(x: -5, y: -8), point(x: -4, y: -8), point(x: -3, y: -8), point(x: -2, y: -8), point(x: -1, y: -8), point(x: 0, y: -8), point(x: 1, y: -8), point(x: 2, y: -8), point(x: 3, y: -8), point(x: 4, y: -8), point(x: 5, y: -8), point(x: 6, y: -8), point(x: 7, y: -8), point(x: 8, y: -8), point(x: 9, y: -8), point(x: 10, y: -8), point(x: 11, y: -8), point(x: 12, y: -8), point(x: 13, y: -8), point(x: 14, y: -8), point(x: 15, y: -8),
      point(x: -15, y: -7), point(x: -14, y: -7), point(x: -13, y: -7), point(x: -12, y: -7), point(x: -11, y: -7), point(x: -10, y: -7), point(x: -9, y: -7), point(x: -8, y: -7), point(x: -7, y: -7), point(x: -6, y: -7), point(x: -5, y: -7), point(x: -4, y: -7), point(x: -3, y: -7), point(x: -2, y: -7), point(x: -1, y: -7), point(x: 0, y: -7), point(x: 1, y: -7), point(x: 2, y: -7), point(x: 3, y: -7), point(x: 4, y: -7), point(x: 5, y: -7), point(x: 6, y: -7), point(x: 7, y: -7), point(x: 8, y: -7), point(x: 9, y: -7), point(x: 10, y: -7), point(x: 11, y: -7), point(x: 12, y: -7), point(x: 13, y: -7), point(x: 14, y: -7), point(x: 15, y: -7),
      point(x: -15, y: -6), point(x: -14, y: -6), point(x: -13, y: -6), point(x: -12, y: -6), point(x: -11, y: -6), point(x: -10, y: -6), point(x: -9, y: -6), point(x: -8, y: -6), point(x: -7, y: -6), point(x: -6, y: -6), point(x: -5, y: -6), point(x: -4, y: -6), point(x: -3, y: -6), point(x: -2, y: -6), point(x: -1, y: -6), point(x: 0, y: -6), point(x: 1, y: -6), point(x: 2, y: -6), point(x: 3, y: -6), point(x: 4, y: -6), point(x: 5, y: -6), point(x: 6, y: -6), point(x: 7, y: -6), point(x: 8, y: -6), point(x: 9, y: -6), point(x: 10, y: -6), point(x: 11, y: -6), point(x: 12, y: -6), point(x: 13, y: -6), point(x: 14, y: -6), point(x: 15, y: -6),
      point(x: -15, y: -5), point(x: -14, y: -5), point(x: -13, y: -5), point(x: -12, y: -5), point(x: -11, y: -5), point(x: -10, y: -5), point(x: -9, y: -5), point(x: -8, y: -5), point(x: -7, y: -5), point(x: -6, y: -5), point(x: -5, y: -5), point(x: -4, y: -5), point(x: -3, y: -5), point(x: -2, y: -5), point(x: -1, y: -5), point(x: 0, y: -5), point(x: 1, y: -5), point(x: 2, y: -5), point(x: 3, y: -5), point(x: 4, y: -5), point(x: 5, y: -5), point(x: 6, y: -5), point(x: 7, y: -5), point(x: 8, y: -5), point(x: 9, y: -5), point(x: 10, y: -5), point(x: 11, y: -5), point(x: 12, y: -5), point(x: 13, y: -5), point(x: 14, y: -5), point(x: 15, y: -5),
      point(x: -15, y: -4), point(x: -14, y: -4), point(x: -13, y: -4), point(x: -12, y: -4), point(x: -11, y: -4), point(x: -10, y: -4), point(x: -9, y: -4), point(x: -8, y: -4), point(x: -7, y: -4), point(x: -6, y: -4), point(x: -5, y: -4), point(x: -4, y: -4), point(x: -3, y: -4), point(x: -2, y: -4), point(x: -1, y: -4), point(x: 0, y: -4), point(x: 1, y: -4), point(x: 2, y: -4), point(x: 3, y: -4), point(x: 4, y: -4), point(x: 5, y: -4), point(x: 6, y: -4), point(x: 7, y: -4), point(x: 8, y: -4), point(x: 9, y: -4), point(x: 10, y: -4), point(x: 11, y: -4), point(x: 12, y: -4), point(x: 13, y: -4), point(x: 14, y: -4), point(x: 15, y: -4),
      point(x: -15, y: -3), point(x: -14, y: -3), point(x: -13, y: -3), point(x: -12, y: -3), point(x: -11, y: -3), point(x: -10, y: -3), point(x: -9, y: -3), point(x: -8, y: -3), point(x: -7, y: -3), point(x: -6, y: -3), point(x: -5, y: -3), point(x: -4, y: -3), point(x: -3, y: -3), point(x: -2, y: -3), point(x: -1, y: -3), point(x: 0, y: -3), point(x: 1, y: -3), point(x: 2, y: -3), point(x: 3, y: -3), point(x: 4, y: -3), point(x: 5, y: -3), point(x: 6, y: -3), point(x: 7, y: -3), point(x: 8, y: -3), point(x: 9, y: -3), point(x: 10, y: -3), point(x: 11, y: -3), point(x: 12, y: -3), point(x: 13, y: -3), point(x: 14, y: -3), point(x: 15, y: -3),
      point(x: -15, y: -2), point(x: -14, y: -2), point(x: -13, y: -2), point(x: -12, y: -2), point(x: -11, y: -2), point(x: -10, y: -2), point(x: -9, y: -2), point(x: -8, y: -2), point(x: -7, y: -2), point(x: -6, y: -2), point(x: -5, y: -2), point(x: -4, y: -2), point(x: -3, y: -2), point(x: -2, y: -2), point(x: -1, y: -2), point(x: 0, y: -2), point(x: 1, y: -2), point(x: 2, y: -2), point(x: 3, y: -2), point(x: 4, y: -2), point(x: 5, y: -2), point(x: 6, y: -2), point(x: 7, y: -2), point(x: 8, y: -2), point(x: 9, y: -2), point(x: 10, y: -2), point(x: 11, y: -2), point(x: 12, y: -2), point(x: 13, y: -2), point(x: 14, y: -2), point(x: 15, y: -2),
      point(x: -15, y: -1), point(x: -14, y: -1), point(x: -13, y: -1), point(x: -12, y: -1), point(x: -11, y: -1), point(x: -10, y: -1), point(x: -9, y: -1), point(x: -8, y: -1), point(x: -7, y: -1), point(x: -6, y: -1), point(x: -5, y: -1), point(x: -4, y: -1), point(x: -3, y: -1), point(x: -2, y: -1), point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1), point(x: 2, y: -1), point(x: 3, y: -1), point(x: 4, y: -1), point(x: 5, y: -1), point(x: 6, y: -1), point(x: 7, y: -1), point(x: 8, y: -1), point(x: 9, y: -1), point(x: 10, y: -1), point(x: 11, y: -1), point(x: 12, y: -1), point(x: 13, y: -1), point(x: 14, y: -1), point(x: 15, y: -1),
      point(x: -15, y: 0), point(x: -14, y: 0), point(x: -13, y: 0), point(x: -12, y: 0), point(x: -11, y: 0), point(x: -10, y: 0), point(x: -9, y: 0), point(x: -8, y: 0), point(x: -7, y: 0), point(x: -6, y: 0), point(x: -5, y: 0), point(x: -4, y: 0), point(x: -3, y: 0), point(x: -2, y: 0), point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0), point(x: 2, y: 0), point(x: 3, y: 0), point(x: 4, y: 0), point(x: 5, y: 0), point(x: 6, y: 0), point(x: 7, y: 0), point(x: 8, y: 0), point(x: 9, y: 0), point(x: 10, y: 0), point(x: 11, y: 0), point(x: 12, y: 0), point(x: 13, y: 0), point(x: 14, y: 0), point(x: 15, y: 0),
      point(x: -15, y: 1), point(x: -14, y: 1), point(x: -13, y: 1), point(x: -12, y: 1), point(x: -11, y: 1), point(x: -10, y: 1), point(x: -9, y: 1), point(x: -8, y: 1), point(x: -7, y: 1), point(x: -6, y: 1), point(x: -5, y: 1), point(x: -4, y: 1), point(x: -3, y: 1), point(x: -2, y: 1), point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1), point(x: 2, y: 1), point(x: 3, y: 1), point(x: 4, y: 1), point(x: 5, y: 1), point(x: 6, y: 1), point(x: 7, y: 1), point(x: 8, y: 1), point(x: 9, y: 1), point(x: 10, y: 1), point(x: 11, y: 1), point(x: 12, y: 1), point(x: 13, y: 1), point(x: 14, y: 1), point(x: 15, y: 1),
      point(x: -15, y: 2), point(x: -14, y: 2), point(x: -13, y: 2), point(x: -12, y: 2), point(x: -11, y: 2), point(x: -10, y: 2), point(x: -9, y: 2), point(x: -8, y: 2), point(x: -7, y: 2), point(x: -6, y: 2), point(x: -5, y: 2), point(x: -4, y: 2), point(x: -3, y: 2), point(x: -2, y: 2), point(x: -1, y: 2), point(x: 0, y: 2), point(x: 1, y: 2), point(x: 2, y: 2), point(x: 3, y: 2), point(x: 4, y: 2), point(x: 5, y: 2), point(x: 6, y: 2), point(x: 7, y: 2), point(x: 8, y: 2), point(x: 9, y: 2), point(x: 10, y: 2), point(x: 11, y: 2), point(x: 12, y: 2), point(x: 13, y: 2), point(x: 14, y: 2), point(x: 15, y: 2),
      point(x: -15, y: 3), point(x: -14, y: 3), point(x: -13, y: 3), point(x: -12, y: 3), point(x: -11, y: 3), point(x: -10, y: 3), point(x: -9, y: 3), point(x: -8, y: 3), point(x: -7, y: 3), point(x: -6, y: 3), point(x: -5, y: 3), point(x: -4, y: 3), point(x: -3, y: 3), point(x: -2, y: 3), point(x: -1, y: 3), point(x: 0, y: 3), point(x: 1, y: 3), point(x: 2, y: 3), point(x: 3, y: 3), point(x: 4, y: 3), point(x: 5, y: 3), point(x: 6, y: 3), point(x: 7, y: 3), point(x: 8, y: 3), point(x: 9, y: 3), point(x: 10, y: 3), point(x: 11, y: 3), point(x: 12, y: 3), point(x: 13, y: 3), point(x: 14, y: 3), point(x: 15, y: 3),
      point(x: -15, y: 4), point(x: -14, y: 4), point(x: -13, y: 4), point(x: -12, y: 4), point(x: -11, y: 4), point(x: -10, y: 4), point(x: -9, y: 4), point(x: -8, y: 4), point(x: -7, y: 4), point(x: -6, y: 4), point(x: -5, y: 4), point(x: -4, y: 4), point(x: -3, y: 4), point(x: -2, y: 4), point(x: -1, y: 4), point(x: 0, y: 4), point(x: 1, y: 4), point(x: 2, y: 4), point(x: 3, y: 4), point(x: 4, y: 4), point(x: 5, y: 4), point(x: 6, y: 4), point(x: 7, y: 4), point(x: 8, y: 4), point(x: 9, y: 4), point(x: 10, y: 4), point(x: 11, y: 4), point(x: 12, y: 4), point(x: 13, y: 4), point(x: 14, y: 4), point(x: 15, y: 4),
      point(x: -15, y: 5), point(x: -14, y: 5), point(x: -13, y: 5), point(x: -12, y: 5), point(x: -11, y: 5), point(x: -10, y: 5), point(x: -9, y: 5), point(x: -8, y: 5), point(x: -7, y: 5), point(x: -6, y: 5), point(x: -5, y: 5), point(x: -4, y: 5), point(x: -3, y: 5), point(x: -2, y: 5), point(x: -1, y: 5), point(x: 0, y: 5), point(x: 1, y: 5), point(x: 2, y: 5), point(x: 3, y: 5), point(x: 4, y: 5), point(x: 5, y: 5), point(x: 6, y: 5), point(x: 7, y: 5), point(x: 8, y: 5), point(x: 9, y: 5), point(x: 10, y: 5), point(x: 11, y: 5), point(x: 12, y: 5), point(x: 13, y: 5), point(x: 14, y: 5), point(x: 15, y: 5),
      point(x: -15, y: 6), point(x: -14, y: 6), point(x: -13, y: 6), point(x: -12, y: 6), point(x: -11, y: 6), point(x: -10, y: 6), point(x: -9, y: 6), point(x: -8, y: 6), point(x: -7, y: 6), point(x: -6, y: 6), point(x: -5, y: 6), point(x: -4, y: 6), point(x: -3, y: 6), point(x: -2, y: 6), point(x: -1, y: 6), point(x: 0, y: 6), point(x: 1, y: 6), point(x: 2, y: 6), point(x: 3, y: 6), point(x: 4, y: 6), point(x: 5, y: 6), point(x: 6, y: 6), point(x: 7, y: 6), point(x: 8, y: 6), point(x: 9, y: 6), point(x: 10, y: 6), point(x: 11, y: 6), point(x: 12, y: 6), point(x: 13, y: 6), point(x: 14, y: 6), point(x: 15, y: 6),
      point(x: -15, y: 7), point(x: -14, y: 7), point(x: -13, y: 7), point(x: -12, y: 7), point(x: -11, y: 7), point(x: -10, y: 7), point(x: -9, y: 7), point(x: -8, y: 7), point(x: -7, y: 7), point(x: -6, y: 7), point(x: -5, y: 7), point(x: -4, y: 7), point(x: -3, y: 7), point(x: -2, y: 7), point(x: -1, y: 7), point(x: 0, y: 7), point(x: 1, y: 7), point(x: 2, y: 7), point(x: 3, y: 7), point(x: 4, y: 7), point(x: 5, y: 7), point(x: 6, y: 7), point(x: 7, y: 7), point(x: 8, y: 7), point(x: 9, y: 7), point(x: 10, y: 7), point(x: 11, y: 7), point(x: 12, y: 7), point(x: 13, y: 7), point(x: 14, y: 7), point(x: 15, y: 7),
      point(x: -15, y: 8), point(x: -14, y: 8), point(x: -13, y: 8), point(x: -12, y: 8), point(x: -11, y: 8), point(x: -10, y: 8), point(x: -9, y: 8), point(x: -8, y: 8), point(x: -7, y: 8), point(x: -6, y: 8), point(x: -5, y: 8), point(x: -4, y: 8), point(x: -3, y: 8), point(x: -2, y: 8), point(x: -1, y: 8), point(x: 0, y: 8), point(x: 1, y: 8), point(x: 2, y: 8), point(x: 3, y: 8), point(x: 4, y: 8), point(x: 5, y: 8), point(x: 6, y: 8), point(x: 7, y: 8), point(x: 8, y: 8), point(x: 9, y: 8), point(x: 10, y: 8), point(x: 11, y: 8), point(x: 12, y: 8), point(x: 13, y: 8), point(x: 14, y: 8), point(x: 15, y: 8),
      point(x: -15, y: 9), point(x: -14, y: 9), point(x: -13, y: 9), point(x: -12, y: 9), point(x: -11, y: 9), point(x: -10, y: 9), point(x: -9, y: 9), point(x: -8, y: 9), point(x: -7, y: 9), point(x: -6, y: 9), point(x: -5, y: 9), point(x: -4, y: 9), point(x: -3, y: 9), point(x: -2, y: 9), point(x: -1, y: 9), point(x: 0, y: 9), point(x: 1, y: 9), point(x: 2, y: 9), point(x: 3, y: 9), point(x: 4, y: 9), point(x: 5, y: 9), point(x: 6, y: 9), point(x: 7, y: 9), point(x: 8, y: 9), point(x: 9, y: 9), point(x: 10, y: 9), point(x: 11, y: 9), point(x: 12, y: 9), point(x: 13, y: 9), point(x: 14, y: 9), point(x: 15, y: 9),
    ],
    category: @[CAT_IO,CAT_LEVELS],
    immutable: true,
  ),

  Input1: prototype(
    area: @[point(x: 0, y: 0), point(x: -1, y: 0), point(x: 0, y: 1), point(x: 0, y: -1)],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), global: true),
    ],
    default_setting_1: 2,
    schematic_inputs: 1,
    category: @[CAT_IO, CAT_INPUT_PINS],
    immutable: true,
  ),

  LevelInput1: prototype(
    area: @[point(x: 0, y: 0), point(x: -1, y: 0), point(x: 0, y: 1), point(x: 0, y: -1)],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), global: true),
    ],
    default_setting_1: 2,
    schematic_inputs: 1,
    category: @[CAT_IO, CAT_LEVELS],
    immutable: true,
  ),

  LevelInput2Pin: prototype(
    area: @[point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0), point(x: -1, y: 1), point(x: -1, y: -1)],
    output_pins: @[
      prototype_pin(position: point(x: 0, y: -1), global: true),
      prototype_pin(position: point(x: 0, y: 1), global: true),
    ],
    schematic_inputs: 2,
    category: @[CAT_IO],
    immutable: true,
  ),

  LevelInput3Pin: prototype(
    area: @[point(x: -1, y: -1), point(x: 0, y: -2), point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1), point(x: 0, y: 2)],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -2), global: true),
      prototype_pin(position: point(x: 1, y: -1), global: true),
      prototype_pin(position: point(x: 1, y: 0), global: true),
    ],
    schematic_inputs: 3,
    category: @[CAT_IO],
    immutable: true,
  ),

  LevelInput4Pin: prototype(
    area: @[point(x: -1, y: -1), point(x: 0, y: -2), point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1), point(x: 0, y: 2)],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -2), global: true),
      prototype_pin(position: point(x: 1, y: -1), global: true),
      prototype_pin(position: point(x: 1, y: 0), global: true),
      prototype_pin(position: point(x: 1, y: 1), global: true),
    ],
    schematic_inputs: 4,
    category: @[CAT_IO],
    immutable: true,
  ),

  LevelInputConditions: prototype(
    area: @[point(x: 0, y: 0), point(x: -1, y: 0), point(x: 0, y: 1), point(x: 0, y: -1)],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8, global: true),
    ],
    schematic_inputs: 1,
    category: @[CAT_IO],
    immutable: true,
  ),

  Input8: prototype(
    area: @[point(x: 0, y: 0), point(x: -1, y: 0), point(x: 0, y: 1), point(x: 0, y: -1)],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8, global: true),
    ],
    schematic_inputs: 1,
    default_setting_1: 2,
    category: @[CAT_IO, CAT_INPUT_PINS],
    immutable: true,
  ),

  LevelInput8: prototype(
    area: @[point(x: 0, y: 0), point(x: -1, y: 0), point(x: 0, y: 1), point(x: 0, y: -1)],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8, global: true),
    ],
    schematic_inputs: 1,
    default_setting_1: 2,
    category: @[CAT_IO, CAT_LEVELS],
    immutable: true,
  ),

  Input16: prototype(
    sandbox: true,
    area: @[
      point(x: -1, y: -1), point(x: -1, y: 0), point(x: -1, y: 1),
      point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1),
      point(x: 1, y: -1), point(x: 1, y: 0), point(x: 1, y: 1),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 2, y: 0), kind: wk_16, global: true),
    ],
    schematic_inputs: 1,
    default_setting_1: 2,
    category: @[CAT_IO, CAT_INPUT_PINS],
    immutable: true,
  ),

  Input32: prototype(
    sandbox: true,
    area: @[
      point(x: -1, y: -1), point(x: -1, y: 0), point(x: -1, y: 1),
      point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1),
      point(x: 1, y: -1), point(x: 1, y: 0), point(x: 1, y: 1),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 2, y: 0), kind: wk_32, global: true),
    ],
    schematic_inputs: 1,
    default_setting_1: 2,
    category: @[CAT_IO, CAT_INPUT_PINS],
    immutable: true,
  ),

  Input64: prototype(
    sandbox: true,
    area: @[
      point(x: -2, y: -1), point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1), point(x: 2, y: -1),
      point(x: -2, y: 0), point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0), point(x: 2, y: 0),
      point(x: -2, y: 1), point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1), point(x: 2, y: 1),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 3, y: 0), kind: wk_64, global: true),
    ],
    schematic_inputs: 1,
    default_setting_1: 2,
    category: @[CAT_IO, CAT_INPUT_PINS],
    immutable: true,
  ),

  LevelInputArch: prototype(
    area: @[point(x: 0, y: 0), point(x: -1, y: 0), point(x: 0, y: -1)],
    input_pins: @[
      prototype_pin(position: point(x: 0, y: 1), global: true),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8, global: true, tri_state: true),
    ],
    schematic_inputs: 1,
    schematic_outputs: 1,
    category: @[CAT_IO,CAT_LEVELS],
    immutable: true,
  ),

  LevelInputCode: prototype(
    area: @[point(x: 0, y: 0), point(x: -1, y: 0), point(x: 0, y: 1), point(x: 0, y: -1)],
    input_pins: @[],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8, global: true),
    ],
    schematic_inputs: 1,
    category: @[CAT_IO],
    immutable: true,
  ),

  LevelGate: prototype(
    area: @[
      point(x: -1, y: -2), point(x: 0, y: -2), point(x: 1, y: -2),
      point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1),
      point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0),
      point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1),
      point(x: -1, y: 2), point(x: 0, y: 2), point(x: 1, y: 2),
    ],
    input_pins: @[
      prototype_pin(position: point(x: -2, y: -1)),
      prototype_pin(position: point(x: -2, y: 0)),
      prototype_pin(position: point(x: -2, y: 1)),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 2, y: 0), global: true),
    ],
    schematic_inputs: 1,
    schematic_outputs: 1,
    category: @[CAT_IO],
    immutable: true,
  ),

  LevelOutput1Sum: prototype(
    area: @[point(x: 0, y: 0), point(x: 0, y: 1), point(x: 0, y: -1), point(x: 1, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), global: true),
    ],
    schematic_outputs: 1,
    category: @[CAT_IO],
    immutable: true,
  ),

  LevelOutput1Car: prototype(
    area: @[point(x: 0, y: 0), point(x: 0, y: 1), point(x: 0, y: -1), point(x: 1, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), global: true),
    ],
    schematic_outputs: 1,
    category: @[CAT_IO],
    immutable: true,
  ),

  LevelOutput2Pin: prototype(
    area: @[point(x: 0, y: 0), point(x: 0, y: -1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), global: true),
      prototype_pin(position: point(x: -1, y: 0), global: true),
    ],
    schematic_outputs: 2,
    category: @[CAT_IO],
    immutable: true,
  ),

  LevelOutput3Pin: prototype(
    area: @[point(x: 0, y: -2), point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -2), global: true),
      prototype_pin(position: point(x: -1, y: -1), global: true),
      prototype_pin(position: point(x: -1, y: 0), global: true),
    ],
    schematic_outputs: 3,
    category: @[CAT_IO],
    immutable: true,
  ),

  LevelOutput4Pin: prototype(
    area: @[point(x: 0, y: -2), point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -2), global: true),
      prototype_pin(position: point(x: -1, y: -1), global: true),
      prototype_pin(position: point(x: -1, y: 0), global: true),
      prototype_pin(position: point(x: -1, y: 1), global: true),
    ],
    schematic_outputs: 4,
    category: @[CAT_IO],
    immutable: true,
  ),

  LevelOutput1: prototype(
    area: @[point(x: 0, y: 0), point(x: 0, y: 1), point(x: 0, y: -1), point(x: 1, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), global: true),
    ],
    schematic_outputs: 1,
    category: @[CAT_IO, CAT_LEVELS],
    immutable: true,
  ),

  LevelOutput8: prototype(
    area: @[point(x: 1, y: 0), point(x: 0, y: 0), point(x: 0, y: 1), point(x: 0, y: -1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8, global: true),
    ],
    schematic_outputs: 1,
    category: @[CAT_IO, CAT_LEVELS],
    immutable: true,
  ),

  Output1: prototype(
    area: @[point(x: 0, y: 0), point(x: 0, y: 1), point(x: 0, y: -1), point(x: 1, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), global: true),
    ],
    schematic_outputs: 1,
    category: @[CAT_IO, CAT_OUTPUT_PINS],
    immutable: true,
  ),

  Output8: prototype(
    area: @[point(x: 1, y: 0), point(x: 0, y: 0), point(x: 0, y: 1), point(x: 0, y: -1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8, global: true),
    ],
    schematic_outputs: 1,
    category: @[CAT_IO, CAT_OUTPUT_PINS],
    immutable: true,
  ),

  Output16: prototype(
    sandbox: true,
    area: @[
      point(x: -1, y: -1), point(x: -1, y: 0), point(x: -1, y: 1),
      point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1),
      point(x: 1, y: -1), point(x: 1, y: 0), point(x: 1, y: 1),
    ],
    input_pins: @[
      prototype_pin(position: point(x: -2, y: 0), kind: wk_16, global: true),
    ],
    schematic_outputs: 1,
    category: @[CAT_IO, CAT_OUTPUT_PINS],
    immutable: true,
  ),

  Output32: prototype(
    sandbox: true,
    area: @[
      point(x: -1, y: -1), point(x: -1, y: 0), point(x: -1, y: 1),
      point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1),
      point(x: 1, y: -1), point(x: 1, y: 0), point(x: 1, y: 1),
    ],
    input_pins: @[
      prototype_pin(position: point(x: -2, y: 0), kind: wk_32, global: true),
    ],
    schematic_outputs: 1,
    category: @[CAT_IO, CAT_OUTPUT_PINS],
    immutable: true,
  ),

  Output64: prototype(
    sandbox: true,
    area: @[
      point(x: -2, y: -1), point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1), point(x: 2, y: -1),
      point(x: -2, y: 0), point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0), point(x: 2, y: 0),
      point(x: -2, y: 1), point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1), point(x: 2, y: 1),
    ],
    input_pins: @[
      prototype_pin(position: point(x: -3, y: 0), kind: wk_64, global: true),
    ],
    schematic_outputs: 1,
    category: @[CAT_IO, CAT_OUTPUT_PINS],
    immutable: true,
  ),

  Output1z: prototype(
    menu_order: 0.uint8,
    area: @[point(x: 0, y: 0), point(x: 0, y: -1), point(x: 1, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: 0, y: 1)),
      prototype_pin(position: point(x: -1, y: 0)),
    ],
    schematic_outputs: 1,
    category: @[CAT_IO, SWITCH_OUTPUT_PINS],
    immutable: true,
  ),

  Output8z: prototype(
    menu_order: 1.uint8,
    area: @[point(x: 1, y: 0), point(x: 0, y: 0), point(x: 0, y: -1)],
    input_pins: @[
      prototype_pin(position: point(x: 0, y: 1)),
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
    ],
    schematic_outputs: 1,
    category: @[CAT_IO, SWITCH_OUTPUT_PINS],
    immutable: true,
  ),

  Output16z: prototype(
    menu_order: 2.uint8,
    sandbox: true,
    area: @[
      point(x: -1, y: -1), point(x: -1, y: 0), point(x: -1, y: 1),
      point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1),
      point(x: 1, y: -1), point(x: 1, y: 0), point(x: 1, y: 1),
    ],
    input_pins: @[
      prototype_pin(position: point(x: 0, y: 2)),
      prototype_pin(position: point(x: -2, y: 0), kind: wk_16),
    ],
    schematic_outputs: 1,
    category: @[CAT_IO, SWITCH_OUTPUT_PINS],
    immutable: true,
  ),


  Output32z: prototype(
    menu_order: 3.uint8,
    sandbox: true,
    area: @[
      point(x: -1, y: -1), point(x: -1, y: 0), point(x: -1, y: 1),
      point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1),
      point(x: 1, y: -1), point(x: 1, y: 0), point(x: 1, y: 1),
    ],
    input_pins: @[
      prototype_pin(position: point(x: 0, y: 2)),
      prototype_pin(position: point(x: -2, y: 0), kind: wk_32),
    ],
    schematic_outputs: 1,
    category: @[CAT_IO, SWITCH_OUTPUT_PINS],
    immutable: true,
  ),

  Output64z: prototype(
    menu_order: 4.uint8,
    sandbox: true,
    area: @[
      point(x: -2, y: -1), point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1), point(x: 2, y: -1),
      point(x: -2, y: 0), point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0), point(x: 2, y: 0),
      point(x: -2, y: 1), point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1), point(x: 2, y: 1),
    ],
    input_pins: @[
      prototype_pin(position: point(x:  0, y: 2)),
      prototype_pin(position: point(x: -3, y: 0), kind: wk_64),
    ],
    schematic_outputs: 1,
    category: @[CAT_IO, SWITCH_OUTPUT_PINS],
    immutable: true,
  ),

  LevelOutputArch: prototype(
    area: @[point(x: 1, y: 0), point(x: 0, y: 0), point(x: 0, y: -1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8, global: true),
      prototype_pin(position: point(x: 0, y: 1), global: true),
    ],
    schematic_outputs: 2,
    category: @[CAT_IO,CAT_LEVELS],
    immutable: true,
  ),

  LevelOutputCounter: prototype(
    area: @[point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1), point(x: 1, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -1), global: true),
      prototype_pin(position: point(x: -1, y: 0), global: true),
      prototype_pin(position: point(x: -1, y: 1), global: true),
    ],
    schematic_outputs: 3,
    category: @[CAT_IO],
    immutable: true,
  ),

  Custom: prototype(
    category: @[CAT_CUST],
    has_virtual: true,
  ),
  VirtualCustom: prototype(backend_only: true),

  WireCluster: prototype(backend_only: true),
  AndOrLatch: prototype(
    backend_only: true,
    input_pins: @[
      prototype_pin(),
      prototype_pin(),
    ],
    output_pins: @[
      prototype_pin(),
      prototype_pin(),
    ],
  ),
  NandNandLatch: prototype(
    backend_only: true,
    memory: 1,
    input_pins: @[
      prototype_pin(),
      prototype_pin(),
    ],
    output_pins: @[
      prototype_pin(),
      prototype_pin(),
    ],
  ),
  NorNorLatch: prototype(
    backend_only: true,
    memory: 1,
    input_pins: @[
      prototype_pin(),
      prototype_pin(),
    ],
    output_pins: @[
      prototype_pin(),
      prototype_pin(),
    ],
  ),
  DotMatrixDisplay: prototype(
    sandbox: true,
    memory: 96,
    default_setting_1: 1,
    effectual: true,
    category: @[CAT_IO, CAT_DISPLAYS],
    area: @[
      point(x: -1, y: -1), point(x: 0, y: -1),
      point(x: -1, y: 0), point(x: 0, y: 0),
      point(x: -1, y: 1), point(x: 0, y: 1),
    ],
    input_pins: @[
      prototype_pin(position: point(x: -2, y: -1)),
      prototype_pin(position: point(x: -1, y: -2)),
      prototype_pin(position: point(x: -2, y: 0), kind: wk_32),
      prototype_pin(position: point(x: 0, y: -2), kind: wk_64),
    ],
    custom_memory_export: proc(node: var node, memory_store: var openArray[uint64]): seq[uint64] =
      return memory_store[node.memory.start..node.memory.start + 47]
    ,
    reset: proc(node: var node, memory_store: var openArray[uint64]) =
      for i in 0..95:
        node.node_set_memory(memory_store, i.uint64, 133 shl 16 + 135 shl 8 + 151)
  ),
  SegmentDisplay: prototype(
    sandbox: true,
    memory: 1,
    effectual: true,
    category: @[CAT_IO, CAT_DISPLAYS],
    area: @[
      point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1),
      point(x: -1, y: 0),  point(x: 0, y: 0),  point(x: 1, y: 0),
      point(x: -1, y: 1),  point(x: 0, y: 1),  point(x: 1, y: 1),
      point(x: -1, y: 2),  point(x: 0, y: 2),  point(x: 1, y: 2),
    ],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: -2)),
      prototype_pin(position: point(x: 0, y: -2), kind: wk_8),
    ],
    custom_memory_export: proc(node: var node, memory_store: var openArray[uint64]): seq[uint64] =
      return @[memory_store[node.memory.start]]
    ,
  ),

  SpriteDisplay: prototype(
    sandbox: true,
    effectual: true,
    area: @[
      point(x: -16, y: -12), point(x: -15, y: -12), point(x: -14, y: -12), point(x: -13, y: -12), point(x: -12, y: -12), point(x: -11, y: -12), point(x: -10, y: -12), point(x: -9, y: -12), point(x: -8, y: -12), point(x: -7, y: -12), point(x: -6, y: -12), point(x: -5, y: -12), point(x: -4, y: -12), point(x: -3, y: -12), point(x: -2, y: -12), point(x: -1, y: -12), point(x: 0, y: -12), point(x: 1, y: -12), point(x: 2, y: -12), point(x: 3, y: -12), point(x: 4, y: -12), point(x: 5, y: -12), point(x: 6, y: -12), point(x: 7, y: -12), point(x: 8, y: -12), point(x: 9, y: -12), point(x: 10, y: -12), point(x: 11, y: -12), point(x: 12, y: -12), point(x: 13, y: -12), point(x: 14, y: -12), point(x: 15, y: -12), 
      point(x: -16, y: -11), point(x: -15, y: -11), point(x: -14, y: -11), point(x: -13, y: -11), point(x: -12, y: -11), point(x: -11, y: -11), point(x: -10, y: -11), point(x: -9, y: -11), point(x: -8, y: -11), point(x: -7, y: -11), point(x: -6, y: -11), point(x: -5, y: -11), point(x: -4, y: -11), point(x: -3, y: -11), point(x: -2, y: -11), point(x: -1, y: -11), point(x: 0, y: -11), point(x: 1, y: -11), point(x: 2, y: -11), point(x: 3, y: -11), point(x: 4, y: -11), point(x: 5, y: -11), point(x: 6, y: -11), point(x: 7, y: -11), point(x: 8, y: -11), point(x: 9, y: -11), point(x: 10, y: -11), point(x: 11, y: -11), point(x: 12, y: -11), point(x: 13, y: -11), point(x: 14, y: -11), point(x: 15, y: -11), 
      point(x: -16, y: -10), point(x: -15, y: -10), point(x: -14, y: -10), point(x: -13, y: -10), point(x: -12, y: -10), point(x: -11, y: -10), point(x: -10, y: -10), point(x: -9, y: -10), point(x: -8, y: -10), point(x: -7, y: -10), point(x: -6, y: -10), point(x: -5, y: -10), point(x: -4, y: -10), point(x: -3, y: -10), point(x: -2, y: -10), point(x: -1, y: -10), point(x: 0, y: -10), point(x: 1, y: -10), point(x: 2, y: -10), point(x: 3, y: -10), point(x: 4, y: -10), point(x: 5, y: -10), point(x: 6, y: -10), point(x: 7, y: -10), point(x: 8, y: -10), point(x: 9, y: -10), point(x: 10, y: -10), point(x: 11, y: -10), point(x: 12, y: -10), point(x: 13, y: -10), point(x: 14, y: -10), point(x: 15, y: -10), 
      point(x: -16, y: -9), point(x: -15, y: -9), point(x: -14, y: -9), point(x: -13, y: -9), point(x: -12, y: -9), point(x: -11, y: -9), point(x: -10, y: -9), point(x: -9, y: -9), point(x: -8, y: -9), point(x: -7, y: -9), point(x: -6, y: -9), point(x: -5, y: -9), point(x: -4, y: -9), point(x: -3, y: -9), point(x: -2, y: -9), point(x: -1, y: -9), point(x: 0, y: -9), point(x: 1, y: -9), point(x: 2, y: -9), point(x: 3, y: -9), point(x: 4, y: -9), point(x: 5, y: -9), point(x: 6, y: -9), point(x: 7, y: -9), point(x: 8, y: -9), point(x: 9, y: -9), point(x: 10, y: -9), point(x: 11, y: -9), point(x: 12, y: -9), point(x: 13, y: -9), point(x: 14, y: -9), point(x: 15, y: -9), 
      point(x: -16, y: -8), point(x: -15, y: -8), point(x: -14, y: -8), point(x: -13, y: -8), point(x: -12, y: -8), point(x: -11, y: -8), point(x: -10, y: -8), point(x: -9, y: -8), point(x: -8, y: -8), point(x: -7, y: -8), point(x: -6, y: -8), point(x: -5, y: -8), point(x: -4, y: -8), point(x: -3, y: -8), point(x: -2, y: -8), point(x: -1, y: -8), point(x: 0, y: -8), point(x: 1, y: -8), point(x: 2, y: -8), point(x: 3, y: -8), point(x: 4, y: -8), point(x: 5, y: -8), point(x: 6, y: -8), point(x: 7, y: -8), point(x: 8, y: -8), point(x: 9, y: -8), point(x: 10, y: -8), point(x: 11, y: -8), point(x: 12, y: -8), point(x: 13, y: -8), point(x: 14, y: -8), point(x: 15, y: -8), 
      point(x: -16, y: -7), point(x: -15, y: -7), point(x: -14, y: -7), point(x: -13, y: -7), point(x: -12, y: -7), point(x: -11, y: -7), point(x: -10, y: -7), point(x: -9, y: -7), point(x: -8, y: -7), point(x: -7, y: -7), point(x: -6, y: -7), point(x: -5, y: -7), point(x: -4, y: -7), point(x: -3, y: -7), point(x: -2, y: -7), point(x: -1, y: -7), point(x: 0, y: -7), point(x: 1, y: -7), point(x: 2, y: -7), point(x: 3, y: -7), point(x: 4, y: -7), point(x: 5, y: -7), point(x: 6, y: -7), point(x: 7, y: -7), point(x: 8, y: -7), point(x: 9, y: -7), point(x: 10, y: -7), point(x: 11, y: -7), point(x: 12, y: -7), point(x: 13, y: -7), point(x: 14, y: -7), point(x: 15, y: -7), 
      point(x: -16, y: -6), point(x: -15, y: -6), point(x: -14, y: -6), point(x: -13, y: -6), point(x: -12, y: -6), point(x: -11, y: -6), point(x: -10, y: -6), point(x: -9, y: -6), point(x: -8, y: -6), point(x: -7, y: -6), point(x: -6, y: -6), point(x: -5, y: -6), point(x: -4, y: -6), point(x: -3, y: -6), point(x: -2, y: -6), point(x: -1, y: -6), point(x: 0, y: -6), point(x: 1, y: -6), point(x: 2, y: -6), point(x: 3, y: -6), point(x: 4, y: -6), point(x: 5, y: -6), point(x: 6, y: -6), point(x: 7, y: -6), point(x: 8, y: -6), point(x: 9, y: -6), point(x: 10, y: -6), point(x: 11, y: -6), point(x: 12, y: -6), point(x: 13, y: -6), point(x: 14, y: -6), point(x: 15, y: -6), 
      point(x: -16, y: -5), point(x: -15, y: -5), point(x: -14, y: -5), point(x: -13, y: -5), point(x: -12, y: -5), point(x: -11, y: -5), point(x: -10, y: -5), point(x: -9, y: -5), point(x: -8, y: -5), point(x: -7, y: -5), point(x: -6, y: -5), point(x: -5, y: -5), point(x: -4, y: -5), point(x: -3, y: -5), point(x: -2, y: -5), point(x: -1, y: -5), point(x: 0, y: -5), point(x: 1, y: -5), point(x: 2, y: -5), point(x: 3, y: -5), point(x: 4, y: -5), point(x: 5, y: -5), point(x: 6, y: -5), point(x: 7, y: -5), point(x: 8, y: -5), point(x: 9, y: -5), point(x: 10, y: -5), point(x: 11, y: -5), point(x: 12, y: -5), point(x: 13, y: -5), point(x: 14, y: -5), point(x: 15, y: -5), 
      point(x: -16, y: -4), point(x: -15, y: -4), point(x: -14, y: -4), point(x: -13, y: -4), point(x: -12, y: -4), point(x: -11, y: -4), point(x: -10, y: -4), point(x: -9, y: -4), point(x: -8, y: -4), point(x: -7, y: -4), point(x: -6, y: -4), point(x: -5, y: -4), point(x: -4, y: -4), point(x: -3, y: -4), point(x: -2, y: -4), point(x: -1, y: -4), point(x: 0, y: -4), point(x: 1, y: -4), point(x: 2, y: -4), point(x: 3, y: -4), point(x: 4, y: -4), point(x: 5, y: -4), point(x: 6, y: -4), point(x: 7, y: -4), point(x: 8, y: -4), point(x: 9, y: -4), point(x: 10, y: -4), point(x: 11, y: -4), point(x: 12, y: -4), point(x: 13, y: -4), point(x: 14, y: -4), point(x: 15, y: -4), 
      point(x: -16, y: -3), point(x: -15, y: -3), point(x: -14, y: -3), point(x: -13, y: -3), point(x: -12, y: -3), point(x: -11, y: -3), point(x: -10, y: -3), point(x: -9, y: -3), point(x: -8, y: -3), point(x: -7, y: -3), point(x: -6, y: -3), point(x: -5, y: -3), point(x: -4, y: -3), point(x: -3, y: -3), point(x: -2, y: -3), point(x: -1, y: -3), point(x: 0, y: -3), point(x: 1, y: -3), point(x: 2, y: -3), point(x: 3, y: -3), point(x: 4, y: -3), point(x: 5, y: -3), point(x: 6, y: -3), point(x: 7, y: -3), point(x: 8, y: -3), point(x: 9, y: -3), point(x: 10, y: -3), point(x: 11, y: -3), point(x: 12, y: -3), point(x: 13, y: -3), point(x: 14, y: -3), point(x: 15, y: -3), 
      point(x: -16, y: -2), point(x: -15, y: -2), point(x: -14, y: -2), point(x: -13, y: -2), point(x: -12, y: -2), point(x: -11, y: -2), point(x: -10, y: -2), point(x: -9, y: -2), point(x: -8, y: -2), point(x: -7, y: -2), point(x: -6, y: -2), point(x: -5, y: -2), point(x: -4, y: -2), point(x: -3, y: -2), point(x: -2, y: -2), point(x: -1, y: -2), point(x: 0, y: -2), point(x: 1, y: -2), point(x: 2, y: -2), point(x: 3, y: -2), point(x: 4, y: -2), point(x: 5, y: -2), point(x: 6, y: -2), point(x: 7, y: -2), point(x: 8, y: -2), point(x: 9, y: -2), point(x: 10, y: -2), point(x: 11, y: -2), point(x: 12, y: -2), point(x: 13, y: -2), point(x: 14, y: -2), point(x: 15, y: -2), 
      point(x: -16, y: -1), point(x: -15, y: -1), point(x: -14, y: -1), point(x: -13, y: -1), point(x: -12, y: -1), point(x: -11, y: -1), point(x: -10, y: -1), point(x: -9, y: -1), point(x: -8, y: -1), point(x: -7, y: -1), point(x: -6, y: -1), point(x: -5, y: -1), point(x: -4, y: -1), point(x: -3, y: -1), point(x: -2, y: -1), point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1), point(x: 2, y: -1), point(x: 3, y: -1), point(x: 4, y: -1), point(x: 5, y: -1), point(x: 6, y: -1), point(x: 7, y: -1), point(x: 8, y: -1), point(x: 9, y: -1), point(x: 10, y: -1), point(x: 11, y: -1), point(x: 12, y: -1), point(x: 13, y: -1), point(x: 14, y: -1), point(x: 15, y: -1), 
      point(x: -16, y: 0), point(x: -15, y: 0), point(x: -14, y: 0), point(x: -13, y: 0), point(x: -12, y: 0), point(x: -11, y: 0), point(x: -10, y: 0), point(x: -9, y: 0), point(x: -8, y: 0), point(x: -7, y: 0), point(x: -6, y: 0), point(x: -5, y: 0), point(x: -4, y: 0), point(x: -3, y: 0), point(x: -2, y: 0), point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0), point(x: 2, y: 0), point(x: 3, y: 0), point(x: 4, y: 0), point(x: 5, y: 0), point(x: 6, y: 0), point(x: 7, y: 0), point(x: 8, y: 0), point(x: 9, y: 0), point(x: 10, y: 0), point(x: 11, y: 0), point(x: 12, y: 0), point(x: 13, y: 0), point(x: 14, y: 0), point(x: 15, y: 0),
      point(x: -16, y: 1), point(x: -15, y: 1), point(x: -14, y: 1), point(x: -13, y: 1), point(x: -12, y: 1), point(x: -11, y: 1), point(x: -10, y: 1), point(x: -9, y: 1), point(x: -8, y: 1), point(x: -7, y: 1), point(x: -6, y: 1), point(x: -5, y: 1), point(x: -4, y: 1), point(x: -3, y: 1), point(x: -2, y: 1), point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1), point(x: 2, y: 1), point(x: 3, y: 1), point(x: 4, y: 1), point(x: 5, y: 1), point(x: 6, y: 1), point(x: 7, y: 1), point(x: 8, y: 1), point(x: 9, y: 1), point(x: 10, y: 1), point(x: 11, y: 1), point(x: 12, y: 1), point(x: 13, y: 1), point(x: 14, y: 1), point(x: 15, y: 1),
      point(x: -16, y: 2), point(x: -15, y: 2), point(x: -14, y: 2), point(x: -13, y: 2), point(x: -12, y: 2), point(x: -11, y: 2), point(x: -10, y: 2), point(x: -9, y: 2), point(x: -8, y: 2), point(x: -7, y: 2), point(x: -6, y: 2), point(x: -5, y: 2), point(x: -4, y: 2), point(x: -3, y: 2), point(x: -2, y: 2), point(x: -1, y: 2), point(x: 0, y: 2), point(x: 1, y: 2), point(x: 2, y: 2), point(x: 3, y: 2), point(x: 4, y: 2), point(x: 5, y: 2), point(x: 6, y: 2), point(x: 7, y: 2), point(x: 8, y: 2), point(x: 9, y: 2), point(x: 10, y: 2), point(x: 11, y: 2), point(x: 12, y: 2), point(x: 13, y: 2), point(x: 14, y: 2), point(x: 15, y: 2),
      point(x: -16, y: 3), point(x: -15, y: 3), point(x: -14, y: 3), point(x: -13, y: 3), point(x: -12, y: 3), point(x: -11, y: 3), point(x: -10, y: 3), point(x: -9, y: 3), point(x: -8, y: 3), point(x: -7, y: 3), point(x: -6, y: 3), point(x: -5, y: 3), point(x: -4, y: 3), point(x: -3, y: 3), point(x: -2, y: 3), point(x: -1, y: 3), point(x: 0, y: 3), point(x: 1, y: 3), point(x: 2, y: 3), point(x: 3, y: 3), point(x: 4, y: 3), point(x: 5, y: 3), point(x: 6, y: 3), point(x: 7, y: 3), point(x: 8, y: 3), point(x: 9, y: 3), point(x: 10, y: 3), point(x: 11, y: 3), point(x: 12, y: 3), point(x: 13, y: 3), point(x: 14, y: 3), point(x: 15, y: 3),
      point(x: -16, y: 4), point(x: -15, y: 4), point(x: -14, y: 4), point(x: -13, y: 4), point(x: -12, y: 4), point(x: -11, y: 4), point(x: -10, y: 4), point(x: -9, y: 4), point(x: -8, y: 4), point(x: -7, y: 4), point(x: -6, y: 4), point(x: -5, y: 4), point(x: -4, y: 4), point(x: -3, y: 4), point(x: -2, y: 4), point(x: -1, y: 4), point(x: 0, y: 4), point(x: 1, y: 4), point(x: 2, y: 4), point(x: 3, y: 4), point(x: 4, y: 4), point(x: 5, y: 4), point(x: 6, y: 4), point(x: 7, y: 4), point(x: 8, y: 4), point(x: 9, y: 4), point(x: 10, y: 4), point(x: 11, y: 4), point(x: 12, y: 4), point(x: 13, y: 4), point(x: 14, y: 4), point(x: 15, y: 4),
      point(x: -16, y: 5), point(x: -15, y: 5), point(x: -14, y: 5), point(x: -13, y: 5), point(x: -12, y: 5), point(x: -11, y: 5), point(x: -10, y: 5), point(x: -9, y: 5), point(x: -8, y: 5), point(x: -7, y: 5), point(x: -6, y: 5), point(x: -5, y: 5), point(x: -4, y: 5), point(x: -3, y: 5), point(x: -2, y: 5), point(x: -1, y: 5), point(x: 0, y: 5), point(x: 1, y: 5), point(x: 2, y: 5), point(x: 3, y: 5), point(x: 4, y: 5), point(x: 5, y: 5), point(x: 6, y: 5), point(x: 7, y: 5), point(x: 8, y: 5), point(x: 9, y: 5), point(x: 10, y: 5), point(x: 11, y: 5), point(x: 12, y: 5), point(x: 13, y: 5), point(x: 14, y: 5), point(x: 15, y: 5),
      point(x: -16, y: 6), point(x: -15, y: 6), point(x: -14, y: 6), point(x: -13, y: 6), point(x: -12, y: 6), point(x: -11, y: 6), point(x: -10, y: 6), point(x: -9, y: 6), point(x: -8, y: 6), point(x: -7, y: 6), point(x: -6, y: 6), point(x: -5, y: 6), point(x: -4, y: 6), point(x: -3, y: 6), point(x: -2, y: 6), point(x: -1, y: 6), point(x: 0, y: 6), point(x: 1, y: 6), point(x: 2, y: 6), point(x: 3, y: 6), point(x: 4, y: 6), point(x: 5, y: 6), point(x: 6, y: 6), point(x: 7, y: 6), point(x: 8, y: 6), point(x: 9, y: 6), point(x: 10, y: 6), point(x: 11, y: 6), point(x: 12, y: 6), point(x: 13, y: 6), point(x: 14, y: 6), point(x: 15, y: 6),
      point(x: -16, y: 7), point(x: -15, y: 7), point(x: -14, y: 7), point(x: -13, y: 7), point(x: -12, y: 7), point(x: -11, y: 7), point(x: -10, y: 7), point(x: -9, y: 7), point(x: -8, y: 7), point(x: -7, y: 7), point(x: -6, y: 7), point(x: -5, y: 7), point(x: -4, y: 7), point(x: -3, y: 7), point(x: -2, y: 7), point(x: -1, y: 7), point(x: 0, y: 7), point(x: 1, y: 7), point(x: 2, y: 7), point(x: 3, y: 7), point(x: 4, y: 7), point(x: 5, y: 7), point(x: 6, y: 7), point(x: 7, y: 7), point(x: 8, y: 7), point(x: 9, y: 7), point(x: 10, y: 7), point(x: 11, y: 7), point(x: 12, y: 7), point(x: 13, y: 7), point(x: 14, y: 7), point(x: 15, y: 7),
      point(x: -16, y: 8), point(x: -15, y: 8), point(x: -14, y: 8), point(x: -13, y: 8), point(x: -12, y: 8), point(x: -11, y: 8), point(x: -10, y: 8), point(x: -9, y: 8), point(x: -8, y: 8), point(x: -7, y: 8), point(x: -6, y: 8), point(x: -5, y: 8), point(x: -4, y: 8), point(x: -3, y: 8), point(x: -2, y: 8), point(x: -1, y: 8), point(x: 0, y: 8), point(x: 1, y: 8), point(x: 2, y: 8), point(x: 3, y: 8), point(x: 4, y: 8), point(x: 5, y: 8), point(x: 6, y: 8), point(x: 7, y: 8), point(x: 8, y: 8), point(x: 9, y: 8), point(x: 10, y: 8), point(x: 11, y: 8), point(x: 12, y: 8), point(x: 13, y: 8), point(x: 14, y: 8), point(x: 15, y: 8),
      point(x: -16, y: 9), point(x: -15, y: 9), point(x: -14, y: 9), point(x: -13, y: 9), point(x: -12, y: 9), point(x: -11, y: 9), point(x: -10, y: 9), point(x: -9, y: 9), point(x: -8, y: 9), point(x: -7, y: 9), point(x: -6, y: 9), point(x: -5, y: 9), point(x: -4, y: 9), point(x: -3, y: 9), point(x: -2, y: 9), point(x: -1, y: 9), point(x: 0, y: 9), point(x: 1, y: 9), point(x: 2, y: 9), point(x: 3, y: 9), point(x: 4, y: 9), point(x: 5, y: 9), point(x: 6, y: 9), point(x: 7, y: 9), point(x: 8, y: 9), point(x: 9, y: 9), point(x: 10, y: 9), point(x: 11, y: 9), point(x: 12, y: 9), point(x: 13, y: 9), point(x: 14, y: 9), point(x: 15, y: 9),
      point(x: -16, y: 10), point(x: -15, y: 10), point(x: -14, y: 10), point(x: -13, y: 10), point(x: -12, y: 10), point(x: -11, y: 10), point(x: -10, y: 10), point(x: -9, y: 10), point(x: -8, y: 10), point(x: -7, y: 10), point(x: -6, y: 10), point(x: -5, y: 10), point(x: -4, y: 10), point(x: -3, y: 10), point(x: -2, y: 10), point(x: -1, y: 10), point(x: 0, y: 10), point(x: 1, y: 10), point(x: 2, y: 10), point(x: 3, y: 10), point(x: 4, y: 10), point(x: 5, y: 10), point(x: 6, y: 10), point(x: 7, y: 10), point(x: 8, y: 10), point(x: 9, y: 10), point(x: 10, y: 10), point(x: 11, y: 10), point(x: 12, y: 10), point(x: 13, y: 10), point(x: 14, y: 10), point(x: 15, y: 10),
      point(x: -16, y: 11), point(x: -15, y: 11), point(x: -14, y: 11), point(x: -13, y: 11), point(x: -12, y: 11), point(x: -11, y: 11), point(x: -10, y: 11), point(x: -9, y: 11), point(x: -8, y: 11), point(x: -7, y: 11), point(x: -6, y: 11), point(x: -5, y: 11), point(x: -4, y: 11), point(x: -3, y: 11), point(x: -2, y: 11), point(x: -1, y: 11), point(x: 0, y: 11), point(x: 1, y: 11), point(x: 2, y: 11), point(x: 3, y: 11), point(x: 4, y: 11), point(x: 5, y: 11), point(x: 6, y: 11), point(x: 7, y: 11), point(x: 8, y: 11), point(x: 9, y: 11), point(x: 10, y: 11), point(x: 11, y: 11), point(x: 12, y: 11), point(x: 13, y: 11), point(x: 14, y: 11), point(x: 15, y: 11),
    ],
    input_pins: @[
      prototype_pin(position: point(x: -17, y: -12), kind: wk_8),
      prototype_pin(position: point(x: -17, y: -11), kind: wk_8),
      prototype_pin(position: point(x: -17, y: -10), kind: wk_32),
      prototype_pin(position: point(x: -17, y: -9),  kind: wk_32),
    ],
    category: @[CAT_IO, CAT_DISPLAYS],
    memory: 512,
    custom_memory_export: proc(node: var node, memory_store: var openArray[uint64]): seq[uint64] =
      return memory_store[node.memory.start..node.memory.start + 512]
    ,
    reset: proc(node: var node, memory_store: var openArray[uint64]) =
      var i = 0'u64
      while i < 256:
        node.node_set_memory(memory_store, i, 0)
        node.node_set_memory(memory_store, i+1, SIGNED_SCREEN_PADDING)
        i += 2
  ),

  Bidirectional1: prototype(
    has_virtual: true,
    schematic_inputs: 1,
    area: @[point(x: 0, y: 0), point(x: -1, y: 0), point(x: 1, y: 0), point(x: 0, y: -1)],
    output_pins: @[
      prototype_pin(position: point(x: 0, y: 1), global: true, tri_state: true),
    ],
    reset: proc(node: var node, memory_store: var openArray[uint64]) =
      node.is_z_state = true
      node.node_set_output(memory_store, 0, BIDIRECATIONAL_Z)
    ,
    category: @[CAT_IO, CAT_BIDIRECTIONAL_PINS],
  ),

  VirtualBidirectional1: prototype(
    input_pins: @[
      prototype_pin(position: point(x: 0, y: 1), global: true),
    ],
  ),

  Bidirectional8: prototype(
    has_virtual: true,
    schematic_inputs: 1,
    area: @[point(x: 0, y: 0), point(x: -1, y: 0), point(x: 1, y: 0), point(x: 0, y: -1)],
    output_pins: @[
      prototype_pin(position: point(x: 0, y: 1), kind: wk_8, global: true, tri_state: true),
    ],
    reset: proc(node: var node, memory_store: var openArray[uint64]) =
      node.is_z_state = true
      node.node_set_output(memory_store, 0, BIDIRECATIONAL_Z)
    ,
    category: @[CAT_IO, CAT_BIDIRECTIONAL_PINS],
  ),

  VirtualBidirectional8: prototype(
    input_pins: @[
      prototype_pin(position: point(x: 0, y: 1), global: true),
    ],
  ),

  Bidirectional16: prototype(
    has_virtual: true,
    sandbox: true,
    schematic_inputs: 1,
    area: @[
      point(x: -1, y: -1), point(x: -1, y: 0), point(x: -1, y: 1),
      point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1),
      point(x: 1, y: -1), point(x: 1, y: 0), point(x: 1, y: 1),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 0, y: 2), kind: wk_16, global: true, tri_state: true),
    ],
    reset: proc(node: var node, memory_store: var openArray[uint64]) =
      node.is_z_state = true
      node.node_set_output(memory_store, 0, BIDIRECATIONAL_Z)
    ,
    category: @[CAT_IO, CAT_BIDIRECTIONAL_PINS],
  ),

  VirtualBidirectional16: prototype(
    input_pins: @[
      prototype_pin(position: point(x: 0, y: 2), global: true),
    ],
  ),

  Bidirectional32: prototype(
    has_virtual: true,
    sandbox: true,
    schematic_inputs: 1,
    area: @[
      point(x: -1, y: -1), point(x: -1, y: 0), point(x: -1, y: 1),
      point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1),
      point(x: 1, y: -1), point(x: 1, y: 0), point(x: 1, y: 1),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 0, y: 2), kind: wk_32, global: true, tri_state: true),
    ],
    reset: proc(node: var node, memory_store: var openArray[uint64]) =
      node.is_z_state = true
      node.node_set_output(memory_store, 0, BIDIRECATIONAL_Z)
    ,
    category: @[CAT_IO, CAT_BIDIRECTIONAL_PINS],
  ),

  VirtualBidirectional32: prototype(
    input_pins: @[
      prototype_pin(position: point(x: 0, y: 2), global: true),
    ],
  ),

  Bidirectional64: prototype(
    has_virtual: true,
    sandbox: true,
    schematic_inputs: 1,
    area: @[
      point(x: -2, y: -1), point(x: -1, y: -1), point(x: 0, y: -1), point(x: 1, y: -1), point(x: 2, y: -1),
      point(x: -2, y: 0), point(x: -1, y: 0), point(x: 0, y: 0), point(x: 1, y: 0), point(x: 2, y: 0),
      point(x: -2, y: 1), point(x: -1, y: 1), point(x: 0, y: 1), point(x: 1, y: 1), point(x: 2, y: 1),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 0, y: 2), kind: wk_64, global: true, tri_state: true),
    ],
    reset: proc(node: var node, memory_store: var openArray[uint64]) =
      node.is_z_state = true
      node.node_set_output(memory_store, 0, BIDIRECATIONAL_Z)
    ,
    category: @[CAT_IO, CAT_BIDIRECTIONAL_PINS],
  ),

  VirtualBidirectional64: prototype(
    input_pins: @[
      prototype_pin(position: point(x: 0, y: 2), global: true),
    ],
  ),

  LevelOutput8z: prototype(
    area: @[point(x: 1, y: 0), point(x: 0, y: 0), point(x: 0, y: -1)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), kind: wk_8),
      prototype_pin(position: point(x: 0, y: 1)),
    ],
    schematic_outputs: 2,
    category: @[CAT_IO],
    immutable: true,
  ),

  Network: prototype(
    sandbox_only: true,
    sandbox: true,
    area: @[
      point(x: -1, y: -1), point(x: -1, y: 0), point(x: -1, y: 1),
      point(x: 0, y: -1), point(x: 0, y: 0), point(x: 0, y: 1),
      point(x: 1, y: -1), point(x: 1, y: 0), point(x: 1, y: 1),
    ],
    input_pins: @[
      prototype_pin(position: point(x: -2, y: -1), kind: wk_8),
      prototype_pin(position: point(x: -2, y: 0), kind: wk_32),
      prototype_pin(position: point(x: -2, y: 1), kind: wk_64),
      prototype_pin(position: point(x: -2, y: 2), kind: wk_8),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: -2), kind: wk_8),
      prototype_pin(position: point(x: 2, y: -1), kind: wk_32),
      prototype_pin(position: point(x: 2, y: 0), kind: wk_64),
      prototype_pin(position: point(x: 2, y: 1), kind: wk_8),
    ],
    category: @[CAT_IO, CAT_SANDBOX_ONLY],
    memory: 3,
  ),

  IndexerBit: prototype(
    sandbox: true,
    area: @[point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), kind: wk_64),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0)),
    ],
    category: @[CAT_IO],
  ),

  IndexerByte: prototype(
    sandbox: true,
    area: @[point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), kind: wk_64),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_8),
    ],
    category: @[CAT_IO],
  ),

  ConfigDelay: prototype(
    sandbox: true,
    area: @[point(x: 0, y: 0)],
    input_pins: @[
      prototype_pin(position: point(x: -1, y: 0), kind: wk_64),
    ],
    output_pins: @[
      prototype_pin(position: point(x: 1, y: 0), kind: wk_64),
    ],
    category: @[CAT_IO],
  ),

}.toTable

proc reset_state*(schematic: var schematic, main_graph_nodes: var array[GRAPH_NODE_COUNT, node], memory_store: var array[GRAPH_MEMORY_SIZE, uint64]) =
  for id, wire in schematic.wires.mpairs:
    wire.value = 0
    wire.runtime_state = r_normal

  for index in nodes(main_graph_nodes, main_graph_nodes_len):
    if main_graph_nodes[index].kind in [Off, On, Rom, SolutionRom]: continue

    if main_graph_nodes[index].kind == WireCluster:
      main_graph_nodes[index].runtime_errors[0].component_id = -1
      main_graph_nodes[index].runtime_errors[1].component_id = -1

    for i, val in main_graph_nodes[index].node_output_items(memory_store):
      main_graph_nodes[index].node_set_output(memory_store, i, 0)
    
    if not prototypes[main_graph_nodes[index].kind].reset.isNil:
      prototypes[main_graph_nodes[index].kind].reset(main_graph_nodes[index], memory_store)

    else:
      for i, val in main_graph_nodes[index].node_memory_items(memory_store):
        main_graph_nodes[index].node_set_memory(memory_store, i.uint64, 0)

    if main_graph_nodes[index].kind == Program:
      main_graph_nodes[index].node_set_memory(memory_store, 0, PROGRAM_LENGTH - 1) # Load last address on first tick, because first address was confusing
