TR = {
    thisEntity = nil,
    entID = nil,
    networkController = nil,
    connectedObjs = nil,
    type = ""
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
        [5] = {}  --Reciever
    }
    t:collect()
    UpdateSys.addEntity(t)
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
    UpdateSys.remove(self)
    if self.networkController ~= nil then
        self.networkController.network.TransReceiverTable[1][self.entID] = nil
        self.networkController.network.shouldRefresh = true
    end
end
--Is valid
function TR:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function TR:update()
    if valid(self) == false then
        self:remove()
        return
    end
    if self.thisEntity.to_be_deconstructed() == true then return end
    self:collect()
end

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

function TR:collect()
    local areas = self:getCheckArea()
    self:resetCollection()
    for _, area in pairs(areas) do
        local ents = self.thisEntity.surface.find_entities_filtered{area={area.startP, area.endP}}
        for _, ent in pairs(ents) do
            if ent ~= nil and ent.valid == true and string.match(ent.name, "RNS_") ~= nil and ent.operable then
                if global.entityTable[ent.unit_number] ~= nil then
                    local obj = global.entityTable[ent.unit_number]
                    if (string.match(obj.thisEntity.name, "RNS_NetworkCableIO") ~= nil and obj:getConnectionDirection() == area.direction) or (string.match(obj.thisEntity.name, "RNS_NetworkCableRamp") ~= nil and obj:getConnectionDirection() == area.direction) or obj.thisEntity.name == Constants.WirelessGrid.name then
                        --Do nothing
                    else
                        table.insert(self.connectedObjs[area.direction], obj)
                    end
                end
            end
        end
    end
end

--Tooltips
function TR:getTooltips(guiTable, mainFrame, justCreated)
    if justCreated == true then
        guiTable.vars.Gui_Title.caption = {"gui-description.RNS_NetworkTransReceiver_Title"}
        mainFrame.style.height = 450

        local infoFrame = GuiApi.add_frame(guiTable, "InformationFrame", mainFrame, "vertical", true)
		infoFrame.style = Constants.Settings.RNS_Gui.frame_1
		infoFrame.style.vertically_stretchable = true
		infoFrame.style.minimal_width = 200
		infoFrame.style.left_margin = 3
		infoFrame.style.left_padding = 3
		infoFrame.style.right_padding = 3

        GuiApi.add_subtitle(guiTable, "", infoFrame, {"gui-description.RNS_Information"})
    end

end