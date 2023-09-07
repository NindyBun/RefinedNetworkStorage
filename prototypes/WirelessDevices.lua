local wirelessGridI = {}
wirelessGridI.type = "item-with-inventory"
wirelessGridI.name = Constants.WirelessGrid.name
wirelessGridI.icon = Constants.WirelessGrid.itemIcon
wirelessGridI.inventory_size = 1
wirelessGridI.icon_size = 512
wirelessGridI.subgroup = Constants.ItemGroup.Category.subgroup
wirelessGridI.order = "i"
wirelessGridI.stack_size = 1
data:extend{wirelessGridI}

local wirelessGridR = {}
wirelessGridR.type = "recipe"
wirelessGridR.name = Constants.WirelessGrid.name
wirelessGridR.energy_required = Constants.WirelessGrid.craft_time
wirelessGridR.enabled = Constants.WirelessGrid.enabled
wirelessGridR.ingredients = Constants.WirelessGrid.ingredients
wirelessGridR.result = Constants.WirelessGrid.name
wirelessGridR.result_count = 1
data:extend{wirelessGridR}