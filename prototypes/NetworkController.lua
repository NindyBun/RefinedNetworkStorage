local controllerI = {}
controllerI.type = "item-with-tags"
controllerI.name = Constants.NetworkController.main.name
controllerI.icon = Constants.NetworkController.main.itemIcon
controllerI.icon_size = 256
controllerI.subgroup = Constants.ItemGroup.Category.subgroup
controllerI.order = "n"
controllerI.stack_size = 10
controllerI.place_result = Constants.NetworkController.main.name
data:extend{controllerI}

--[[
local controllerR = {}
controllerR.type = "recipe"
controllerR.name = Constants.NetworkController.main.name
controllerR.energy_required = 1
controllerR.enabled = true
controllerR.ingredients = {}
controllerR.result = Constants.NetworkController.main.name
controllerR.result_count = 1
data:extend{controllerR}
]]

local cE0 = {}
cE0.type = "electric-energy-interface"
cE0.name = Constants.NetworkController.main.name
cE0.icon = Constants.NetworkController.main.itemIcon
cE0.icon_size = 256
cE0.flags = {"placeable-neutral", "player-creation"}
cE0.minable = {mining_time = 0.2, result = Constants.NetworkController.main.name}
cE0.max_health = 350
cE0.dying_explosion = "medium-explosion"
cE0.corpse = "medium-remnants"
cE0.collision_box = {{-1.40, -1.40}, {1.40, 1.40}}
cE0.selection_box = {{-1.5, -1.5}, {1.5, 1.5}}
cE0.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
cE0.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
cE0.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
cE0.energy_source = {
    type = "electric",
    usage_priority = "secondary-input",
    buffer_capacity = "0J" --1 Joule is 50 Watts
}
cE0.energy_usage = "0W"
cE0.picture =
    {
        layers =
        {
            {
                filename = Constants.NetworkController.main.entityE,
                priority = "medium",
                size = 512,
                scale = 192/512
            },
            {
                filename = Constants.NetworkController.main.entityS,
                priority = "medium",
                draw_as_shadow = true,
                size = 512,
                scale = (96 * 3)/512
            }
        }
    }
data:extend{cE0}