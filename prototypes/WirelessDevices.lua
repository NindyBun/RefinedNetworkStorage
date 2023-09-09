local wirelessGridI = {}
wirelessGridI.type = "item-with-tags"
wirelessGridI.name = Constants.WirelessGrid.name
wirelessGridI.icon = Constants.WirelessGrid.itemIcon
wirelessGridI.icon_size = 512
wirelessGridI.subgroup = Constants.ItemGroup.Category.subgroup
wirelessGridI.order = "i"
wirelessGridI.stack_size = 1
wirelessGridI.place_result = Constants.WirelessGrid.name
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

local wirelessGridE = {}
wirelessGridE.type = "container"
wirelessGridE.name = Constants.WirelessGrid.name
wirelessGridE.icon = Constants.WirelessGrid.itemIcon
wirelessGridE.icon_size = 512
wirelessGridE.inventory_size = 0
wirelessGridE.flags = {"placeable-neutral", "player-creation"}
wirelessGridE.minable = {mining_time = 0.2, result = Constants.WirelessGrid.name}
wirelessGridE.max_health = 250
wirelessGridE.dying_explosion = "medium-explosion"
wirelessGridE.corpse = "small-remnants"
wirelessGridE.collision_box = {{-0.49, -0.49}, {0.49, 0.49}}
wirelessGridE.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
wirelessGridE.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
wirelessGridE.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
wirelessGridE.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
wirelessGridE.picture =
    {
        layers =
        {
            {
                filename = Constants.WirelessGrid.entityE,
                priority = "extra-high",
                width = 512,
                height = 512,
                shift = {0,0},
                scale = 1/8
            },
            {
                filename = Constants.WirelessGrid.entityS,
                priority = "high",
                width = 512,
                height = 512,
                shift = {0,-0.125},
                draw_as_shadow = true,
                scale = 1/4
            }
        }
    }
data:extend{wirelessGridE}