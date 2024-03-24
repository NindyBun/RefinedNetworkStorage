function GUI.update(force)
    for _, player in pairs(game.connected_players) do
        local RNSPlayer = getRNSPlayer(player.name)
        if RNSPlayer ~= nil then
            if game.tick % 1--[[Constants.Settings.RNS_Gui_Tick == 0]] or force then
                for _, guiTable in pairs(RNSPlayer.GUI or {}) do
                    if guiTable.gui ~= nil and guiTable.gui.valid == true and GUI["update_" .. guiTable.gui.name] ~= nil then
                        if guiTable.vars.currentObject.thisEntity == nil or guiTable.vars.currentObject.thisEntity.valid == false or guiTable.vars.currentObject.thisEntity.to_be_deconstructed() == true then
                            GUI.remove_gui(guiTable, player)
                            goto continue
                        end
                        local playerVars = RNSPlayer:pull_varTable(guiTable.vars.currentObject.entID) or false
                        if playerVars == true then RNSPlayer:remove_varTable(guiTable.vars.currentObject.entID) end
                        if Util.safeCall(GUI["update_" .. guiTable.gui.name], guiTable, playerVars) == false then
                            player.print({"gui-description.RNS_updating_gui_failed"})
                            Util.safeCall(Event.clear_gui, {player_index=player.index})
                            goto continue
                        end
                    end
                    ::continue::
                end
            end
        end
    end
end

function GUI.remove_gui(guiTable, player)
    guiTable.gui.destroy()
    guiTable = nil
    player.opened = nil
end

function GUI.update_tooltip_gui(guiObj, justCreated)
    if valid(guiObj.vars.currentObject) == true and guiObj.vars.currentObject.getTooltips ~= nil then
        guiObj.vars.currentObject:getTooltips(guiObj, guiObj.vars.MainFrame, justCreated)
    end
end

function GUI.create_tooltip_gui(player, obj)
    if valid(obj) == false then return end
    local RNSPlayer = getRNSPlayer(player.name)
    local guiTable = GuiApi.create_base_window(Constants.Settings.RNS_Gui.tooltip, RNSPlayer, true, true, false, "vertical", "horizontal")
    GuiApi.add_close_button(guiTable)
    guiTable.vars.currentObject = obj
    GUI.update_tooltip_gui(guiTable, true)
    return guiTable
end

function GUI.open_tooltip_gui(RNSPlayer, player, entity)
    if entity == nil or entity.valid == false or entity.to_be_deconstructed() == true then return end

    local cursorStack = player.cursor_stack
	if cursorStack and cursorStack.valid_for_read then
		if cursorStack.name == "green-wire" or cursorStack.name == "red-wire" or cursorStack.type == "repair-tool" then return end
	end

    local obj = global.entityTable[entity.unit_number]
    if valid(obj) == false or obj.getTooltips == nil then return end

    local guiTable = GUI.create_tooltip_gui(player, obj)
    player.opened = guiTable.gui
    RNSPlayer.GUI[Constants.Settings.RNS_Gui.tooltip] = guiTable
end

function GUI.on_gui_opened(event)
    local player = getPlayer(event.player_index)
    local RNSPlayer = getRNSPlayer(event.player_index)

    if event.entity ~= nil and event.entity.valid == true then
        if Util.safeCall(GUI.open_tooltip_gui, RNSPlayer, player, player.selected) == false then
            player.print({"gui-description.RNS_openGui_falied"})
            Event.clear_gui(event)
        end
    end
end

function GUI.on_gui_closed(event)
    if event.element == nil or event.element.valid == false then return end
    local playerIndex = event.player_index
    local RNSPlayer = getRNSPlayer(playerIndex)
    if RNSPlayer.GUI == nil or RNSPlayer.GUI.valid == false then return end

    if event.element.name == Constants.Settings.RNS_Gui.tooltip then
        RNSPlayer.GUI[Constants.Settings.RNS_Gui.tooltip].gui.destroy()
        RNSPlayer.GUI[Constants.Settings.RNS_Gui.tooltip] = nil
        return
    end
end

--Mainly used for buttons
function GUI.on_gui_clicked(event)
    local playerIndex = event.player_index
    local player = getPlayer(playerIndex)
    local RNSPlayer = getRNSPlayer(playerIndex)
    if RNSPlayer.GUI == nil or RNSPlayer.GUI.valid == false then return end

    if event.element.name == Constants.Settings.RNS_Gui.tooltip .. "_CloseButton" then
        if RNSPlayer.GUI[Constants.Settings.RNS_Gui.tooltip] ~= nil then
            RNSPlayer.GUI[Constants.Settings.RNS_Gui.tooltip].gui.destroy()
            RNSPlayer.GUI[Constants.Settings.RNS_Gui.tooltip] = nil
        end
        return
    end

    if string.match(event.element.name, "RNS_NII") then
        NII.interaction(event, RNSPlayer)
        GUI.update(true)
        return
    end

    if string.match(event.element.name, "RNS_WG") then
        WG.interaction(event, RNSPlayer)
        GUI.update(true)
        return
    end

    if string.match(event.element.name, "RNS_WT") then
        WT.interaction(event, RNSPlayer)
        GUI.update(true)
        return
    end
end

function GUI.on_gui_element_changed(event)
    local player = getPlayer(event.player_index)
    local RNSPlayer = getRNSPlayer(event.player_index)
    if player == nil then return end

    if string.match(event.element.name, "RNS_NetworkCableIO_Item") then
        IIO3.interaction(event, RNSPlayer)
        GUI.update(true)
        return
    end

    if string.match(event.element.name, "RNS_NetworkCableIO_Fluid") then
        FIO.interaction(event, RNSPlayer)
        GUI.update(true)
        return
    end
    
    if string.match(event.element.name, "RNS_NetworkCableIO_External") then
        EIO.interaction(event, RNSPlayer)
        GUI.update(true)
        return
    end

    if string.match(event.element.name, "RNS_ItemDrive") then
        ID.interaction(event, RNSPlayer)
        GUI.update(true)
        return
    end

    if string.match(event.element.name, "RNS_FluidDrive") then
        FD.interaction(event, RNSPlayer)
        GUI.update(true)
        return
    end

    if string.match(event.element.name, "RNS_WirelessGrid") then
        WG.interaction(event, RNSPlayer)
        GUI.update(true)
        return
    end

    if string.match(event.element.name, "RNS_WirelessTransmitter") then
        WT.interaction(event, RNSPlayer)
        GUI.update(true)
        return
    end

    if string.match(event.element.name, "RNS_Detector") then
        DT.interaction(event, RNSPlayer)
        GUI.update(true)
        return
    end

    if string.match(event.element.name, "RNS_TransReceiver") then
        TR.interaction(event, RNSPlayer)
        GUI.update(true)
        return
    end
end