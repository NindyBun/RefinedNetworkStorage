local name = "rns_Blank_ItemIO"
local name2 = "RNS_NetworkCableIOV2_Item"

local i = {}
i.type = "item"
i.name = name2
i.icon = Constants.NetworkCables.itemIO.itemIcon
i.icon_size = 512
i.subgroup = Constants.ItemGroup.Category.subgroup
i.order = "i"
i.place_result = name2
i.stack_size = 50
data:extend{i}

local r = {}
r.type = "recipe"
r.name = name2
r.energy_required = 0.1
r.enabled = true
r.ingredients = {}
r.result = name2
r.result_count = 1
data:extend{r}

local e = {}
e.type = "inserter"
e.name = name
e.icon = Constants.NetworkCables.itemIO.itemIcon
e.icon_size = 512
e.flags = {"placeable-neutral", "player-creation", "not-rotatable"}
e.collision_box = {{-0.25, -0.25}, {0.25, 0.25}}
e.selection_box = {{-0.25, -0.25}, {0.25, 0.25}}
e.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
e.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
e.energy_source = {
    type = "void",
}
e.draw_circuit_wires = true
e.circuit_wire_max_distance = 7
e.selection_priority = 51
e.allow_custom_vectors = true
e.draw_held_item = false
e.use_easter_egg = false
e.filter_count = 1
e.chases_belt_items = false
e.stack_size_bonus = 15-1
e.extension_speed = 1
e.rotation_speed = 15/60
e.insert_position = {0, -1}
e.pickup_position = {0, 0.1}
e.platform_picture = {
    north = {
        layers = {
            {
                filename = Constants.Settings.RNS_BlankIcon,
                priority = 'extra-high',
                size = 32
            }
        }
    }
}
e.platform_picture.east = table.deepcopy(e.platform_picture.north)
e.platform_picture.south = table.deepcopy(e.platform_picture.north)
e.platform_picture.west = table.deepcopy(e.platform_picture.north)
e.hand_base_picture = {filename = Constants.Settings.RNS_BlankIcon, size = 32}
e.hand_open_picture = {filename = Constants.Settings.RNS_BlankIcon, size = 32}
e.hand_closed_picture = {filename = Constants.Settings.RNS_BlankIcon, size = 32}
e.hand_base_shadow = {filename = Constants.Settings.RNS_BlankIcon, size = 32}
e.hand_open_shadow = {filename = Constants.Settings.RNS_BlankIcon, size = 32}
e.hand_closed_shadow = {filename = Constants.Settings.RNS_BlankIcon, size = 32}
data:extend{e}

local c = {}
c.type = "container"
c.name = "rns_Blank_Container"
c.icon = Constants.Settings.RNS_BlankIcon
c.icon_size = 32
c.flags = {"placeable-neutral", "player-creation", "hide-alt-info"}
c.collision_box = {{-0.40, -0.40}, {0.40, 0.40}}
c.selection_box = {{-0.50, -0.50}, {0.50, 0.50}}
c.inventory_size = 10
c.picture =
    {
        filename = Constants.Settings.RNS_BlankIcon,
        priority = 'extra-high',
        size = 32
    }
c.draw_copper_wires = false
c.draw_circuit_wires = false
c.selectable_in_game = false
data:extend{c}

local ioE = {}
ioE.type = "assembling-machine"
ioE.name = name2
ioE.icon = Constants.NetworkCables.itemIO.itemIcon
ioE.icon_size = 512
ioE.flags = {"placeable-neutral", "player-creation"}
ioE.collision_box = {{-0.40, -0.40}, {0.40, 0.40}}
ioE.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
ioE.fast_replaceable_group = Constants.Settings.RNS_FR_Cable
ioE.selection_priority = 51
ioE.minable = {mining_time = 0.2, result = name2}
ioE.max_health = 350
ioE.dying_explosion = "medium-explosion"
ioE.corpse = "small-remnants"
ioE.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
ioE.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
ioE.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
ioE.animation =
    {
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
ioE.animation.east = table.deepcopy(ioE.animation.north)
ioE.animation.east.layers[1].x = 512
ioE.animation.east.layers[2].x = 512
ioE.animation.south = table.deepcopy(ioE.animation.north)
ioE.animation.south.layers[1].x = 512*2
ioE.animation.south.layers[2].x = 512*2
ioE.animation.west = table.deepcopy(ioE.animation.north)
ioE.animation.west.layers[1].x = 512*3
ioE.animation.west.layers[2].x = 512*3
ioE.crafting_categories = {"RNS-Nothing"}
ioE.crafting_speed = 1
ioE.energy_source =
{
    type = "void",
}
ioE.energy_usage = "1J"
ioE.fluid_boxes = {
    {
        base_area = 1,
		hide_connection_info = true,
        pipe_connections = {
            {position = {0, -0.5}}
        },
        production_type = "output"
    }
}
data:extend{ioE}