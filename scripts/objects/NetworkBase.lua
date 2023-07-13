--This will manage store related blocks for the Network Controller to see and for things that import/export 
BaseNet = {
    networkController = nil,
    ItemDriveTable = nil,
    FluidDriveTable = nil,
    ItemIOTable = nil,
    FluidIOTable = nil,
    shouldRefresh = false,
    updateTick = 200,
    lastUpdate = 0
}

function BaseNet:new()
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = BaseNet
    t:resetTables()
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

function BaseNet:resetTables()
    self.ItemDriveTable = {}
    self.FluidDriveTable = {}
    self.ItemIOTable = {}
    self.FluidIOTable = {}
end

--Refreshes laser connections
function BaseNet:doRefresh(controller)
    self:resetTables()
    addConnectables(controller, {}, controller)
    self.shouldRefresh = false
end

function addConnectables(source, connections, master)
    if valid(source) == false then return end
    if source.thisEntity == nil and source.thisEntity.valid == false then return end
    if source.connectedObjs == nil and source.connectedObjs.valid == false then return end
    for _, connected in pairs(source.connectedObjs) do
        for _, con in pairs(connected) do
            if valid(con) == false then goto continue end
            --if con.thisEntity.to_be_deconstructed() == true then goto continue end
            if con.thisEntity == nil and con.thisEntity.valid == false then goto continue end
            if connections[con.entID] ~= nil then goto continue end

            if con.thisEntity.name == Constants.NetworkController.slateEntity.name and con.entID ~= master.entID then
                con.thisEntity.order_deconstruction("player")
                goto continue
            end

            con.networkController = master
            connections[con.entID] = con

            if string.match(con.thisEntity.name, "RNS_ItemDrive") ~= nil then
                master.network.ItemDriveTable[con.entID] = con
            elseif string.match(con.thisEntity.name, "RNS_FluidDrive") ~= nil then
                master.network.FluidDriveTable[con.entID] = con
            elseif con.thisEntity.name == Constants.NetworkCables.itemIO.slateEntity.name then
                master.network.ItemIOTable[con.entID] = con
            elseif con.thisEntity.name == Constants.NetworkCables.fluidIO.slateEntity.name then
                master.network.FluidIOTable[con.entID] = con
            end
            addConnectables(con, connections, master)
            ::continue::
        end
    end
end

function BaseNet:getTooltips()
    
end

function BaseNet.getOperableObjects(array)
    local objs = {}
    for _, o in pairs(array) do
        if o.thisEntity.to_be_deconstructed() == false then
            objs[o.entID] = o
        end
    end
    return objs
end

function BaseNet.filter(name, array)
    local filtered = {}
    for _, t in pairs(array) do
        if t.thisEntity.name == name then
            filtered[t.entID] = t
        end
    end
    return filtered
end

--Get connected objects
function BaseNet:getTotalObjects()
    return Util.getTableLength(BaseNet.getOperableObjects(self.ItemDriveTable)) + Util.getTableLength(BaseNet.getOperableObjects(self.FluidDriveTable)) + Util.getTableLength(BaseNet.getOperableObjects(self.ItemIOTable)) + Util.getTableLength(BaseNet.getOperableObjects(self.FluidIOTable))
end