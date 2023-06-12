function createDriveItem(name, icon, icon_size, stack_size, subgroup, order)
	local driveI = {}
	driveI.type = "item-with-tags"
	driveI.name = name
	driveI.icon = icon
	driveI.icon_size = icon_size
	driveI.subgroup = subgroup
	driveI.order = order
	driveI.place_result = name
	driveI.stack_size = stack_size
	data:extend{driveI}
end

function createDriveRecipe(name, craft_time, enabled, ingredients, count)
	local driveR = {}
	driveR.type = "recipe"
	driveR.name = name
	driveR.energy_required = craft_time
	driveR.enabled = enabled
	driveR.ingredients = ingredients
	driveR.result = name
	driveR.result_count = count
	data:extend{driveR}
end

function createDriveEntity(name, icon, icon_size, entity, shadow)
	local driveE = {}
	driveE.type = "container"
	driveE.name = name
	driveE.icon = icon
	driveE.icon_size = icon_size
	driveE.flags = {"placeable-neutral", "player-creation"}
	driveE.minable = {mining_time = 0.2, result = name}
	driveE.max_health = 100
	driveE.dying_explosion = "medium-explosion"
	driveE.corpse = "medium-remnants"
	driveE.render_not_in_network_icon = false
	driveE.collision_box = {{-1.0, -1.0}, {1.0, 1.0}}
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
					width = icon_size,
					height = icon_size,
					shift = {0,-0.5},
					scale = 0.5
				},
				{
					filename = shadow,
					priority = "high",
					width = icon_size,
					height = icon_size,
					shift = {1,-0.5},
					draw_as_shadow = true,
					scale = 0.5
				}
			}
		}
	data:extend{driveE}
end
--------------------------------------------------------------------------------
createDriveItem(
	Constants.Drives.ItemDrive1k.name,
	Constants.Drives.ItemDrive1k.itemIcon,
	256,
	10,
	Constants.ItemGroup.Category.ItemDrive_subgroup,
	"i-i[1]"
)
createDriveItem(
	Constants.Drives.ItemDrive4k.name,
	Constants.Drives.ItemDrive4k.itemIcon,
	256,
	10,
	Constants.ItemGroup.Category.ItemDrive_subgroup,
	"i-i[2]"
)
createDriveItem(
	Constants.Drives.ItemDrive16k.name,
	Constants.Drives.ItemDrive16k.itemIcon,
	256,
	10,
	Constants.ItemGroup.Category.ItemDrive_subgroup,
	"i-i[3]"
)
createDriveItem(
	Constants.Drives.ItemDrive64k.name,
	Constants.Drives.ItemDrive64k.itemIcon,
	256,
	10,
	Constants.ItemGroup.Category.ItemDrive_subgroup,
	"i-i[4]"
)
--------------------------------------------------------------------------------
createDriveRecipe(
	Constants.Drives.ItemDrive1k.name,
	1,
	true,
	{},
	1
)
createDriveRecipe(
	Constants.Drives.ItemDrive4k.name,
	1,
	true,
	{},
	1
)
createDriveRecipe(
	Constants.Drives.ItemDrive16k.name,
	1,
	true,
	{},
	1
)
createDriveRecipe(
	Constants.Drives.ItemDrive64k.name,
	1,
	true,
	{},
	1
)
--------------------------------------------------------------------------------
createDriveEntity(
	Constants.Drives.ItemDrive1k.name,
	Constants.Drives.ItemDrive1k.itemIcon,
	256,
	Constants.Drives.ItemDrive1k.entityE,
	Constants.Drives.ItemDrive1k.entityS
)
createDriveEntity(
	Constants.Drives.ItemDrive4k.name,
	Constants.Drives.ItemDrive4k.itemIcon,
	256,
	Constants.Drives.ItemDrive4k.entityE,
	Constants.Drives.ItemDrive4k.entityS
)
createDriveEntity(
	Constants.Drives.ItemDrive16k.name,
	Constants.Drives.ItemDrive16k.itemIcon,
	256,
	Constants.Drives.ItemDrive16k.entityE,
	Constants.Drives.ItemDrive16k.entityS
)
createDriveEntity(
	Constants.Drives.ItemDrive64k.name,
	Constants.Drives.ItemDrive64k.itemIcon,
	256,
	Constants.Drives.ItemDrive64k.entityE,
	Constants.Drives.ItemDrive64k.entityS
)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
createDriveItem(
	Constants.Drives.FluidDrive4k.name,
	Constants.Drives.FluidDrive4k.itemIcon,
	256,
	10,
	Constants.ItemGroup.Category.FluidDrive_subgroup,
	"f-f[1]"
)
createDriveItem(
	Constants.Drives.FluidDrive16k.name,
	Constants.Drives.FluidDrive16k.itemIcon,
	256,
	10,
	Constants.ItemGroup.Category.FluidDrive_subgroup,
	"f-f[2]"
)
createDriveItem(
	Constants.Drives.FluidDrive64k.name,
	Constants.Drives.FluidDrive64k.itemIcon,
	256,
	10,
	Constants.ItemGroup.Category.FluidDrive_subgroup,
	"f-f[3]"
)
createDriveItem(
	Constants.Drives.FluidDrive256k.name,
	Constants.Drives.FluidDrive256k.itemIcon,
	256,
	10,
	Constants.ItemGroup.Category.FluidDrive_subgroup,
	"f-f[4]"
)
--------------------------------------------------------------------------------
createDriveRecipe(
	Constants.Drives.FluidDrive4k.name,
	1,
	true,
	{},
	1
)
createDriveRecipe(
	Constants.Drives.FluidDrive16k.name,
	1,
	true,
	{},
	1
)
createDriveRecipe(
	Constants.Drives.FluidDrive64k.name,
	1,
	true,
	{},
	1
)
createDriveRecipe(
	Constants.Drives.FluidDrive256k.name,
	1,
	true,
	{},
	1
)
--------------------------------------------------------------------------------
createDriveEntity(
	Constants.Drives.FluidDrive4k.name,
	Constants.Drives.FluidDrive4k.itemIcon,
	256,
	Constants.Drives.FluidDrive4k.entityE,
	Constants.Drives.FluidDrive4k.entityS
)
createDriveEntity(
	Constants.Drives.FluidDrive16k.name,
	Constants.Drives.FluidDrive16k.itemIcon,
	256,
	Constants.Drives.FluidDrive16k.entityE,
	Constants.Drives.FluidDrive16k.entityS
)
createDriveEntity(
	Constants.Drives.FluidDrive64k.name,
	Constants.Drives.FluidDrive64k.itemIcon,
	256,
	Constants.Drives.FluidDrive64k.entityE,
	Constants.Drives.FluidDrive64k.entityS
)
createDriveEntity(
	Constants.Drives.FluidDrive256k.name,
	Constants.Drives.FluidDrive256k.itemIcon,
	256,
	Constants.Drives.FluidDrive256k.entityE,
	Constants.Drives.FluidDrive256k.entityS
)
--------------------------------------------------------------------------------