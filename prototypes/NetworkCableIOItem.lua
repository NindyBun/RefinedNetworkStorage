local ioI = {}
ioI.type = "item"
ioI.name = Constants.NetworkCables.itemIO.itemEntity.name
ioI.icon = Constants.NetworkCables.itemIO.itemEntity.itemIcon
ioI.icon_size = 512
ioI.subgroup = Constants.ItemGroup.Category.subgroup
ioI.order = "i"
ioI.place_result = Constants.NetworkCables.itemIO.itemEntity.name
ioI.stack_size = 25
data:extend{ioI}

local ioR = {}
ioR.type = "recipe"
ioR.name = Constants.NetworkCables.itemIO.itemEntity.name
ioR.energy_required = 1
ioR.enabled = true
ioR.ingredients = {}
ioR.result = Constants.NetworkCables.itemIO.itemEntity.name
ioR.result_count = 1
data:extend{ioR}

local ioE = {}
ioE.type = "assembling-machine"
ioE.name = Constants.NetworkCables.itemIO.itemEntity.name
ioE.icon = Constants.NetworkCables.itemIO.itemEntity.itemIcon
ioE.icon_size = 512
ioE.flags = {"placeable-neutral", "placeable-player"}
ioE.collision_box = {{-0.40, -0.40}, {0.40, 0.40}}
ioE.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
ioE.animation =
    {
        north = {
			layers = {
				{
					filename = Constants.NetworkCables.itemIO.itemEntity.entityE,
					priority = "extra-high",
                    size = 512,
					scale = 1/8,
					x=0
				},
				{
					filename = Constants.NetworkCables.itemIO.itemEntity.entityS,
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
io.name = Constants.NetworkCables.itemIO.slateEntity.name
io.icon = Constants.NetworkCables.itemIO.slateEntity.itemIcon
io.icon_size = 32
io.flags = {"placeable-neutral", "placeable-player"}
io.collision_box = {{-0.40, -0.40}, {0.40, 0.40}}
io.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
io.placeable_by = {item=Constants.NetworkCables.itemIO.itemEntity.name, count=1}
io.fast_replaceable_group = Constants.Settings.RNS_FR_Cable
io.max_health = 350
io.dying_explosion = "medium-explosion"
io.corpse = "small-remnants"
io.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
io.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
io.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
io.minable = {mining_time = 0.2, result = Constants.NetworkCables.itemIO.itemEntity.name}
io.animation =
    {
        north = {
			layers = {
				{
					filename = Constants.NetworkCables.itemIO.slateEntity.entityE,
					priority = "extra-high",
                    size = 512,
					scale = 1/8,
					x=0
				},
				{
					filename = Constants.NetworkCables.itemIO.slateEntity.entityS,
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
    buffer_capacity = "1J",
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

--[[function createItemIO(id)
    local io1 = {}
	io1.type = "container"
	io1.name = Constants.NetworkCables.itemIO.statesEntity.states[id].name
	io1.icon = Constants.NetworkCables.itemIO.statesEntity.itemIcon
	io1.icon_size = 32
    io1.flags = {"placeable-neutral"}
    io1.collision_box = {{-0.40, -0.40}, {0.40, 0.40}}
	io1.inventory_size = 0
    io1.selectable_in_game = false
    io1.alert_when_damaged = false
	io1.picture = Constants.NetworkCables.itemIO.statesEntity.states[id].picture
	data:extend{io1}
end

for i = 1, 4  do
    createItemIO(i)
end]]

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

function createTestEntity2(name, icon)
	local io = {}
	io.type = "assembling-machine"
	io.name = name
	io.icon = icon
	io.icon_size = 32
	io.flags = {"placeable-neutral", "placeable-player"}
	io.collision_box = {{-0.40, -0.40}, {0.40, 0.40}}
	io.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
	io.max_health = 350
	io.dying_explosion = "medium-explosion"
	io.corpse = "small-remnants"
	io.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
	io.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
	io.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
	io.minable = {mining_time = 0.2, result = name}
	io.animation =
		{
			north = {
				layers = {
					{
						filename = "__RefinedNetworkStorage__/graphics/Cables/IO/ItemIOSheet.png",
						priority = "extra-high",
						size = 512,
						scale = 1/8,
						x=0
					}
				}
			},
			east = {
				layers = {
					{
						filename = "__RefinedNetworkStorage__/graphics/Cables/IO/ItemIOSheet.png",
						priority = "extra-high",
						size = 512,
						scale = 1/8,
						x=512
					}
				}
			},
			south = {
				layers = {
					{
						filename = "__RefinedNetworkStorage__/graphics/Cables/IO/ItemIOSheet.png",
						priority = "extra-high",
						size = 512,
						scale = 1/8,
						x=512*2
					}
				}
			},
			west = {
				layers = {
					{
						filename = "__RefinedNetworkStorage__/graphics/Cables/IO/ItemIOSheet.png",
						priority = "extra-high",
						size = 512,
						scale = 1/8,
						x=512*3
					}
				}
			}
		}
	io.crafting_categories = {"RNS-Nothing"}
	io.crafting_speed = 1
	io.energy_source =
	{
		type = "electric",
		usage_priority = "secondary-input",
		buffer_capacity = "1J",
		render_no_power_icon = false,
		render_no_network_icon = false
	}
	io.energy_usage = "1J"
	io.fluid_boxes = {
		{
			base_area = 1,
			hide_connection_info = true,
			--pipe_covers = pipecoverspictures(),
			pipe_connections = {
				{position = {0, -0.5}}
			},
			production_type = "output"
		}
	 }
	data:extend{io}
end

--createTestItem("test", "__RefinedNetworkStorage__/graphics/Cables/IO/ItemIO.png", 25, Constants.ItemGroup.Category.subgroup, "t")
--createTestRecipe("test", 1, true, {})
--createTestEntity2("test", "__RefinedNetworkStorage__/graphics/Cables/IO/ItemIO.png")
--createTestEntity("test", "__RefinedNetworkStorage__/graphics/Cables/untitled.png", "__RefinedNetworkStorage__/graphics/Cables/untitled.png", "__RefinedNetworkStorage__/graphics/Cables/untitled.png")