use std::collections::HashMap;
use crate::save_loader::*;
use crate::save_loader::ComponentType::{Bidirectional1, Bidirectional16, Bidirectional32, Bidirectional64, Bidirectional8, Custom, Deleted12, Deleted13, Deleted14, Deleted15, Deleted16, Error, Program, Program8_1, Program8_4};

pub fn parse(input: &[u8], i: &mut usize) -> Option<SaveFile> {
    let input = tetsy_snappy::decompress(&input[*i..input.len()]).ok()?;
    let mut i = 0;

    Some(SaveFile {
        version: 3,
        save_id: get_u64(&input, &mut i)?,
        hub_id: 0,
        gate: get_u64(&input, &mut i)?,
        delay: get_u64(&input, &mut i)?,
        menu_visible: get_bool(&input, &mut i)?,
        clock_speed: get_u32(&input, &mut i)?,
        dependencies: get_vec_u64(&input, &mut i)?,
        description: get_string(&input, &mut i)?,
        camera_position: get_point(&input, &mut i)?,
        synced: get_sync_state(&input, &mut i)?,
        campaign_bound: get_bool(&input, &mut i)?,
        player_data: {
            get_bool(&input, &mut i);
            get_vec_u8(&input, &mut i, false)
        }?,
        hub_description: String::default(),
        components: get_components(&input, &mut i)?,
        wires: get_wires(&input, &mut i)?
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

    Some(Component {
        component_type,
        position: get_point(input, i)?,
        rotation: get_u8(input, i)?,
        permanent_id: get_u64(input, i)?,
        custom_string: get_string(input, i)?,
        setting_1: get_u64(input, i)?,
        setting_2: get_u64(input, i)?,
        ui_order: 0,
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

            Some(programs)
        }?
    })
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
    Some(Wire {
        wire_type: WireType::from_ordinal(get_u8(input, i)? as usize)?,
        color: get_u8(input, i)?,
        comment: get_string(input, i)?,
        points: {
            // path is commented out since it's not actually used. The only required points are the endpoints.
            //let mut path: Vec<Point> = Vec::new();

            let first = get_point(input, i)?;
            let mut last = first;
            //path.push(last);
            let mut segment = get_u8(input, i)?;
            if segment == TELEPORT_WIRE {
                last = get_point(input, i)?;
                //path.push(last);
            } else {
                let mut length_left = segment & 0x1F;
                while length_left != 0 {
                    let direction = &DIRECTIONS[(segment >> 5) as usize];
                    while length_left > 0 {
                        last = &last + direction;
                        //path.push(last);
                        length_left -= 1;
                    }

                    segment = get_u8(input, i)?;
                    length_left = segment & 0x1F;
                }
            }

            Some(vec![first, last])
        }?
    })
}