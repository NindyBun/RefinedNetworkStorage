function createNetworkLaserItem(name, icon, stack_size)
	local networklaserI = {}
	networklaserI.type = "item"
	networklaserI.name = name
	networklaserI.icon = icon
	networklaserI.icon_size = 512
	networklaserI.subgroup = Constants.ItemGroup.Category.Laser_subgroup
	networklaserI.order = "l"
	networklaserI.place_result = name
	networklaserI.stack_size = stack_size
	data:extend{networklaserI}
end

function createNetworkLaserRecipe(name, craft_time, enabled, ingredients)
	local networklaserR = {}
	networklaserR.type = "recipe"
	networklaserR.name = name
	networklaserR.energy_required = craft_time
	networklaserR.enabled = enabled
	networklaserR.ingredients = ingredients
	networklaserR.result = name
	networklaserR.result_count = 1
	data:extend{networklaserR}
end

function createNetworkLaserEntity(name, icon, entity, shadow, fluidbox)
	local networklaserE = {}
	networklaserE.type = "assembling-machine"
	networklaserE.name = name
	networklaserE.icon = icon
	networklaserE.icon_size = 512
	networklaserE.flags = {"placeable-neutral", "placeable-player", "player-creation"}
	networklaserE.minable = {mining_time = 0.2, result = name}
	networklaserE.max_health = 250
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
                    width = 512,
                    height = 512,
                    frame_count = 1,
                    shift = {0,-0.02},
                    scale = 1/10
                },
                {
                    filename = shadow,
                    priority = "high",
                    width = 512,
                    height = 512,
                    frame_count = 1,
                    shift = {0.02,-0.02},
                    draw_as_shadow = true,
                    scale = 1/10
                },
			}
        }
    }
    networklaserE.animation.east = table.deepcopy(networklaserE.animation.north)
    networklaserE.animation.east.layers[1].x = 512*1
    networklaserE.animation.east.layers[2].x = 512*1
    networklaserE.animation.south = table.deepcopy(networklaserE.animation.north)
    networklaserE.animation.south.layers[1].x = 512*2
    networklaserE.animation.south.layers[2].x = 512*2
    networklaserE.animation.west = table.deepcopy(networklaserE.animation.north)
    networklaserE.animation.west.layers[1].x = 512*3
    networklaserE.animation.west.layers[2].x = 512*3
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
    networklaserE.fluid_boxes = { fluidbox }
	data:extend{networklaserE}
end
------------------------------------------------------------------------------------------------
for _, laser in pairs(Constants.NetworkLasers) do
    createNetworkLaserItem(laser.name, laser.itemIcon, laser.stack_size)
    createNetworkLaserRecipe(laser.name, laser.craft_time, laser.enabled, laser.ingredients)
    createNetworkLaserEntity(laser.name, laser.itemIcon, laser.entityE, laser.entityS, laser.connections)
end