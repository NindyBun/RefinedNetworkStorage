FD = {
    thisEntity = nil,
    entID = nil,
    networkController = nil,
    maxStorage = 0,
    storage = nil,
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
    if object.name == Constants.Drives.FluidDrive4k.name then
        t.maxStorage = Constants.Drives.FluidDrive4k.max_size
    elseif object.name == Constants.Drives.FluidDrive16k.name then
        t.maxStorage = Constants.Drives.FluidDrive16k.max_size
    elseif object.name == Constants.Drives.FluidDrive64k.name then
        t.maxStorage = Constants.Drives.FluidDrive64k.max_size
    elseif object.name == Constants.Drives.FluidDrive256k.name then
        t.maxStorage = Constants.Drives.FluidDrive256k.max_size
    end
    t.storage = {}
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
        self.networkController.network.ItemDriveTable[self.entID] = nil
        self.networkController.network.shouldRefresh = true
    end
end

function FD:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function FD:update()
    self.lastUpdate = game.tick
    if self:valid() == false then
        self:remove()
        return
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

function FD:getTooltips()
end