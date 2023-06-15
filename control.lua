GUI = GUI or {}
Event = Event or {}
UpdateSys = UpdateSys or {}

require("utils.Util")
require("scripts.Events")
require("scripts.Functions")

--When the mod is added in a save
function onInit()
    local freeplay = remote.interfaces["freeplay"]
    if freeplay then  -- Disable freeplay popup-message
        if freeplay["set_skip_intro"] then remote.call("freeplay", "set_skip_intro", true) end
        if freeplay["set_disable_crashsite"] then remote.call("freeplay", "set_disable_crashsite", true) end
    end

    global.networkID = global.networkID or {{id=0, used=false}}
end

--When the mod loads up in a save
function onLoad()

end

--When a player is created
function initPlayer()

end

script.on_init(onInit)
script.on_configuration_changed(onInit)
script.on_load(onLoad)
script.on_event(defines.events.on_cutscene_cancelled, initPlayer)
script.on_event(defines.events.on_player_created, initPlayer)
script.on_event(defines.events.on_player_joined_game, initPlayer)