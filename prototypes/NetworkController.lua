local controllerI = {}
controllerI.type = "item"
controllerI.name = Constants.NetworkController.item.name
controllerI.icon = Constants.NetworkController.item.itemIcon
controllerI.icon_size = 256
controllerI.subgroup = Constants.ItemGroup.Category.subgroup
controllerI.order = "n"
controllerI.stack_size = 20
controllerI.place_result = Constants.NetworkController.item.name
data:extend{controllerI}

local controllerR = {}
controllerR.type = "recipe"
controllerR.name = Constants.NetworkController.item.name
controllerR.energy_required = 1
controllerR.enabled = true
controllerR.ingredients = {}
controllerR.result = Constants.NetworkController.item.name
controllerR.result_count = 1
data:extend{controllerR}

local controllerE = {}
controllerE.type = "electric-energy-interface"
controllerE.name = Constants.NetworkController.item.name
controllerE.icon = Constants.NetworkController.item.itemIcon
controllerE.icon_size = 256
controllerE.flags = {"placeable-neutral", "player-creation"}
controllerE.minable = {mining_time = 0.2, result = Constants.NetworkController.item.name}
controllerE.max_health = 350
controllerE.dying_explosion = "medium-explosion"
controllerE.corpse = "medium-remnants"
controllerE.collision_box = {{-1.49, -1.49}, {1.49, 1.49}}
controllerE.selection_box = {{-1.5, -1.5}, {1.5, 1.5}}
controllerE.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
controllerE.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
controllerE.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
controllerE.energy_source = {
    type = "electric",
    usage_priority = "secondary-input",
    buffer_capacity = "1J" --1 Joule is 50 Watts
}
controllerE.energy_usage = "0W"
controllerE.picture =
    {
        layers =
        {
            {
                filename = Constants.NetworkController.item.entityE,
                priority = "extra-high",
                width = 512,
                height = 512,
                shift = {0,-3/4},
                scale = 3/8
            },
            {
                filename = Constants.NetworkController.item.entityS,
                priority = "high",
                width = 256,
                height = 256,
                shift = {3/2,-3/4},
                draw_as_shadow = true,
                scale = 3/4
            }
        }
    }
data:extend{controllerE}

local controller_E = {}
controller_E.type = "electric-energy-interface"
controller_E.name = Constants.NetworkController.entity.name
controller_E.icon = Constants.NetworkController.item.itemIcon
controller_E.icon_size = 256
controller_E.flags = {"placeable-neutral", "player-creation"}
controller_E.minable = {mining_time = 0.2, result = Constants.NetworkController.item.name}
controller_E.max_health = 350
controller_E.dying_explosion = "medium-explosion"
controller_E.corpse = "medium-remnants"
controller_E.collision_box = {{-1.49, -1.49}, {1.49, 1.49}}
controller_E.selection_box = {{-1.5, -1.5}, {1.5, 1.5}}
controller_E.placeable_by = {item = Constants.NetworkController.item.name, count = 1}
controller_E.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
controller_E.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
controller_E.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
controller_E.energy_source = {
    type = "electric",
    usage_priority = "secondary-input",
    buffer_capacity = "1J" --1 Joule is 50 Watts
}
controller_E.energy_usage = "0W"
controller_E.picture =
    {
        layers =
        {
            {
                filename = Constants.NetworkController.entity.entityE,
                priority = "extra-high",
                width = 32,
                height = 32,
                draw_as_shadow = true,
                scale = 1
            }
        }
    }
data:extend{controller_E}

local controllerE_unstable_sprite = {}
controllerE_unstable_sprite.type = "sprite"
controllerE_unstable_sprite.name = Constants.NetworkController.entity.name.."_unstable"
controllerE_unstable_sprite.layers = {
    {
        filename = "__RefinedNetworkStorage__/graphics/Networks/NetworkControllerE_unstable.png",
        priority = "extra-high",
        size = 512,
        shift = {0, -3/4},
        scale = 3/8,
    },
    {
        filename = "__RefinedNetworkStorage__/graphics/Drives/DriveS.png",
        priority = "high",
        width = 256,
        height = 256,
        shift = {3/2,-3/4},
        draw_as_shadow = true,
        scale = 3/4
    }
}
data:extend{controllerE_unstable_sprite}

local controllerE_stable_sprite = {}
controllerE_stable_sprite.type = "sprite"
controllerE_stable_sprite.name = Constants.NetworkController.entity.name.."_stable"
controllerE_stable_sprite.layers = {
    {
        filename = "__RefinedNetworkStorage__/graphics/Networks/NetworkControllerE.png",
        priority = "extra-high",
        size = 512,
        shift = {0, -3/4},
        scale = 3/8,
    },
    {
        filename = "__RefinedNetworkStorage__/graphics/Drives/DriveS.png",
        priority = "high",
        width = 256,
        height = 256,
        shift = {3/2,-3/4},
        draw_as_shadow = true,
        scale = 3/4
    }
}
data:extend{controllerE_stable_sprite}