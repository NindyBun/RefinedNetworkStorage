local name = "RNS_ItemIO_V2"

local i = {}
i.type = "item"
i.name = name
i.icon = Constants.NetworkCables.itemIO.itemIcon
i.icon_size = 512
i.subgroup = Constants.ItemGroup.Category.subgroup
i.order = "i"
i.place_result = name
i.stack_size = 50
data:extend{i}

local r = {}
r.type = "recipe"
r.name = name
r.energy_required = 0.1
r.enabled = true
r.ingredients = {}
r.result = name
r.result_count = 1
data:extend{r}

local e = {}
e.type = "inserter"
e.name = name
e.icon = Constants.NetworkCables.itemIO.itemIcon
e.icon_size = 512
e.flags = {"placeable-neutral", "player-creation"}
e.collision_box = {{-0.40, -0.40}, {0.40, 0.40}}
e.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
e.fast_replaceable_group = Constants.Settings.RNS_FR_Cable
e.max_health = 350
e.dying_explosion = "medium-explosion"
e.corpse = "small-remnants"
e.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
e.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
e.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
e.minable = {mining_time = 0.2, result = name}
e.energy_source = {
    type = "void",
}
e.allow_custom_vectors = true
e.draw_held_item = false
e.use_easter_egg = false
e.filter_count = 1
e.chases_belt_items = false
e.stack_size_bonus = 15
e.extension_speed = 1
e.rotation_speed = 0.25
e.insert_position = {0, -0.1}
e.pickup_position = {0, 1}
e.platform_picture = {
    north = {
        layers = {
            {
                filename = Constants.NetworkCables.itemIO.entityE,
                priority = "extra-high",
                size = 512,
                scale = 1/8,
                x=0
            },
            {
                filename = Constants.NetworkCables.itemIO.entityS,
                priority = "high",
                size = 512,
                draw_as_shadow = true,
                scale = 1/8,
                x=0
            }
        }
    }
}
e.platform_picture.east = table.deepcopy(e.platform_picture.north)
e.platform_picture.east.layers[1].x = 512
e.platform_picture.east.layers[2].x = 512
e.platform_picture.south = table.deepcopy(e.platform_picture.north)
e.platform_picture.south.layers[1].x = 512*2
e.platform_picture.south.layers[2].x = 512*2
e.platform_picture.west = table.deepcopy(e.platform_picture.north)
e.platform_picture.west.layers[1].x = 512*3
e.platform_picture.west.layers[2].x = 512*3
e.hand_base_picture = {filename = Constants.Settings.RNS_BlankIcon, size = 32}
e.hand_open_picture = {filename = Constants.Settings.RNS_BlankIcon, size = 32}
e.hand_closed_picture = {filename = Constants.Settings.RNS_BlankIcon, size = 32}
e.hand_base_shadow = {filename = Constants.Settings.RNS_BlankIcon, size = 32}
e.hand_open_shadow = {filename = Constants.Settings.RNS_BlankIcon, size = 32}
e.hand_closed_shadow = {filename = Constants.Settings.RNS_BlankIcon, size = 32}
data:extend{e}