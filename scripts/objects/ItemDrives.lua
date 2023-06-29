ID = {
    thisEntity = nil,
    entID = nil,
    networkController = nil,
    maxStorage = 0,
    storage = nil,
    updateTick = 60,
    lastUpdate = 0,
}

function ID:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = ID
    t.thisEntity = object
    t.entID = object.unit_number
    if object.name == Constants.Drives.ItemDrive1k.name then
        t.maxStorage = Constants.Drives.ItemDrive1k.max_size
    elseif object.name == Constants.Drives.ItemDrive4k.name then
        t.maxStorage = Constants.Drives.ItemDrive4k.max_size
    elseif object.name == Constants.Drives.ItemDrive16k.name then
        t.maxStorage = Constants.Drives.ItemDrive16k.max_size
    elseif object.name == Constants.Drives.ItemDrive64k.name then
        t.maxStorage = Constants.Drives.ItemDrive64k.max_size
    end
    t.storage = {}
    UpdateSys.addEntity(t)
    return t
end

function ID:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = ID
    setmetatable(object, mt)
end

function ID:remove()
    UpdateSys.remove(self)
    if self.networkController ~= nil then
        self.networkController.network.ItemDriveTable[self.entID] = nil
        self.networkController.network.shouldRefresh = true
    end
end

function ID:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function ID:update()
    self.lastUpdate = game.tick
    if self:valid() == false then
        self:remove()
        return
    end
end

function ID:validate()
    for n, c in pairs(self.storage) do
        if n ~= nil and game.item_prototypes[n] == nil then
            n = nil
            c = 0
        end
    end
end

function ID:getStorageSize()
    local count = 0
    for _, c in pairs(self.storage) do
        count = count + c
    end
    return count
end

function ID:getRemainingStorageSize()
    return self.maxStorage - self:getStorageSize()
end

function ID:DataConvert_ItemToEntity(tag)
    self.storage = tag or {}
end

function ID:DataConvert_EntityToItem(tag)
    if self.storage ~= nil then
        if self:getStorageSize() == 0 then return end
        tag.set_tag(Constants.Settings.RNS_Tag, self.storage)
        tag.custom_description = {"", tag.prototype.localised_description, {"item-description.RNS_ItemDriveTag", self:getStorageSize(), self.maxStorage}}
    end
end

function ID:getTooltips()
end