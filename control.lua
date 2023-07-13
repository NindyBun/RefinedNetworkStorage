GUI = GUI or {}
Event = Event or {}
UpdateSys = UpdateSys or {}

Constants = require("utils.constants")
require("utils.Util")
require("scripts.Events")
require("scripts.Functions")
require("scripts.updates")
require("scripts.gui.Gui")
require("scripts.gui.GuiApi")
require("scripts.objects.NetworkBase")
require("scripts.objects.NetworkController")
require("scripts.objects.RNSPlayer")
require("scripts.objects.NetworkCables")
require("scripts.objects.ItemIO")
require("scripts.objects.FluidIO")
require("scripts.objects.ItemDrives")
require("scripts.objects.FluidDrives")

--When the mod is added in a save
function onInit()
    local freeplay = remote.interfaces["freeplay"]
    if freeplay then  -- Disable freeplay popup-message
        if freeplay["set_skip_intro"] then remote.call("freeplay", "set_skip_intro", true) end
        if freeplay["set_disable_crashsite"] then remote.call("freeplay", "set_disable_crashsite", true) end
    end

	global.entityTable = global.entityTable or {}
    createObjectTables()

    for _, obj in pairs(global.objectTables) do
		if obj.tableName and obj.tag then
			if _G[obj.tag].validate then
				for _, entry in pairs(global[obj.tableName]) do
					entry:validate()
				end
			end
		end
	end

    if global.playerTable == nil then global.playerTable = {} end
	for _, player in pairs(game.players) do
		Event.initPlayer({player_index = player.index})
	end
end

--When the mod loads up in a save
function onLoad()
    for _, obj in pairs(global.objectTables) do
		if obj.tableName ~= nil and obj.tag ~= nil and _G[obj.tag] ~= nil then
			for _, entry in pairs(global[obj.tableName] or {}) do
				_G[obj.tag]:rebuild(entry)
			end
		end
    end
end

--When a player is created
function initPlayer(event)
    if Util.safeCall(Event.initPlayer, event) == true then
		if event.player_index ~= nil and game.players[event.player_index] ~= nil and game.players[event.player_index].name ~= nil then
			game.print({"gui-description.RNS_initAPlayer_PlayerInitFailed", game.players[event.player_index].name})
		else
			game.print({"gui-description.RNS_initAPlayer_PlayerInitFailed", {"gui-description.RNS_Unknown"}})
		end
	end
end

function onTick(event)
    Util.safeCall(Event.tick, event)
end

function pipette(event)
	if Util.safeCall(Event.pipette, event) == false then
        game.print({"gui-description.RNS_pipette_failed"})
        local entity = event.created_entity or event.entity or event.destination
        if entity ~= nil and entity.valid == true then
            entity.destroy()
        end
    end
end

function placed(event)
    if Util.safeCall(Event.placed, event) == false then
        game.print({"gui-description.RNS_placed_failed"})
        local entity = event.created_entity or event.entity or event.destination
        if entity ~= nil and entity.valid == true then
            entity.destroy()
        end
    end
end

function rotated(event)
    Util.safeCall(Event.rotated, event)
end
function changed_selection(event)
    Util.safeCall(Event.changed_selection, event)
end

function removed(event)
    Util.safeCall(Event.removed, event)
end

function onGuiOpened(event)
    Util.safeCall(GUI.on_gui_opened, event)
end

function onGuiClosed(event)
    Util.safeCall(GUI.on_gui_closed, event)
end

function onGuiClicked(event)
    Util.safeCall(GUI.on_gui_clicked, event)
end

script.on_init(onInit)
script.on_configuration_changed(onInit)
script.on_load(onLoad)

script.on_event(defines.events.on_cutscene_cancelled, initPlayer)
script.on_event(defines.events.on_player_created, initPlayer)
script.on_event(defines.events.on_player_joined_game, initPlayer)
script.on_event(defines.events.on_tick, onTick)

script.on_event(defines.events.on_built_entity, placed)
script.on_event(defines.events.on_player_built_tile, placed)
script.on_event(defines.events.script_raised_built, placed)
script.on_event(defines.events.script_raised_revive, placed)
script.on_event(defines.events.on_robot_built_entity, placed)
script.on_event(defines.events.on_robot_built_tile, placed)

script.on_event(defines.events.on_player_mined_entity, removed)
script.on_event(defines.events.on_player_mined_tile, removed)
script.on_event(defines.events.on_robot_mined_entity, removed)
script.on_event(defines.events.on_robot_mined_tile, removed)
script.on_event(defines.events.script_raised_destroy, removed)

script.on_event(defines.events.on_player_rotated_entity , rotated)
script.on_event(defines.events.on_selected_entity_changed, changed_selection)

script.on_event(defines.events.on_gui_opened, onGuiOpened)
script.on_event(defines.events.on_gui_closed, onGuiClosed)
--script.on_event(defines.events.on_gui_elem_changed, onGuiElemChanged)
--script.on_event(defines.events.on_gui_switch_state_changed, onGuiSwitchStateChanged)
script.on_event(defines.events.on_gui_click, onGuiClicked)