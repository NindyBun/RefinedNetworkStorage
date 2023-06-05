local driveI = {}
driveI.type = "item"
driveI.name = Constants.DriveHolder.name
driveI.place_result = Constants.DriveHolder.name
driveI.icon = Constants.DriveHolder.itemIcon
driveI.icon_size = 64
driveI.subgroup = Constants.ItemGroup.Category.group
driveI.order = "a"
driveI.stack_size = 20
data:extend{driveI}

local driveR = {}
driveR.type = "recipe"
driveR.name = Constants.DriveHolder.name
driveR.energy_required = 3
driveR.enabled = true
driveR.ingredients = {}
driveR.result = Constants.DriveHolder.name
driveR.result_count = 1
data:extend{driveR}

--[[local driveE = {}
driveE.type = "car"
driveE.name = Constants.DriveHolder.name
driveE.icon = Constants.DriveHolder.itemIcon
driveE.icon_size = 64
driveE.flags = {"placeable-neutral", "player-creation"}
driveE.minable = {mining_time = 0.2, result = Constants.DriveHolder.name}
driveE.max_health = 100
driveE.corpse = "small-remnants"
driveE.collision_box = {{-0.8, -0.5}, {0.8, 0.9}}
driveE.selection_box = {{-0.8, -0.5}, {0.8, 1}}
driveE.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
driveE.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
driveE.energy_source = {
    type="void"
}
driveE.inventory_size = 0
driveE.equipment_grid = "RNS_EquipmentGrid"
driveE.weight = 1
driveE.friction = 1
driveE.effectivity = 0
driveE.energy_per_hit_point = 0
driveE.braking_force = 1
driveE.has_belt_immunity = true
driveE.rotation_speed = 0
driveE.consumption = "1MW"
driveE.allow_passengers= false
driveE.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
driveE.animation =
    {
      layers =
      {
        {
            filename = Constants.DriveHolder.entityE,
            priority = "extra-high",
            width = 400,
            height = 400,
            direction_count = 1,
            -- shift = {-0.5,-1},
            scale = 1/200*30
        },
        {
            filename = Constants.DriveHolder.entityS,
            priority = "high",
            width = 400,
            height = 400,
            direction_count = 1,
            shift = {0.5,0.7},
            draw_as_shadow = true,
            scale = 1/200*45
        }
      }
    }

data:extend{driveE}]]

local driveE = {}
driveE.type = "assembling-machine"
driveE.name = Constants.DriveHolder.name
driveE.icon = Constants.DriveHolder.itemIcon
driveE.icon_size = 64
driveE.flags = {"placeable-neutral", "player-creation"}
driveE.minable = {mining_time = 0.2, result = Constants.DriveHolder.name}
driveE.max_health = 100
driveE.corpse = "small-remnants"
driveE.collision_box = {{-0.8, -0.5}, {0.8, 0.9}}
driveE.selection_box = {{-0.8, -0.5}, {0.8, 1}}
driveE.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
driveE.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
driveE.energy_source = {
    type="electric",
    buffer_capacity="1MW",
    usage_priority="secondary-input",
    drain="1MW"
}
driveE.energy_usage="1MW"
driveE.crafting_speed=1
driveE.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
driveE.module_specification = {
    module_slots = 6
}
driveE.crafting_categories = {"blank"}
data:extend{driveE}