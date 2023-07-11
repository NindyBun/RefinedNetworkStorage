local ioI = {}
ioI.type = "item"
ioI.name = Constants.NetworkCables.fluidIO.itemEntity.name
ioI.icon = Constants.NetworkCables.fluidIO.itemEntity.itemIcon
ioI.icon_size = 512
ioI.subgroup = Constants.ItemGroup.Category.subgroup
ioI.order = "i"
ioI.place_result = Constants.NetworkCables.fluidIO.itemEntity.name
ioI.stack_size = 25
data:extend{ioI}

local ioR = {}
ioR.type = "recipe"
ioR.name = Constants.NetworkCables.fluidIO.itemEntity.name
ioR.energy_required = 1
ioR.enabled = true
ioR.ingredients = {}
ioR.result = Constants.NetworkCables.fluidIO.itemEntity.name
ioR.result_count = 1
data:extend{ioR}

local ioE = {}
ioE.type = "assembling-machine"
ioE.name = Constants.NetworkCables.fluidIO.itemEntity.name
ioE.icon = Constants.NetworkCables.fluidIO.itemEntity.itemIcon
ioE.icon_size = 512
ioE.flags = {"placeable-neutral", "player-creation"}
ioE.collision_box = {{-0.40, -0.40}, {0.40, 0.40}}
ioE.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
ioE.animation =
    {
        north = {
			layers = {
				{
					filename = Constants.NetworkCables.fluidIO.itemEntity.entityE,
					priority = "extra-high",
                    size = 512,
					scale = 1/8,
					x=0
				},
				{
					filename = Constants.NetworkCables.fluidIO.itemEntity.entityS,
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
    type = "electric",
    usage_priority = "secondary-input",
    buffer_capacity = "1J",
    render_no_power_icon = false,
    render_no_network_icon = false
}
ioE.energy_usage = "1J"
ioE.fluid_boxes = {
    {
        base_area = 1,
        pipe_connections = {
            {type = "input-output", position = {0, -1}}
        },
        production_type = "output"
    }
}
data:extend{ioE}

local io = {}
io.type = "storage-tank"
io.name = Constants.NetworkCables.fluidIO.slateEntity.name
io.icon = Constants.NetworkCables.fluidIO.slateEntity.itemIcon
io.icon_size = 512
io.flags = {"placeable-neutral", "player-creation"}
io.collision_box = {{-0.40, -0.40}, {0.40, 0.40}}
io.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
io.window_bounding_box = {{0, 0}, {0, 0}}
io.fluid_box = {
    base_area = 12,
    hide_connection_info = true,
    pipe_connections = {
        {position = {0, -1}}
    }
}
io.placeable_by = {item=Constants.NetworkCables.fluidIO.itemEntity.name, count=1}
io.fast_replaceable_group = Constants.Settings.RNS_FR_Cable
io.max_health = 350
io.dying_explosion = "medium-explosion"
io.corpse = "small-remnants"
io.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
io.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
io.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
io.minable = {mining_time = 0.2, result = Constants.NetworkCables.fluidIO.itemEntity.name}
io.pictures =
    {
        picture = {
            north = {
                layers = {
                    {
                        filename = Constants.NetworkCables.fluidIO.slateEntity.entityE,
                        priority = "extra-high",
                        size = 512,
                        scale = 1/8,
                        x=0
                    },
                    {
                        filename = Constants.NetworkCables.fluidIO.slateEntity.entityS,
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
io.flow_length_in_ticks = 1
io.pictures.picture.east = table.deepcopy(io.pictures.picture.north)
io.pictures.picture.east.layers[1].x = 512
io.pictures.picture.east.layers[2].x = 512
io.pictures.picture.south = table.deepcopy(io.pictures.picture.north)
io.pictures.picture.south.layers[1].x = 512*2
io.pictures.picture.south.layers[2].x = 512*2
io.pictures.picture.west = table.deepcopy(io.pictures.picture.north)
io.pictures.picture.west.layers[1].x = 512*3
io.pictures.picture.west.layers[2].x = 512*3
data:extend{io}