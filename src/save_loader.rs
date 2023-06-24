use std::fs;
use enum_ordinalize::Ordinalize;
use std::collections::{HashSet, HashMap};
use std::ops::{Add, Sub, Mul};
use once_cell::sync::Lazy;
use std::convert::TryInto;
use crate::versions::{
    v0,
    v1,
    v2,
    v3,
    v4,
    v5,
    v6
};

pub const TELEPORT_WIRE: u8 = 0b0010_0000;

#[derive(Debug, PartialEq, Eq, Ordinalize, Hash, PartialOrd, Ord, Clone, Copy)]
#[repr(usize)]
pub enum ComponentType {
    Error = 0,
    Off = 1,
    On = 2,
    Buffer1 = 3,
    Not = 4,
    And = 5,
    And3 = 6,
    Nand = 7,
    Or = 8,
    Or3 = 9,
    Nor = 10,
    Xor = 11,
    Xnor = 12,
    Counter8 = 13,
    VirtualCounter8 = 14,
    Counter64 = 15,
    VirtualCounter64 = 16,
    Ram8 = 17,
    VirtualRam8 = 18,
    Deleted0 = 19,
    Deleted1 = 20,
    Deleted17 = 21,
    Deleted18 = 22,
    Register8 = 23,
    VirtualRegister8 = 24,
    Register8Red = 25,
    VirtualRegister8Red = 26,
    Register8RedPlus = 27,
    VirtualRegister8RedPlus = 28,
    Register64 = 29,
    VirtualRegister64 = 30,
    Switch8 = 31,
    Mux8 = 32,
    Decoder1 = 33,
    Decoder3 = 34,
    Constant8 = 35,
    Not8 = 36,
    Or8 = 37,
    And8 = 38,
    Xor8 = 39,
    Equal8 = 40,
    Deleted2 = 41,
    Deleted3 = 42,
    Neg8 = 43,
    Add8 = 44,
    Mul8 = 45,
    Splitter8 = 46,
    Maker8 = 47,
    Splitter64 = 48,
    Maker64 = 49,
    FullAdder = 50,
    BitMemory = 51,
    VirtualBitMemory = 52,
    Deleted10 = 53,
    Decoder2 = 54,
    Timing = 55,
    NoteSound = 56,
    Deleted4 = 57,
    Deleted5 = 58,
    Keyboard = 59,
    FileLoader = 60,
    Halt = 61,
    WireCluster = 62,
    LevelScreen = 63,
    Program8_1 = 64,
    Program8_1Red = 65,
    Deleted6 = 66,
    Deleted7 = 67,
    Program8_4 = 68,
    LevelGate = 69,
    Input1 = 70,
    LevelInput2Pin = 71,
    LevelInput3Pin = 72,
    LevelInput4Pin = 73,
    LevelInputConditions = 74,
    Input8 = 75,
    Input64 = 76,
    LevelInputCode = 77,
    LevelInputArch = 78,
    Output1 = 79,
    LevelOutput1Sum = 80,
    LevelOutput1Car = 81,
    Deleted8 = 82,
    Deleted9 = 83,
    LevelOutput2Pin = 84,
    LevelOutput3Pin = 85,
    LevelOutput4Pin = 86,
    Output8 = 87,
    Output64 = 88,
    LevelOutputArch = 89,
    LevelOutputCounter = 90,
    Deleted11 = 91,
    Custom = 92,
    VirtualCustom = 93,
    Program = 94,
    DelayLine1 = 95,
    VirtualDelayLine1 = 96,
    Console = 97,
    Shl8 = 98,
    Shr8 = 99,

    Constant64 = 100,
    Not64 = 101,
    Or64 = 102,
    And64 = 103,
    Xor64 = 104,
    Neg64 = 105,
    Add64 = 106,
    Mul64 = 107,
    Equal64 = 108,
    LessU64 = 109,
    LessI64 = 110,
    Shl64 = 111,
    Shr64 = 112,
    Mux64 = 113,
    Switch64 = 114,

    ProbeMemoryBit = 115,
    ProbeMemoryWord = 116,

    AndOrLatch = 117,
    NandNandLatch = 118,
    NorNorLatch = 119,

    LessU8 = 120,
    LessI8 = 121,

    DotMatrixDisplay = 122,
    SegmentDisplay = 123,

    Input16 = 124,
    Input32 = 125,

    Output16 = 126,
    Output32 = 127,

    Deleted12 = 128,
    Deleted13 = 129,
    Deleted14 = 130,
    Deleted15 = 131,
    Deleted16 = 132,

    Buffer8 = 133,
    Buffer16 = 134,
    Buffer32 = 135,
    Buffer64 = 136,

    ProbeWireBit = 137,
    ProbeWireWord = 138,

    Switch1 = 139,

    Output1z = 140,
    Output8z = 141,
    Output16z = 142,
    Output32z = 143,
    Output64z = 144,

    Constant16 = 145,
    Not16 = 146,
    Or16 = 147,
    And16 = 148,
    Xor16 = 149,
    Neg16 = 150,
    Add16 = 151,
    Mul16 = 152,
    Equal16 = 153,
    LessU16 = 154,
    LessI16 = 155,
    Shl16 = 156,
    Shr16 = 157,
    Mux16 = 158,
    Switch16 = 159,
    Splitter16 = 160,
    Maker16 = 161,
    Register16 = 162,
    VirtualRegister16 = 163,
    Counter16 = 164,
    VirtualCounter16 = 165,

    Constant32 = 166,
    Not32 = 167,
    Or32 = 168,
    And32 = 169,
    Xor32 = 170,
    Neg32 = 171,
    Add32 = 172,
    Mul32 = 173,
    Equal32 = 174,
    LessU32 = 175,
    LessI32 = 176,
    Shl32 = 177,
    Shr32 = 178,
    Mux32 = 179,
    Switch32 = 180,
    Splitter32 = 181,
    Maker32 = 182,
    Register32 = 183,
    VirtualRegister32 = 184,
    Counter32 = 185,
    VirtualCounter32 = 186,

    LevelOutput8z = 187,

    Nand8 = 188,
    Nor8 = 189,
    Xnor8 = 190,
    Nand16 = 191,
    Nor16 = 192,
    Xnor16 = 193,
    Nand32 = 194,
    Nor32 = 195,
    Xnor32 = 196,
    Nand64 = 197,
    Nor64 = 198,
    Xnor64 = 199,

    Ram = 200,
    VirtualRam = 201,
    RamLatency = 202,
    VirtualRamLatency = 203,

    RamFast = 204,
    VirtualRamFast = 205,
    Rom = 206,
    VirtualRom = 207,
    SolutionRom = 208,
    VirtualSolutionRom = 209,

    DelayLine8 = 210,
    VirtualDelayLine8 = 211,
    DelayLine16 = 212,
    VirtualDelayLine16 = 213,
    DelayLine32 = 214,
    VirtualDelayLine32 = 215,
    DelayLine64 = 216,
    VirtualDelayLine64 = 217,

    RamDualLoad = 218,
    VirtualRamDualLoad = 219,

    Hdd = 220,
    VirtualHdd = 221,

    Network = 222,

    Rol8 = 223,
    Rol16 = 224,
    Rol32 = 225,
    Rol64 = 226,
    Ror8 = 227,
    Ror16 = 228,
    Ror32 = 229,
    Ror64 = 230,

    IndexerBit = 231,
    IndexerByte = 232,

    DivMod8 = 233,
    DivMod16 = 234,
    DivMod32 = 235,
    DivMod64 = 236,

    SpriteDisplay = 237,
    ConfigDelay = 238,

    Clock = 239,

    LevelInput1 = 240,
    LevelInput8 = 241,
    LevelOutput1 = 242,
    LevelOutput8 = 243,

    Ashr8 = 244,
    Ashr16 = 245,
    Ashr32 = 246,
    Ashr64 = 247,

    Bidirectional1 = 248,
    VirtualBidirectional1 = 249,
    Bidirectional8 = 250,
    VirtualBidirectional8 = 251,
    Bidirectional16 = 252,
    VirtualBidirectional16 = 253,
    Bidirectional32 = 254,
    VirtualBidirectional32 = 255,
    Bidirectional64 = 256,
    VirtualBidirectional64 = 257,
}

pub static EARLY_KINDS: Lazy<HashSet<ComponentType>> = Lazy::new(|| HashSet::from( [ComponentType::LevelInput1, ComponentType::LevelInput2Pin, ComponentType::LevelInput3Pin, ComponentType::LevelInput4Pin, ComponentType::LevelInputConditions, ComponentType::LevelInput8, ComponentType::Input64, ComponentType::LevelInputCode, ComponentType::LevelOutput1, ComponentType::LevelOutput1Sum, ComponentType::LevelOutput1Car, ComponentType::LevelOutput2Pin, ComponentType::LevelOutput3Pin, ComponentType::LevelOutput4Pin, ComponentType::LevelOutput8, ComponentType::LevelOutputArch, ComponentType::LevelOutputCounter, ComponentType::LevelOutput8z, ComponentType::DelayLine1, ComponentType::DelayLine16, ComponentType::BitMemory, ComponentType::Ram8, ComponentType::Hdd, ComponentType::Register8, ComponentType::Counter32, ComponentType::Counter16, ComponentType::Register16, ComponentType::DelayLine8, ComponentType::Custom, ComponentType::SolutionRom, ComponentType::RamFast, ComponentType::Counter64, ComponentType::Rom, ComponentType::Register32, ComponentType::Ram, ComponentType::Register8RedPlus, ComponentType::DelayLine64, ComponentType::Register64, ComponentType::DelayLine32, ComponentType::Counter8, ComponentType::Register8Red, ComponentType::RamLatency, ComponentType::RamDualLoad, ComponentType::DelayLine1, ComponentType::DelayLine16, ComponentType::BitMemory, ComponentType::Ram8, ComponentType::Hdd, ComponentType::Register8, ComponentType::Counter32, ComponentType::Counter16, ComponentType::Register16, ComponentType::DelayLine8, ComponentType::Custom, ComponentType::SolutionRom, ComponentType::RamFast, ComponentType::Counter64, ComponentType::Rom, ComponentType::Register32, ComponentType::Ram, ComponentType::Register8RedPlus, ComponentType::DelayLine64, ComponentType::Register64, ComponentType::DelayLine32, ComponentType::Counter8, ComponentType::Register8Red, ComponentType::RamLatency, ComponentType::RamDualLoad, ComponentType::Bidirectional1, ComponentType::Bidirectional8, ComponentType::Bidirectional16, ComponentType::Bidirectional32, ComponentType::Bidirectional64]));
pub static LATE_KINDS: Lazy<HashSet<ComponentType>> = Lazy::new(|| HashSet::from([ComponentType::VirtualCounter8, ComponentType::VirtualCounter64, ComponentType::VirtualRam8, ComponentType::VirtualRegister8, ComponentType::VirtualRegister8Red, ComponentType::VirtualRegister8RedPlus, ComponentType::VirtualRegister64, ComponentType::VirtualBitMemory, ComponentType::VirtualCustom, ComponentType::VirtualDelayLine1, ComponentType::VirtualRegister16, ComponentType::VirtualCounter16, ComponentType::VirtualRegister32, ComponentType::VirtualCounter32, ComponentType::VirtualRam, ComponentType::VirtualRamLatency, ComponentType::VirtualRamFast, ComponentType::VirtualRom, ComponentType::VirtualSolutionRom, ComponentType::VirtualDelayLine8, ComponentType::VirtualDelayLine16, ComponentType::VirtualDelayLine32, ComponentType::VirtualDelayLine64, ComponentType::VirtualRamDualLoad, ComponentType::VirtualHdd, ComponentType::VirtualBidirectional1, ComponentType::VirtualBidirectional8, ComponentType::VirtualBidirectional16, ComponentType::VirtualBidirectional32, ComponentType::VirtualBidirectional64]));
pub static CUSTOM_INPUTS: Lazy<HashSet<ComponentType>> = Lazy::new(|| HashSet::from([ComponentType::Input1, ComponentType::Input8, ComponentType::Input16, ComponentType::Input32, ComponentType::Input64]));
pub static CUSTOM_OUTPUTS: Lazy<HashSet<ComponentType>> = Lazy::new(|| HashSet::from([ComponentType::Output1, ComponentType::Output8, ComponentType::Output16, ComponentType::Output32, ComponentType::Output64]));
pub static CUSTOM_TRISTATE_OUTPUTS: Lazy<HashSet<ComponentType>> = Lazy::new(|| HashSet::from([ComponentType::Output1z, ComponentType::Output8z, ComponentType::Output16z, ComponentType::Output32z, ComponentType::Output64z]));
pub static CUSTOM_BIDIRECTIONAL: Lazy<HashSet<ComponentType>> = Lazy::new(|| HashSet::from([ComponentType::Bidirectional1, ComponentType::Bidirectional8, ComponentType::Bidirectional16, ComponentType::Bidirectional32, ComponentType::Bidirectional64]));
pub static LEVEL_INPUTS: Lazy<HashSet<ComponentType>> = Lazy::new(|| HashSet::from([ComponentType::LevelInput1, ComponentType::LevelInput2Pin, ComponentType::LevelInput3Pin, ComponentType::LevelInput4Pin, ComponentType::LevelInput8, ComponentType::LevelInputArch, ComponentType::LevelInputCode, ComponentType::LevelInputConditions]));
pub static LEVEL_OUTPUTS: Lazy<HashSet<ComponentType>> = Lazy::new(|| HashSet::from([ComponentType::LevelOutput1, ComponentType::LevelOutput1Car, ComponentType::LevelOutput1Sum, ComponentType::LevelOutput2Pin, ComponentType::LevelOutput3Pin, ComponentType::LevelOutput4Pin, ComponentType::LevelOutput8, ComponentType::LevelOutput8z, ComponentType::LevelOutputArch, ComponentType::LevelOutputCounter]));
pub static LATCHES: Lazy<HashSet<ComponentType>> = Lazy::new(|| HashSet::from([ComponentType::AndOrLatch, ComponentType::NandNandLatch, ComponentType::NorNorLatch]));
pub static DELETED_KINDS: Lazy<HashSet<ComponentType>> = Lazy::new(|| HashSet::from([ComponentType::Deleted0, ComponentType::Deleted1, ComponentType::Deleted2, ComponentType::Deleted3, ComponentType::Deleted4, ComponentType::Deleted5, ComponentType::Deleted6, ComponentType::Deleted7, ComponentType::Deleted8, ComponentType::Deleted9, ComponentType::Deleted10, ComponentType::Deleted11, ComponentType::Deleted12, ComponentType::Deleted13, ComponentType::Deleted14, ComponentType::Deleted15, ComponentType::Deleted16, ComponentType::Deleted17, ComponentType::Deleted18]));

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Default)]
pub struct Point {
    pub x: i16,
    pub y: i16
}

impl From<Point> for (i16, i16) {
    fn from(p: Point) -> (i16, i16) {
        (p.x, p.y)
    }
}

impl<'a, 'b> Add<&'b Point> for &'a Point {
    type Output = Point;

    fn add(self, other: &'b Point) -> Point {
        Point {
            x: self.x + other.x,
            y: self.y + other.y
        }
    }
}

impl<'a, 'b> Sub<&'b Point> for &'a Point {
    type Output = Point;

    fn sub(self, other: &'b Point) -> Point {
        Point {
            x: self.x - other.x,
            y: self.y - other.y
        }
    }
}

impl<'a, 'b> Mul<&'b i16> for &'a Point {
    type Output = Point;

    fn mul(self, other: &'b i16) -> Point {
        Point {
            x: self.x * other,
            y: self.y * other
        }
    }
}

pub static DIRECTIONS: Lazy<Vec<Point>> = Lazy::new(|| Vec::from([
    Point {x: 1, y: 0},
    Point {x: 1, y: 1},
    Point {x: 0, y: 1},
    Point {x: -1, y: 1},
    Point {x: -1, y: 0},
    Point {x: -1, y: -1},
    Point {x: 0, y: -1},
    Point {x: 1, y: -1}
]));

#[derive(Debug, PartialEq, Eq, Ordinalize)]
#[repr(usize)]
pub enum WireType {
    Wire1,
    Wire8,
    Wire16,
    Wire32,
    Wire64
}

#[derive(Debug, PartialEq, Eq, Ordinalize)]
#[repr(usize)]
pub enum SyncState {
    Unsynced,
    Synced,
    ChangedAfterSync
}

#[derive(Debug)]
pub struct Component {
    pub component_type: ComponentType,
    pub position: Point,
    pub custom_displacement: Point,
    pub rotation: u8,
    pub permanent_id: u64,
    pub custom_string: String,
    pub custom_id: u64,
    pub setting_1: u64,
    pub setting_2: u64,
    pub selected_programs: HashMap<u64, String>,
    pub ui_order: i16
}

#[derive(Debug)]
pub struct Wire {
    pub points: Vec<Point>,
    pub wire_type: WireType,
    pub color: u8,
    pub comment: String
}

#[derive(Debug)]
pub struct SaveFile {
    pub version: u8,
    pub components: Vec<Component>,
    pub wires: Vec<Wire>,
    pub save_id: u64,
    pub hub_id: u32,
    pub hub_description: String,
    pub gate: u64,
    pub delay: u64,
    pub menu_visible: bool,
    pub clock_speed: u32,
    pub dependencies: Vec<u64>,
    pub description: String,
    pub camera_position: Point,
    pub player_data: Vec<u8>,
    pub synced: SyncState,
    pub campaign_bound: bool
}

pub fn get_bool(input: &[u8], i: &mut usize) -> Option<bool> {
    if *i + 1 > input.len() {
        None
    } else {
        let result = Some(input[*i] != 0);
        *i += 1;
        result
    }
}

pub fn get_u64(input: &[u8], i: &mut usize) -> Option<u64> {
    if *i + 8 > input.len() {
        None
    } else {
        let result = u64::from_le_bytes(input[*i..(*i + 8)].try_into().unwrap());
        *i += 8;
        Some(result)
    }
}

pub fn get_i64(input: &[u8], i: &mut usize) -> Option<i64> {
    if *i + 8 > input.len() {
        None
    } else {
        let result = i64::from_le_bytes(input[*i..(*i + 8)].try_into().unwrap());
        *i += 8;
        Some(result)
    }
}

pub fn get_u32(input: &[u8], i: &mut usize) -> Option<u32> {
    if *i + 4 > input.len() {
        None
    } else {
        let result = u32::from_le_bytes(input[*i..(*i + 4)].try_into().unwrap());
        *i += 4;
        Some(result)
    }
}

pub fn get_i32(input: &[u8], i: &mut usize) -> Option<i32> {
    if *i + 4 > input.len() {
        None
    } else {
        let result = i32::from_le_bytes(input[*i..(*i + 4)].try_into().unwrap());
        *i += 4;
        Some(result)
    }
}

pub fn get_u16(input: &[u8], i: &mut usize) -> Option<u16> {
    if *i + 2 > input.len() {
        None
    } else {
        let result = u16::from_le_bytes(input[*i..(*i + 2)].try_into().unwrap());
        *i += 2;
        Some(result)
    }
}

pub fn get_i16(input: &[u8], i: &mut usize) -> Option<i16> {
    if *i + 2 > input.len() {
        None
    } else {
        let result = i16::from_le_bytes(input[*i..(*i + 2)].try_into().unwrap());
        *i += 2;
        Some(result)
    }
}

pub fn get_u8(input: &[u8], i: &mut usize) -> Option<u8> {
    if *i + 1 > input.len() {
        None
    } else {
        let result = Some(input[*i]);
        *i += 1;
        result
    }
}

pub fn get_i8(input: &[u8], i: &mut usize) -> Option<i8> {
    if *i + 1 > input.len() {
        None
    } else {
        let result = Some(input[*i] as i8);
        *i += 1;
        result
    }
}

pub fn get_sync_state(input: &[u8], i: &mut usize) -> Option<SyncState> {
    let result = get_u8(input, i)? as usize;
    SyncState::from_ordinal(result)
}

pub fn get_point(input: &[u8], i: &mut usize) -> Option<Point> {
    let x = get_i16(input, i)?;
    let y = get_i16(input, i)?;
    Some(Point {x, y})
}

pub fn get_vec_u8(input: &[u8], i: &mut usize, index_size_is_32_bit: bool) -> Option<Vec<u8>> {
    let mut result: Vec<u8> = Vec::new();
    let length = if index_size_is_32_bit {
        get_u32(input, i)?
    } else {
        get_u16(input, i)? as u32
    };

    let mut index: u32 = 0;
    while index < length {
        result.push(get_u8(input, i)?);
        index += 1;
    }

    Some(result)
}

pub fn get_vec_u64(input: &[u8], i: &mut usize) -> Option<Vec<u64>> {
    let mut result: Vec<u64> = Vec::new();
    let length = get_u16(input, i)?;

    let mut index: u16 = 0;
    while index < length {
        result.push(get_u64(input, i)?);
        index += 1;
    }

    Some(result)
}

pub fn get_string(input: &[u8], i: &mut usize) -> Option<String> {
    let length = get_u16(input, i)? as usize;

    if *i + length > input.len() {
        None
    } else {
        let result: String = String::from_utf8(input[*i..(*i + length)].to_vec()).ok()?;
        *i += length;

        Some(result)
    }
}

pub fn load_save(file_path: &str) -> Result<SaveFile, String> {
    let data = fs::read(file_path).unwrap_or_else(|_| panic!("Failed to load file: {}", file_path));
    let mut i: usize = 0;
    let version = get_u8(&data, &mut i).ok_or("Failed to get save version")?;
    match version {
        0 => v0::parse(&data, &mut i),
        1 => v1::parse(&data, &mut i),
        2 => v2::parse(&data, &mut i),
        3 => v3::parse(&data, &mut i),
        4 => v4::parse(&data, &mut i),
        5 => v5::parse(&data, &mut i),
        6 => v6::parse(&data, &mut i),
        _ => None
    }.ok_or_else(|| format!("Failed to parse save file version {version}"))
}