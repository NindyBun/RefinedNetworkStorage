for _, tech in pairs(Constants.Technologies) do
    local T = {}
	T.type = "technology"
	T.name = tech.name
	if tech.icon ~= nil then
		T.icon = tech.icon
	else
		T.icons = tech.icons
	end
	T.icon_size = tech.icon_size or 512
	T.prerequisites = tech.prerequisites
	T.max_level = tech.max_level
	T.effects = tech.effects
	T.unit = tech.unit
	T.upgrade = tech.upgrade
	T.order = "a-z"
	data:extend{T}
end