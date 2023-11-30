--This will manage store related blocks for the Network Controller to see and for things that import/export 
BaseNet = {
    networkController = nil,
    ItemDriveTable = nil,
    FluidDriveTable = nil,
    ItemIOTable = nil,
    ItemIOV2Table = nil,
    FluidIOTable = nil,
    FluidIOV2Table = nil,
    ExternalIOTable = nil,
    NetworkInventoryInterfaceTable = nil,
    WirelessTransmitterTable = nil,
    DetectorTable = nil,
    TransmitterTable = nil,
    ReceiverTable = nil,
    PlayerPorts = nil,
    Contents = nil,
    shouldRefresh = false,
}

function BaseNet:new()
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = BaseNet
    t.PlayerPorts = {}
    t.Contents = {
        item = {},
        fluid = {}
    }
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

function generate_priority_table(array)
    for i=1, Constants.Settings.RNS_Max_Priority*2 + 1 do
        array[i] = {}
    end
end

function BaseNet:resetTables()
    self.ItemDriveTable = {}
    generate_priority_table(self.ItemDriveTable)
    self.FluidDriveTable = {}
    generate_priority_table(self.FluidDriveTable)
    self.ItemIOTable = {}
    generate_priority_table(self.ItemIOTable)
    self.ItemIOV2Table = {}
    generate_priority_table(self.ItemIOV2Table)
    self.FluidIOTable = {}
    generate_priority_table(self.FluidIOTable)
    self.FluidIOV2Table = {}
    generate_priority_table(self.FluidIOV2Table)
    self.ExternalIOTable = {}
    generate_priority_table(self.ExternalIOTable)
    self.NetworkInventoryInterfaceTable = {}
    self.NetworkInventoryInterfaceTable[1] = {}
    self.WirelessTransmitterTable = {}
    self.WirelessTransmitterTable[1] = {}
    self.DetectorTable = {}
    self.DetectorTable[1] = {}
    self.TransmitterTable = {}
    self.TransmitterTable[1] = {}
    self.ReceiverTable = {}
    self.ReceiverTable[1] = {}
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
    if source.createArms == nil then return end
    source:createArms()
    if source.connectedObjs == nil and source.connectedObjs.valid == false then return end
    for _, connected in pairs(source.connectedObjs) do
        for _, con in pairs(connected) do
            if valid(con) == false then goto continue end
            --if con.thisEntity.to_be_deconstructed() == true then goto continue end
            if con.thisEntity == nil and con.thisEntity.valid == false then goto continue end
            if connections[con.entID] ~= nil then goto continue end

            if con.thisEntity.name == Constants.NetworkController.main.name and con.entID ~= master.entID then
                con.thisEntity.order_deconstruction("player")
                goto continue
            end

            con.networkController = master
            connections[con.entID] = con

            if string.match(con.thisEntity.name, "RNS_ItemDrive") ~= nil then
                master.network.ItemDriveTable[1+Constants.Settings.RNS_Max_Priority-con.priority][con.entID] = con

            elseif string.match(con.thisEntity.name, "RNS_FluidDrive") ~= nil then
                master.network.FluidDriveTable[1+Constants.Settings.RNS_Max_Priority-con.priority][con.entID] = con

            elseif con.thisEntity.name == Constants.NetworkCables.itemIO.name then
                master.network.ItemIOTable[1+Constants.Settings.RNS_Max_Priority-con.priority][con.entID] = con

            elseif con.thisEntity.name == "RNS_NetworkCableIOV2_Item" then
                master.network.ItemIOV2Table[1+Constants.Settings.RNS_Max_Priority-con.priority][con.entID] = con

            elseif con.thisEntity.name == Constants.NetworkCables.fluidIO.name then
                master.network.FluidIOTable[1+Constants.Settings.RNS_Max_Priority-con.priority][con.entID] = con

            elseif con.thisEntity.name == "RNS_NetworkCableIOV2_Fluid" then
                master.network.FluidIOV2Table[1+Constants.Settings.RNS_Max_Priority-con.priority][con.entID] = con

            elseif con.thisEntity.name == Constants.NetworkCables.externalIO.name then
                master.network.ExternalIOTable[1+Constants.Settings.RNS_Max_Priority-con.priority][con.entID] = con

            elseif con.thisEntity.name == Constants.NetworkInventoryInterface.name then
                master.network.NetworkInventoryInterfaceTable[1][con.entID] = con

            elseif con.thisEntity.name == Constants.NetworkCables.wirelessTransmitter.name then
                master.network.WirelessTransmitterTable[1][con.entID] = con

            elseif con.thisEntity.name == Constants.Detector.name then
                master.network.DetectorTable[1][con.entID] = con

            elseif con.thisEntity.name == Constants.NetworkTransReceiver.transmitter.name then
                master.network.TransmitterTable[1][con.entID] = con
                
            elseif con.thisEntity.name == Constants.NetworkTransReceiver.receiver.name then
                master.network.ReceiverTable[1][con.entID] = con
            end
            addConnectables(con, connections, master)
            ::continue::
        end
    end
end

function BaseNet:getTooltips()
    
end

function BaseNet.transfer_from_tank_to_tank(from_tank, to_tank, from_index, to_index, name, amount_to_transfer)
    local amount = amount_to_transfer

    for i=1, 1 do
        if from_tank.fluidbox[from_index] == nil then break end
        if from_tank.fluidbox[from_index].name ~= name then break end
        if to_tank.fluidbox[to_index] ~= nil and to_tank.fluidbox[to_index].name ~= name then break end
        local amount0 = from_tank.fluidbox[from_index].amount
        amount = math.min(amount0, amount_to_transfer)

        --[[local temp0 = from_tank.fluidbox[from_index].temperature

        if to_tank.fluidbox[to_index] == nil then
            to_tank.fluidbox[to_index] = {
                name = name,
                amount = amount,
                temperature = from_tank.fluidbox[from_index].temperature
            }
            local transfered = to_tank.fluidbox[to_index].amount
            if amount0 - transfered <= 0 then
                from_tank.fluidbox[from_index] = nil
                break
            end
            from_tank.fluidbox[from_index] = {
                name = name,
                amount = amount0 - transfered,
                temperature = temp0
            }
        else
            if to_tank.fluidbox[to_index].name ~= name then break end
            local amount1 = to_tank.fluidbox[to_index].amount
            local temp1 = to_tank.fluidbox[to_index].temperature
            to_tank.fluidbox[to_index] = {
                name = name,
                amount = amount1 + amount,
                temperature = temp1
            }
            local amount2 = to_tank.fluidbox[to_index].amount
            local transfered = amount2 - amount1 <= 0 and 0 or amount2 - amount1
            amount = amount - transfered <= 0 and 0 or amount - transfered
            if transfered <= 0 then break end
            to_tank.fluidbox[to_index] = {
                name = name,
                amount = amount2,
                temperature = (temp0 * transfered + amount1 * temp1) / (amount2)
            }
            if amount0 - transfered <= 0 then
                from_tank.fluidbox[from_index] = nil
                break
            end
            from_tank.fluidbox[from_index] = {
                name = name,
                amount = amount0 - transfered,
                temperature = temp0
            }
        end]]
        local transfered = to_tank.insert_fluid({
            name = name,
            amount = amount,
            temperature = from_tank.fluidbox[from_index].temperature
        })
        amount = amount - transfered <= 0 and 0 or amount - transfered
        if amount0 - transfered <= 0 then
            from_tank.fluidbox[from_index] = nil
        else
            from_tank.fluidbox[from_index] = {
                name = name,
                amount = amount0 - transfered,
                temperature = from_tank.fluidbox[from_index].temperature
            }
        end
    end

    return amount_to_transfer - amount
end

function BaseNet.transfer_from_drive_to_tank(drive, tank_entity, index, name, amount_to_transfer)
    local amount = amount_to_transfer

    for i=1, 1 do
        --[[if tank_entity.fluidbox[index] == nil then
            tank_entity.fluidbox[index] = {
                name = name,
                amount = amount,
                temperature = drive.fluidArray[name].temperature
            }
            local transfered = tank_entity.insert_fluid({
                name = name,
                amount = amount,
                temperature = drive.fluidArray[name].temperature
            })
            amount = amount - transfered <= 0 and 0 or amount - transfered
            drive:remove_fluid(name, transfered)
            break
        else
            if tank_entity.fluidbox[index].name ~= name then break end
            local amount0 = tank_entity.fluidbox[index].amount
            local temp0 = tank_entity.fluidbox[index].temperature
            tank_entity.fluidbox[index] = {
                name = name,
                amount = amount0 + amount,
                temperature = temp0
            }
            local amount1 = tank_entity.fluidbox[index].amount
            local transfered = amount1 - amount0 <= 0 and 0 or amount1 - amount0
            amount = amount - transfered <= 0 and 0 or amount - transfered
            if transfered <= 0 then break end
            tank_entity.fluidbox[index] = {
                name = name,
                amount = amount1,
                temperature = (drive.fluidArray[name].temperature * transfered + amount0 * temp0) / (amount1)
            }
            local portion = tank_entity.fluidbox.get_capacity(index) - tank_entity.fluidbox[index].amount
            local transfered = tank_entity.insert_fluid({
                name = name,
                amount = portion,
                temperature = drive.fluidArray[name].temperature
            })
            amount = amount - transfered <= 0 and 0 or amount - transfered
            drive:remove_fluid(name, transfered)
            break
        end]]
        if tank_entity.fluidbox[index] ~= nil and tank_entity.fluidbox[index].name ~= name then break end
        local transfered = tank_entity.insert_fluid({
            name = name,
            amount = amount,
            temperature = drive.fluidArray[name].temperature
        })
        amount = amount - transfered <= 0 and 0 or amount - transfered
        drive:remove_fluid(name, transfered)
    end

    return amount_to_transfer - amount
end

function BaseNet.transfer_from_tank_to_drive(tank_entity, drive, index, name, amount_to_transfer)
    local amount = amount_to_transfer

    for i=1, 1 do
        if tank_entity.fluidbox[index] == nil then break end
        if tank_entity.fluidbox[index].name ~= name then break end
        local amount0 = tank_entity.fluidbox[index].amount
        local temp0 = tank_entity.fluidbox[index].temperature
        local transfered = drive:insert_fluid(name, math.min(amount0, amount), temp0)
        amount = amount - transfered <= 0 and 0 or amount - transfered
        if transfered <= 0 then break end
        if amount0 - transfered <= 0 then
            tank_entity.fluidbox[index] = nil
        else
            tank_entity.remove_fluid{
                name = name,
                amount = transfered,
                temperature = temp0
            }
        end
    end

    return amount_to_transfer - amount
end

--Meant for exporting from the network. Exporting is always whitelisted
function BaseNet.transfer_from_drive_to_inv(drive_inv, to_inv, itemstack_data, count, allowMetadata)
    allowMetadata = allowMetadata or false
    --drive_inv:get_sorted_and_merged_inventory()
    local amount = count
    local list = drive_inv.storageArray
    --local inventory = drive_inv.storageArray.inventory
    for i=1, 1 do
        to_inv.sort_and_merge()
        if list[itemstack_data.cont.name] ~= nil and itemstack_data.modified == false then
            local item = list[itemstack_data.cont.name]
            local min = math.min(item.count, amount)
            if item.count <= 1 and allowMetadata == false then
                if item.ammo ~= nil and item.ammo ~= itemstack_data.cont.ammo then break end
                if item.durability ~= nil and item.durability ~= itemstack_data.cont.durability then break end
            --elseif item.count > 1 and allowMetadata == false then
                --if item.ammo ~= nil and item.ammo ~= itemstack_data.cont.ammo then min = min - 1 end
                --if item.durability ~= nil and item.durability ~= itemstack_data.cont.durability then min = min - 1 end
            end
            local temp = {
                name=itemstack_data.cont.name,
                count=min,
                durability=not allowMetadata and itemstack_data.cont.durability or item.durability,
                ammo=not allowMetadata and itemstack_data.cont.ammo or item.ammo
            }
            local t = to_inv.insert(temp)
            amount = amount - t
            item.count = item.count - t
            if allowMetadata == false and t > 0 then
                if item.ammo ~= nil and itemstack_data.cont.ammo == item.ammo then item.ammo = game.item_prototypes[item.name].magazine_size end
                if item.durability ~= nil and itemstack_data.cont.durability == item.durability then item.durability = game.item_prototypes[item.name].durability end
            end
            if item.count <= 0 then
                list[itemstack_data.cont.name] = nil
            end
        end
        if amount <= 0 then break end
        --[[
        for k=1, #inventory do
            local item1 = inventory[k]
            if item1.count <= 0 then break end
            local item1C = Util.itemstack_convert(item1) --Doesn't grab the right item
            if Util.itemstack_matches(itemstack_data, item1C, allowMetadata) == true then
                if item1C.cont.health ~= 1 then
                    local min1 = math.min(item1C.cont.count, amount)
                    local temp = {
                        name=itemstack_data.cont.name,
                        count=min1,
                        health=not allowMetadata and itemstack_data.cont.health or item1C.cont.health,
                        durability=not allowMetadata and itemstack_data.cont.durability or item1C.cont.durability,
                        ammo=not allowMetadata and itemstack_data.cont.ammo or item1C.cont.ammo,
                        tags=not allowMetadata and itemstack_data.cont.tags or item1C.cont.tags
                    }
                    local t = to_inv.insert(temp)
                    amount = amount - t
                    item1.count = item1.count - t <= 0 and 0 or item1.count - t
                else
                    for l=1, #to_inv do
                        local item2 = to_inv[l]
                        if item2.count > 0 then goto continue end
                        if item2.transfer_stack(item1) then
                            amount = amount - item1.count
                            break
                        end
                        ::continue::
                    end
                end
            end
            if amount <= 0 then break end
        end
        ]]
    end
    return count - amount
end

function BaseNet.transfer_from_inv_to_inv(from_inv, to_inv, itemstack_data, external_data, count, allowModified, whitelist)
    local amount = count
    allowModified = allowModified or false
    whitelist = whitelist or false
    for i = 1, #from_inv do
        local mod = false
        local itemstack = from_inv[i]
        if itemstack.count <= 0 then goto continue end
        local itemstackC = Util.itemstack_convert(itemstack)
        if itemstack_data ~= nil then
            if whitelist == true then
                if game.item_prototypes[itemstackC.cont.name] ~= game.item_prototypes[itemstack_data.cont.name] then goto continue end
            else
                if game.item_prototypes[itemstackC.cont.name] == game.item_prototypes[itemstack_data.cont.name] then goto continue end
            end
        else
            itemstack_data = Util.itemstack_template(itemstackC.cont.name)
        end
        if external_data ~= nil then
            if external_data.onlyModified == true and itemstack_data.modified == false and string.match(external_data.io, "input") ~= nil then goto continue end
            if Util.getTableLength_non_nil(external_data.filters.item.values) > 0 then
                if external_data:matches_filters("item", itemstack_data.cont.name) == true then
                    if external_data.whitelist == false then goto continue end
                else
                    if external_data.whitelist == true then goto continue end
                end
            end
        end
        local min = math.min(itemstackC.cont.count, amount)
        if Util.itemstack_matches(itemstack_data, itemstackC, allowModified) == false then
            if game.item_prototypes[itemstack_data.cont.name] == game.item_prototypes[itemstackC.cont.name] then
                if itemstack_data.cont.ammo and itemstackC.cont.ammo and itemstack_data.cont.ammo > itemstackC.cont.ammo and itemstackC.cont.count > 1 then
                    mod = true
                    goto go
                end
                if itemstack_data.cont.durability and itemstackC.cont.durability and itemstack_data.cont.durability > itemstackC.cont.durability and itemstackC.cont.count > 1 then
                    mod = true
                    goto go
                end
            end
            goto continue
        end
        ::go::
        if itemstackC.modified == false then
            local temp = {
                name = itemstackC.cont.name,
                count = min,
                durability = not allowModified and itemstack_data.cont.durability or itemstackC.cont.durability,
                ammo = not allowModified and itemstack_data.cont.ammo or itemstackC.cont.ammo
            }
            local inserted = to_inv.insert(temp)
            amount = amount - inserted
            itemstack.count = itemstack.count - inserted <= 0 and 0 or itemstack.count - inserted
            if itemstack.count > 0 and itemstackC.cont.ammo and not allowModified then
                if mod then itemstack.ammo = itemstackC.cont.ammo end
            end
            if itemstack.count > 0 and itemstackC.cont.durability and not allowModified then
                if mod then itemstack.durability = itemstackC.cont.durability end
            end
        else
            if itemstackC.cont.health ~= 1 then
                local min1 = math.min(itemstackC.cont.count, amount)
                local temp = {
                    name=itemstack_data.cont.name,
                    count=min1,
                    health=not allowModified and itemstack_data.cont.health or itemstackC.cont.health,
                    durability=not allowModified and itemstack_data.cont.durability or itemstackC.cont.durability,
                    ammo=not allowModified and itemstack_data.cont.ammo or itemstackC.cont.ammo,
                    tags=not allowModified and itemstack_data.cont.tags or itemstackC.cont.tags
                }
                local t = to_inv.insert(temp)
                amount = amount - t
                itemstack.count = itemstack.count - t <= 0 and 0 or itemstack.count - t
            else
                for j=1, #to_inv do
                    local item1 = to_inv[j]
                    if item1.count > 0 then goto continue end
                    if item1.transfer_stack(itemstack) then
                        amount = amount - min
                        break
                    end
                    ::continue::
                end
            end
        end
        if amount <= 0 then break end
        ::continue::
    end
    return count - amount
end

--Meant for importing from the network. Importing always needs whitelist or blacklist or no filters
function BaseNet.transfer_from_inv_to_drive(from_inv, drive_inv, itemstack_data, filters, count, allowMetadata, whitelist)
    whitelist = whitelist or false
    allowMetadata = allowMetadata or false
    --drive_inv:get_sorted_and_merged_inventory()
    local amount = count
    from_inv.sort_and_merge()

    for i=1, #from_inv do
        local mod = false
        local item = from_inv[i]
        if itemstack_data ~= nil and whitelist == true then
            item, i = from_inv.find_item_stack(itemstack_data.cont.name)
            if item == nil then break end
        end
        if item.count <= 0 then goto continue end
        local itemC = Util.itemstack_convert(item)
        if itemstack_data ~= nil then
            if whitelist == false then
                if filters ~= nil and IIO3.matches_filters(itemC.cont.name, filters) == true then
                    goto continue
                else
                    itemstack_data = Util.itemstack_template(itemC.cont.name)
                end
            end
        else
            itemstack_data = Util.itemstack_template(itemC.cont.name)
        end
        if Util.itemstack_matches(itemstack_data, itemC, allowMetadata) == false then
            if game.item_prototypes[itemstack_data.cont.name] == game.item_prototypes[itemC.cont.name] then
                if itemstack_data.cont.ammo and itemC.cont.ammo and itemstack_data.cont.ammo > itemC.cont.ammo and itemC.cont.count > 1 then
                    mod = true
                    goto go
                end
                if itemstack_data.cont.durability and itemC.cont.durability and itemstack_data.cont.durability > itemC.cont.durability and itemC.cont.count > 1 then
                    mod = true
                    goto go
                end
            end
            goto continue
        end
        ::go::
        local min = math.min(itemC.cont.count, amount)
        if itemC.modified == false then
            local temp = {
                name=itemstack_data.cont.name,
                count=min,
                durability=not allowMetadata and itemstack_data.cont.durability or itemC.cont.durability,
                ammo=not allowMetadata and itemstack_data.cont.ammo or itemC.cont.ammo,
            }
            local t = drive_inv:add_or_merge_basic_item(temp, min)
            amount = amount - t
            item.count = item.count - t <= 0 and 0 or item.count - t
            if item.count > 0 and itemC.cont.ammo and not allowMetadata then
                if mod then item.ammo = itemC.cont.ammo end
            end
            if item.count > 0 and itemC.cont.durability and not allowMetadata then
                if mod then item.durability = itemC.cont.durability end
            end
        --[[
            elseif itemC.modified == true then
            local inv = drive_inv.storageArray.inventory
            if item.item_number == nil then
                local temp1 = {
                    name=itemstack_data.cont.name,
                    count=min,
                    health=not allowMetadata and itemstack_data.cont.health or itemC.cont.health,
                    durability=not allowMetadata and itemstack_data.cont.durability or itemC.cont.durability,
                    ammo=not allowMetadata and itemstack_data.cont.ammo or itemC.cont.ammo,
                    tags=not allowMetadata and itemstack_data.cont.tags or itemC.cont.tags
                }
                local t = inv.insert(temp1)
                amount = amount - t
                item.count = item.count - t <= 0 and 0 or item.count - t
            else
                for j=1, #inv do
                    local item1 = inv[j]
                    if item1.count > 0 then goto continue end
                    if item1.transfer_stack(item) then
                        amount = amount - min
                        break
                    end
                    ::continue::
                end
            end
        ]]
        end
        if amount <= 0 then break end
        ::continue::
    end
    return count - amount
end

--[[
-- from_inv, to_inv, count
function BaseNet.transfer_item(from_inv, to_inv, itemstack_data, count, allowMetadata, whitelist, transferDirection)
    local amount = count
    for i = 1, #from_inv do
        local itemstack = from_inv[i]
        if itemstack.count <= 0 then goto continue end
        local itemstackC = Util.itemstack_convert(itemstack)
        if itemstack_data ~= nil then
            if whitelist == true then
                if game.item_prototypes[itemstackC.cont.name] ~= game.item_prototypes[itemstack_data.cont.name] then goto continue end
            elseif whitelist == false then
                if game.item_prototypes[itemstackC.cont.name] == game.item_prototypes[itemstack_data.cont.name] then goto continue end
            end
        end
        local item_template = Util.itemstack_template(itemstackC.cont.name)
        local min = math.min(itemstackC.cont.count, amount)
        if itemstackC.id == nil then
            amount = amount - BaseNet.transfer_basic_item(itemstack, to_inv, item_template, min, allowMetadata, transferDirection)
        else
            amount = amount - BaseNet.transfer_advanced_item(itemstack, to_inv, item_template, min, allowMetadata, transferDirection)
        end
        if amount <= 0 then break end
        ::continue::
    end
    return count - amount
end

-- from_inv, to_inv, itemstack_data, count
function BaseNet.transfer_basic_item(from_inv_itemstack, to_inv, itemstack_data, count, metadataMode, transferDirection)
    local temp_count = count
    metadataMode = metadataMode or false

    for i = 1, 1 do
        local itemstack = from_inv_itemstack --from_inv[i]
        local mod = false
        if itemstack.count <= 0 then goto continue end
        local itemstackC = Util.itemstack_convert(itemstack)
        if Util.itemstack_matches(itemstack_data, itemstackC, metadataMode) == false then
            if game.item_prototypes[itemstack_data.cont.name] == game.item_prototypes[itemstackC.cont.name] then
                if itemstack_data.cont.ammo and itemstackC.cont.ammo and itemstack_data.cont.ammo > itemstackC.cont.ammo and itemstackC.cont.count > 1 then
                    mod = true
                    goto go
                end
                if itemstack_data.cont.durability and itemstackC.cont.durability and itemstack_data.cont.durability > itemstackC.cont.durability and itemstackC.cont.count > 1 then
                    mod = true
                    goto go
                end
            end
            goto continue
        end

        ::go::
        
        local min = math.min(itemstackC.cont.count, temp_count)
        local temp = {
            name=itemstack_data.cont.name,
            count=min,
            health=not metadataMode and itemstack_data.cont.health or itemstackC.cont.health,
            durability=not metadataMode and itemstack_data.cont.durability or itemstackC.cont.durability,
            ammo=not metadataMode and itemstack_data.cont.ammo or itemstackC.cont.ammo,
            tags=not metadataMode and itemstack_data.cont.tags or itemstackC.cont.tags
        }
        local inserted = to_inv.insert(temp)
        if inserted <= 0 then return count - temp_count end
        
        temp_count = temp_count - inserted
        itemstack.count = itemstack.count - inserted <= 0 and 0 or itemstack.count - inserted
        if itemstack.count > 0 and itemstackC.cont.ammo and not metadataMode then
            if mod then itemstack.ammo = itemstackC.cont.ammo end
        end
        if itemstack.count > 0 and itemstackC.cont.durability and not metadataMode then
            if mod then itemstack.durability = itemstackC.cont.durability end
        end

        if temp_count <= 0 then break end
        ::continue::
    end

    return count - temp_count
end

--from_inv, to_inv, itemstack_data, count
function BaseNet.transfer_advanced_item(from_inv_itemstack, to_inv, itemstack_data, count, metadataMode, whitelist, transferDirection)
    local temp_count = count
    whitelist = whitelist or false
    metadataMode = metadataMode or false

    for i = 1, 1 do
        local itemstack = from_inv_itemstack --from_inv[i]
        if itemstack.count <= 0 then goto continue end
        local itemstackC = Util.itemstack_convert(itemstack)
        if Util.itemstack_matches(itemstack_data, itemstackC, metadataMode) == not whitelist then goto continue end

        local min = math.min(itemstack.count, temp_count)
        for j = 1, #to_inv do
            local itemstack_j = to_inv[j]
            if itemstack_j.count > 0 then goto continue end
            if itemstack_j.transfer_stack(itemstack) then
                temp_count = temp_count - min
                break
            end
            ::continue::
            if j == #to_inv then return count - temp_count end
        end

        if temp_count <= 0 then break end
        ::continue::
    end
    return count - temp_count
end
]]

function BaseNet.getOperableObjects(array)
    local objs = {}
    for p, priority in pairs(array) do
        objs[p] = {}
        for _, o in pairs(priority) do
            if o.thisEntity.valid and o.thisEntity.to_be_deconstructed() == false then
                objs[p][o.entID] = o
            end
        end
    end
    return objs
end

function BaseNet:filter_externalIO_by_valid_signal()
    local objs = {}
    for p, priority in pairs(self.ExternalIOTable) do
        objs[p] = {}
        for _, o in pairs(priority) do
            if o:signal_valid() == true then
                o:reset_focused_entity()
                objs[p][o.entID] = o
            end
        end
    end
    return objs
end

function BaseNet.filter_by_mode(mode, array)
    local objs = {}
    for p, priority in pairs(array) do
        objs[p] = {}
        for _, o in pairs(priority) do
            if string.match(o.io, mode) ~= nil then
                objs[p][o.entID] = o
            end
        end
    end
    return objs
end

function BaseNet.filter_by_type(type, array)
    local objs = {}
    for p, priority in pairs(array) do
        objs[p] = {}
        for _, o in pairs(priority) do
            if type == o.type then
                objs[p][o.entID] = o
            end
        end
    end
    return objs
end

function BaseNet.filter_by_name(name, array)
    local objs = {}
    for p, priority in pairs(array) do
        objs[p] = {}
        for _, o in pairs(priority) do
            if name == o.thisEntity.name then
                objs[p][o.entID] = o
            end
        end
    end
    return objs
end

function BaseNet:get_item_storage_size()
    local m = 0
    local t = 0
    for _, priority in pairs(self.getOperableObjects(self.ItemDriveTable)) do
        for _, drive in pairs(priority) do
            m = m + drive.maxStorage
            t = t + drive:getStorageSize()
        end
    end
    return t, m
end

function BaseNet.get_table_length_in_priority(array)
    local count = 0
    for _, p in pairs(array) do
        count = count + Util.getTableLength(p)
    end
    return count
end

function BaseNet.get_powerusage(array)
    local power = 0
    for _, p in pairs(array) do
        for _, o in pairs(p) do
            power = power + o.powerUsage
        end
    end
    return power
end

--Get connected objects
function BaseNet:getTotalObjects()
    return  BaseNet.get_powerusage(BaseNet.getOperableObjects(self.ItemDriveTable)) + BaseNet.get_powerusage(BaseNet.getOperableObjects(self.FluidDriveTable))
            + BaseNet.get_powerusage(BaseNet.getOperableObjects(self.ItemIOTable))*global.IIOMultiplier + BaseNet.get_powerusage(BaseNet.getOperableObjects(self.FluidIOTable))*global.FIOMultiplier
            + BaseNet.get_powerusage(BaseNet.getOperableObjects(self.ExternalIOTable)) + BaseNet.get_powerusage(BaseNet.getOperableObjects(self.NetworkInventoryInterfaceTable))
            + BaseNet.get_powerusage(BaseNet.getOperableObjects(self.WirelessTransmitterTable))*global.WTRangeMultiplier + BaseNet.get_powerusage(BaseNet.getOperableObjects(self.DetectorTable))
            + BaseNet.get_table_length_in_priority(BaseNet.getOperableObjects(self.TransmitterTable)) + BaseNet.get_table_length_in_priority(BaseNet.getOperableObjects(self.ReceiverTable))
            + BaseNet.get_powerusage(BaseNet.getOperableObjects(self.ItemIOV2Table))*global.IIOMultiplier
end