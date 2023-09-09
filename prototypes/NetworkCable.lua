local networkCableI = {}
networkCableI.type = "item"
networkCableI.name = Constants.NetworkCables.Cable.item.name
networkCableI.icon = Constants.NetworkCables.Cable.item.itemIcon
networkCableI.icon_size = 512
networkCableI.subgroup = Constants.ItemGroup.Category.subgroup
networkCableI.order = "i"
networkCableI.stack_size = 10
networkCableI.place_result = Constants.NetworkCables.Cable.item.name
data:extend{networkCableI}

local networkCableR = {}
networkCableR.type = "recipe"
networkCableR.name = Constants.NetworkCables.Cable.item.name
networkCableR.energy_required = 1
networkCableR.enabled = true
networkCableR.ingredients = {}
networkCableR.result = Constants.NetworkCables.Cable.item.name
networkCableR.result_count = 1
data:extend{networkCableR}

local networkCableE = {}
networkCableE.type = "container"
networkCableE.name = Constants.NetworkCables.Cable.item.name
networkCableE.icon = Constants.NetworkCables.Cable.item.itemIcon
networkCableE.icon_size = 512
networkCableE.inventory_size = 0
networkCableE.flags = {"placeable-neutral", "player-creation"}
networkCableE.fast_replaceable_group = Constants.Settings.RNS_FR_Cable
networkCableE.minable = {mining_time = 0.2, result = Constants.NetworkCables.Cable.item.name}
networkCableE.max_health = 250
networkCableE.dying_explosion = "medium-explosion"
networkCableE.corpse = "small-remnants"
networkCableE.collision_box = {{-0.40, -0.40}, {0.40, 0.40}}
networkCableE.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
networkCableE.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
networkCableE.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
networkCableE.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
networkCableE.picture =
    {
        layers =
        {
            {
                filename = Constants.NetworkCables.Cable.item.entityE,
                priority = "extra-high",
                width = 512,
                height = 512,
                shift = {0,0},
                scale = 1/16
            },
            {
                filename = Constants.NetworkCables.Cable.item.entityS,
                priority = "high",
                width = 512,
                height = 512,
                shift = {0,0},
                draw_as_shadow = true,
                scale = 1/16
            }
        }
    }
data:extend{networkCableE}

local networkCable_E = {}
networkCable_E.type = "container"
networkCable_E.name = Constants.NetworkCables.Cable.entity.name
networkCable_E.icon = Constants.NetworkCables.Cable.item.itemIcon
networkCable_E.icon_size = 512
networkCable_E.inventory_size = 0
networkCable_E.flags = {"placeable-neutral", "player-creation"}
networkCable_E.minable = {mining_time = 0.2, result = Constants.NetworkCables.Cable.item.name}
networkCable_E.fast_replaceable_group = Constants.Settings.RNS_FR_Cable
networkCable_E.max_health = 250
networkCable_E.dying_explosion = "medium-explosion"
networkCable_E.placeable_by = {item = Constants.NetworkCables.Cable.item.name, count = 1}
networkCable_E.corpse = "small-remnants"
networkCable_E.collision_box = {{-0.40, -0.40}, {0.49, 0.40}}
networkCable_E.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
networkCable_E.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
networkCable_E.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
networkCable_E.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
networkCable_E.picture =
    {
        layers =
        {
            {
                filename = Constants.NetworkCables.Cable.entity.entityE,
                priority = "extra-high",
                width = 32,
                height = 32,
                draw_as_shadow = true,
                shift = {0,0},
                scale = 1
            }
        }
    }
data:extend{networkCable_E}

local sprite = {}
sprite.type = "sprite"
sprite.name = "NetworkCableDot"
sprite.layers = {
    {
        filename = "__RefinedNetworkStorage__/graphics/Cables/NetworkCableDot.png",
        priority = "extra-high",
        size = 512,
        shift = {0,0},
        scale = 1/16
    },
    {
        filename = "__RefinedNetworkStorage__/graphics/Cables/NetworkCableDot_S.png",
        priority = "high",
        size = 512,
        shift = {0,0},
        draw_as_shadow = true,
        scale = 1/16
    }
}
data:extend{sprite}

for _, s in pairs(Constants.NetworkCables.Sprites) do
    local sprite = {}
    sprite.type = "sprite"
    sprite.name = s.name
    sprite.layers = {
        {
            filename = s.sprite_E,
            priority = "extra-high",
            size = 512,
            shift = {0,0},
            scale = 1/16
        },
        {
            filename = s.sprite_S,
            priority = "high",
            size = 512,
            shift = {0,0},
            draw_as_shadow = true,
            scale = 1/16
        }
    }
    data:extend{sprite}
end

--[[local ncblI = {}
ncblI.type = "item"
ncblI.name = "RNS_Cable"
ncblI.icon = "__RefinedNetworkStorage__/graphics/Cables/NetworkCable2.png"
ncblI.icon_size = 512
ncblI.subgroup = Constants.ItemGroup.Category.subgroup
ncblI.order = "i"
ncblI.stack_size = 10
ncblI.place_result = "RNS_Cable"
data:extend{ncblI}

local ncblR = {}
ncblR.type = "recipe"
ncblR.name = "RNS_Cable"
ncblR.energy_required = 1
ncblR.enabled = true
ncblR.ingredients = {}
ncblR.result = "RNS_Cable"
ncblR.result_count = 1
data:extend{ncblR}

local ncblE = {}
ncblE.type = "container"
ncblE.name = "RNS_Cable"
ncblE.icon = "__RefinedNetworkStorage__/graphics/Cables/NetworkCable2.png"
ncblE.icon_size = 512
ncblE.inventory_size = 0
ncblE.flags = {"placeable-neutral", "player-creation"}
ncblE.minable = {mining_time = 0.2, result = "RNS_Cable"}
ncblE.max_health = 250
ncblE.dying_explosion = "medium-explosion"
ncblE.corpse = "medium-remnants"
ncblE.collision_box = {{-0.49, -0.49}, {0.49, 0.49}}
ncblE.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
ncblE.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
ncblE.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
ncblE.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
ncblE.picture =
    {
        layers =
        {
            {
                filename = "__RefinedNetworkStorage__/graphics/Cables/NetworkCable2.png",
                priority = "extra-high",
                width = 512,
                height = 512,
                shift = {0,0},
                scale = 1/16
            },
            {
                filename = "__RefinedNetworkStorage__/graphics/Cables/NetworkCable2_S.png",
                priority = "high",
                width = 512,
                height = 512,
                shift = {0,0},
                draw_as_shadow = true,
                scale = 1/16
            }
        }
    }
data:extend{ncblE}]]