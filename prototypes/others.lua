local sprite1 = {}
sprite1.type = "sprite"
sprite1.name = Constants.Icons.check_mark.name
sprite1.layers = {
    {
        filename = Constants.Icons.check_mark.sprite,
        priority = "high",
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
        priority = "high",
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
        priority = "high",
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
        priority = "high",
        size = 64,
        scale = 0.5,
        x=0
    }
}
data:extend{sprite4}

local connection_points  = {
	{shadow={green={0, 0}, red={0, 0}}, wire={green={0, 0}, red={0, 0}}},
	{shadow={green={0, 0}, red={0, 0}}, wire={green={0, 0}, red={0, 0}}},
	{shadow={green={0, 0}, red={0, 0}}, wire={green={0, 0}, red={0, 0}}},
	{shadow={green={0, 0}, red={0, 0}}, wire={green={0, 0}, red={0, 0}}}
}

local combinator = {}
combinator.circuit_wire_connection_points = connection_points
combinator.circuit_wire_max_distance = 0
combinator.collision_box = {{-0.5, -0.5}, {0.5, 0.5}}
combinator.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
combinator.flags = {'placeable-neutral', 'hidden', 'not-upgradable', 'not-rotatable'}
combinator.icon = Constants.Settings.RNS_BlankIcon
combinator.icon_size = 32
combinator.item_slot_count = 10
combinator.name = 'RNS_Combinator'
combinator.type = 'constant-combinator'
combinator.collision_mask = {}
combinator.remove_decoratives = 'false'
combinator.sprites = {
	filename = Constants.Settings.RNS_BlankIcon,
	priority = 'extra-high',
	size = 32
}
combinator.activity_led_sprites = {
	filename = Constants.Settings.RNS_BlankIcon,
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
combinator1.circuit_wire_max_distance = 6
combinator1.collision_box = {{-0.25, -0.25}, {0.25, 0.25}}
combinator1.selection_box = {{-0.25, -0.25}, {0.25, 0.25}}
combinator1.flags = {'placeable-neutral', 'hidden', 'not-upgradable', 'not-rotatable', 'hide-alt-info'}
combinator1.icon = Constants.Settings.RNS_BlankIcon
combinator1.icon_size = 32
combinator1.item_slot_count = 1
combinator1.name = 'RNS_Combinator_1'
combinator1.type = 'constant-combinator'
combinator1.collision_mask = {}
combinator1.remove_decoratives = 'false'
combinator1.sprites = {
	filename = Constants.Settings.RNS_BlankIcon,
	priority = 'extra-high',
	size = 32
}
combinator1.activity_led_sprites = {
	filename = Constants.Settings.RNS_BlankIcon,
	priority = 'extra-high',
	size = 32
}
combinator1.selection_priority = 51
combinator1.activity_led_light_offsets = {{0, 0}, {0, 0}, {0, 0}, {0, 0}}
data:extend{combinator1}

local combinator1 = {}
combinator1.circuit_wire_connection_points = connection_points
combinator1.circuit_wire_max_distance = 6
combinator1.collision_box = {{-0.25, -0.25}, {0.25, 0.25}}
combinator1.selection_box = {{-0.25, -0.25}, {0.25, 0.25}}
combinator1.flags = {'placeable-neutral', 'hidden', 'not-upgradable', 'not-rotatable', 'hide-alt-info'}
combinator1.icon = Constants.Settings.RNS_BlankIcon
combinator1.icon_size = 32
combinator1.item_slot_count = 1
combinator1.name = 'RNS_Combinator_2'
combinator1.type = 'constant-combinator'
combinator1.collision_mask = {}
combinator1.remove_decoratives = 'false'
combinator1.sprites = {
	filename = Constants.Settings.RNS_BlankIcon,
	priority = 'extra-high',
	size = 32
}
combinator1.activity_led_sprites = {
	filename = Constants.Settings.RNS_BlankIcon,
	priority = 'extra-high',
	size = 32
}
combinator1.selection_priority = 51
combinator1.activity_led_light_offsets = {{0, 0}, {0, 0}, {0, 0}, {0, 0}}
data:extend{combinator1}

local iddleBeam = {}
iddleBeam.type = "beam"
iddleBeam.name = "IddleBeam"
iddleBeam.flags = {"not-on-map"}
iddleBeam.width = 1
iddleBeam.damage_interval = 20
iddleBeam.random_target_offset = true
iddleBeam.action_triggered_automatically = false
iddleBeam.action = nil
iddleBeam.head =
{
    filename = "__RefinedNetworkStorage__/graphics/Cables/IddleBeam.png",
    flags = beam_non_light_flags,
    line_length = 2,
    width = 30,
    height = 30,
    frame_count = 2,
    scale = 1.0,
    animation_speed = 0.025,
    blend_mode = laser_beam_blend_mode
}
iddleBeam.tail = iddleBeam.head
iddleBeam.body = iddleBeam.head
iddleBeam.light_animations =
{
    head =
    {
        filename = "__RefinedNetworkStorage__/graphics/Cables/IddleBeamLight.png",
        line_length = 2,
        width = 30,
        height = 30,
        scale = 1.0,
        animation_speed = 0.025,
        frame_count = 2
    }
}
iddleBeam.light_animations.tail = iddleBeam.light_animations.head
iddleBeam.light_animations.body = iddleBeam.light_animations.head
data:extend{iddleBeam}

local mk1ConnectedBeam = {}
mk1ConnectedBeam.type = "beam"
mk1ConnectedBeam.name = "ConnectedBeam"
mk1ConnectedBeam.flags = {"not-on-map"}
mk1ConnectedBeam.width = 1
mk1ConnectedBeam.damage_interval = 20   
mk1ConnectedBeam.random_target_offset = true
mk1ConnectedBeam.action_triggered_automatically = false
mk1ConnectedBeam.action = nil
mk1ConnectedBeam.head =
{
    filename = "__RefinedNetworkStorage__/graphics/Cables/MK1ConnectedBeam.png",
	tint = {255, 0, 0},
    flags = beam_non_light_flags,
	apply_runtime_tint = true,
    line_length = 1,
    width = 90,
    height = 90,
    scale = 1/2.7,
    blend_mode = laser_beam_blend_mode
}
mk1ConnectedBeam.tail = mk1ConnectedBeam.head
mk1ConnectedBeam.body = mk1ConnectedBeam.head
mk1ConnectedBeam.light_animations =
{
    head =
    {
        filename = "__RefinedNetworkStorage__/graphics/Cables/MK1ConnectedBeamLight.png",
        line_length = 1,
        width = 90,
        height = 90,
        scale = 1/2.7,
        frame_count = 1
    }
}
mk1ConnectedBeam.light_animations.tail = mk1ConnectedBeam.light_animations.head
mk1ConnectedBeam.light_animations.body = mk1ConnectedBeam.light_animations.head
data:extend{mk1ConnectedBeam}