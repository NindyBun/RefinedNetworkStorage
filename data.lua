Constants = require("utils.constants")
require("prototypes.Drives")
require("prototypes.RNSNetworkController")
require("prototypes.NetworkLasers")
-------------------------------------------------------------------------------------
data:extend{
	{
		type="item-group",
		name=Constants.ItemGroup.Category.group,
		icon=Constants.Drives.ItemDrive1k.itemIcon,
		icon_size=256,
		order="x"
	}
}

data:extend{
	{
		type="item-subgroup",
		name=Constants.ItemGroup.Category.subgroup,
		group=Constants.ItemGroup.Category.group,
		order="a"
	}
}

data:extend{
	{
		type="item-subgroup",
		name=Constants.ItemGroup.Category.ItemDrive_subgroup,
		group=Constants.ItemGroup.Category.group,
		order="i"
	}
}

data:extend{
	{
		type="item-subgroup",
		name=Constants.ItemGroup.Category.FluidDrive_subgroup,
		group=Constants.ItemGroup.Category.group,
		order="f"
	}
}

data:extend{
	{
		type="item-subgroup",
		name=Constants.ItemGroup.Category.Laser_subgroup,
		group=Constants.ItemGroup.Category.group,
		order="l"
	}
}