for _, recipe in pairs(Constants.Recipies) do
    local R = {}
	R.type = "recipe"
    R.category = recipe.category
	R.name = recipe.name
	R.energy_required = recipe.craft_time
	R.enabled = recipe.enabled
	R.ingredients = recipe.ingredients
	R.result = recipe.name
	R.result_count = recipe.count
	data:extend{R}
end