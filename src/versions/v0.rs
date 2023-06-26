use std::collections::HashMap;
use crate::save_parser::{SaveFile, get_u8, get_i8, get_u16, get_u32, get_u64, get_bool, Component, ComponentType, DELETED_KINDS, Point, Wire, WireType, SyncState};
use crate::save_parser::ComponentType::{Bidirectional1, Bidirectional16, Bidirectional32, Bidirectional64, Bidirectional8, Custom, Deleted12, Deleted13, Deleted14, Deleted15, Deleted16, Deleted6, Deleted7, Error, Program, Program8_1, Program8_4};

fn get_point(input: &[u8], i: &mut usize) -> Option<Point> {
    let x = get_i8(input, i)? as i16;
    let y = get_i8(input, i)? as i16;
    Some(Point {x, y})
}

fn get_vec_points(input: &[u8], i: &mut usize) -> Option<Vec<Point>> {
    let mut result: Vec<Point> = Vec::new();
    let length = get_u64(input, i)?;

    let mut index: u64 = 0;
    while index < length {
        result.push(get_point(input, i)?);
        index += 1;
    }

    Some(result)
}

fn get_string(input: &[u8], i: &mut usize) -> Option<String> {
    let length = get_u64(input, i)? as usize;

    if *i + length > input.len() {
        None
    } else {
        let result: String = String::from_utf8(input[*i..(*i + length)].to_vec()).ok()?;
        *i += length;

        Some(result)
    }
}

fn get_vec_u64(input: &[u8], i: &mut usize) -> Option<Vec<u64>> {
    let mut result: Vec<u64> = Vec::new();
    let length = get_u64(input, i)?;

    let mut index: u64 = 0;
    while index < length {
        result.push(get_u64(input, i)?);
        index += 1;
    }

    Some(result)
}

pub fn parse(input: &[u8], i: &mut usize) -> Option<SaveFile> {
    Some(SaveFile {
        version: 0,
        save_id: get_u64(input, i)?,
        hub_id: 0,
        gate: get_u32(input, i)? as u64,
        delay: get_u32(input, i)? as u64,
        menu_visible: get_bool(input, i)?,
        clock_speed: get_u32(input, i)?,
        dependencies: {
            get_u8(input, i);
            get_vec_u64(input, i)?
        },
        description: get_string(input, i)?,
        camera_position: Point::default(),
        synced: SyncState::Unsynced,
        campaign_bound: false,
        player_data: Vec::default(),
        hub_description: String::default(),
        components: get_components(input, i)?,
        wires: get_wires(input, i)?
    })
}

fn get_components(input: &[u8], i: &mut usize) -> Option<Vec<Component>> {
    let mut components: Vec<Component> = Vec::new();
    let length = get_u64(input, i)?;
    let mut j = 0u64;
    while j < length {
        let comp = get_component(input, i)?;
        if comp.component_type != Error && !DELETED_KINDS.contains(&comp.component_type) {
            components.push(comp);
        }
        j += 1
    }

    Some(components)
}

fn get_component(input: &[u8], i: &mut usize) -> Option<Component> {
    let mut component_type = ComponentType::from_ordinal(get_u16(input, i)? as usize)?;
    let index = [Deleted12, Deleted13, Deleted14, Deleted15, Deleted16].binary_search(&component_type).ok();
    if let Some(i) = index {
        component_type = [Bidirectional1, Bidirectional8, Bidirectional16, Bidirectional32, Bidirectional64][i];
    }

    let c = Component {
        component_type,
        position: get_point(input, i)?,
        rotation: get_u8(input, i)?,
        permanent_id: get_u32(input, i)? as u64,
        custom_string: get_string(input, i)?,
        setting_1: 0,
        setting_2: 0,
        ui_order: 0,
        custom_id: if component_type == Custom {
            get_u64(input, i)?
        } else {
            0
        },
        custom_displacement: Point::default(),
        selected_programs: HashMap::default()
    };

    if [Program8_1, Deleted6, Deleted7, Program8_4, Program].contains(&c.component_type) {
        get_string(input, i);
    }

    Some(c)
}

fn get_wires(input: &[u8], i: &mut usize) -> Option<Vec<Wire>> {
    let mut wires: Vec<Wire> = Vec::new();
    let length = get_u64(input, i)?;
    let mut j = 0u64;
    while j < length {
        wires.push(get_wire(input, i)?);
        j += 1
    }

    Some(wires)
}

fn get_wire(input: &[u8], i: &mut usize) -> Option<Wire> {
    get_u32(input, i);
    Some(Wire {
        wire_type: WireType::from_ordinal(get_u8(input, i)? as usize)?,
        color: get_u8(input, i)?,
        comment: get_string(input, i)?,
        points: get_vec_points(input, i)?
    })
}