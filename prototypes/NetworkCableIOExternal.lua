local ioI = {}
ioI.type = "item"
ioI.name = Constants.NetworkCables.externalIO.itemEntity.name
ioI.icon = Constants.NetworkCables.externalIO.itemEntity.itemIcon
ioI.icon_size = 512
ioI.subgroup = Constants.ItemGroup.Category.subgroup
ioI.order = "i"
ioI.place_result = Constants.NetworkCables.externalIO.itemEntity.name
ioI.stack_size = 25
data:extend{ioI}

local ioR = {}
ioR.type = "recipe"
ioR.name = Constants.NetworkCables.externalIO.itemEntity.name
ioR.energy_required = 1
ioR.enabled = true
ioR.ingredients = {}
ioR.result = Constants.NetworkCables.externalIO.itemEntity.name
ioR.result_count = 1
data:extend{ioR}

local ioE = {}
ioE.type = "assembling-machine"
ioE.name = Constants.NetworkCables.externalIO.itemEntity.name
ioE.icon = Constants.NetworkCables.externalIO.itemEntity.itemIcon
ioE.icon_size = 512
ioE.max_health = 350
ioE.flags = {"placeable-neutral", "player-creation"}
ioE.collision_box = {{-0.40, -0.40}, {0.40, 0.40}}
ioE.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
ioE.animation =
    {
        north = {
			layers = {
				{
					filename = Constants.NetworkCables.externalIO.itemEntity.entityE,
					priority = "extra-high",
                    size = 512,
					scale = 1/8,
					x=0
				},
				{
					filename = Constants.NetworkCables.externalIO.itemEntity.entityS,
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
io.type = "assembling-machine"
io.name = Constants.NetworkCables.externalIO.slateEntity.name
io.icon = Constants.NetworkCables.externalIO.slateEntity.itemIcon
io.icon_size = 512
io.flags = {"placeable-neutral", "player-creation"}
io.collision_box = {{-0.40, -0.40}, {0.40, 0.40}}
io.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
io.placeable_by = {item=Constants.NetworkCables.externalIO.itemEntity.name, count=1}
io.fast_replaceable_group = Constants.Settings.RNS_FR_Cable
io.max_health = 350
io.dying_explosion = "medium-explosion"
io.corpse = "small-remnants"
io.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
io.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
io.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
io.minable = {mining_time = 0.2, result = Constants.NetworkCables.externalIO.itemEntity.name}
io.animation =
    {
        north = {
			layers = {
				{
					filename = Constants.NetworkCables.externalIO.slateEntity.entityE,
					priority = "extra-high",
                    size = 512,
					scale = 1/8,
					x=0
				},
				{
					filename = Constants.NetworkCables.externalIO.slateEntity.entityS,
					priority = "high",
                    size = 512,
					draw_as_shadow = true,
					scale = 1/8,
					x=0
				}
			}
		}
    }
io.animation.east = table.deepcopy(io.animation.north)
io.animation.east.layers[1].x = 512
io.animation.east.layers[2].x = 512
io.animation.south = table.deepcopy(io.animation.north)
io.animation.south.layers[1].x = 512*2
io.animation.south.layers[2].x = 512*2
io.animation.west = table.deepcopy(io.animation.north)
io.animation.west.layers[1].x = 512*3
io.animation.west.layers[2].x = 512*3
io.crafting_categories = {"RNS-Nothing"}
io.crafting_speed = 1
io.energy_source =
{
    type = "electric",
    usage_priority = "secondary-input",
    buffer_capacity = "0J",
	drain = "0J",
    render_no_power_icon = false,
    render_no_network_icon = false
}
io.energy_usage = "1J"
io.fluid_boxes = {
    {
        base_area = 1,
		hide_connection_info = true,
        pipe_connections = {
            {position = {0, -0.5}}
        },
        production_type = "output"
    }
}
data:extend{io}

local sprite1 = {}
sprite1.type = "sprite"
sprite1.name = Constants.Icons.storage.name
sprite1.layers = {
    {
        filename = Constants.Icons.storage.sprite,
        priority = "high",
        size = 48,
        scale = 24/48
    }
}
data:extend{sprite1}

local sprite2 = {}
sprite2.type = "sprite"
sprite2.name = Constants.Icons.storage_bothways.name
sprite2.layers = {
    {
        filename = Constants.Icons.storage_bothways.sprite,
        priority = "high",
        size = 48,
        scale = 24/48
    }
}
data:extend{sprite2}