local detectorI = {}
detectorI.type = "item"
detectorI.name = Constants.Detector.name
detectorI.icon = Constants.Detector.itemIcon
detectorI.icon_size = 512
detectorI.subgroup = Constants.ItemGroup.Category.subgroup
detectorI.order = "i"
detectorI.stack_size = 50
detectorI.place_result = Constants.Detector.name
data:extend{detectorI}

--[[
local detectorR = {}
detectorR.type = "recipe"
detectorR.name = Constants.Detector.name
detectorR.energy_required = 1
detectorR.enabled = true
detectorR.ingredients = {}
detectorR.result = Constants.Detector.name
detectorR.result_count = 1
data:extend{detectorR}
]]

local detector_E = {}
detector_E.type = "container"
detector_E.name = Constants.Detector.name
detector_E.icon = Constants.Detector.itemIcon
detector_E.icon_size = 512
detector_E.inventory_size = 0
detector_E.flags = {"placeable-neutral", "player-creation"}
detector_E.minable = {mining_time = 0.2, result = Constants.Detector.name}
detector_E.fast_replaceable_group = Constants.Settings.RNS_FR_Cable
detector_E.max_health = 250
detector_E.dying_explosion = "medium-explosion"
detector_E.corpse = "small-remnants"
detector_E.collision_box = {{-0.40, -0.40}, {0.49, 0.40}}
detector_E.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
detector_E.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
detector_E.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
detector_E.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
detector_E.picture =
    {
        layers =
        {
            {
                filename = Constants.Detector.entityE,
                priority = "extra-high",
                width = 512,
                height = 512,
                shift = {0,0},
                scale = 1/8
            },
            {
                filename = Constants.Detector.entityS,
                priority = "high",
                width = 512,
                height = 512,
                shift = {0,0},
                draw_as_shadow = true,
                scale = 1/8
            }
        }
    }
data:extend{detector_E}