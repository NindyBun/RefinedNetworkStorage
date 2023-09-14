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
                shift = {0,-0.123},
                scale = 1/8
            },
            {
                filename = Constants.WirelessGrid.entityS,
                priority = "high",
                width = 512,
                height = 512,
                shift = {0,-0.123},
                draw_as_shadow = true,
                scale = 1/4
            }
        }
    }
data:extend{wirelessGridE}

------------------------------------------------------------------------------------------------------------------------------------------------------------
local wirelessTransmitterI = {}
wirelessTransmitterI.type = "item"
wirelessTransmitterI.name = Constants.NetworkCables.wirelessTransmitter.slateEntity.name
wirelessTransmitterI.icon = Constants.NetworkCables.wirelessTransmitter.itemEntity.itemIcon
wirelessTransmitterI.icon_size = 512
wirelessTransmitterI.subgroup = Constants.ItemGroup.Category.subgroup
wirelessTransmitterI.order = "i"
wirelessTransmitterI.stack_size = 10
wirelessTransmitterI.place_result = Constants.NetworkCables.wirelessTransmitter.slateEntity.name
data:extend{wirelessTransmitterI}

local wirelessTransmitterR = {}
wirelessTransmitterR.type = "recipe"
wirelessTransmitterR.name = Constants.NetworkCables.wirelessTransmitter.slateEntity.name
wirelessTransmitterR.energy_required = 1
wirelessTransmitterR.enabled = true
wirelessTransmitterR.ingredients = {}
wirelessTransmitterR.result = Constants.NetworkCables.wirelessTransmitter.slateEntity.name
wirelessTransmitterR.result_count = 1
data:extend{wirelessTransmitterR}

local wirelessTransmitterE = {}
wirelessTransmitterE.type = "container"
wirelessTransmitterE.name = Constants.NetworkCables.wirelessTransmitter.itemEntity.name
wirelessTransmitterE.icon = Constants.NetworkCables.wirelessTransmitter.itemEntity.itemIcon
wirelessTransmitterE.icon_size = 512
wirelessTransmitterE.inventory_size = 0
wirelessTransmitterE.flags = {"placeable-neutral", "player-creation"}
wirelessTransmitterE.fast_replaceable_group = Constants.Settings.RNS_FR_Cable
wirelessTransmitterE.minable = {mining_time = 0.2, result = Constants.NetworkCables.wirelessTransmitter.itemEntity.name}
wirelessTransmitterE.max_health = 250
wirelessTransmitterE.dying_explosion = "medium-explosion"
wirelessTransmitterE.corpse = "small-remnants"
wirelessTransmitterE.collision_box = {{-0.40, -0.40}, {0.40, 0.40}}
wirelessTransmitterE.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
wirelessTransmitterE.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
wirelessTransmitterE.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
wirelessTransmitterE.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
wirelessTransmitterE.picture =
    {
        layers =
        {
            {
                filename = Constants.NetworkCables.wirelessTransmitter.itemEntity.entityE,
                priority = "extra-high",
                width = 512,
                height = 512,
                shift = {0,0},
                scale = 1/8
            },
            {
                filename = Constants.NetworkCables.wirelessTransmitter.itemEntity.entityS,
                priority = "high",
                width = 512,
                height = 512,
                shift = {0,0},
                draw_as_shadow = true,
                scale = 1/8
            }
        }
    }
--data:extend{wirelessTransmitterE}

local wirelessTransmitter_E = {}
wirelessTransmitter_E.type = "container"
wirelessTransmitter_E.name = Constants.NetworkCables.wirelessTransmitter.slateEntity.name
wirelessTransmitter_E.icon = Constants.NetworkCables.wirelessTransmitter.itemEntity.itemIcon
wirelessTransmitter_E.icon_size = 512
wirelessTransmitter_E.inventory_size = 0
wirelessTransmitter_E.flags = {"placeable-neutral", "player-creation"}
wirelessTransmitter_E.minable = {mining_time = 0.2, result = Constants.NetworkCables.wirelessTransmitter.slateEntity.name}
wirelessTransmitter_E.fast_replaceable_group = Constants.Settings.RNS_FR_Cable
wirelessTransmitter_E.max_health = 250
wirelessTransmitter_E.dying_explosion = "medium-explosion"
--wirelessTransmitter_E.placeable_by = {item = Constants.NetworkCables.wirelessTransmitter.itemEntity.name, count = 1}
wirelessTransmitter_E.corpse = "small-remnants"
wirelessTransmitter_E.collision_box = {{-0.40, -0.40}, {0.49, 0.40}}
wirelessTransmitter_E.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
wirelessTransmitter_E.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
wirelessTransmitter_E.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
wirelessTransmitter_E.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
wirelessTransmitter_E.picture =
    {
        layers =
        {
            {
                filename = Constants.NetworkCables.wirelessTransmitter.slateEntity.entityE,
                priority = "extra-high",
                width = 512,
                height = 512,
                shift = {0,0},
                scale = 1/8
            },
            {
                filename = Constants.NetworkCables.wirelessTransmitter.slateEntity.entityS,
                priority = "high",
                width = 512,
                height = 512,
                shift = {0,0},
                draw_as_shadow = true,
                scale = 1/8
            }
        }
    }
data:extend{wirelessTransmitter_E}

local playerportI = {}
playerportI.type = "item"
playerportI.name = Constants.PlayerPort.name
playerportI.icon = Constants.PlayerPort.icon
playerportI.icon_size = 256
playerportI.subgroup = Constants.ItemGroup.Category.subgroup
playerportI.order = "i"
playerportI.stack_size = 1
playerportI.placed_as_equipment_result = Constants.PlayerPort.name
data:extend{playerportI}

local playerportR = {}
playerportR.type = "recipe"
playerportR.name = Constants.PlayerPort.name
playerportR.energy_required = 1
playerportR.enabled = true
playerportR.ingredients = {}
playerportR.result = Constants.PlayerPort.name
playerportR.result_count = 1
data:extend{playerportR}

local playerportE = {}
playerportE.type = "battery-equipment"
playerportE.name = Constants.PlayerPort.name
playerportE.sprite = {
    filename = Constants.PlayerPort.icon,
    priority = "extra-high",
    size = 256,
}
playerportE.shape = {
    width = 2,
    height = 2,
    type = "full"
}
playerportE.categories = {"armor"}
playerportE.energy_source = {
    type = "energy",
    buffer_capacity = "250MJ",
    usage_priority = "secondary-input"
}
data:extend{playerportE}