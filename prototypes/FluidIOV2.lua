local name = "RNS_NetworkCableIOV2_Fluid"
local nameI = "RNS_Fluid_input"
local nameO = "RNS_Fluid_output"

local ioI = {}
ioI.type = "item"
ioI.name = name
ioI.icon = Constants.NetworkCables.fluidIO.itemIcon
ioI.icon_size = 512
ioI.subgroup = Constants.ItemGroup.Category.subgroup
ioI.order = "i"
ioI.place_result = name
ioI.stack_size = 50
data:extend{ioI}

local ioR = {}
ioR.type = "recipe"
ioR.name = name
ioR.energy_required = 1
ioR.enabled = true
ioR.ingredients = {}
ioR.result = name
ioR.result_count = 1
data:extend{ioR}

local ioE = {}
ioE.type = "assembling-machine"
ioE.name = name
ioE.icon = Constants.NetworkCables.fluidIO.itemIcon
ioE.icon_size = 512
ioE.flags = {"placeable-neutral", "player-creation"}
ioE.collision_box = {{-0.40, -0.40}, {0.40, 0.40}}
ioE.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
ioE.fast_replaceable_group = Constants.Settings.RNS_FR_Cable
ioE.selection_priority = 51
ioE.minable = {mining_time = 0.2, result = name}
ioE.max_health = 350
ioE.dying_explosion = "medium-explosion"
ioE.corpse = "small-remnants"
ioE.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
ioE.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
ioE.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
ioE.animation =
    {
        north = {
			layers = {
				{
					filename = Constants.NetworkCables.fluidIO.entityE,
					priority = "extra-high",
                    size = 512,
					scale = 1/8,
					x=0
				},
				{
					filename = Constants.NetworkCables.fluidIO.entityS,
					priority = "high",
                    size = 512,
					draw_as_shadow = true,
					scale = 1/8,
					x=0
				}
			}
		}
    }
ioE.animation.east = table.deepcopy(ioE.animation.north)
ioE.animation.east.layers[1].x = 512
ioE.animation.east.layers[2].x = 512
ioE.animation.south = table.deepcopy(ioE.animation.north)
ioE.animation.south.layers[1].x = 512*2
ioE.animation.south.layers[2].x = 512*2
ioE.animation.west = table.deepcopy(ioE.animation.north)
ioE.animation.west.layers[1].x = 512*3
ioE.animation.west.layers[2].x = 512*3
ioE.crafting_categories = {"RNS-Nothing"}
ioE.crafting_speed = 1
ioE.energy_source =
{
    type = "void",
}
ioE.energy_usage = "1J"
ioE.fluid_boxes = {
    {
        base_area = 1,
		hide_connection_info = true,
        pipe_connections = {
            {position = {0, -0.5}}
        },
        production_type = "output"
    }
}
data:extend{ioE}

local connection_points = {
	{shadow={green={0, 0}, red={0, 0}}, wire={green={0, 0}, red={0, 0}}},
	{shadow={green={0, 0}, red={0, 0}}, wire={green={0, 0}, red={0, 0}}},
	{shadow={green={0, 0}, red={0, 0}}, wire={green={0, 0}, red={0, 0}}},
	{shadow={green={0, 0}, red={0, 0}}, wire={green={0, 0}, red={0, 0}}}
}

local connection_lights = {
    {
        led_red = {
            filename = Constants.Settings.RNS_BlankIcon,
            size = 32
        },
        led_green = {
            filename = Constants.Settings.RNS_BlankIcon,
            size = 32
        },
        led_blue = {
            filename = Constants.Settings.RNS_BlankIcon,
            size = 32
        },
        led_light = {
            type = "basic",
            intensity = 0,
            size = 0
        }
    },
    {
        led_red = {
            filename = Constants.Settings.RNS_BlankIcon,
            size = 32
        },
        led_green = {
            filename = Constants.Settings.RNS_BlankIcon,
            size = 32
        },
        led_blue = {
            filename = Constants.Settings.RNS_BlankIcon,
            size = 32
        },
        led_light = {
            type = "basic",
            intensity = 0,
            size = 0
        }
    },
    {
        led_red = {
            filename = Constants.Settings.RNS_BlankIcon,
            size = 32
        },
        led_green = {
            filename = Constants.Settings.RNS_BlankIcon,
            size = 32
        },
        led_blue = {
            filename = Constants.Settings.RNS_BlankIcon,
            size = 32
        },
        led_light = {
            type = "basic",
            intensity = 0,
            size = 0
        }
    },
    {
        led_red = {
            filename = Constants.Settings.RNS_BlankIcon,
            size = 32
        },
        led_green = {
            filename = Constants.Settings.RNS_BlankIcon,
            size = 32
        },
        led_blue = {
            filename = Constants.Settings.RNS_BlankIcon,
            size = 32
        },
        led_light = {
            type = "basic",
            intensity = 0,
            size = 0
        }
    }
}

local i = {}
i.type = "pump"
i.name = nameI
i.icon = Constants.Settings.RNS_BlankIcon
i.icon_size = 32
i.flags = {"placeable-neutral", "player-creation", "not-rotatable"}
i.collision_box = {{-0.25, -0.25}, {0.25, 0.25}}
i.selection_box = {{-0.25, -0.25}, {0.25, 0.25}}
i.circuit_wire_connection_points = connection_points
i.circuit_connector_sprites = connection_lights
i.draw_circuit_wires = true
i.circuit_wire_max_distance = 9
i.selection_priority = 51
i.energy_source = {
    type = "void"
}
i.energy_usage = "1J"
i.pumping_speed = 20
i.fluid_wagon_connector_speed = 64
i.fluid_box = {
    base_area = 12, --volume = base_area * height * 100
    base_level = 1,
    pipe_connections = {
        {type = "input", position = {0, -1}}
    },
    --production_type = "input"
}
i.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
i.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
i.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
i.animations = {
    north = {
        filename = Constants.Settings.RNS_BlankIcon,
        size = 32,
        scale = 1,
    }
}
data:extend{i}

local o = {}
o.type = "pump"
o.name = nameO
o.icon = Constants.Settings.RNS_BlankIcon
o.icon_size = 32
o.flags = {"placeable-neutral", "player-creation", "not-rotatable"}
o.collision_box = {{-0.25, -0.25}, {0.25, 0.25}}
o.selection_box = {{-0.25, -0.25}, {0.25, 0.25}}
o.circuit_wire_connection_points = connection_points
o.circuit_connector_sprites = connection_lights
o.draw_circuit_wires = true
o.circuit_wire_max_distance = 9
o.selection_priority = 51
o.energy_source = {
    type = "void"
}
o.energy_usage = "1J"
o.pumping_speed = 20
o.fluid_wagon_connector_speed = 64
o.fluid_box = {
    base_area = 12, --volume = base_area * height * 100
    base_level = 1,
    pipe_connections = {
        {type = "output", position = {0, -1}}
    },
    --production_type = "output"
}
o.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
o.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
o.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
o.animations = {
    north = {
        filename = Constants.Settings.RNS_BlankIcon,
        size = 32,
        scale = 1,
    }
}
data:extend{o}

--[[local i = {}
i.type = "storage-tank"
i.name = nameI
i.icon = Constants.Settings.RNS_BlankIcon
i.icon_size = 32
i.flags = {"placeable-neutral", "player-creation", "not-rotatable"}
i.collision_box = {{-0.25, -0.25}, {0.25, 0.25}}
i.selection_box = {{-0.25, -0.25}, {0.25, 0.25}}
i.window_bounding_box = {{0, 0}, {0, 0}}
i.circuit_wire_connection_points = connection_points
i.circuit_connector_sprites = connection_lights
i.draw_circuit_wires = true
i.circuit_wire_max_distance = 7
i.selection_priority = 51
i.fluid_box = {
    base_area = 12, --volume = base_area * height * 100
    base_level = -1,
    pipe_connections = {
        {type = "input", position = {0, -1}}
    },
    production_type = "input"
}
i.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
i.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
i.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
i.pictures =
    {
        picture = {
            north = {
                layers = {
                    {
                        filename = Constants.Settings.RNS_BlankIcon,
                        priority = "extra-high",
                        size = 32,
                        scale = 1,
                    },
                }
            }
        },
        window_background = {
            filename = Constants.Settings.RNS_BlankIcon,
            size = 32,
            scale = 1
        },
        fluid_background = {
            filename = Constants.Settings.RNS_BlankIcon,
            size = 32,
            scale = 1
        },
        flow_sprite = {
            filename = Constants.Settings.RNS_BlankIcon,
            size = 32,
            scale = 1
        },
        gas_flow = {
            filename = Constants.Settings.RNS_BlankIcon,
            size = 32,
            scale = 1
        },
    }
i.flow_length_in_ticks = 1
i.pictures.picture.east = table.deepcopy(i.pictures.picture.north)
i.pictures.picture.south = table.deepcopy(i.pictures.picture.north)
i.pictures.picture.west = table.deepcopy(i.pictures.picture.north)
data:extend{i}

local o = {}
o.type = "storage-tank"
o.name = nameO
o.icon = Constants.Settings.RNS_BlankIcon
o.icon_size = 32
o.flags = {"placeable-neutral", "player-creation","not-rotatable"}
o.collision_box = {{-0.25, -0.25}, {0.25, 0.25}}
o.selection_box = {{-0.25, -0.25}, {0.25, 0.25}}
o.window_bounding_box = {{0, 0}, {0, 0}}
o.circuit_wire_connection_points = connection_points
o.circuit_connector_sprites = connection_lights
o.draw_circuit_wires = true
o.circuit_wire_max_distance = 7
o.selection_priority = 51
o.fluid_box = {
    base_area = 12, --volume = base_area * height * 100
    base_level = 1,
    pipe_connections = {
        {type = "output", position = {0, -1}}
    },
    production_type = "output"
}
o.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
o.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
o.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
o.pictures =
    {
        picture = {
            north = {
                layers = {
                    {
                        filename = Constants.Settings.RNS_BlankIcon,
                        priority = "extra-high",
                        size = 32,
                        scale = 1,
                    },
                }
            }
        },
        window_background = {
            filename = Constants.Settings.RNS_BlankIcon,
            size = 32,
            scale = 1
        },
        fluid_background = {
            filename = Constants.Settings.RNS_BlankIcon,
            size = 32,
            scale = 1
        },
        flow_sprite = {
            filename = Constants.Settings.RNS_BlankIcon,
            size = 32,
            scale = 1
        },
        gas_flow = {
            filename = Constants.Settings.RNS_BlankIcon,
            size = 32,
            scale = 1
        },
    }
o.flow_length_in_ticks = 1
o.pictures.picture.east = table.deepcopy(o.pictures.picture.north)
o.pictures.picture.south = table.deepcopy(o.pictures.picture.north)
o.pictures.picture.west = table.deepcopy(o.pictures.picture.north)
data:extend{o}]]