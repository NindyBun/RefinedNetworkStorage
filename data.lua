Constants = require("utils.constants")
require("prototypes.Intermediates")
require("prototypes.others")
require("prototypes.Drives")
require("prototypes.WirelessDevices")
require("prototypes.Detector")
require("prototypes.NetworkController")
require("prototypes.NetworkInventoryBlock")
require("prototypes.NetworkCable")
--require("prototypes.ItemIOV2")
--require("prototypes.FluidIOV2")
require("prototypes.NetworkCableIOItem")
require("prototypes.NetworkCableIOFluid")
require("prototypes.NetworkCableIOExternal")
require("prototypes.Recipes")
require("prototypes.Technologies")
-------------------------------------------------------------------------------------
data:extend{
	{
		type = "shortcut",
		name = Constants.Settings.RNS_Player_Port_Shortcut,
		order = "p",
		toggleable=true,
		action = "lua",
		icon =
		{
		  filename = Constants.MOD_ID.."/graphics/playerportIcon.png",
		  priority = "extra-high-no-scale",
		  size = 40,
		  flags = {"gui-icon"}
		},
	  }
}

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
		icon=Constants.Drives.ItemDrive.ItemDrive4k.itemIcon,
		icon_size=512,
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
		name=Constants.ItemGroup.Category.Cable_subgroup,
		group=Constants.ItemGroup.Category.group,
		order="c"
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
		type="item-subgroup",
		name=Constants.ItemGroup.Category.Intermediate_subgroup,
		group=Constants.ItemGroup.Category.group,
		order="b"
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
	type = "scroll_pane_style",
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

data.raw["gui-style"].default[Constants.Settings.RNS_Gui.button_1] =
{
	type = "button_style",
	parent = "shortcut_bar_button",
	default_graphical_set =
	{
		base = {position={312, 744}, corner_size=8, tint={255, 255, 255}},
		shadow = offset_by_2_default_glow(default_dirt_color, 0.5)
	},
	hovered_graphical_set =
	{
		base = {position={312, 744}, corner_size=8, tint={243, 170, 69}},
		shadow = offset_by_2_default_glow(default_dirt_color, 0.5)
	},
	clicked_graphical_set =
	{
		base = {position={312, 744}, corner_size=8, tint={243, 170, 69}},
		shadow = offset_by_2_default_glow(default_dirt_color, 0.5)
	}
}

data.raw["gui-style"].default[Constants.Settings.RNS_Gui.button_2] =
{
	type = "button_style",
	parent = "shortcut_bar_button",
	default_graphical_set =
	{
		base = {position={312, 744}, corner_size=8, tint={255, 130, 255}},
		shadow = offset_by_2_default_glow(default_dirt_color, 0.5)
	},
	hovered_graphical_set =
	{
		base = {position={312, 744}, corner_size=8, tint={255, 216, 255}},
		shadow = offset_by_2_default_glow(default_dirt_color, 0.5)
	},
	clicked_graphical_set =
	{
		base = {position={312, 744}, corner_size=8, tint={255, 216, 255}},
		shadow = offset_by_2_default_glow(default_dirt_color, 0.5)
	}
}

local blank32 = {
	filename = Constants.Settings.RNS_BlankIcon32,
	size = 32,
	priority = "medium",
	scale = 1
}

local detector_middle = {
	filename = Constants.Detector.itemIcon,
	priority = "medium",
	width = 512,
	height = 512,
	scale = 1/16
}

data.raw["gui-style"].default[Constants.Settings.RNS_Gui.checkbox] = {
	type = "checkbox_style",
	font = "default",
	font_color = { r = 1, g = 1, b = 1 },
	padding = 0,
	size = { 32, 32 },
	default_graphical_set = data.raw["gui-style"].default.button.default_graphical_set,
	hovered_graphical_set = data.raw["gui-style"].default.button.hovered_graphical_set,
	clicked_graphical_set = data.raw["gui-style"].default.button.clicked_graphical_set,
	disabled_graphical_set = data.raw["gui-style"].default.button.disabled_graphical_set,
	selected_graphical_set = {
	  base = data.raw["gui-style"].default.button.hovered_graphical_set.base,
	  shadow = offset_by_2_default_glow(default_dirt_color, 0.5),
	},
	selected_hovered_graphical_set = data.raw["gui-style"].default.button.hovered_graphical_set,
	selected_clicked_graphical_set = data.raw["gui-style"].default.button.clicked_graphical_set,
	checkmark = blank32,
  }

data.raw["gui-style"].default[Constants.Settings.RNS_Gui.checkbox_blank] = {
	type = "checkbox_style",
	font = "default",
	font_color = { r = 1, g = 1, b = 1 },
	padding = 0,
	size = { 32, 32 },
	default_graphical_set = blank32,
	hovered_graphical_set = blank32,
	clicked_graphical_set = blank32,
	disabled_graphical_set = blank32,
	selected_graphical_set = blank32,
	selected_hovered_graphical_set = blank32,
	selected_clicked_graphical_set = blank32,
	checkmark = blank32,
  }
  
  data.raw["gui-style"].default[Constants.Settings.RNS_Gui.checkbox_middle] = {
	type = "checkbox_style",
	font = "default",
	font_color = { r = 1, g = 1, b = 1 },
	padding = 0,
	size = { 32, 32 },
	default_graphical_set = detector_middle,
	hovered_graphical_set = detector_middle,
	clicked_graphical_set = detector_middle,
	disabled_graphical_set = detector_middle,
	selected_graphical_set = detector_middle,
	selected_hovered_graphical_set = detector_middle,
	selected_clicked_graphical_set = detector_middle,
	checkmark = blank32,
  }

data:extend({
    {
      type = "virtual-signal",
      name = Constants.Icons.select_icon_black,
      icon = "__core__/graphics/icons/mip/select-icon-black.png",
      icon_size = 40,
      subgroup = "virtual-signal",
      order = "z-z-o"
    },
	{
		type = "virtual-signal",
		name = Constants.Icons.select_icon_white,
		icon = "__core__/graphics/icons/mip/select-icon-white.png",
		icon_size = 40,
		subgroup = "virtual-signal",
		order = "z-z-o"
	  }
})