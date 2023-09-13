WT = {
    thisEntity = nil,
    entID = nil,
    arms = nil,
    connectedObjs = nil,
    color = "RED",
    networkController = nil,
    cardinals = nil,
}

function WT:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = WT
    t.thisEntity = object
    t.entID = object.unit_number
    rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[t.color].sprites[5].name, target=t.thisEntity, surface=t.thisEntity.surface, render_layer="lower-object-above-shadow"}
    t.arms = {
        [1] = nil, --N
        [2] = nil, --E
        [3] = nil, --S
        [4] = nil, --W
    }
    t.connectedObjs = {
        [1] = {}, --N
        [2] = {}, --E
        [4] = {}, --S
        [3] = {}, --W
    }
    t.cardinals = {
        [1] = false, --N
        [2] = false, --E
        [3] = false, --S
        [4] = false, --W
    }
    t:createArms()
    UpdateSys.addEntity(t)
    return t
end

function WT:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = WT
    setmetatable(object, mt)
end

function WT:remove()
    UpdateSys.remove(self)
    if self.networkController ~= nil then
        self.networkController.network.WirelessTransmitterTable[1][self.entID] = nil
        self.networkController.network.shouldRefresh = true
    end
end

function WT:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function WT:update()
    --if game.tick % 60 then
        if valid(self) == false then
            self:remove()
            return
        end
        if valid(self.networkController) == false then
            self.networkController = nil
        end
        if self.thisEntity.to_be_deconstructed() == true then return end
        self:createArms()
    --end
end

function WT:locate_and_inject()

end

function WT:resetConnection()
    self.connectedObjs = {
        [1] = {}, --N
        [2] = {}, --E
        [3] = {}, --S
        [4] = {}, --W
    }
    for _, arm in pairs(self.arms) do
        if arm ~= nil then
            rendering.destroy(arm)
        end
    end
end

function WT:getCheckArea()
    local x = self.thisEntity.position.x
    local y = self.thisEntity.position.y
    return {
        [1] = {direction = 1, startP = {x-0.5, y-1.5}, endP = {x+0.5, y-0.5}}, --North
        [2] = {direction = 2, startP = {x+0.5, y-0.5}, endP = {x+1.5, y+0.5}}, --East
        [4] = {direction = 4, startP = {x-0.5, y+0.5}, endP = {x+0.5, y+1.5}}, --South
        [3] = {direction = 3, startP = {x-1.5, y-0.5}, endP = {x-0.5, y+0.5}}, --West
    }
end

function WT:createArms()
    local areas = self:getCheckArea()
    local selfP = self.thisEntity.position
    self:resetConnection()
    for _, area in pairs(areas) do
        local ents = self.thisEntity.surface.find_entities_filtered{area={area.startP, area.endP}}
        local nearest = nil
        for _, ent in pairs(ents) do
            if ent ~= nil and ent.valid == true then
                if (nearest == nil or Util.distance(selfP, ent.position) < Util.distance(selfP, nearest.position)) and string.match(ent.name, "RNS_") ~= nil and ent.operable then
                    nearest = ent
                end
            end
        end
        if nearest ~= nil and global.entityTable[nearest.unit_number] ~= nil then
            local obj = global.entityTable[nearest.unit_number]
            if (string.match(obj.thisEntity.name, "RNS_NetworkCableIO") ~= nil and obj:getConnectionDirection() == area.direction) or obj.thisEntity.name == Constants.WirelessGrid.name then
                --Do nothing
            else
                if obj.color == nil then
                    self.arms[area.direction] = rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[self.color].sprites[area.direction].name, target=self.thisEntity, surface=self.thisEntity.surface, render_layer="lower-object-above-shadow"}
                    self.connectedObjs[area.direction] = {obj}
                elseif obj.color ~= "" and obj.color == self.color then
                    self.arms[area.direction] = rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[self.color].sprites[area.direction].name, target=self.thisEntity, surface=self.thisEntity.surface, render_layer="lower-object-above-shadow"}
                    self.connectedObjs[area.direction] = {obj}
                end
            end
            if self.cardinals[area.direction] == false then
                self.cardinals[area.direction] = true
                if valid(self.networkController) == true and self.networkController.thisEntity ~= nil and self.networkController.thisEntity.valid == true then
                    self.networkController.network.shouldRefresh = true
                elseif obj.thisEntity.name == Constants.NetworkController.slateEntity.name then
                    obj.network.shouldRefresh = true
                end
            end
        elseif nearest == nil then
            if self.cardinals[area.direction] == true then
                self.cardinals[area.direction] = false
                if valid(self.networkController) == true and self.networkController.thisEntity ~= nil and self.networkController.thisEntity.valid == true then
                    self.networkController.network.shouldRefresh = true
                end
            end
        end
    end
end

function WT:getTooltips(guiTable, mainFrame, justCreated)
    if justCreated == true then
        guiTable.vars.Gui_Title.caption = {"gui-description.RNS_WirelessTransmitter_Title"}
        mainFrame.style.height = 250

        local colorFrame = GuiApi.add_frame(guiTable, "ColorFrame", mainFrame, "vertical", true)
		colorFrame.style = Constants.Settings.RNS_Gui.frame_1
		colorFrame.style.vertically_stretchable = true
		colorFrame.style.left_padding = 3
		colorFrame.style.right_padding = 3
		colorFrame.style.right_margin = 3
		colorFrame.style.width = 150

        GuiApi.add_subtitle(guiTable, "", colorFrame, {"gui-description.RNS_Connection_Color"})
        local colorDD = GuiApi.add_dropdown(guiTable, "RNS_WirelessTransmitter_Color", colorFrame, Constants.Settings.RNS_ColorG, Constants.Settings.RNS_Colors[self.color], false, {"gui-description.RNS_Connection_Color_tooltip"}, {ID=self.thisEntity.unit_number})
        colorDD.style.minimal_width = 100

        local infoFrame = GuiApi.add_frame(guiTable, "InformationFrame", mainFrame, "vertical", true)
		infoFrame.style = Constants.Settings.RNS_Gui.frame_1
		infoFrame.style.vertically_stretchable = true
		infoFrame.style.left_padding = 3
		infoFrame.style.right_padding = 3
		infoFrame.style.right_margin = 3
		infoFrame.style.width = 150

        GuiApi.add_subtitle(guiTable, "", infoFrame, {"gui-description.RNS_Information"})

        GuiApi.add_label(guiTable, "", infoFrame, {"gui-description.RNS_WirelessTransmitterRange", Constants.Settings.RNS_Default_WirelessGrid_Distance}, Constants.Settings.RNS_Gui.white)
    
        local playerFrame = GuiApi.add_frame(guiTable, "PlayerFrame", mainFrame, "vertical", true)
		playerFrame.style = Constants.Settings.RNS_Gui.frame_1
		playerFrame.style.vertically_stretchable = true
		playerFrame.style.left_padding = 3
		playerFrame.style.right_padding = 3
		playerFrame.style.right_margin = 3
        GuiApi.add_subtitle(guiTable, "", playerFrame, {"gui-description.RNS_Connected_Players"})

		local flow = GuiApi.add_flow(guiTable, "", playerFrame, "horizontal")
		flow.style.vertical_align = "center"
    
		local textField = GuiApi.add_text_field(guiTable, "RNS_PlayerField", flow, "", "", true, false, false, false, false)
		textField.style.maximal_width = 140
        --GuiApi.add_label(guiTable, "", flow, "  ")
        local checkMark = GuiApi.add_button(guiTable, "RNS_WT_Checkmark", flow, Constants.Icons.check_mark.name, Constants.Icons.check_mark.name, Constants.Icons.check_mark.name, {"gui-description.RNS_Add"}, 30, false, true, nil, nil, {ID=self.thisEntity.unit_number})
        --GuiApi.add_label(guiTable, "", flow, "  ")
        local xMark = GuiApi.add_button(guiTable, "RNS_WT_Xmark", flow, Constants.Icons.x_mark.name, Constants.Icons.x_mark.name, Constants.Icons.x_mark.name, {"gui-description.RNS_Remove"}, 30, false, true, nil, nil, {ID=self.thisEntity.unit_number})

        GuiApi.add_line(guiTable, "", playerFrame, "horizontal")
        local playerScrollPane = GuiApi.add_scroll_pane(guiTable, "PlayerScrollPane", playerFrame, 300, true)
		playerScrollPane.style = Constants.Settings.RNS_Gui.scroll_pane
		playerScrollPane.style.minimal_width = 208
		playerScrollPane.style.vertically_stretchable = true
		playerScrollPane.style.bottom_margin = 3
    end
    local playerPane = guiTable.vars.PlayerScrollPane
    playerPane.clear()

    if self.networkController == nil or not self.networkController.stable or (self.networkController.thisEntity ~= nil and self.networkController.thisEntity.valid == false) then return end

    for name, rnsplayer in pairs(self.networkController.network.PlayerPorts) do
        local button = GuiApi.add_simple_button(guiTable, "", playerPane, name, nil)
        button.style.minimal_width = 200-4
    end

end

function WT.interaction(event, RNSPlayer)
    if string.match(event.element.name, "RNS_WirelessTransmitter_Color") then
		local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local color = Constants.Settings.RNS_ColorN[event.element.selected_index]
        if color ~= io.color then
            io.color = color
            rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[io.color].sprites[5].name, target=io.thisEntity, surface=io.thisEntity.surface, render_layer="lower-object-above-shadow"}
        end
		return
	end
    if string.match(event.element.name, "RNS_WT_Checkmark") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        for _, guiTable in pairs(RNSPlayer.GUI or {}) do
            if guiTable.gui ~= nil and guiTable.gui.valid == true then
                if guiTable.vars.currentObject.thisEntity ~= nil and guiTable.vars.currentObject.thisEntity.valid == true and guiTable.vars.currentObject.thisEntity.unit_number == id then
                    local text = guiTable.vars.RNS_PlayerField.text
                    if game.players[text] ~= nil and io.networkController ~= nil and io.networkController.thisEntity ~= nil and io.networkController.thisEntity.valid == true and io.networkController.network.PlayerPorts[text] == nil then
                        io.networkController.network.PlayerPorts[text] = RNSPlayer
                        return
                    end
                end
            end
        end
    end
    if string.match(event.element.name, "RNS_WT_Xmark") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        for _, guiTable in pairs(RNSPlayer.GUI or {}) do
            if guiTable.gui ~= nil and guiTable.gui.valid == true then
                if guiTable.vars.currentObject.thisEntity ~= nil and guiTable.vars.currentObject.thisEntity.valid == true and guiTable.vars.currentObject.thisEntity.unit_number == id then
                    local text = guiTable.vars.RNS_PlayerField.text
                    if game.players[text] ~= nil and io.networkController ~= nil and io.networkController.thisEntity ~= nil and io.networkController.thisEntity.valid == true and io.networkController.network.PlayerPorts[text] ~= nil then
                        io.networkController.network.PlayerPorts[text] = nil
                        return
                    end
                end
            end
        end
    end
end