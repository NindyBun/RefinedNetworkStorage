Constants = require("utils.constants")
require("prototypes.DriveHolder")
require("prototypes.Drives")
-------------------------------------------------------------------------------------
data:extend{
	{
		type="module-category",
		name="RNS_Category-drives"
	}
}

data:extend{
	{
		type="item-group",
		name=Constants.ItemGroup.Category.group,
		icon=Constants.DriveHolder.itemIcon,
		icon_size=64,
		order="x"
	}
}

data:extend{
	{
		type="item-subgroup",
		name=Constants.ItemGroup.Category.group,
		group=Constants.ItemGroup.Category.group,
		order="a"
	}
}

data:extend{
	{
		type="equipment-category",
		name="RNS_equipments",
		order="a"
	}
}

data:extend{
	{
		type="equipment-grid",
		equipment_categories={"RNS_equipments"},
		name="RNS_EquipmentGrid",
		height=4,
		width=6
	}
}