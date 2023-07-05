--This will manage store related blocks for the Network Controller to see and for things that import/export 
BaseNet = {
    ID = nil,
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
            if con.thisEntity.to_be_deconstructed() == true then goto continue end
            if con.thisEntity == nil and con.thisEntity.valid == false then goto continue end
            if connections[con.entID] ~= nil then goto continue end

            if con.thisEntity.name == Constants.NetworkController.entity.name and con.entID ~= master.entID then
                con.thisEntity.order_deconstruction("player")
                goto continue
            end

            con.networkController = master
            connections[con.entID] = con

            if string.match(con.thisEntity.name, "RNS_ItemDrive") ~= nil then
                master.network.ItemDriveTable[con.entID] = con
            elseif string.match(con.thisEntity.name, "RNS_FluidDrive") ~= nil then
                master.network.FluidDriveTable[con.entID] = con
            elseif con.thisEntity.name == Constants.NetworkCables.IO.item.eName then
                master.network.ItemIOTable[con.entID] = con
            end
            addConnectables(con, connections, master)
            ::continue::
        end
    end
end

function BaseNet:getTooltips()
    
end

--Get connected objects
function BaseNet:getTotalObjects()
    return Util.getTableLength(self.ItemDriveTable) + Util.getTableLength(self.FluidDriveTable) + Util.getTableLength(self.ItemIOTable) + Util.getTableLength(self.FluidIOTable)
end