Constants = require("utils.constants")
data:extend({
    {
        type = "bool-setting",
        name = Constants.Settings.RNS_RoundRobin,
        setting_type = "runtime-global",
        default_value = true
    },
    {
        type = "color-setting",
        name = Constants.Settings.RNS_WirelessTransmitter_Color,
        setting_type = "runtime-global",
        default_value = {r=25, g=0, b=51, a=0}
    }
})
--[[data:extend({
    {
        type = "int-setting",
        name = Constants.Settings.RNS_RGBA_A,
        setting_type = "runtime-global",
        default_value = 0,
        minimum_value = 0,
        maximum_value = 255
    }
})
data:extend({
    {
        type = "int-setting",
        name = Constants.Settings.RNS_RGBA_B,
        setting_type = "runtime-global",
        default_value = 51,
        minimum_value = 0,
        maximum_value = 255
    }
})
data:extend({
    {
        type = "int-setting",
        name = Constants.Settings.RNS_RGBA_G,
        setting_type = "runtime-global",
        default_value = 0,
        minimum_value = 0,
        maximum_value = 255
    }
})
data:extend({
    {
        type = "int-setting",
        name = Constants.Settings.RNS_RGBA_R,
        setting_type = "runtime-global",
        default_value = 25,
        minimum_value = 0,
        maximum_value = 255
    }
})]]
