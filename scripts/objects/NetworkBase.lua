--This will manage store related blocks for the Network Controller to see and for things that import/export 
BaseNet = {
    networkController = nil,
    ItemDriveTable = nil,
    FluidDriveTable = nil,
    ItemIOTable = nil,
    FluidIOTable = nil,
    ExternalIOTable = nil,
    NetworkInventoryInterfaceTable = nil,
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
    self.ExternalIOTable = {}
    self.NetworkInventoryInterfaceTable = {}
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
            elseif con.thisEntity.name == Constants.NetworkCables.externalIO.slateEntity.name then
                master.network.ExternalIOTable[con.entID] = con
            elseif con.thisEntity.name == Constants.NetworkInventoryInterface.name then
                master.network.NetworkInventoryInterfaceTable[con.entID] = con
            end
            addConnectables(con, connections, master)
            ::continue::
        end
    end
end

function BaseNet:getTooltips()
    
end

-- from_inv, to_inv, itemstack_data, count
function BaseNet.transfer_basic_item(from_inv, to_inv, itemstack_data, count)
    local temp = {name=itemstack_data.cont.name, count=count, health=itemstack_data.cont.health, durability=itemstack_data.cont.durability, ammo=itemstack_data.cont.ammo, tags=itemstack_data.cont.tags}
    
    --local removed = from_inv.remove(temp) --Removes the first instance by name. Not what I wanted it to do...
    local inserted = to_inv.insert(temp) --This works fine tho

    local temp_count = inserted

    for i = 1, #from_inv do
        local itemstack = from_inv[i]
        if itemstack.count <= 0 then goto continue end
        local itemstackC = Util.itemstack_convert(itemstack)
        if Util.itemstack_matches(itemstackC, itemstack_data) == false then goto continue end

        local min = math.min(itemstack.count, temp_count)
        temp_count = temp_count - min
        itemstack.count = itemstack.count - min <= 0 and 0 or itemstack.count - min

        if temp_count <= 0 then break end
        ::continue::
    end

    return inserted
end

--from_inv, to_inv, itemstack_data, count
function BaseNet.transfer_advanced_item(from_inv, to_inv, itemstack_data, count)
    local temp_count = count
    
    for i = 1, #from_inv do
        local itemstack = from_inv[i]
        if itemstack.count <= 0 then goto continue end
        local itemstackC = Util.itemstack_convert(itemstack)
        if Util.itemstack_matches(itemstackC, itemstack_data, true) == false then goto continue end

        local min = math.min(itemstack.count, temp_count)
        for j = 1, #to_inv do
            if itemstack.count > 0 then goto continue end
            if to_inv[j].transfer_stack(itemstack) then
                temp_count = temp_count - min
                break
            end
            ::continue::
        end

        if temp_count <= 0 then break end
        ::continue::
    end
end



function BaseNet.getOperableObjects(array)
    local objs = {}
    for _, o in pairs(array) do
        if o.thisEntity.valid and o.thisEntity.to_be_deconstructed() == false then
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

function BaseNet:get_item_storage_size()
    local m = 0
    local t = 0
    for _, drive in pairs(self.getOperableObjects(self.ItemDriveTable)) do
        m = m + drive.maxStorage
        t = t + drive:getStorageSize()
    end
    return t, m
end

--Get connected objects
function BaseNet:getTotalObjects()
    return  Util.getTableLength(BaseNet.getOperableObjects(self.ItemDriveTable)) + Util.getTableLength(BaseNet.getOperableObjects(self.FluidDriveTable)) 
            + Util.getTableLength(BaseNet.getOperableObjects(self.ItemIOTable)) + Util.getTableLength(BaseNet.getOperableObjects(self.FluidIOTable))
            + Util.getTableLength(BaseNet.getOperableObjects(self.ExternalIOTable)) + Util.getTableLength(BaseNet.getOperableObjects(self.NetworkInventoryInterfaceTable))
end