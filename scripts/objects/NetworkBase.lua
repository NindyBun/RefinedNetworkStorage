--This will manage store related blocks for the Network Controller to see and for things that import/export 
BaseNet = {
    ID = nil,
    networkController = nil,
    ItemDriveTable = nil,
    FluidDriveTable = nil,
    NetworkInventoryInterfaceTable = nil,
    updateTick = 200,
    lastUpdate = 0
}

function BaseNet:new()
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = BaseNet
    t.ItemDriveTable = {}
    t.FluidDriveTable = {}
    t.NetworkInventoryInterfaceTable = {}
    t.ID = getNextAvailableNetworkID()
    UpdateSys.addEntity(t)
    return t
end

function BaseNet:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = BaseNet
    setmetatable(object, mt)
end

function BaseNet:remove() end

function BaseNet:valid()
    return true
end

function BaseNet:update()
    self.lastUpdate = game.tick
end

function BaseNet:getTooltips()
    
end

--Get connected objects
function BaseNet:getTotalObjects()
    return #self.ItemDriveTable + #self.FluidDriveTable + #self.NetworkInventoryInterfaceTable
end