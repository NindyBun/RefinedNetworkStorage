function createDriveItem(drive)
	local driveI = {}
	driveI.type = "item-with-tags"
	driveI.name = drive.name
	if string.match(drive.name, "RNS_ItemDrive") then
		driveI.localised_name = {"item-name.RNS_ItemDrive", drive.size}
		driveI.localised_description = {"item-description.RNS_ItemDrive", drive.size}
	else
		driveI.localised_name = {"item-name.RNS_FluidDrive", drive.size}
		driveI.localised_description = {"item-description.RNS_FluidDrive", drive.size}
	end
	driveI.icon = drive.itemIcon
	driveI.icon_size = 512
	driveI.subgroup = drive.subgroup
	driveI.order = drive.order
	driveI.place_result = drive.name
	driveI.stack_size = 20
	data:extend{driveI}
end
--[[
function createDriveRecipe(drive)
	local driveR = {}
	driveR.type = "recipe"
	driveR.name = drive.name
	driveR.energy_required = drive.craft_time
	driveR.enabled = drive.enabled
	driveR.ingredients = drive.ingredients
	driveR.result = drive.name
	driveR.result_count = 1
	data:extend{driveR}
end
]]

function createDriveEntity(drive)
	local driveE = {}
	driveE.type = "container"
	driveE.name = drive.name
	driveE.icon = drive.itemIcon
	driveE.icon_size = 512
	driveE.flags = {"placeable-neutral", "player-creation"}
	if string.match(drive.name, "RNS_ItemDrive") then
		driveE.localised_name = {"entity-name.RNS_ItemDrive", drive.size}
		driveE.localised_description = {"entity-description.RNS_ItemDrive", drive.size}
	else
		driveE.localised_name = {"entity-name.RNS_FluidDrive", drive.size}
		driveE.localised_description = {"entity-description.RNS_FluidDrive", drive.size}
	end
	driveE.minable = {mining_time = 0.2, result = drive.name}
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
					filename = drive.entityE,
					priority = "extra-high",
					width = 512,
					height = 512,
					shift = {0,-148/512},
					scale = 1/4
				},
				{
					filename = drive.entityS,
					priority = "high",
					width = 256,
					height = 256,
					shift = {1,-0.47225},
					draw_as_shadow = true,
					scale = 1/2
				}
			}
		}
	data:extend{driveE}
end
--------------------------------------------------------------------------------
for _, drive in pairs(Constants.Drives.ItemDrive) do
	createDriveItem(drive)
	--createDriveRecipe(drive)
	createDriveEntity(drive)
end

for _, drive in pairs(Constants.Drives.FluidDrive) do
	createDriveItem(drive)
	--createDriveRecipe(drive)
	createDriveEntity(drive)
end