function createDriveItem(name, icon, stack_size, subgroup, order)
	local driveI = {}
	driveI.type = "item-with-tags"
	driveI.name = name
	driveI.icon = icon
	driveI.icon_size = 256
	driveI.subgroup = subgroup
	driveI.order = order
	driveI.place_result = name
	driveI.stack_size = stack_size
	data:extend{driveI}
end

function createDriveRecipe(name, craft_time, enabled, ingredients)
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

function createDriveEntity(name, icon, entity, shadow)
	local driveE = {}
	driveE.type = "container"
	driveE.name = name
	driveE.icon = icon
	driveE.icon_size = 256
	driveE.flags = {"placeable-neutral", "player-creation"}
	driveE.minable = {mining_time = 0.2, result = name}
	driveE.max_health = 350
	driveE.dying_explosion = "medium-explosion"
	driveE.corpse = "medium-remnants"
	driveE.collision_box = {{-0.90, -0.90}, {0.90, 0.90}}
	driveE.selection_box = {{-1.0, -1.0}, {1.0, 1.0}}
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
					width = 256,
					height = 256,
					shift = {0,-0.47225},
					scale = 0.5
				},
				{
					filename = shadow,
					priority = "high",
					width = 256,
					height = 256,
					shift = {1,-0.47225},
					draw_as_shadow = true,
					scale = 0.5
				}
			}
		}
	data:extend{driveE}
end
--------------------------------------------------------------------------------
for _, drive in pairs(Constants.Drives.ItemDrive) do
	createDriveItem(drive.name, drive.itemIcon, drive.stack_size, drive.subgroup, drive.order)
	createDriveRecipe(drive.name, drive.craft_time, drive.enabled, drive.ingredients)
	createDriveEntity(drive.name, drive.itemIcon, drive.entityE, drive.entityS)
end

for _, drive in pairs(Constants.Drives.FluidDrive) do
	createDriveItem(drive.name, drive.itemIcon, drive.stack_size, drive.subgroup, drive.order)
	createDriveRecipe(drive.name, drive.craft_time, drive.enabled, drive.ingredients)
	createDriveEntity(drive.name, drive.itemIcon, drive.entityE, drive.entityS)
end