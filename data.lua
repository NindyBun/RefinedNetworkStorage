Constants = require("utils.constants")
require("prototypes.Drives")
require("prototypes.NetworkController")
require("prototypes.NetworkInventoryBlock")
require("prototypes.NetworkCable")
require("prototypes.NetworkCableIOItem")
require("prototypes.NetworkCableIOFluid")
require("prototypes.NetworkCableIOExternal")
-------------------------------------------------------------------------------------
data:extend{
	{
		type="recipe-category",
		name="RNS-Nothing",
		order="z"
	}
}

data:extend{
	{
		type="item-group",
		name=Constants.ItemGroup.Category.group,
		icon=Constants.Drives.ItemDrive.ItemDrive1k.itemIcon,
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

data:extend{
	{
		type = "font",
		name = Constants.Settings.RNS_Gui.title_font,
		size = 20,
		from = "default-bold"
	}
}

data:extend{
	{
		type = "font",
		name = Constants.Settings.RNS_Gui.label_font,
		size = 18,
		from = "default"
	}
}

data:extend{
	{
		type = "font",
		name = Constants.Settings.RNS_Gui.label_font_2,
		size = 20,
		from = "default"
	}
}


data.raw["gui-style"].default[Constants.Settings.RNS_Gui.frame_1] =
{
	type = "frame_style",
	graphical_set = {},
	border = border_image_set(),
	right_padding = 4,
	use_header_filler = false,
	title_style =
	{
	  type="label_style",
	  parent = "caption_label"
	}
}