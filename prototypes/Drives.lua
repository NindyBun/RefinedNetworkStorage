local drive1I = {}
drive1I.type = "item"
drive1I.name = "drive1"
drive1I.placed_as_equipment_result = "drive1"
drive1I.icon = "__RefinedNetworkStorage__/graphics/MFEnergyPowerModule.png"
drive1I.icon_size = 64
drive1I.subgroup = Constants.ItemGroup.Category.group
drive1I.order = "a"
drive1I.stack_size = 20
data:extend{drive1I}

local drive1E = {}
drive1E.name = "drive1"
drive1E.type = "battery-equipment"
drive1E.categories = {"RNS_equipments"}
drive1E.sprite = {filename="__RefinedNetworkStorage__/graphics/MFEnergyPowerModule.png", size=64}
drive1E.shape = {width=2, height=2, type="full"}
drive1E.energy_source =
{
	type="electric",
	usage_priority="tertiary",
	input_flow_limit="0J",
	output_flow_limit="0J",
	buffer_capacity="0J"
}
data:extend{drive1E}

local drive1R = {}
drive1R.type = "recipe"
drive1R.name = "drive1"
drive1R.energy_required = 3
drive1R.enabled = true
drive1R.ingredients = {}
drive1R.result = "drive1"
drive1R.result_count = 1
data:extend{drive1R}