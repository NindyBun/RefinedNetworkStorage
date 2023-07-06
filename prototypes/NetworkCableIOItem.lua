local networkItemioI = {}
networkItemioI.type = "item"
networkItemioI.name = Constants.NetworkCables.itemIO.itemEntity.name
networkItemioI.icon = Constants.NetworkCables.itemIO.itemEntity.itemIcon
networkItemioI.icon_size = 512
networkItemioI.subgroup = Constants.ItemGroup.Category.subgroup
networkItemioI.order = "i"
networkItemioI.place_result = Constants.NetworkCables.itemIO.itemEntity.name
networkItemioI.stack_size = 25
data:extend{networkItemioI}

local networkItemioR = {}
networkItemioR.type = "recipe"
networkItemioR.name = Constants.NetworkCables.itemIO.itemEntity.name
networkItemioR.energy_required = 1
networkItemioR.enabled = true
networkItemioR.ingredients = {}
networkItemioR.result = Constants.NetworkCables.itemIO.itemEntity.name
networkItemioR.result_count = 1
data:extend{networkItemioR}

local networkItemioE = {}
networkItemioE.type = "assembling-machine"
networkItemioE.name = Constants.NetworkCables.itemIO.itemEntity.name
networkItemioE.icon = Constants.NetworkCables.itemIO.itemEntity.itemIcon
networkItemioE.icon_size = 512
networkItemioE.flags = {"placeable-neutral", "placeable-player"}
networkItemioE.collision_box = {{-0.40, -0.40}, {0.40, 0.40}}
networkItemioE.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
networkItemioE.minable = {mining_time = 0.2, result = Constants.NetworkCables.itemIO.itemEntity.name}
networkItemioE.animation =
    {
        north = Constants.NetworkCables.itemIO.statesEntity.states[1].picture,
        east = Constants.NetworkCables.itemIO.statesEntity.states[2].picture,
        south = Constants.NetworkCables.itemIO.statesEntity.states[3].picture,
        west = Constants.NetworkCables.itemIO.statesEntity.states[4].picture
    }
networkItemioE.crafting_categories = {"RNS-Nothing"}
networkItemioE.crafting_speed = 1
networkItemioE.energy_source =
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
networkItemioE.energy_usage = "1J"
networkItemioE.fluid_boxes = {
    {
        base_area = 1,
        pipe_connections = {
            {type = "input-output", position = {0, -1}}
        },
        production_type = "output"
    }
 }
data:extend{networkItemioE}

function createNetworkIOBusEntity(eName, iName, icon, fluidbox)
    local networkItemioE = {}
	networkItemioE.type = "assembling-machine"
	networkItemioE.name = eName
	networkItemioE.icon = icon
	networkItemioE.icon_size = 512
	networkItemioE.flags = {"placeable-neutral", "placeable-player", "player-creation"}
	networkItemioE.minable = {mining_time = 0.2, result = iName}
    networkItemioE.placeable_by = {item = iName, count = 1}
	networkItemioE.max_health = 250
    networkItemioE.dying_explosion = "medium-explosion"
	networkItemioE.corpse = "small-remnants"
	networkItemioE.render_not_in_network_icon = false
	networkItemioE.collision_box = {{-0.40, -0.40}, {0.40, 0.40}}
	networkItemioE.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
    networkItemioE.resistances =
    {
        {
        type = "fire",
        percent = 70
        }
    }
    networkItemioE.animation =
    {
        north =
        {
            layers =
			{
                {
                    filename = "__RefinedNetworkStorage__/graphics/Cables/NetworkCableBlank.png",
                    priority = "extra-high",
                    width = 32,
                    height = 32,
                    draw_as_shadow = true,
                    shift = {0,0},
                    scale = 1
                }
            }
        }
    }
    networkItemioE.animation.east = table.deepcopy(networkItemioE.animation.north)
    networkItemioE.animation.south = table.deepcopy(networkItemioE.animation.north)
    networkItemioE.animation.west = table.deepcopy(networkItemioE.animation.north)
    networkItemioE.crafting_categories = {"RNS-Nothing"}
    networkItemioE.crafting_speed = 1
    networkItemioE.energy_source =
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
    networkItemioE.energy_usage = "1J"
	data:extend{networkItemioE}
end

function createTestItem(name, icon, stack_size, subgroup, order)
	local driveI = {}
	driveI.type = "item"
	driveI.name = name
	driveI.icon = icon
	driveI.icon_size = 512
	driveI.subgroup = subgroup
	driveI.order = order
	driveI.place_result = name
	driveI.stack_size = stack_size
	data:extend{driveI}
end

function createTestRecipe(name, craft_time, enabled, ingredients)
	local driveR = {}
	driveR.type = "recipe"
	driveR.name = name
	driveR.energy_required = craft_time
	driveR.enabled = enabled
	driveR.ingredients = ingredients
	driveR.result = name
	driveR.result_count = 1
	data:extend{driveR}
end

function createTestEntity(name, icon, entity, shadow)
	local driveE = {}
	driveE.type = "container"
	driveE.name = name
	driveE.icon = icon
	driveE.icon_size = 512
	driveE.flags = {"placeable-neutral", "player-creation"}
	driveE.minable = {mining_time = 0.2, result = name}
	driveE.max_health = 350
	driveE.dying_explosion = "medium-explosion"
	driveE.corpse = "small-remnants"
	driveE.collision_box = {{-0.40, -0.40}, {0.40, 0.40}}
	driveE.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
	driveE.inventory_size = 0
	driveE.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
	driveE.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
	driveE.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
	driveE.picture =
		{
			layers =
			{
				{
					filename = entity,
					priority = "extra-high",
                    size = 512,
					scale = 1/8
				},
				{
					filename = shadow,
					priority = "high",
                    size = 512,
					draw_as_shadow = true,
					scale = 1/8
				}
			}
		}
	data:extend{driveE}
end

--createTestItem("test", "__RefinedNetworkStorage__/graphics/Cables/untitled.png", 25, Constants.ItemGroup.Category.subgroup, "t")
--createTestRecipe("test", 1, true, {})
--createTestEntity("test", "__RefinedNetworkStorage__/graphics/Cables/untitled.png", "__RefinedNetworkStorage__/graphics/Cables/untitled.png", "__RefinedNetworkStorage__/graphics/Cables/untitled.png")