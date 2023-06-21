--RNSPlayer object
RNSP = {
    thisEntity = nil,
    entID = nil,
    name = nil,
    networkID = nil,
    GUI = nil,
    varTable = nil,
    lastTick = 0
}

--Constructor
function RNSP:new(player)
    if player == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt) --this is necessary for all objects so the objects can be reloaded when the save loads up
    mt.__index = RNSP
    t.thisEntity = player
    t.entID = player.index
    t.name = player.name
    t.GUI = {}
    t.varTable = {}
    UpdateSys.addEntity(t)
    return t
end

--Reconstructor
function RNSP:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = RNSP
    setmetatable(object, mt)
end

function RNSP:update()
    self.lastTick = game.tick
end

--Deconstructor
function RNSP:remove()
    
end

--Is valid
function RNSP:valid()
    return true
end

--Tooltips
function RNSP:getTooltips(GUI)
    
end