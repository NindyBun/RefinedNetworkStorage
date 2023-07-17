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

local outer_frame_light = outer_frame_light()
outer_frame_light.base.center = {position = {42,8}, size=1}
data.raw["gui-style"].default[Constants.Settings.RNS_Gui.scroll_pane] =
{
	type = 'scroll_pane_style',
	padding = 0,
	extra_padding_when_activated = 0,
	extra_right_padding_when_activated = -12,
	graphical_set = outer_frame_light,
	background_graphical_set = {
		base = {
			position = {282, 17},
			corner_size = 8,
			overall_tiling_horizontal_padding = 0,
			overall_tiling_horizontal_size = 37,
			overall_tiling_horizontal_spacing = 0,
			overall_tiling_vertical_padding = 0,
			overall_tiling_vertical_size = 37,
			overall_tiling_vertical_spacing = 0
	  	}
	  }
}

data.raw["gui-style"].default.RNS_Fake_Button_Blue =
{
	type = "button_style",
	parent = "shortcut_bar_button",
	default_graphical_set =
	{
		base = {position = {312, 759}, corner_size = 8},
        shadow = offset_by_2_default_glow(default_dirt_color, 0.5)
	},
	hovered_graphical_set =
	{
		base = {position = {312, 759}, corner_size = 8},
        shadow = offset_by_2_default_glow(default_dirt_color, 0.5)
	},
	clicked_graphical_set =
	{
		base = {position = {312, 759}, corner_size = 8},
        shadow = offset_by_2_default_glow(default_dirt_color, 0.5)
	}
}

data.raw["gui-style"].default.RNS_Fake_Button_Green =
{
	type = "button_style",
	parent = "shortcut_bar_button",
	default_graphical_set =
	{
		base = {position = {312, 792}, corner_size = 8},
        shadow = offset_by_2_default_glow(default_dirt_color, 0.5)
	},
	hovered_graphical_set =
	{
		base = {position = {312, 792}, corner_size = 8},
        shadow = offset_by_2_default_glow(default_dirt_color, 0.5)
	},
	clicked_graphical_set =
	{
		base = {position = {312, 792}, corner_size = 8},
        shadow = offset_by_2_default_glow(default_dirt_color, 0.5)
	}
}

data.raw["gui-style"].default.RNS_Fake_Button_Red =
{
	type = "button_style",
	parent = "shortcut_bar_button",
	default_graphical_set =
	{
		base = {position = {312, 776}, corner_size = 8},
        shadow = offset_by_2_default_glow(default_dirt_color, 0.5)
	},
	hovered_graphical_set =
	{
		base = {position = {312, 776}, corner_size = 8},
        shadow = offset_by_2_default_glow(default_dirt_color, 0.5)
	},
	clicked_graphical_set =
	{
		base = {position = {312, 776}, corner_size = 8},
        shadow = offset_by_2_default_glow(default_dirt_color, 0.5)
	}
}

data.raw["gui-style"].default.RNS_Fake_Button_Purple =
{
	type = "button_style",
	parent = "shortcut_bar_button",
	default_graphical_set =
	{
		base = {position = {346, 759}, corner_size = 8, tint=purpleTint},
		shadow = offset_by_2_default_glow(default_dirt_color, 0.5)
	},
	hovered_graphical_set =
	{
		base = {position = {346, 759}, corner_size = 8, tint=purpleTint},
		shadow = offset_by_2_default_glow(default_dirt_color, 0.5)
	},
	clicked_graphical_set =
	{
		base = {position = {346, 759}, corner_size = 8, tint=purpleTint},
		shadow = offset_by_2_default_glow(default_dirt_color, 0.5)
	}
}