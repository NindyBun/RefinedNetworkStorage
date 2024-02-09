TR = {
    thisEntity = nil,
    entID = nil,
    networkController = nil,
    connectedObjs = nil,
    cardinals = nil,
    type = "",
    receiver = nil,
    powerUsage = 2560
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
    t.connectedObjs = {
        [1] = {}, --N
        [2] = {}, --E
        [3] = {}, --S
        [4] = {}, --W
        [5] = {}  --Receiver
    }
    t.receiver = {
        position = {x=nil, y=nil},
        surface = nil
    }
    t.cardinals = {
        [1] = false, --N
        [2] = false, --E
        [3] = false, --S
        [4] = false, --W
        [5] = false  --Receiver
    }
    UpdateSys.add_to_entity_table(t)
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
    --UpdateSys.remove(self)
    --[[if self.networkController ~= nil then
        if self.type == "transmitter" then
            self.networkController.network.TransmitterTable[1][self.entID] = nil
        else
            self.networkController.network.ReceiverTable[1][self.entID] = nil
        end
        self.networkController.network.shouldRefresh = true
    end]]
    BaseNet.update_network_controller(self.networkController)
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
            if ent ~= nil and ent.valid == true and string.match(ent.name, "RNS_") ~= nil and global.entityTable[ent.unit_number] ~= nil then
                local obj = global.entityTable[ent.unit_number]
                if (string.match(obj.thisEntity.name, "RNS_NetworkCableIO") ~= nil and obj:getConnectionDirection() == area.direction) or (string.match(obj.thisEntity.name, "RNS_NetworkCableRamp") ~= nil and obj:getConnectionDirection() == area.direction) or obj.thisEntity.name == Constants.WirelessGrid.name then
                    --Do nothing
                else
                    table.insert(self.connectedObjs[area.direction], obj)
                    if obj.thisEntity.name == Constants.NetworkController.main.name then
                        self.networkController = obj
                    else
                        self.networkController = obj.networkController
                    end
                    --[[if self.cardinals[area.direction] == false then
                        self.cardinals[area.direction] = true
                        if valid(self.networkController) == true and self.networkController.thisEntity ~= nil and self.networkController.thisEntity.valid == true then
                            self.networkController.network.shouldRefresh = true
                        elseif obj.thisEntity.name == Constants.NetworkController.main.name then
                            obj.network.shouldRefresh = true
                        end
                    end]]
                end
            end
        end
        --[[if self.cardinals[area.direction] == true and enti == 0 then
            self.cardinals[area.direction] = false
            if valid(self.networkController) == true and self.networkController.thisEntity ~= nil and self.networkController.thisEntity.valid == true then
                self.networkController.network.shouldRefresh = true
            end
        end]]
    end
    if self.type ~= "transmitter" then return end
    if self.receiver.surface == nil or (self.receiver.surface ~= nil and game.surfaces[self.receiver.surface] == nil) then return end
    if self.receiver.position.x == nil or self.receiver.position.y == nil then return end

    local rec = game.surfaces[self.receiver.surface].find_entity(Constants.NetworkTransReceiver.receiver.name, self.receiver.position)
    if rec ~= nil and global.entityTable[rec.unit_number] ~= nil then
        self.connectedObjs[5] = {global.entityTable[rec.unit_number]}
        --[[if self.cardinals[5] == false then
            self.cardinals[5] = true
            if valid(self.networkController) == true and self.networkController.thisEntity ~= nil and self.networkController.thisEntity.valid == true then
                self.networkController.network.shouldRefresh = true
            end
        end
    else
        if self.cardinals[5] == true then
            self.cardinals[5] = false
            if valid(self.networkController) == true and self.networkController.thisEntity ~= nil and self.networkController.thisEntity.valid == true then
                self.networkController.network.shouldRefresh = true
            end
        end]]
    end
    
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

        GuiApi.add_subtitle(guiTable, "", infoFrame, {"gui-description.RNS_Information"})

        if self.type == "transmitter" then
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
        end
    end
end

function TR:force_controller_update()
    BaseNet.update_network_controller(self.networkController)
end

function TR.interaction(event, RNSPlayer)
    if string.match(event.element.name, "xPos") then
		local obj = global.entityTable[event.element.tags.ID]
		if obj == nil then return end
        if event.element.text ~= "" then
            obj.receiver.position.x = tonumber(event.element.text)
        else
            obj.receiver.position.x = nil
        end
        obj:force_controller_update()
		return
	end
    if string.match(event.element.name, "yPos") then
		local obj = global.entityTable[event.element.tags.ID]
		if obj == nil then return end
        if event.element.text ~= "" then
            obj.receiver.position.y = tonumber(event.element.text)
        else
            obj.receiver.position.y = nil
        end
        obj:force_controller_update()
		return
	end
	if string.match(event.element.name, "SurfaceID") then
		local obj = global.entityTable[event.element.tags.ID]
		if obj == nil then return end
        if event.element.text ~= "" then
            obj.receiver.surface = tonumber(event.element.text)
        else
            obj.receiver.surface = nil
        end
        obj:force_controller_update()
		return
	end
end