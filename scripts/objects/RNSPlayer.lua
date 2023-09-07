--RNSPlayer object
RNSP = {
    thisEntity = nil,
    entID = nil,
    name = nil,
    networkID = nil,
    GUI = nil,
    varTable = nil,
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
    if self.thisEntity.selected == nil then return end
    local entity = self.thisEntity.selected
    if string.match(entity.name, "RNS_NetworkCableIO") then
        local obj = global.entityTable[entity.unit_number]
        if obj.valid and obj ~= nil and obj.toggleHoverIcon then
            obj:toggleHoverIcon(true)
        end
    end
end

--Deconstructor
function RNSP:remove()
    
end

--Is valid
function RNSP:valid()
    return true
end

function RNSP:has_room()
    local inv = self.thisEntity.get_main_inventory()
    for i = 1, #inv do
        if inv[i].count <= 0 then return true end
    end
    if not self.thisEntity.get_main_inventory().is_full() then return true end
    if self.thisEntity.get_main_inventory().is_empty() then return true end
    return false
end

function RNSP:has_empty_slot()
    local inv = self.thisEntity.get_main_inventory()
    for i = 1, #inv do
        if inv[i].count <= 0 then return true end
    end
    return false
end

function RNSP:get_inventory()
    local contents = {}
    local inv = self.thisEntity.get_main_inventory()
    for i = 1, #inv do
        local itemstack = inv[i]
        if itemstack.count <= 0 then goto continue end
        Util.add_or_merge(itemstack, contents)
        ::continue::
    end
    return contents
end

function RNSP:pull_varTable(name)
    local exists = self.varTable[name]
    if exists ~= nil then self.varTable[name] = nil end
    return exists
end

function RNSP:push_varTable(name, value)
    self.varTable[name] = value
end

--Tooltips
function RNSP:getTooltips(guiTable, mainFrame, justCreated)
    
end