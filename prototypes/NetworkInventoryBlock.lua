local inventoryBlockI = {}
inventoryBlockI.type = "item"
inventoryBlockI.name = Constants.NetworkInventoryBlock.name
inventoryBlockI.icon = Constants.NetworkInventoryBlock.itemIcon
inventoryBlockI.icon_size = 512
inventoryBlockI.subgroup = Constants.ItemGroup.Category.subgroup
inventoryBlockI.order = "i"
inventoryBlockI.stack_size = 10
inventoryBlockI.place_result = Constants.NetworkInventoryBlock.name
data:extend{inventoryBlockI}

local inventoryBlockR = {}
inventoryBlockR.type = "recipe"
inventoryBlockR.name = Constants.NetworkInventoryBlock.name
inventoryBlockR.energy_required = 1
inventoryBlockR.enabled = true
inventoryBlockR.ingredients = {}
inventoryBlockR.result = Constants.NetworkInventoryBlock.name
inventoryBlockR.result_count = 1
data:extend{inventoryBlockR}

local inventoryBlockE = {}
inventoryBlockE.type = "container"
inventoryBlockE.name = Constants.NetworkInventoryBlock.name
inventoryBlockE.icon = Constants.NetworkInventoryBlock.itemIcon
inventoryBlockE.icon_size = 512
inventoryBlockE.inventory_size = 0
inventoryBlockE.flags = {"placeable-neutral", "player-creation"}
inventoryBlockE.minable = {mining_time = 0.2, result = Constants.NetworkInventoryBlock.name}
inventoryBlockE.max_health = 250
inventoryBlockE.dying_explosion = "medium-explosion"
inventoryBlockE.corpse = "medium-remnants"
inventoryBlockE.collision_box = {{-0.5, -0.5}, {0.5, 0.5}}
inventoryBlockE.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
inventoryBlockE.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
inventoryBlockE.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
inventoryBlockE.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
inventoryBlockE.picture =
    {
        layers =
        {
            {
                filename = Constants.NetworkInventoryBlock.entityE,
                priority = "extra-high",
                width = 512,
                height = 512,
                shift = {0,-1/4},
                scale = 1/8
            },
            {
                filename = Constants.NetworkInventoryBlock.entityS,
                priority = "high",
                width = 512,
                height = 512,
                shift = {1/2,-1/4},
                draw_as_shadow = true,
                scale = 1/8
            }
        }
    }
data:extend{inventoryBlockE}