local detectorI = {}
detectorI.type = "item"
detectorI.name = Constants.Detector.name
detectorI.icon = Constants.Detector.itemIcon
detectorI.icon_size = 512
detectorI.subgroup = Constants.ItemGroup.Category.subgroup
detectorI.order = "i"
detectorI.stack_size = 10
detectorI.place_result = Constants.Detector.name
data:extend{detectorI}

local detectorR = {}
detectorR.type = "recipe"
detectorR.name = Constants.Detector.name
detectorR.energy_required = 1
detectorR.enabled = true
detectorR.ingredients = {}
detectorR.result = Constants.Detector.name
detectorR.result_count = 1
data:extend{detectorR}

local detector_E = {}
detector_E.type = "container"
detector_E.name = Constants.Detector.name
detector_E.icon = Constants.Detector.itemIcon
detector_E.icon_size = 512
detector_E.inventory_size = 0
detector_E.flags = {"placeable-neutral", "player-creation"}
detector_E.minable = {mining_time = 0.2, result = Constants.Detector.name}
detector_E.fast_replaceable_group = Constants.Settings.RNS_FR_Cable
detector_E.max_health = 250
detector_E.dying_explosion = "medium-explosion"
detector_E.corpse = "small-remnants"
detector_E.collision_box = {{-0.40, -0.40}, {0.49, 0.40}}
detector_E.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
detector_E.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
detector_E.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
detector_E.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
detector_E.picture =
    {
        layers =
        {
            {
                filename = Constants.Detector.entityE,
                priority = "extra-high",
                width = 512,
                height = 512,
                shift = {0,0},
                scale = 1/8
            },
            {
                filename = Constants.Detector.entityS,
                priority = "high",
                width = 512,
                height = 512,
                shift = {0,0},
                draw_as_shadow = true,
                scale = 1/8
            }
        }
    }
data:extend{detector_E}

local combinator1 = {}
combinator1.circuit_wire_connection_points = {
	{shadow={green={0, 0}, red={0, 0}}, wire={green={0, 0}, red={0, 0}}},
	{shadow={green={0, 0}, red={0, 0}}, wire={green={0, 0}, red={0, 0}}},
	{shadow={green={0, 0}, red={0, 0}}, wire={green={0, 0}, red={0, 0}}},
	{shadow={green={0, 0}, red={0, 0}}, wire={green={0, 0}, red={0, 0}}}
}
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