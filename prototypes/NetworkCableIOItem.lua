local ioI = {}
ioI.type = "item"
ioI.name = Constants.NetworkCables.itemIO.name
ioI.icon = Constants.NetworkCables.itemIO.itemIcon
ioI.icon_size = 512
ioI.subgroup = Constants.ItemGroup.Category.subgroup
ioI.order = "i"
ioI.place_result = Constants.NetworkCables.itemIO.name
ioI.stack_size = 25
data:extend{ioI}

local ioR = {}
ioR.type = "recipe"
ioR.name = Constants.NetworkCables.itemIO.name
ioR.energy_required = 1
ioR.enabled = true
ioR.ingredients = {}
ioR.result = Constants.NetworkCables.itemIO.name
ioR.result_count = 1
data:extend{ioR}

local ioE = {}
ioE.type = "assembling-machine"
ioE.name = Constants.NetworkCables.itemIO.name
ioE.icon = Constants.NetworkCables.itemIO.itemIcon
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
ioE.minable = {mining_time = 0.2, result = Constants.NetworkCables.itemIO.name}
ioE.animation =
    {
        north = {
			layers = {
				{
					filename = Constants.NetworkCables.itemIO.entityE,
					priority = "extra-high",
                    size = 512,
					scale = 1/8,
					x=0
				},
				{
					filename = Constants.NetworkCables.itemIO.entityS,
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