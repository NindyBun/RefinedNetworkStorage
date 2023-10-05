for _, intermediate in pairs(Constants.Intermediates) do
    local item = {}
	item.type = "item"
	item.name = intermediate.name
	item.icon = intermediate.itemIcon
	item.icon_size = 512
	item.subgroup = Constants.ItemGroup.Category.Intermediate_subgroup
	item.order = intermediate.order
	item.stack_size = 200
	data:extend{item}
end