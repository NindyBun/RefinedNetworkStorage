--RNSPlayer object
RNSP = {
    thisEntity = nil,
    entID = nil,
    name = nil,
    networkID = nil,
    GUI = nil,
    varTable = nil
}

--Constructor
function RNSP:new(player)
    if player == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt) --this is necessary for all objects so the objects can be reloaded when the save loads up
    mt._index = RNSP
    t.thisEntity = player
    t.index = player.index
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
    mt._index = RNSP
    setmetatable(object, mt)
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