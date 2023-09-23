for _, color in pairs(Constants.NetworkCables.Cables) do
    local networkCableI = {}
    networkCableI.type = "item"
    networkCableI.name = color.cable.entity.name
    networkCableI.icon = color.cable.item.itemIcon
    networkCableI.icon_size = 512
    networkCableI.subgroup = Constants.ItemGroup.Category.Cable_subgroup
    networkCableI.order = "a"
    networkCableI.stack_size = 200
    networkCableI.place_result = color.cable.entity.name
    data:extend{networkCableI}
end

for _, color in pairs(Constants.NetworkCables.Cables) do
    local networkCableR = {}
    networkCableR.type = "recipe"
    networkCableR.name = color.cable.entity.name
    networkCableR.energy_required = 1
    networkCableR.enabled = true
    networkCableR.ingredients = {}
    networkCableR.result = color.cable.entity.name
    networkCableR.result_count = 10
    data:extend{networkCableR}
end

--[[
    for _, color in pairs(Constants.NetworkCables.Cables) do
    local networkCableE = {}
    networkCableE.type = "container"
    networkCableE.name = color.cable.item.name
    networkCableE.icon = color.cable.item.itemIcon
    networkCableE.icon_size = 512
    networkCableE.inventory_size = 0
    networkCableE.flags = {"placeable-neutral", "player-creation"}
    networkCableE.fast_replaceable_group = Constants.Settings.RNS_FR_Cable
    networkCableE.minable = {mining_time = 0.2, result = color.cable.item.name}
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
                    filename = color.cable.item.entityE,
                    priority = "extra-high",
                    width = 512,
                    height = 512,
                    shift = {0,0},
                    scale = 1/16
                },
                {
                    filename = color.cable.item.entityS,
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
end
]]

for _, color in pairs(Constants.NetworkCables.Cables) do
    local networkCable_E = {}
    networkCable_E.type = "container"
    networkCable_E.name = color.cable.entity.name
    networkCable_E.icon = color.cable.item.itemIcon
    networkCable_E.icon_size = 512
    networkCable_E.inventory_size = 0
    networkCable_E.flags = {"placeable-neutral", "player-creation"}
    networkCable_E.minable = {mining_time = 0.2, result = color.cable.entity.name}
    networkCable_E.fast_replaceable_group = Constants.Settings.RNS_FR_Cable
    networkCable_E.max_health = 250
    networkCable_E.dying_explosion = "medium-explosion"
    --networkCable_E.placeable_by = {item = color.cable.item.name, count = 1}
    networkCable_E.corpse = "small-remnants"
    networkCable_E.collision_box = {{-0.40, -0.40}, {0.49, 0.40}}
    networkCable_E.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
    networkCable_E.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
    networkCable_E.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
    networkCable_E.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
    networkCable_E.ghost_tint = {g=1, b=1, a=0.3}
    networkCable_E.picture =
        {
            layers =
            {
                {
                    filename =color.cable.entity.entityE,
                    priority = "extra-high",
                    width = 512,
                    height = 512,
                    --draw_as_shadow = true,
                    shift = {0,0},
                    scale = 1/16
                },
                {
                    filename = "__RefinedNetworkStorage__/graphics/Cables/NetworkCableDot_S.png",
                    priority = "high",
                    width = 512,
                    height = 512,
                    shift = {0,0},
                    draw_as_shadow = true,
                    scale = 1/16
                }
            }
        }
    data:extend{networkCable_E}
end

--[[
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
]]

for _, color in pairs(Constants.NetworkCables.Cables) do
    for _, tex in pairs(color.sprites) do
        local sprite = {}
        sprite.type = "sprite"
        sprite.name = tex.name
        sprite.layers = {
            {
                filename = tex.sprite_E,
                priority = "extra-high",
                size = 512,
                shift = {0,0},
                scale = 1/16
            },
            {
                filename = tex.sprite_S,
                priority = "high",
                size = 512,
                shift = {0,0},
                draw_as_shadow = true,
                scale = 1/16
            }
        }
        data:extend{sprite}
    end
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

for _, color in pairs(Constants.NetworkCables.Cables) do
    local networkCableI = {}
    networkCableI.type = "item"
    networkCableI.name = color.underground.name
    networkCableI.icon = color.underground.itemIcon
    networkCableI.icon_size = 512
    networkCableI.subgroup = Constants.ItemGroup.Category.Cable_subgroup
    networkCableI.order = "a"
    networkCableI.stack_size = 200
    networkCableI.place_result = color.underground.name
    data:extend{networkCableI}
end

for _, color in pairs(Constants.NetworkCables.Cables) do
    local networkCableR = {}
    networkCableR.type = "recipe"
    networkCableR.name = color.underground.name
    networkCableR.energy_required = 1
    networkCableR.enabled = true
    networkCableR.ingredients = {}
    networkCableR.result = color.underground.name
    networkCableR.result_count = 10
    data:extend{networkCableR}
end

for _, color in pairs(Constants.NetworkCables.Cables) do
    local networkCable_E = {}
    networkCable_E.type = "assembling-machine"
    networkCable_E.name = color.underground.name
    networkCable_E.icon = color.underground.itemIcon
    networkCable_E.icon_size = 512
    networkCable_E.localised_description = {"entity-description.RNS_NetworkCableRamp", Constants.Settings.RNS_CableUnderground_Reach+1}
    networkCable_E.flags = {"placeable-neutral", "player-creation"}
    networkCable_E.collision_box = {{-0.40, -0.40}, {0.40, 0.40}}
    networkCable_E.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
    networkCable_E.fast_replaceable_group = Constants.Settings.RNS_FR_Cable
    networkCable_E.max_health = 350
    networkCable_E.dying_explosion = "medium-explosion"
    networkCable_E.corpse = "small-remnants"
    networkCable_E.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
    networkCable_E.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
    networkCable_E.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
    networkCable_E.minable = {mining_time = 0.2, result = color.underground.name}
    networkCable_E.animation =
        {
            north = {
                layers = {
                    {
                        filename = color.underground.entityE,
                        priority = "extra-high",
                        size = 512,
                        scale = 1/16,
                        x=0
                    },
                    {
                        filename = color.underground.entityS,
                        priority = "high",
                        size = 512,
                        draw_as_shadow = true,
                        scale = 1/16,
                        x=0
                    }
                }
            }
        }
    networkCable_E.animation.east = table.deepcopy(networkCable_E.animation.north)
    networkCable_E.animation.east.layers[1].x = 512
    networkCable_E.animation.east.layers[2].x = 512
    networkCable_E.animation.south = table.deepcopy(networkCable_E.animation.north)
    networkCable_E.animation.south.layers[1].x = 512*2
    networkCable_E.animation.south.layers[2].x = 512*2
    networkCable_E.animation.west = table.deepcopy(networkCable_E.animation.north)
    networkCable_E.animation.west.layers[1].x = 512*3
    networkCable_E.animation.west.layers[2].x = 512*3
    networkCable_E.crafting_categories = {"RNS-Nothing"}
    networkCable_E.crafting_speed = 1
    networkCable_E.energy_source =
    {
        type = "electric",
        usage_priority = "secondary-input",
        buffer_capacity = "0J",
        drain = "0J",
        render_no_power_icon = false,
        render_no_network_icon = false
    }
    networkCable_E.energy_usage = "1J"
    networkCable_E.fluid_boxes = {
        {
            base_area = 1,
            hide_connection_info = true,
            pipe_connections = {
                {position = {0, -0.5}}
            },
            production_type = "output"
        }
    }
    data:extend{networkCable_E}
end