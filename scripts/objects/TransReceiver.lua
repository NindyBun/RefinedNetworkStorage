TR = {
    thisEntity = nil,
    entID = nil,
    networkController = nil,
    connectedObjs = nil,
    cardinals = nil,
    type = "",
    nametag = nil,
    powerUsage = 2560,
    connected = nil
}
--Constructor
function TR:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = TR
    t.thisEntity = object
    t.entID = object.unit_number
    t.type = object.name == "RNS_NetworkTransmitter" and "transmitter" or "receiver"
    t.nametag = {"gui-description.RNS_TransReceiver_ID", t.thisEntity.unit_number, t.thisEntity.surface.name, tostring(serpent.line(t.thisEntity.position))}
    t.connectedObjs = {
        [1] = {}, --N
        [2] = {}, --E
        [3] = {}, --S
        [4] = {}, --W
        [5] = {}  --Receiver
    }
    t.cardinals = {
        [1] = false, --N
        [2] = false, --E
        [3] = false, --S
        [4] = false, --W
        [5] = false  --Receiver
    }
    UpdateSys.add_to_entity_table(t)
    BaseNet.add_transreciever_to_global(t)
    t:createArms()
    BaseNet.postArms(t)
    BaseNet.update_network_controller(t.networkController)
    --UpdateSys.addEntity(t)
    return t
end

--Reconstructor
function TR:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = TR
    setmetatable(object, mt)
end

--Deconstructor
function TR:remove()
    UpdateSys.remove_from_entity_table(self)
    BaseNet.remove_transreciever_from_global(self)
    BaseNet.postArms(self)
    --UpdateSys.remove(self)
    --[[if self.networkController ~= nil then
        if self.type == "transmitter" then
            self.networkController.network.TransmitterTable[1][self.entID] = nil
        else
            self.networkController.network.ReceiverTable[1][self.entID] = nil
        end
        self.networkController.network.shouldRefresh = true
    end]]
    BaseNet.update_network_controller(self.networkController, self.entID)
end
--Is valid
function TR:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

--[[function TR:update()
    if valid(self) == false then
        self:remove()
        return
    end
    if self.thisEntity.to_be_deconstructed() == true then return end
    --if game.tick % 25 then self:createArms() end
end]]

function TR:resetCollection()
    self.connectedObjs = {
        [1] = {}, --N
        [2] = {}, --E
        [3] = {}, --S
        [4] = {}, --W
        [5] = {}  --Receiver
    }
end

function TR:getCheckArea()
    local x = self.thisEntity.position.x
    local y = self.thisEntity.position.y
    return {
        [1] = {direction = 1, startP = {x-1.0, y-2.0}, endP = {x+1.0, y-1.0}}, --North
        [2] = {direction = 2, startP = {x+1.0, y-1.0}, endP = {x+2.0, y+1.0}}, --East
        [4] = {direction = 4, startP = {x-1.0, y+1.0}, endP = {x+1.0, y+2.0}}, --South
        [3] = {direction = 3, startP = {x-2.0, y-1.0}, endP = {x-1.0, y+1.0}}, --West
    }
end

function TR:createArms()
    local areas = self:getCheckArea()
    self:resetCollection()
    for _, area in pairs(areas) do
        local ents = self.thisEntity.surface.find_entities_filtered{area={area.startP, area.endP}}
        for _, ent in pairs(ents) do
            if ent ~= nil and ent.valid == true and ent.to_be_deconstructed() == false and string.match(ent.name, "RNS_") ~= nil and global.entityTable[ent.unit_number] ~= nil then
                local obj = global.entityTable[ent.unit_number]
                if (string.match(obj.thisEntity.name, "RNS_NetworkCableIO") ~= nil and obj:getConnectionDirection() == area.direction) or (string.match(obj.thisEntity.name, "RNS_NetworkCableRamp") ~= nil and obj:getConnectionDirection() == area.direction) or obj.thisEntity.name == Constants.WirelessGrid.name then
                    --Do nothing
                else
                    table.insert(self.connectedObjs[area.direction], obj)
                    BaseNet.join_network(self, obj)
                end
            end
        end
    end
    if self.type ~= "transmitter" then return end
    if self.connected == nil or global.entityTable[self.connected] == nil or global.entityTable[self.connected].thisEntity == nil or global.entityTable[self.connected].thisEntity.valid == false then return end

    local obj = global.entityTable[self.connected]
    if BaseNet.exists_in_network(obj.networkController, obj.entID) and obj.networkController.entID ~= self.networkController.entID then
        self.thisEntity.order_deconstruction("player")
    else
        self.connectedObjs[5] = {obj}
        BaseNet.join_network(self, obj)
    end
    
end

function TR:copy_settings(obj)
    self.connected = obj.connected
end

function TR:serialize_settings()
    local tags = {}
    tags["connection"] = self.connected
    return tags
end

function TR:deserialize_settings(tags)
    self.connected = tags["connection"]
end

function TR:DataConvert_ItemToEntity(tag)
    if tag.connection then
        self.connected = tag.connection
    end
    if tag.nametag then
        self.nametag = tag.nametag
    end
    if self.connected and global.entityTable[self.connected] then
        global.entityTable[self.connected].connected = self.thisEntity.unit_number
        global.entityTable[self.connected]:force_controller_update()
    end
    self:force_controller_update()
end

function TR:DataConvert_EntityToItem(tag)
    local tags = {}
    local description = {"", tag.prototype.localised_description}

    if self.connected then
        tags.connection = self.connected
        local obj = global.entityTable[self.connected]
        Util.add_list_into_table(description, {{"item-description.RNS_TransReceiverConnectionTag"}, obj and obj.nametag or ""})
    end

    tags.nametag = self.nametag
    Util.add_list_into_table(description, {{"item-description.RNS_TransReceiverNameTag"}, self.nametag})

    tag.set_tag(Constants.Settings.RNS_Tag, tags)
    tag.custom_description = description
end

--Tooltips
function TR:getTooltips(guiTable, mainFrame, justCreated)
    if justCreated == true then
        guiTable.vars.Gui_Title.caption = self.type == "transmitter" and {"gui-description.RNS_NetworkTransmitter_Title"} or {"gui-description.RNS_NetworkReceiver_Title"}

        local infoFrame = GuiApi.add_frame(guiTable, "InformationFrame", mainFrame, "vertical", true)
		infoFrame.style = Constants.Settings.RNS_Gui.frame_1
		infoFrame.style.vertically_stretchable = true
		infoFrame.style.minimal_width = 200
		infoFrame.style.left_margin = 3
		infoFrame.style.left_padding = 3
		infoFrame.style.right_padding = 3

        GuiApi.add_subtitle(guiTable, "", infoFrame, {"gui-description.RNS_NameTag"})
        local infoFlow = GuiApi.add_flow(guiTable, "", infoFrame, "vertical")
        infoFlow.style.horizontal_align = "center"
        --GuiApi.add_label(guiTable, "", infoFlow, {"gui-description.RNS_TransReceiver_ID", self.thisEntity.unit_number, self.thisEntity.surface.name, tostring(serpent.line(self.thisEntity.position))}, Constants.Settings.RNS_Gui.white)
        local nameFlow = GuiApi.add_flow(guiTable, "nameFlow", infoFlow, "horizontal", true)
        nameFlow.style.vertical_align = "center"

        self:make_name_label(guiTable, nameFlow)
        
        GuiApi.add_line(guiTable, "", infoFlow, "horizontal")
        if self.connected then
            if global.entityTable[self.connected] == nil or global.entityTable[self.connected].thisEntity == nil or global.entityTable[self.connected].thisEntity.valid == false then
                self.connected = nil
            end
        end

        GuiApi.add_subtitle(guiTable, "", infoFlow, {"gui-description.RNS_Connections"})

        local selected = 1
        local index = 1
        local values = {""}
        for id, obj in pairs(BaseNet.get_transreciever_from_global(self.type == "transmitter" and "receiver" or "transmitter")) do
            if obj.thisEntity.valid then
                index = index + 1
                table.insert(values, obj.nametag)
                if self.connected and self.connected == id then selected = index end
            end
        end

        GuiApi.add_label(guiTable, "Connection", infoFlow, self.type == "transmitter" and (self.connected and {"gui-description.RNS_TransReceiver_Available_Receivers_Connected"} or {"gui-description.RNS_TransReceiver_Available_Receivers_Disconnected"}) or (self.connected and {"gui-description.RNS_TransReceiver_Available_Transmitters_Connected"} or {"gui-description.RNS_TransReceiver_Available_Transmitters_Disconnected"}), Constants.Settings.RNS_Gui.white, "", true)
        GuiApi.add_dropdown(guiTable, "RNS_TransReceiver_Channels", infoFlow, values, selected, false, "", {ID=self.thisEntity.unit_number})
        --[[if self.type == "transmitter" then
            local xflow = GuiApi.add_flow(guiTable, "", infoFrame, "horizontal")
            GuiApi.add_label(guiTable, "", xflow, {"gui-description.RNS_xPos"}, Constants.Settings.RNS_Gui.white)
            local xPos = GuiApi.add_text_field(guiTable, "RNS_TransReceiver_xPos", xflow, self.receiver.position.x == nil and "" or tostring(self.receiver.position.x), {"gui-description.RNS_xPos_tooltip"}, true, true, true, true, false, {ID=self.thisEntity.unit_number})
            xPos.style.maximal_width = 50

            local yflow = GuiApi.add_flow(guiTable, "", infoFrame, "horizontal")
            GuiApi.add_label(guiTable, "", yflow, {"gui-description.RNS_yPos"}, Constants.Settings.RNS_Gui.white)
            local yPos = GuiApi.add_text_field(guiTable, "RNS_TransReceiver_yPos", yflow, self.receiver.position.y == nil and "" or tostring(self.receiver.position.y), {"gui-description.RNS_yPos_tooltip"}, true, true, true, true, false, {ID=self.thisEntity.unit_number})
            yPos.style.maximal_width = 50

            local surfIDflow = GuiApi.add_flow(guiTable, "", infoFrame, "horizontal")
            GuiApi.add_label(guiTable, "", surfIDflow, {"gui-description.RNS_ReceiverSurfaceID"}, Constants.Settings.RNS_Gui.white)
            local surfID = GuiApi.add_text_field(guiTable, "RNS_TransReceiver_SurfaceID", surfIDflow, self.receiver.surface == nil and "" or tostring(self.receiver.surface), {"gui-description.RNS_ReceiverSurfaceID_tooltip"}, true, true, false, false, false, {ID=self.thisEntity.unit_number})
            surfID.style.maximal_width = 50
        else
            GuiApi.add_label(guiTable, "", infoFrame, {"gui-description.RNS_Position", self.thisEntity.position.x, self.thisEntity.position.y}, Constants.Settings.RNS_Gui.white, "", false)
            GuiApi.add_label(guiTable, "", infoFrame, {"gui-description.RNS_Surface", self.thisEntity.surface.index}, Constants.Settings.RNS_Gui.white, "", false)
        end]]
    end
    guiTable.vars.Connection.caption = self.type == "transmitter" and (self.connected and {"gui-description.RNS_TransReceiver_Available_Receivers_Connected"} or {"gui-description.RNS_TransReceiver_Available_Receivers_Disconnected"}) or (self.connected and {"gui-description.RNS_TransReceiver_Available_Transmitters_Connected"} or {"gui-description.RNS_TransReceiver_Available_Transmitters_Disconnected"})
end

function TR:make_name_label(guiTable, nameFlow)
    nameFlow.clear()
    local nameLabel = GuiApi.add_label(guiTable, "RNS_TransReceiver_Name_Label", nameFlow, self.nametag, Constants.Settings.RNS_Gui.white)
    nameLabel.style.horizontally_squashable = true

    local nameButton = GuiApi.add_button(guiTable, "RNS_TransReceiver_Name_Button", nameFlow, "utility/rename_icon_normal", nil, nil, "", 30, false, true, nil, "mini_button_aligned_to_text_vertically_when_centered", {ID=self.entID})
    nameButton.mouse_button_filter = {"left"}
end

function TR:make_name_change(guiTable, nameFlow)
    nameFlow.clear()
    local text = self.nametag[1] == "gui-description.RNS_TransReceiver_ID" and --[[("ID: "..self.nametag[2].."Surface: "..self.nametag[3].."Pos: "..self.nametag[4])]]"" or self.nametag[2]
    local nameText = GuiApi.add_text_field(guiTable, "RNS_TransReceiver_Name_Text", nameFlow, text, "", true, false, false, false, false, {ID = self.entID})
    nameText.clear_and_focus_on_right_click = true
    nameText.style.horizontally_stretchable = true
    nameText.style.maximal_width = 0
    nameText.select_all()
    nameText.focus()

    local elementButton = GuiApi.add_element_button(guiTable, "RNS_TransReceiver_Element_Button", nameFlow, "", false, "signal", {type="virtual", name=Constants.Icons.select_icon_white}, 30, {ID = self.entID})
    --elementButton.style = Constants.Settings.RNS_Gui.button_1
    --elementButton.style.height = 30
    --elementButton.style.width = 30
    local checkMark = GuiApi.add_button(guiTable, "RNS_TransReceiver_Checkmark", nameFlow, Constants.Icons.check_mark.name, Constants.Icons.check_mark.name, Constants.Icons.check_mark.name, {"gui-description.RNS_Confirm"}, 30, false, true, nil, nil, {ID=self.thisEntity.unit_number})
    checkMark.mouse_button_filter = {"left"}
    --checkMark.style = Constants.Settings.RNS_Gui.button_1
    --checkMark.style.height = 30
    --checkMark.style.width = 30
end

function TR:force_controller_update()
    BaseNet.update_network_controller(self.networkController, self.entID)
end

function TR.interaction(event, RNSPlayer)
    local guiTable = RNSPlayer.GUI[Constants.Settings.RNS_Gui.tooltip]
    if string.match(event.element.name, "RNS_TransReceiver_Channels") and event.name ~= defines.events.on_gui_click then
		local obj = global.entityTable[event.element.tags.ID]
		if obj == nil then return end
        local selected_index = event.element.selected_index
        local selected = event.element.items[selected_index]
        if selected == "" then
            global.entityTable[obj.connected].connected = nil
            global.entityTable[obj.connected]:force_controller_update()
            obj.connected = nil
            obj:force_controller_update()
        else
            local number = selected[1] == "gui-description.RNS_TransReceiver_ID" and selected[2] or selected[3]
            obj.connected = tonumber(number)
            global.entityTable[obj.connected].connected = obj.thisEntity.unit_number
            global.entityTable[obj.connected]:force_controller_update()
            obj:force_controller_update()
        end
		return
	elseif string.match(event.element.name, "RNS_TransReceiver_Name_Button") then
		local obj = global.entityTable[event.element.tags.ID]
		if obj == nil then return end
            obj:make_name_change(guiTable, guiTable.vars["nameFlow"])
		return
	elseif string.match(event.element.name, "RNS_TransReceiver_Element_Button") and event.name ~= defines.events.on_gui_click then
		local obj = global.entityTable[event.element.tags.ID]
		if obj == nil then return end
            guiTable.vars["RNS_TransReceiver_Name_Text"].text = guiTable.vars["RNS_TransReceiver_Name_Text"].text .. Util.signal_to_rich_text(event.element.elem_value)
            guiTable.vars["RNS_TransReceiver_Name_Text"].focus()
            event.element.elem_value = {
                type = "virtual",
                name = Constants.Icons.select_icon_white
              }
		return
	elseif string.match(event.element.name, "RNS_TransReceiver_Checkmark") then
		local obj = global.entityTable[event.element.tags.ID]
		if obj == nil then return end
        if guiTable.vars["RNS_TransReceiver_Name_Text"].text == "" then
            obj.nametag = {"gui-description.RNS_TransReceiver_ID", obj.thisEntity.unit_number, obj.thisEntity.surface.name, tostring(serpent.line(obj.thisEntity.position))}
        else
            obj.nametag = {"gui-description.RNS_TransReceiver_Name", guiTable.vars["RNS_TransReceiver_Name_Text"].text, obj.thisEntity.unit_number}
        end
        obj:make_name_label(guiTable, guiTable.vars["nameFlow"])
		return
    --[[elseif string.match(event.element.name, "xPos") then
		local obj = global.entityTable[event.element.tags.ID]
		if obj == nil then return end
        if event.element.text ~= "" then
            obj.receiver.position.x = tonumber(event.element.text)
        else
            obj.receiver.position.x = nil
        end
        obj:force_controller_update()
		return
	elseif string.match(event.element.name, "yPos") then
		local obj = global.entityTable[event.element.tags.ID]
		if obj == nil then return end
        if event.element.text ~= "" then
            obj.receiver.position.y = tonumber(event.element.text)
        else
            obj.receiver.position.y = nil
        end
        obj:force_controller_update()
		return
	elseif string.match(event.element.name, "SurfaceID") then
		local obj = global.entityTable[event.element.tags.ID]
		if obj == nil then return end
        if event.element.text ~= "" then
            obj.receiver.surface = tonumber(event.element.text)
        else
            obj.receiver.surface = nil
        end
        obj:force_controller_update()
		return]]
	end
end