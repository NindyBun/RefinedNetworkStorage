function createNetworkLaserItem(name, icon, icon_size, stack_size, subgroup, order)
	local networklaserI = {}
	networklaserI.type = "item"
	networklaserI.name = name
	networklaserI.icon = icon
	networklaserI.icon_size = icon_size
	networklaserI.subgroup = subgroup
	networklaserI.order = order
	networklaserI.place_result = name
	networklaserI.stack_size = stack_size
	data:extend{networklaserI}
end

function createNetworkLaserRecipe(name, craft_time, enabled, ingredients, count)
	local networklaserR = {}
	networklaserR.type = "recipe"
	networklaserR.name = name
	networklaserR.energy_required = craft_time
	networklaserR.enabled = enabled
	networklaserR.ingredients = ingredients
	networklaserR.result = name
	networklaserR.result_count = count
	data:extend{networklaserR}
end

function createNetworkLaserEntity(name, icon, icon_size, entity, shadow)
	local networklaserE = {}
	networklaserE.type = "assembling-machine"
	networklaserE.name = name
	networklaserE.icon = icon
	networklaserE.icon_size = icon_size
	networklaserE.flags = {"placeable-neutral", "placeable-player", "player-creation"}
	networklaserE.minable = {mining_time = 0.2, result = name}
	networklaserE.max_health = 350
    networklaserE.dying_explosion = "medium-explosion"
	networklaserE.corpse = "small-remnants"
	networklaserE.render_not_in_network_icon = false
	networklaserE.collision_box = {{-0.5, -0.5}, {0.5, 0.5}}
	networklaserE.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
    networklaserE.resistances =
    {
        {
        type = "fire",
        percent = 70
        }
    }
    networklaserE.animation =
    {
        north =
        {
            layers =
			{
				{
					filename = entity,
					priority = "extra-high",
					width = icon_size,
					height = icon_size,
                    frame_count = 1,
					shift = {0,-1/10},
					scale = 1/10
				},
				{
					filename = shadow,
					priority = "high",
					width = icon_size,
					height = icon_size,
                    frame_count = 1,
					shift = {1/20,-1/10},
					draw_as_shadow = true,
					scale = 1/10
				}
			}
        }
    }
    networklaserE.animation.east = table.deepcopy(networklaserE.animation.north)
    networklaserE.animation.east.layers[1].x = icon_size*1
    networklaserE.animation.east.layers[2].x = icon_size*1
    networklaserE.animation.south = table.deepcopy(networklaserE.animation.north)
    networklaserE.animation.south.layers[1].x = icon_size*2
    networklaserE.animation.south.layers[2].x = icon_size*2
    networklaserE.animation.west = table.deepcopy(networklaserE.animation.north)
    networklaserE.animation.west.layers[1].x = icon_size*3
    networklaserE.animation.west.layers[2].x = icon_size*3
    networklaserE.crafting_categories = {"RNS-Nothing"}
    networklaserE.crafting_speed = 1
    networklaserE.energy_source =
    {
        type = "electric",
        usage_priority = "secondary-input",
        buffer_capacity = "1J",
        output_flow_limit = "0W",
        input_flow_limit = "0W",
        drain = "0W",
        render_no_power_icon = false,
        render_no_network_icon = false
    }
    networklaserE.energy_usage = "1J"
    networklaserE.fluid_boxes = {
        {
            base_level = 1,
            pipe_connections = {{type = "output", position = {0, -1}}},
            production_type = "output",
        },
        {
            base_level = 1,
            pipe_connections = {{type = "input", position = {0, 1}}},
            production_type = "input",
        }
    }
	data:extend{networklaserE}
end
------------------------------------------------------------------------------------------------
createNetworkLaserItem(
    Constants.NetworkLasers.NL1.name,
    Constants.NetworkLasers.NL1.itemIcon,
    512,
    25,
    Constants.ItemGroup.Category.Laser_subgroup,
    "1"
)
------------------------------------------------------------------------------------------------
createNetworkLaserRecipe(
    Constants.NetworkLasers.NL1.name,
    1,
    true,
    {},
    1
)
------------------------------------------------------------------------------------------------
createNetworkLaserEntity(
    Constants.NetworkLasers.NL1.name,
    Constants.NetworkLasers.NL1.itemIcon,
    512,
    Constants.NetworkLasers.NL1.entityE,
    Constants.NetworkLasers.NL1.entityS
)