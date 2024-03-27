local sprite1 = {}
sprite1.type = "sprite"
sprite1.name = Constants.Icons.check_mark.name
sprite1.layers = {
    {
        filename = Constants.Icons.check_mark.sprite,
        priority = "medium",
        size = 32,
        scale = 1
    }
}
data:extend{sprite1}

local sprite2 = {}
sprite2.type = "sprite"
sprite2.name = Constants.Icons.x_mark.name
sprite2.layers = {
    {
        filename = Constants.Icons.x_mark.sprite,
        priority = "medium",
        size = 32,
        scale = 1
    }
}
data:extend{sprite2}

local sprite3 = {}
sprite3.type = "sprite"
sprite3.name = Constants.Icons.underground.target.name
sprite3.layers = {
    {
        filename = Constants.Icons.underground.target.sprite,
        priority = "medium",
        size = 64,
        scale = 0.5,
        x=192
    }
}
data:extend{sprite3}

local sprite4 = {}
sprite4.type = "sprite"
sprite4.name = Constants.Icons.underground.gap.name
sprite4.layers = {
    {
        filename = Constants.Icons.underground.gap.sprite,
        priority = "medium",
        size = 64,
        scale = 0.5,
        x=0
    }
}
data:extend{sprite4}

local sprite5 = {}
sprite5.type = "sprite"
sprite5.name = Constants.Icons.storage.name
sprite5.layers = {
    {
        filename = Constants.Icons.storage.sprite,
        priority = "medium",
        size = 48,
        scale = 24/48
    }
}
data:extend{sprite5}

local sprite6 = {}
sprite6.type = "sprite"
sprite6.name = Constants.Icons.storage_bothways.name
sprite6.layers = {
    {
        filename = Constants.Icons.storage_bothways.sprite,
        priority = "medium",
        size = 48,
        scale = 24/48
    }
}
data:extend{sprite6}


local sprite7 = {}
sprite7.type = "sprite"
sprite7.name = Constants.NetworkController.states.stable
sprite7.layers = {
    {
        filename = Constants.NetworkController.states.stableE,
        priority = "medium",
        size = 512,
        scale = (96 * 3)/512
    }
}
data:extend{sprite7}

local sprite8 = {}
sprite8.type = "sprite"
sprite8.name = Constants.NetworkController.states.unstable
sprite8.layers = {
    {
        filename = Constants.NetworkController.states.unstableE,
        priority = "medium",
        size = 512,
        scale = (96 * 3)/512
    }
}
data:extend{sprite8}

for _, color in pairs(Constants.NetworkCables.Cables) do
    for _, tex in pairs(color.sprites) do
        local sprite9 = {}
        sprite9.type = "sprite"
        sprite9.name = tex.name
        sprite9.layers = {
            {
                filename = tex.sprite_E,
                priority = "medium",
                size = 512,
                shift = {0,0},
                scale = 1/16
            },
            {
                filename = tex.sprite_S,
                priority = "medium",
                size = 512,
                shift = {0,0},
                draw_as_shadow = true,
                scale = 1/16
            }
        }
        data:extend{sprite9}
    end
end

local sprite10 = {}
sprite10.type = "sprite"
sprite10.name = Constants.Icons.insert_arrow.name
sprite10.layers = {
    {
        filename = Constants.Icons.insert_arrow.sprite,
        priority = "medium",
        size = 128,
        scale = 1
    }
}
data:extend{sprite10}

local connection_points  = {
	{shadow={green={0, 0}, red={0, 0}}, wire={green={0, 0}, red={0, 0}}},
	{shadow={green={0, 0}, red={0, 0}}, wire={green={0, 0}, red={0, 0}}},
	{shadow={green={0, 0}, red={0, 0}}, wire={green={0, 0}, red={0, 0}}},
	{shadow={green={0, 0}, red={0, 0}}, wire={green={0, 0}, red={0, 0}}}
}

--[[local pole = {}
pole.type = "electric-pole"
pole.name = "rns_Pole"
pole.icon = Constants.Settings.RNS_BlankIcon32
pole.icon_size = 32
pole.connection_points = connection_points
pole.flags = {'placeable-neutral', 'hidden', 'not-upgradable', 'not-rotatable'}
pole.maximum_wire_distance = 0
pole.collision_box = {{-0.5, -0.5}, {0.5, 0.5}}
pole.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
pole.supply_area_distance = 1
pole.selection_priority = 51
pole.pictures = {
    direction_count = 4,
	filename = Constants.Settings.RNS_BlankIcon128,
	priority = 'extra-high',
	size = 32
}
data:extend{pole}]]

local combinator = {}
combinator.circuit_wire_connection_points = connection_points
combinator.circuit_wire_max_distance = 0
combinator.collision_box = {{-0.5, -0.5}, {0.5, 0.5}}
combinator.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
combinator.flags = {'placeable-neutral', 'hidden', 'not-upgradable', 'not-rotatable'}
combinator.icon = Constants.Settings.RNS_BlankIcon32
combinator.icon_size = 32
combinator.item_slot_count = 10
combinator.name = 'rns_Combinator'
combinator.type = 'constant-combinator'
combinator.collision_mask = {}
combinator.remove_decoratives = 'false'
combinator.sprites = {
	filename = Constants.Settings.RNS_BlankIcon32,
	priority = 'extra-high',
	size = 32
}
combinator.activity_led_sprites = {
	filename = Constants.Settings.RNS_BlankIcon32,
	priority = 'extra-high',
	size = 32
}
--combinator.selection_priority = 51
combinator.draw_copper_wires = false
combinator.draw_circuit_wires = false
combinator.activity_led_light_offsets = {{0, 0}, {0, 0}, {0, 0}, {0, 0}}
combinator.selectable_in_game = false
data:extend{combinator}

local combinator1 = {}
combinator1.circuit_wire_connection_points = connection_points
combinator1.circuit_wire_max_distance = 9
combinator1.collision_box = {{-0.25, -0.25}, {0.25, 0.25}}
combinator1.selection_box = {{-0.25, -0.25}, {0.25, 0.25}}
combinator1.flags = {'placeable-neutral', 'hidden', 'not-upgradable', 'not-rotatable', 'hide-alt-info'}
combinator1.icon = Constants.Settings.RNS_BlankIcon32
combinator1.icon_size = 32
combinator1.item_slot_count = 1
combinator1.name = 'rns_Combinator_1'
combinator1.type = 'constant-combinator'
combinator1.collision_mask = {}
combinator1.remove_decoratives = 'false'
combinator1.sprites = {
	filename = Constants.Settings.RNS_BlankIcon32,
	priority = 'extra-high',
	size = 32
}
combinator1.activity_led_sprites = {
	filename = Constants.Settings.RNS_BlankIcon32,
	priority = 'extra-high',
	size = 32
}
combinator1.selection_priority = 51
combinator1.activity_led_light_offsets = {{0, 0}, {0, 0}, {0, 0}, {0, 0}}
data:extend{combinator1}

local combinator1 = {}
combinator1.circuit_wire_connection_points = connection_points
combinator1.circuit_wire_max_distance = 9
combinator1.collision_box = {{-0.25, -0.25}, {0.25, 0.25}}
combinator1.selection_box = {{-0.25, -0.25}, {0.25, 0.25}}
combinator1.flags = {'placeable-neutral', 'hidden', 'not-upgradable', 'not-rotatable', 'hide-alt-info'}
combinator1.icon = Constants.Settings.RNS_BlankIcon32
combinator1.icon_size = 32
combinator1.item_slot_count = 1
combinator1.name = 'rns_Combinator_2'
combinator1.type = 'constant-combinator'
combinator1.collision_mask = {}
combinator1.remove_decoratives = 'false'
combinator1.sprites = {
	filename = Constants.Settings.RNS_BlankIcon32,
	priority = 'extra-high',
	size = 32
}
combinator1.activity_led_sprites = {
	filename = Constants.Settings.RNS_BlankIcon32,
	priority = 'extra-high',
	size = 32
}
combinator1.selection_priority = 51
combinator1.activity_led_light_offsets = {{0, 0}, {0, 0}, {0, 0}, {0, 0}}
data:extend{combinator1}