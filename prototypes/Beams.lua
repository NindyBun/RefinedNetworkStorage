local iddleBeam = {}
iddleBeam.type = "beam"
iddleBeam.name = Constants.Beams.IddleBeam.name
iddleBeam.flags = {"not-on-map"}
iddleBeam.width = 1
iddleBeam.damage_interval = 20
iddleBeam.random_target_offset = true
iddleBeam.action_triggered_automatically = false
iddleBeam.action = nil
iddleBeam.head =
{
    filename = Constants.Beams.IddleBeam.entityE,
    flags = beam_non_light_flags,
    line_length = 1,
    width = 30,
    height = 30,
    frame_count = 1,
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
        filename = Constants.Beams.IddleBeam.entityL,
        line_length = 1,
        width = 30,
        height = 30,
        scale = 1.0,
        animation_speed = 0.025,
        frame_count = 1
    }
}
iddleBeam.light_animations.tail = iddleBeam.light_animations.head
iddleBeam.light_animations.body = iddleBeam.light_animations.head
data:extend{iddleBeam}

local connectedBeam = {}
connectedBeam.type = "beam"
connectedBeam.name = Constants.Beams.ConnectedBeam.name
connectedBeam.flags = {"not-on-map"}
connectedBeam.width = 1
connectedBeam.damage_interval = 20   
connectedBeam.random_target_offset = true
connectedBeam.action_triggered_automatically = false
connectedBeam.action = nil
connectedBeam.head =
{
    filename = Constants.Beams.ConnectedBeam.entityE,
    flags = beam_non_light_flags,
    line_length = 1,
    width = 90,
    height = 90,
    frame_count = 1,
    scale = 1/2.7,
    animation_speed = 0.025,
    blend_mode = laser_beam_blend_mode
}
connectedBeam.tail = connectedBeam.head
connectedBeam.body = connectedBeam.head
connectedBeam.light_animations =
{
    head =
    {
        filename = Constants.Beams.ConnectedBeam.entityL,
        line_length = 1,
        width = 90,
        height = 90,
        scale = 1/2.7,
        animation_speed = 0.025,
        frame_count = 1
    }
}
connectedBeam.light_animations.tail = connectedBeam.light_animations.head
connectedBeam.light_animations.body = connectedBeam.light_animations.head
data:extend{connectedBeam}