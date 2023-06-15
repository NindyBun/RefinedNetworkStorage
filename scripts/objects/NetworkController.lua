--NetworkController object
NC = {
    thisEntity = nil,
    entID = nil,
    updateTick = 300,
    lastUpdate = 0,
    network = nil,
    ItemDriveTable = nil,
    FluidDriveTable = nil,
    varTable = nil
}

--Constructor
function NC:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt._index = NC
    t.thisEntity = object
    t.entID = object.unit_number
    t.ItemDriveTable = {}
    t.FluidDriveTable = {}
    t.network = getNextAvailableNetworkID()
    t.varTable = {}
    UpdateSys.addObject(t)
    return t
end

--Reconstructor
function NC:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt._index = NC
    setmetatable(object, mt)
end

--Deconstructor
function NC:remove()
    global.networkID[self.network+1].used = false
    UpdateSys.removeObj(self)
end
--Is valid
function NC:isValid()
    return self.thisEntity ~= nil and self.thisEntity.valid
end

function NC:update()
    self.lastUpdate = game.tick
end

--Tooltips
function NC:getTooltips(GUI)
    
end