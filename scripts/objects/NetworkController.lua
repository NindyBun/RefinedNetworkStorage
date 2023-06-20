--NetworkController object
NC = {
    thisEntity = nil,
    entID = nil,
    updateTick = 300,
    lastUpdate = 0,
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
    t.network = t.network or BaseNet:new()
    t.varTable = {}
    t.network.networkController = t
    UpdateSys.addEntity(t)
    return t
end

--Reconstructor
function NC:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt._index = NC
    setmetatable(object, mt)
    BaseNet:rebuild(object.network)
end

--Deconstructor
function NC:remove()
    global.networkID[self.network+1].used = false
    UpdateSys.remove(self)
end
--Is valid
function NC:valid()
    if self.thisEntity ~= nil and self.thisEntity.valid then return true end
	return false
end

function NC:update()
    self.lastUpdate = game.tick
    local powerDraw = self.network:getTotalObjects()+1
    local maxPowerDraw = powerDraw*2
    game.print(self.thisEntity.energy_usage)
    self.thisEntity.energy_usage = powerDraw.."KW"
    self.thisEntity.energy_source.buffer_capacity = (maxPowerDraw+1).."KW"
end

--Tooltips
function NC:getTooltips(GUI)
    
end