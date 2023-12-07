data:extend
{
    {
        type = "fluid",
        name = "rns_empty_fluid",
        default_temperature = 15,
        max_temperature = 100,
        heat_capacity = "0.2KJ",
        base_color = {r=0, g=0.34, b=0.6},
        flow_color = {r=0.7, g=0.7, b=0.7},
        icon = Constants.Settings.RNS_BlankIcon,
        icon_size = 32,
        hidden = true,
        auto_barrel = false
    }
}

local ioI = {}
ioI.type = "item"
ioI.name = Constants.NetworkCables.fluidIO.name
ioI.icon = Constants.NetworkCables.fluidIO.itemIcon
ioI.icon_size = 512
ioI.subgroup = Constants.ItemGroup.Category.subgroup
ioI.order = "i"
ioI.place_result = Constants.NetworkCables.fluidIO.name
ioI.stack_size = 50
data:extend{ioI}

--[[
local ioR = {}
ioR.type = "recipe"
ioR.name = Constants.NetworkCables.fluidIO.name
ioR.energy_required = 1
ioR.enabled = true
ioR.ingredients = {}
ioR.result = Constants.NetworkCables.fluidIO.name
ioR.result_count = 1
data:extend{ioR}
]]

--[[local ioE = {}
ioE.type = "storage-tank"
ioE.name = Constants.NetworkCables.fluidIO.name
ioE.icon = Constants.NetworkCables.fluidIO.itemIcon
ioE.icon_size = 512
ioE.flags = {"placeable-neutral", "player-creation"}
ioE.collision_box = {{-0.40, -0.40}, {0.40, 0.40}}
ioE.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
ioE.window_bounding_box = {{0, 0}, {0, 0}}
ioE.fluid_box = {
    base_area = 1, --scales by 100x
    base_level = 1,
    --filter="rns_empty_fluid",
    hide_connection_info = true,
    pipe_connections = {
        {type = "output", position = {0, -1}}
    }
}
ioE.fast_replaceable_group = Constants.Settings.RNS_FR_Cable
ioE.max_health = 350
ioE.dying_explosion = "medium-explosion"
ioE.corpse = "small-remnants"
ioE.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
ioE.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
ioE.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
ioE.minable = {mining_time = 0.2, result = Constants.NetworkCables.fluidIO.name}
ioE.pictures =
    {
        picture = {
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
ioE.flow_length_in_ticks = 1
ioE.pictures.picture.east = table.deepcopy(ioE.pictures.picture.north)
ioE.pictures.picture.east.layers[1].x = 512
ioE.pictures.picture.east.layers[2].x = 512
ioE.pictures.picture.south = table.deepcopy(ioE.pictures.picture.north)
ioE.pictures.picture.south.layers[1].x = 512*2
ioE.pictures.picture.south.layers[2].x = 512*2
ioE.pictures.picture.west = table.deepcopy(ioE.pictures.picture.north)
ioE.pictures.picture.west.layers[1].x = 512*3
ioE.pictures.picture.west.layers[2].x = 512*3
data:extend{ioE}]]

local ioE = {}
ioE.type = "assembling-machine"
ioE.name = Constants.NetworkCables.fluidIO.name
ioE.icon = Constants.NetworkCables.fluidIO.itemIcon
ioE.icon_size = 512
ioE.flags = {"placeable-neutral", "player-creation"}
ioE.collision_box = {{-0.40, -0.40}, {0.40, 0.40}}
ioE.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
ioE.fast_replaceable_group = Constants.Settings.RNS_FR_Cable
ioE.max_health = 350
ioE.dying_explosion = "medium-explosion"
ioE.corpse = "small-remnants"
ioE.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
ioE.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
ioE.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
ioE.minable = {mining_time = 0.2, result = Constants.NetworkCables.fluidIO.name}
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
            {type = "output", position = {0, -1}}
        },
        production_type = "output"
    }
}
data:extend{ioE}