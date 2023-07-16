NII = {
    thisEntity = nil,
    entID = nil,
    networkController = nil,
    connectedObjs = nil,
    cardinals = nil,
    updateTick = 60,
    lastUpdate = 0,
}

function NII:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = NII
    t.thisEntity = object
    t.entID = object.unit_number
    t.cardinals = {
        [1] = false, --N
        [2] = false, --E
        [3] = false, --S
        [4] = false, --W
    }
    t.connectedObjs = {
        [1] = {}, --N
        [2] = {}, --E
        [3] = {}, --S
        [4] = {}, --W
    }
    t:collect()
    UpdateSys.addEntity(t)
    return t
end

function NII:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = NII
    setmetatable(object, mt)
end

function NII:remove()
    UpdateSys.remove(self)
    if self.networkController ~= nil then
        self.networkController.network.NetworkInventoryInterfaceTable[self.entID] = nil
        self.networkController.network.shouldRefresh = true
    end
end

function NII:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function NII:update()
    self.lastUpdate = game.tick
    if valid(self) == false then
        self:remove()
        return
    end
    if self.thisEntity.to_be_deconstructed() == true then return end
    self:collect()
end

function NII:resetCollection()
    self.connectedObjs = {
        [1] = {}, --N
        [2] = {}, --E
        [3] = {}, --S
        [4] = {}, --W
    }
end

function NII:getCheckArea()
    local x = self.thisEntity.position.x
    local y = self.thisEntity.position.y
    return {
        [1] = {direction = 1, startP = {x-0.5, y-1.5}, endP = {x+0.5, y-0.5}}, --North
        [2] = {direction = 2, startP = {x+0.5, y-0.5}, endP = {x+1.5, y+0.5}}, --East
        [4] = {direction = 4, startP = {x-0.5, y+0.5}, endP = {x+0.5, y+1.5}}, --South
        [3] = {direction = 3, startP = {x-1.5, y-0.5}, endP = {x-0.5, y+0.5}}, --West
    }
end

function NII:collect()
    local areas = self:getCheckArea()
    self:resetCollection()
    for _, area in pairs(areas) do
        local enti = 0
        local ents = self.thisEntity.surface.find_entities_filtered{area={area.startP, area.endP}}
        for _, ent in pairs(ents) do
            if ent ~= nil and ent.valid == true and string.match(ent.name, "RNS_") ~= nil and global.entityTable[ent.unit_number] ~= nil and ent.operable then
                local obj = global.entityTable[ent.unit_number]
                if string.match(obj.thisEntity.name, "RNS_NetworkCableIO") ~= nil and obj:getConnectionDirection() == area.direction then
                    --Do nothing
                else
                    table.insert(self.connectedObjs[area.direction], obj)
                    enti = enti + 1

                    if self.cardinals[area.direction] == false then
                        self.cardinals[area.direction] = true
                        if valid(self.networkController) == true and self.networkController.thisEntity ~= nil and self.networkController.thisEntity.valid == true then
                            self.networkController.network.shouldRefresh = true
                        elseif obj.thisEntity.name == Constants.NetworkController.slateEntity.name then
                            obj.network.shouldRefresh = true
                        end
                    end
                end
            end
        end
        if self.cardinals[area.direction] == true and enti == 0 then
            self.cardinals[area.direction] = false
            if valid(self.networkController) == true and self.networkController.thisEntity ~= nil and self.networkController.thisEntity.valid == true then
                self.networkController.network.shouldRefresh = true
            end
        end
    end
end

function NII:getTooltips(guiTable, mainFrame, justCreated)
    if justCreated == true then
        guiTable.vars.Gui_Title.caption = {"gui-description.RNS_NetworkInventoryInterface_Title"}
        local infoFrame = GuiApi.add_frame(guiTable, "InformationFrame", mainFrame, "vertical", true)
		infoFrame.style = Constants.Settings.RNS_Gui.frame_1
		infoFrame.style.vertically_stretchable = true
		infoFrame.style.minimal_width = 200
		infoFrame.style.left_margin = 3
		infoFrame.style.left_padding = 3
		infoFrame.style.right_padding = 3
		GuiApi.add_subtitle(guiTable, "", infoFrame, {"gui-description.RNS_Information"})
        --GuiApi.add_label(guiTable, "Capacity", infoFrame, {"gui-description.RNS_ItemDrive_Capacity", self:getStorageSize(), self.maxStorage}, Constants.Settings.RNS_Gui.orange, nil, true)
    end
end