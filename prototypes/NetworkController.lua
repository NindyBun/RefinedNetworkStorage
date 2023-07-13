local controllerI = {}
controllerI.type = "item"
controllerI.name = Constants.NetworkController.itemEntity.name
controllerI.icon = Constants.NetworkController.itemEntity.itemIcon
controllerI.icon_size = 256
controllerI.subgroup = Constants.ItemGroup.Category.subgroup
controllerI.order = "n"
controllerI.stack_size = 20
controllerI.place_result = Constants.NetworkController.itemEntity.name
data:extend{controllerI}

local controllerR = {}
controllerR.type = "recipe"
controllerR.name = Constants.NetworkController.itemEntity.name
controllerR.energy_required = 1
controllerR.enabled = true
controllerR.ingredients = {}
controllerR.result = Constants.NetworkController.itemEntity.name
controllerR.result_count = 1
data:extend{controllerR}

local controllerE = {}
controllerE.type = "electric-energy-interface"
controllerE.name = Constants.NetworkController.itemEntity.name
controllerE.icon = Constants.NetworkController.itemEntity.itemIcon
controllerE.icon_size = 256
controllerE.flags = {"placeable-neutral", "player-creation"}
--controllerE.minable = {mining_time = 0.2, result = Constants.NetworkController.name}
controllerE.max_health = 350
--controllerE.dying_explosion = "medium-explosion"
--controllerE.corpse = "medium-remnants"
controllerE.collision_box = {{-1.40, -1.40}, {1.40, 1.40}}
controllerE.selection_box = {{-1.5, -1.5}, {1.5, 1.5}}
--controllerE.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
--controllerE.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
--controllerE.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
controllerE.energy_source = {
    type = "electric",
    usage_priority = "secondary-input",
    buffer_capacity = "0J" --1 Joule is 50 Watts
}
controllerE.energy_usage = "0W"
controllerE.picture =
    {
        layers =
        {
            {
                filename = Constants.NetworkController.itemEntity.entityE,
                priority = "extra-high",
                size = 512,
                scale = (96 * 3)/512
            },
            {
                filename = Constants.NetworkController.itemEntity.entityS,
                priority = "extra-high",
                draw_as_shadow = true,
                size = 512,
                scale = (96 * 3)/512
            }
        }
    }
data:extend{controllerE}

local cE0 = {}
cE0.type = "electric-energy-interface"
cE0.name = Constants.NetworkController.slateEntity.name
cE0.icon = Constants.NetworkController.slateEntity.itemIcon
cE0.icon_size = 256
cE0.flags = {"placeable-neutral", "player-creation"}
cE0.minable = {mining_time = 0.2, result = Constants.NetworkController.itemEntity.name}
cE0.max_health = 350
cE0.dying_explosion = "medium-explosion"
cE0.corpse = "medium-remnants"
cE0.collision_box = {{-1.40, -1.40}, {1.40, 1.40}}
cE0.selection_box = {{-1.5, -1.5}, {1.5, 1.5}}
cE0.placeable_by = {item=Constants.NetworkController.itemEntity.name, count=1}
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
                filename = Constants.NetworkController.slateEntity.entityE,
                priority = "extra-high",
                size = 32,
                scale = 1
            },
            {
                filename = Constants.NetworkController.slateEntity.entityS,
                priority = "extra-high",
                draw_as_shadow = true,
                size = 32,
                scale = 1
            }
        }
    }
data:extend{cE0}

local ce1 = {}
ce1.type = "container"
ce1.name = Constants.NetworkController.statesEntity.stable
ce1.icon = Constants.NetworkController.statesEntity.itemIcon
ce1.icon_size = 32
ce1.flags = {"placeable-neutral"}
ce1.collision_box = {{-1.40, -1.40}, {1.40, 1.40}}
ce1.inventory_size = 0
ce1.selectable_in_game = false
ce1.alert_when_damaged = false
ce1.picture =
{
    layers =
    {
        {
            filename = Constants.NetworkController.statesEntity.stableE,
            priority = "extra-high",
            size = 512,
            scale = (96 * 3)/512
        },
        {
            filename = Constants.NetworkController.statesEntity.shadow,
            priority = "high",
            draw_as_shadow = true,
            size = 512,
            scale = (96 * 3)/512
        }
    }
}
data:extend{ce1}

local ce2 = {}
ce2.type = "container"
ce2.name = Constants.NetworkController.statesEntity.unstable
ce2.icon = Constants.NetworkController.statesEntity.itemIcon
ce2.icon_size = 32
ce2.flags = {"placeable-neutral"}
ce2.collision_box = {{-1.40, -1.40}, {1.40, 1.40}}
ce2.inventory_size = 0
ce2.selectable_in_game = false
ce2.alert_when_damaged = false
ce2.picture =
{
    layers =
    {
        {
            filename = Constants.NetworkController.statesEntity.unstableE,
            priority = "extra-high",
            size = 512,
            scale = (96 * 3)/512
        },
        {
            filename = Constants.NetworkController.statesEntity.shadow,
            priority = "high",
            draw_as_shadow = true,
            size = 512,
            scale = (96 * 3)/512
        }
    }
}
data:extend{ce2}

--[[local cE1 = {}
cE1.type = "electric-energy-interface"
cE1.name = Constants.NetworkController.statesEntity.stable
cE1.icon = Constants.NetworkController.statesEntity.itemIcon
cE1.icon_size = 32
cE1.collision_box = {{-1.40, -1.40}, {1.40, 1.40}}
cE1.selectable_in_game = false
cE1.energy_source = {
    type = "electric",
    render_no_power_icon = false,
    render_no_network_icon = false,
    usage_priority = "secondary-input",
    buffer_capacity = "0J" --1 Joule is 50 Watts
}
cE1.alert_when_damaged = false
cE1.energy_usage = "0W"
cE1.picture =
    {
        layers =
        {
            {
                filename = Constants.NetworkController.statesEntity.stableE,
                priority = "extra-high",
                size = 512,
                scale = (96 * 3)/512
            },
            {
                filename = Constants.NetworkController.statesEntity.shadow,
                priority = "high",
                draw_as_shadow = true,
                size = 512,
                scale = (96 * 3)/512
            }
        }
    }
data:extend{cE1}

local cE2 = {}
cE2.type = "electric-energy-interface"
cE2.name = Constants.NetworkController.statesEntity.unstable
cE1.icon = Constants.NetworkController.statesEntity.itemIcon
cE1.icon_size = 32
cE2.collision_box = {{-1.40, -1.40}, {1.40, 1.40}}
cE2.selectable_in_game = false
cE2.energy_source = {
    type = "electric",
    render_no_power_icon = false,
    render_no_network_icon = false,
    usage_priority = "secondary-input",
    buffer_capacity = "0J" --1 Joule is 50 Watts
}
cE2.alert_when_damaged = false
cE2.energy_usage = "0W"
cE2.picture =
    {
        layers =
        {
            {
                filename = Constants.NetworkController.statesEntity.unstableE,
                priority = "extra-high",
                size = 512,
                scale = (96 * 3)/512
            },
            {
                filename = Constants.NetworkController.statesEntity.shadow,
                priority = "high",
                draw_as_shadow = true,
                size = 512,
                scale = (96 * 3)/512
            }
        }
    }
data:extend{cE2}]]