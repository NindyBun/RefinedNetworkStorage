FD = {
    thisEntity = nil,
    entID = nil,
    networkController = nil,
    maxStorage = 0,
    storage = nil,
    connectedObjs = nil,
    cardinals = nil,
    updateTick = 60,
    lastUpdate = 0,
}

function FD:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = FD
    t.thisEntity = object
    t.entID = object.unit_number
    if object.name == Constants.Drives.FluidDrive.FluidDrive4k.name then
        t.maxStorage = Constants.Drives.FluidDrive.FluidDrive4k.max_size
    elseif object.name == Constants.Drives.FluidDrive.FluidDrive16k.name then
        t.maxStorage = Constants.Drives.FluidDrive.FluidDrive16k.max_size
    elseif object.name == Constants.Drives.FluidDrive.FluidDrive64k.name then
        t.maxStorage = Constants.Drives.FluidDrive.FluidDrive64k.max_size
    elseif object.name == Constants.Drives.FluidDrive.FluidDrive256k.name then
        t.maxStorage = Constants.Drives.FluidDrive.FluidDrive256k.max_size
    end
    t.storage = {}
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

function FD:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = FD
    setmetatable(object, mt)
end

function FD:remove()
    UpdateSys.remove(self)
    if self.networkController ~= nil then
        self.networkController.network.FluidDriveTable[self.entID] = nil
        self.networkController.network.shouldRefresh = true
    end
end

function FD:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function FD:update()
    self.lastUpdate = game.tick
    if valid(self) == false then
        self:remove()
        return
    end
    if self.thisEntity.to_be_deconstructed() == true then return end
    self:collect()
end

function FD:resetCollection()
    self.connectedObjs = {
        [1] = {}, --N
        [2] = {}, --E
        [3] = {}, --S
        [4] = {}, --W
    }
end

function FD:getCheckArea()
    local x = self.thisEntity.position.x
    local y = self.thisEntity.position.y
    return {
        [1] = {direction = 1, startP = {x-1.0, y-2.0}, endP = {x+1.0, y-1.0}}, --North
        [2] = {direction = 2, startP = {x+1.0, y-1.0}, endP = {x+2.0, y+1.0}}, --East
        [4] = {direction = 4, startP = {x-1.0, y+1.0}, endP = {x+1.0, y+2.0}}, --South
        [3] = {direction = 3, startP = {x-2.0, y-1.0}, endP = {x-1.0, y+1.0}}, --West
    }
end

function FD:collect()
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

function FD:validate()
    for n, c in pairs(self.storage) do
        if n ~= nil and game.fluid_prototypes[n] == nil then
            n = nil
            c = nil
        end
    end
end

function FD:getStorageSize()
    local count = 0
    for _, c in pairs(self.storage) do
        count = count + c.amount
    end
    return count
end

function FD:getRemainingStorageSize()
    return self.maxStorage - self:getStorageSize()
end

function FD:DataConvert_ItemToEntity(tag)
    self.storage = tag or {}
end

function FD:DataConvert_EntityToItem(tag)
    if self.storage ~= nil then
        if self:getStorageSize() == 0 then return end
        tag.set_tag(Constants.Settings.RNS_Tag, self.storage)
        tag.custom_description = {"", tag.prototype.localised_description, {"item-description.RNS_FluidDriveTag", self:getStorageSize(), self.maxStorage}}
    end
end

function FD:getTooltips(guiTable, mainFrame, justCreated)
    if justCreated == true then
        guiTable.vars.Gui_Title.caption = {"gui-description.RNS_FluidDrive_Title"}
        local infoFrame = GuiApi.add_frame(guiTable, "InformationFrame", mainFrame, "vertical", true)
        infoFrame.style = Constants.Settings.RNS_Gui.frame_1
        infoFrame.style.vertically_stretchable = true
        infoFrame.style.minimal_width = 200
        infoFrame.style.left_margin = 3
        infoFrame.style.left_padding = 3
        infoFrame.style.right_padding = 3
        GuiApi.add_subtitle(guiTable, "", infoFrame, {"gui-description.RNS_Information"})
        --GuiApi.add_label(guiTable, "Capacity", infoFrame, {"gui-description.RNS_FluidDrive_Capacity", self:getStorageSize(), self.maxStorage}, Constants.Settings.RNS_Gui.orange, nil, true)
    end

    local infoFrame = guiTable.vars.InformationFrame
    GuiApi.add_label(guiTable, "Capacity", infoFrame, {"gui-description.RNS_ItemDrive_Capacity", self:getStorageSize(), self.maxStorage}, Constants.Settings.RNS_Gui.orange, nil, true)
end