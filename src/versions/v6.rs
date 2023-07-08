use std::collections::HashMap;
use crate::save_parser::{SaveFile, get_u8, get_u16, get_i16, get_u32, get_u64, get_bool, get_string, get_vec_u8, get_vec_u64, get_point, get_sync_state, Component, ComponentType, DELETED_KINDS, Point, Wire, WireType, TELEPORT_WIRE, DIRECTIONS, get_wires};
use crate::save_parser::ComponentType::{Bidirectional1, Bidirectional16, Bidirectional32, Bidirectional64, Bidirectional8, Custom, Deleted12, Deleted13, Deleted14, Deleted15, Deleted16, Error, Program, Program8_1, Program8_4};

pub fn parse(input: &[u8], i: &mut usize) -> Option<SaveFile> {
    let input = tetsy_snappy::decompress(&input[*i..input.len()]).ok()?;
    let mut i = 0;

    let version = 6;
    let save_id = get_u64(&input, &mut i)?;
    let hub_id = get_u32(&input, &mut i)?;
    let gate = get_u64(&input, &mut i)?;
    let delay = get_u64(&input, &mut i)?;
    let menu_visible = get_bool(&input, &mut i)?;
    let clock_speed = get_u32(&input, &mut i)?;
    let dependencies = get_vec_u64(&input, &mut i)?;
    let description = get_string(&input, &mut i)?;
    let camera_position = get_point(&input, &mut i)?;
    let synced = get_sync_state(&input, &mut i)?;
    let campaign_bound = get_bool(&input, &mut i)?;
    get_u16(&input, &mut i)?;
    let player_data = get_vec_u8(&input, &mut i, false)?;
    let hub_description = get_string(&input, &mut i)?;

    Some(SaveFile::new(version, save_id, hub_id, hub_description, gate, delay, menu_visible, clock_speed, dependencies, description, camera_position, player_data, synced, campaign_bound,
                       get_components, get_wires, input, i))
}

fn get_components(input: &[u8], i: &mut usize) -> Option<Vec<Component>> {
    let mut components = Vec::new();
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

    Some(Component {
        component_type,
        position: get_point(input, i)?,
        rotation: get_u8(input, i)?,
        permanent_id: get_u64(input, i)?,
        custom_string: get_string(input, i)?,
        setting_1: get_u64(input, i)?,
        setting_2: get_u64(input, i)?,
        ui_order: get_i16(input, i)?,
        custom_id: if component_type == Custom {
            get_u64(input, i)?
        } else {
            0
        },
        custom_displacement: if component_type == Custom {
            get_point(input, i)?
        } else {
            Point {x: 0, y: 0}
        },
        selected_programs: {
            let mut programs = HashMap::new();

            if [Program8_1, Program8_4, Program].contains(&component_type) {
                let len = get_u16(input, i)?;
                let mut j = 0u16;
                while j < len {
                    let key = get_u64(input, i)?;
                    programs.insert(key, get_string(input, i)?);
                    j += 1;
                }
            }

            programs
        }
    })
}