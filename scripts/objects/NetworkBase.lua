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
    connectedEntities = nil,
    importDriveCache = nil,
    importExternalCache = nil,
    exportDriveCache = nil,
    exportExternalCache = nil,
}

function BaseNet:new()
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = BaseNet
    t.PlayerPorts = {}
    t.Contents = {}
    t.importDriveCache = {}
    t.importExternalCache = {}
    t.exportDriveCache = {}
    t.exportExternalCache = {}
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

function generate_priority_table(array, group)
    for i=1, Constants.Settings.RNS_Max_Priority*2 + 1 do
        if group == "io" then
            array[i] = {
                input = {},
                output = {}
            }
        elseif group == "eo" then
            array[i] = {
                item = {},
                fluid = {}
            }
        else
            array[i] = {}
        end
    end
end

function BaseNet:resetTables()
    self.ItemDriveTable = {}
    generate_priority_table(self.ItemDriveTable)
    self.FluidDriveTable = {}
    generate_priority_table(self.FluidDriveTable)
    self.ItemIOTable = {}
    generate_priority_table(self.ItemIOTable, "io")
    --self.ItemIOV2Table = {}
    --generate_priority_table(self.ItemIOV2Table)
    self.FluidIOTable = {}
    generate_priority_table(self.FluidIOTable, "io")
    --self.FluidIOV2Table = {}
    --generate_priority_table(self.FluidIOV2Table)
    self.ExternalIOTable = {}
    generate_priority_table(self.ExternalIOTable, "eo")
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
    self.connectedEntities = {}
end

--Refreshes laser connections
function BaseNet:doRefresh(controller)
    self:resetTables()
    self.connectedEntities[controller.entID] = controller
    addConnectables(controller, self.connectedEntities, controller)
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
                master.network.ItemIOTable[1+Constants.Settings.RNS_Max_Priority-con.priority][con.io][con.entID] = con

            elseif con.thisEntity.name == Constants.NetworkCables.fluidIO.name then
                master.network.FluidIOTable[1+Constants.Settings.RNS_Max_Priority-con.priority][con.io][con.entID] = con

            elseif con.thisEntity.name == Constants.NetworkCables.externalIO.name then
                master.network.ExternalIOTable[1+Constants.Settings.RNS_Max_Priority-con.priority][con.type][con.entID] = con

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

function BaseNet.generateArms(object)
    if object == nil then return end
    if object.thisEntity ~= nil and object.thisEntity.valid and object.thisEntity.to_be_deconstructed() == false then
        local areas = object:getCheckArea()
        object:resetConnection()
        for _, area in pairs(areas) do
            local ents = object.thisEntity.surface.find_entities_filtered{area={area.startP, area.endP}}
            for _, ent in pairs(ents) do
                if ent ~= nil and ent.valid == true and ent.to_be_deconstructed() == false then
                    if ent ~= nil and global.entityTable[ent.unit_number] ~= nil and string.match(ent.name, "RNS_") ~= nil then
                        if object.getDirection ~= nil and area.direction == object:getDirection() then break end--Prevent cable connection on the IO port
                        local obj = global.entityTable[ent.unit_number]
                        if (string.match(obj.thisEntity.name, "RNS_NetworkCableIO") ~= nil and obj:getConnectionDirection() == area.direction) or (string.match(obj.thisEntity.name, "RNS_NetworkCableRamp") ~= nil and obj:getConnectionDirection() == area.direction) or obj.thisEntity.name == Constants.WirelessGrid.name then
                            --Do nothing
                        else
                            if obj.color == nil then
                                object.arms[area.direction] = rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[object.color].sprites[area.direction].name, target=object.thisEntity, surface=object.thisEntity.surface, render_layer="lower-object-above-shadow"}
                                object.connectedObjs[area.direction] = {obj}
                                BaseNet.join_network(object, obj)
                            elseif obj.color ~= "" and obj.color == object.color then
                                object.arms[area.direction] = rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[object.color].sprites[area.direction].name, target=object.thisEntity, surface=object.thisEntity.surface, render_layer="lower-object-above-shadow"}
                                object.connectedObjs[area.direction] = {obj}
                                BaseNet.join_network(object, obj)
                            end
                        end
                        break
                    end
                end
            end
        end
    end
end

function BaseNet.update_network_controller(controller, objectID)
    if controller == nil then return end
    if controller:interactable() then
        if objectID == nil or controller.network.connectedEntities[objectID] ~= nil then
            controller.network.shouldRefresh = true
        end
    end
end

function BaseNet.exists_in_network(controller, objectID)
    if controller == nil then return false end
    if controller:interactable() == false then return false end
    return controller.network.connectedEntities[objectID] ~= nil
end

function BaseNet.join_network(main, side)
    if side.thisEntity.name == Constants.NetworkController.main.name then
        main.networkController = side
    else
        if BaseNet.exists_in_network(main.networkController, main.entID) then
            side.networkController = main.networkController
        else
            main.networkController = side.networkController
        end
    end
end

function BaseNet.postArms(object)
    for _, connected in pairs(object.connectedObjs) do
        for _, con in pairs(connected) do
            if valid(con) == false then goto next end
            if con.thisEntity == nil then goto next end
            if con.thisEntity ~= nil and con.thisEntity.valid == false then goto next end
            if con.thisEntity ~= nil and con.thisEntity.valid and con.thisEntity.to_be_deconstructed() == true then goto next end
            if con.createArms == nil then goto next end
            con:createArms()
            ::next::
        end
    end
end

function BaseNet:transfer_io_mode(obj, type, from, to)
    if type == "item" then
        if self.ItemIOTable[1+Constants.Settings.RNS_Max_Priority-obj.priority][from][obj.entID] ~= nil then
            self.ItemIOTable[1+Constants.Settings.RNS_Max_Priority-obj.priority][from][obj.entID] = nil
            self.ItemIOTable[1+Constants.Settings.RNS_Max_Priority-obj.priority][to][obj.entID] = obj
        end
        return
    end
    if type == "fluid" then
        if self.FluidIOTable[1+Constants.Settings.RNS_Max_Priority-obj.priority][from][obj.entID] ~= nil then
            self.FluidIOTable[1+Constants.Settings.RNS_Max_Priority-obj.priority][from][obj.entID] = nil
            self.FluidIOTable[1+Constants.Settings.RNS_Max_Priority-obj.priority][to][obj.entID] = obj
        end
        return
    end
    if type == "external" then
        if self.ExternalIOTable[1+Constants.Settings.RNS_Max_Priority-obj.priority][from][obj.entID] ~= nil then
            self.ExternalIOTable[1+Constants.Settings.RNS_Max_Priority-obj.priority][from][obj.entID] = nil
            self.ExternalIOTable[1+Constants.Settings.RNS_Max_Priority-obj.priority][to][obj.entID] = obj
        end
        return
    end
end

function BaseNet:has_cache(mode, type, key)
    if type == "drive" then
        return (self[mode.."DriveCache"][key] ~= nil and {true} or {false})[1]
    elseif type == "external" then
        return (self[mode.."ExternalCache"][key] ~= nil and {true} or {false})[1]
    end
    return false
end

function BaseNet:get_cache(mode, type, key)
    if type == "drive" then
        return self[mode.."DriveCache"][key]
    elseif type == "external" then
        return self[mode.."ExternalCache"][key]
    end
    return nil
end

function BaseNet:put_cache(mode, type, key, obj)
    if type == "drive" then
        self[mode.."DriveCache"][key] = obj
    elseif type == "external" then
        self[mode.."ExternalCache"][key] = obj
    end
end

function BaseNet:remove_cache(mode, type, key)
    if type == "drive" then
        self[mode.."DriveCache"][key] = nil
    elseif type == "external" then
        self[mode.."ExternalCache"][key] = nil
    end
end

function BaseNet.transfer_from_tank_to_tank(from_tank, to_tank, from_index, to_index, name, amount_to_transfer)
    local to_tank_capacity = to_tank.fluidbox.get_capacity(to_index)
    local amount = amount_to_transfer
    
    for i=1, 1 do
        if from_tank.fluidbox[from_index] == nil then break end
        if from_tank.fluidbox[from_index].name ~= name then break end
        if to_tank.fluidbox[to_index] ~= nil and to_tank.fluidbox[to_index].name ~= name then break end

        local a0 = from_tank.fluidbox[from_index].amount
        local t0 = from_tank.fluidbox[from_index].temperature
        amount = math.min(math.min(a0, amount_to_transfer), to_tank_capacity)

        if to_tank.fluidbox[to_index] == nil then
            to_tank.fluidbox[to_index] = {
                name = name,
                amount = amount,
                temperature = t0
            }
            if a0 - amount <= 0 then
                from_tank.fluidbox[from_index] = nil
            else
                from_tank.fluidbox[from_index] = {
                    name = name,
                    amount = a0 - amount,
                    temperature = t0
                }
            end
            amount = 0
        elseif to_tank.fluidbox[to_index] ~= nil then
            local a1 = to_tank.fluidbox[to_index].amount
            local t1 = to_tank.fluidbox[to_index].temperature
            local transfer = amount
            if transfer + a1 >= to_tank_capacity then
                transfer = to_tank_capacity - a1
                if transfer <= 0 then break end
            end
            to_tank.fluidbox[to_index] = {
                name = name,
                amount = transfer + a1,
                temperature = (a1 * t1 + transfer * t0) / (transfer + a1)
            }
            amount = amount - transfer <= 0 and 0 or amount - transfer
            if amount <= 0 then
                from_tank.fluidbox[from_index] = nil
            else
                from_tank.fluidbox[from_index] = {
                    name = name,
                    amount = a0 - transfer,
                    temperature = t0
                }
            end
        end
    end

    return amount_to_transfer - amount
end

function BaseNet.transfer_from_drive_to_tank(drive, tank_entity, index, name, amount_to_transfer)
    local capacity = tank_entity.fluidbox.get_capacity(index)
    local amount = math.min(amount_to_transfer, capacity)
    for i=1, 1 do
        if tank_entity.fluidbox[index] == nil then
            tank_entity.fluidbox[index] = {
                name = name,
                amount = amount,
                temperature = drive.fluidArray[name].temperature
            }
            amount = 0
            drive:remove_fluid(name, amount)
        elseif tank_entity.fluidbox[index] ~= nil and tank_entity.fluidbox[index].name == name then
            local a0 = tank_entity.fluidbox[index].amount
            local t0 = tank_entity.fluidbox[index].temperature
            local transfer = amount
            if transfer + a0 >= capacity then
                transfer = capacity - a0
                if transfer <= 0 then break end
            end
            tank_entity.fluidbox[index] = {
                name = name,
                amount = transfer + a0,
                temperature = (a0 * t0 + transfer * drive.fluidArray[name].temperature) / (transfer + a0)
            }
            amount = amount - transfer <= 0 and 0 or amount - transfer
            drive:remove_fluid(name, transfer)
        end
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
            tank_entity.fluidbox[index] = {
                name = name,
                amount = amount0 - transfered,
                temperature = temp0
            }
        end
    end

    return amount_to_transfer - amount
end

function BaseNet.extract_fluid_from_drive(to_tank, drive, filter, extractSize, storedFluidAmount, storedFluidTemperature, fluid_box)
    local takeAmount = math.min(extractSize, drive.fluidArray[filter].amount)
    extractSize = extractSize - takeAmount <= 0 and 0 or extractSize - takeAmount

    local takeTemperature = drive.fluidArray[filter].temperature
    drive:remove_fluid(filter, takeAmount)

    local a0 = storedFluidAmount
    local t0 = storedFluidTemperature
    local a1 = takeAmount
    local t1 = takeTemperature

    storedFluidAmount = a0 + a1
    storedFluidTemperature = (a0*t0 + a1*t1) / (a0 + a1)

    to_tank.thisEntity.fluidbox[fluid_box.index] = {
        name = filter,
        amount = storedFluidAmount,
        temperature = storedFluidTemperature
    }
    return extractSize
end

function BaseNet.extract_fluid_from_external(to_tank, external, filter, extractSize, storedFluidAmount, storedFluidTemperature, fluid_box)
    local takeAmount = math.min(extractSize, external.focusedEntity.thisEntity.fluidbox[external.focusedEntity.fluid_box.index].amount)
    extractSize = extractSize - takeAmount <= 0 and 0 or extractSize - takeAmount

    local takeTemperature = external.focusedEntity.thisEntity.fluidbox[external.focusedEntity.fluid_box.index].temperature

    if takeAmount == external.focusedEntity.thisEntity.fluidbox[external.focusedEntity.fluid_box.index].amount then
        external.focusedEntity.thisEntity.fluidbox[external.focusedEntity.fluid_box.index] = nil
    else
        external.focusedEntity.thisEntity.fluidbox[external.focusedEntity.fluid_box.index] = {
            name = filter,
            amount = external.focusedEntity.thisEntity.fluidbox[external.focusedEntity.fluid_box.index].amount - takeAmount,
            temperature = takeTemperature
        }
    end
    local a0 = storedFluidAmount
    local t0 = storedFluidTemperature
    local a1 = takeAmount
    local t1 = takeTemperature

    storedFluidAmount = a0 + a1
    storedFluidTemperature = (a0*t0 + a1*t1) / (a0 + a1)

    to_tank.thisEntity.fluidbox[fluid_box.index] = {
        name = filter,
        amount = storedFluidAmount,
        temperature = storedFluidTemperature
    }
    return extractSize
end

function BaseNet.transfer_from_network_to_tank(network, to_tank, transportCapacity, filter)
    local fluid_box = to_tank.fluid_box
    local networkAmount = network.Contents[filter]
    if networkAmount <= 0 then return 0 end
    if fluid_box.filter ~= "" and fluid_box.filter ~= filter then return 0 end

    local fluid = to_tank.thisEntity.fluidbox[fluid_box.index]
    local storedFluidAmount = (fluid ~= nil and fluid.amount or 0)
    local storedFluidTemperature = (fluid ~= nil and fluid.temperature or 0)

    local max_capacity = to_tank.thisEntity.fluidbox.get_capacity(fluid_box.index)
    local extractSize = math.min(max_capacity - storedFluidAmount, math.min(networkAmount, transportCapacity))
    
    if network:has_cache("export", "drive", filter) then
        local drive = network:get_cache("export", "drive", filter)
        if drive.valid == false then
            network:remove_cache("export", "drive", filter)
        else
            if drive:interactable() and drive.fluidArray[filter].amount > 0 then
                extractSize = BaseNet.extract_fluid_from_drive(to_tank, drive, filter, extractSize, storedFluidAmount, storedFluidTemperature, fluid_box)
                if extractSize <= 0 then return 0 end
            else
                network:remove_cache("export", "drive", fluid.name)
            end
        end
    end

    if network:has_cache("export", "external", filter) then
        local external = network:get_cache("export", "external", filter)
        if external.valid == false then
            network:remove_cache("export", "external", filter)
        else
            if external:interactable() and external:target_interactable() and external.type == "fluid" and string.match(external.io, "output") ~= nil and string.match(external.focusedEntity.fluid_box.flow, "output") ~= nil
            and external.focusedEntity.thisEntity.fluidbox[external.focusedEntity.fluid_box.index] ~= nil and external.focusedEntity.thisEntity.fluidbox[external.focusedEntity.fluid_box.index].name ~= filter 
            and external.focusedEntity.thisEntity.fluidbox[external.focusedEntity.fluid_box.index].amount > 0 then
                extractSize = BaseNet.extract_fluid_from_external(to_tank, external, filter, extractSize, storedFluidAmount, storedFluidTemperature, fluid_box)
                if extractSize <= 0 then return 0 end
            else
                network:remove_cache("export", "external", filter)
            end
        end
    end

    for p = 1, Constants.Settings.RNS_Max_Priority*2 + 1 do
        local priorityF = network.FluidDriveTable[p]
        local priorityE = network.ExternalIOTable[p].fluid

        for _, drive in pairs(priorityF) do
            if drive:interactable() and drive.fluidArray[filter].amount > 0 then
                extractSize = BaseNet.extract_fluid_from_drive(to_tank, drive, filter, extractSize, storedFluidAmount, storedFluidTemperature, fluid_box)
                if extractSize <= 0 then
                    network:put_cache("export", "drive", filter)
                    return 0
                end
            end
        end

        for _, external in pairs(priorityE) do
            if external:interactable() and external:target_interactable() and external.type == "fluid" and string.match(external.io, "output") ~= nil and string.match(external.focusedEntity.fluid_box.flow, "output") ~= nil
            and external.focusedEntity.thisEntity.fluidbox[external.focusedEntity.fluid_box.index] ~= nil and external.focusedEntity.thisEntity.fluidbox[external.focusedEntity.fluid_box.index].name ~= filter 
            and external.focusedEntity.thisEntity.fluidbox[external.focusedEntity.fluid_box.index].amount > 0 then
                extractSize = BaseNet.extract_fluid_from_external(to_tank, external, filter, extractSize, storedFluidAmount, storedFluidTemperature, fluid_box)
                if extractSize <= 0 then
                    network:put_cache("export", "external", filter)
                    return 0
                end
            end
        end
    end

    return extractSize
end

function BaseNet.insert_fluid_into_drive(drive, fluid, extractSize, storedFluidTemperature, storedFluidAmount, from_tank, fluid_box)
    local insertedAmount = drive:insert_fluid(fluid.name, extractSize, storedFluidTemperature)
    extractSize = extractSize - insertedAmount <= 0 and 0 or extractSize - insertedAmount
    if storedFluidAmount - insertedAmount <= 0 then
        from_tank.thisEntity.fluidbox[fluid_box.index] = nil
    else
        from_tank.thisEntity.fluidbox[fluid_box.index] = {
            name = fluid.name,
            amount = storedFluidAmount - insertedAmount,
            temperature = storedFluidTemperature
        }
    end
    return extractSize
end

function BaseNet.insert_fluid_into_external(external, extractSize, fluid_box, fluid, storedFluidTemperature, storedFluidAmount, from_tank)
    local e_fluid_box = external.focusedEntity.fluid_box
    local e_fluid = external.focusedEntity.thisEntity.fluidbox[e_fluid_box.index]
    local e_max_capacity = external.focusedEntity.thisEntity.fluidbox.get_capacity(e_fluid_box.index)
    local insertedAmount = math.min(e_max_capacity, extractSize)

    if e_fluid == nil then
        extractSize = extractSize - insertedAmount <= 0 and 0 or extractSize - insertedAmount
        external.focusedEntity.thisEntity.fluidbox[fluid_box.index] = {
            name = fluid.name,
            amount = insertedAmount,
            temperature = storedFluidTemperature
        }

        if storedFluidAmount - insertedAmount <= 0 then
            from_tank.thisEntity.fluidbox[fluid_box.index] = nil
        else
            from_tank.thisEntity.fluidbox[fluid_box.index] = {
                name = fluid.name,
                amount = storedFluidAmount - insertedAmount,
                temperature = storedFluidTemperature
            }
        end
    elseif e_fluid ~= nil then
        local e_storedFluidAmount = e_fluid.amount
        local e_storedFluidTemperature = e_fluid.temperature
        insertedAmount = math.min(e_max_capacity - e_storedFluidAmount, extractSize)
        extractSize = extractSize - insertedAmount <= 0 and 0 or extractSize - insertedAmount
        
        external.focusedEntity.thisEntity.fluidbox[fluid_box.index] = {
            name = fluid.name,
            amount = insertedAmount + e_storedFluidAmount,
            temperature = (e_storedFluidAmount * e_storedFluidTemperature + insertedAmount * storedFluidTemperature) / (insertedAmount + e_storedFluidAmount)
        }

        if storedFluidAmount - insertedAmount <= 0 then
            from_tank.thisEntity.fluidbox[fluid_box.index] = nil
        else
            from_tank.thisEntity.fluidbox[fluid_box.index] = {
                name = fluid.name,
                amount = storedFluidAmount - insertedAmount,
                temperature = storedFluidTemperature
            }
        end
    end
    return extractSize
end

function BaseNet.transfer_from_tank_to_network(network, from_tank, transportCapacity)
    local fluid_box = from_tank.fluid_box
    local fluid = from_tank.thisEntity.fluidbox[fluid_box.index]
    local storedFluidAmount = fluid.amount
    local storedFluidTemperature = fluid.temperature
    local extractSize = math.min(transportCapacity, storedFluidAmount)

    if network:has_cache("import", "drive", fluid.name) then
        local drive = network:get_cache("import", "drive", fluid.name)
        if drive.valid == false then
            network:remove_cache("import", "drive", fluid.name)
        else
            if drive:interactable() and Util.filter_accepts_fluid(drive.filters, drive.whitelistBlacklist, fluid.name) and drive:getRemainingStorageSize() > 0 then
                extractSize = BaseNet.insert_fluid_into_drive(drive, fluid, extractSize, storedFluidTemperature, storedFluidAmount, from_tank, fluid_box)
                if extractSize <= 0 then return 0 end
            else
                network:remove_cache("import", "drive", fluid.name)
            end
        end
    end
    
    if network:has_cache("import", "external", fluid.name) then
        local external = network:get_cache("import", "external", fluid.name)
        if external.valid == false then
            network:remove_cache("import", "external", fluid.name)
        else
            if external.type == "fluid" and string.match(external.io, "input") ~= nil and string.match(external.focusedEntity.fluid_box.flow, "input")
            and external:interactable() and external:target_interactable() and Util.filter_accepts_fluid(external.filters.fluid, external.whitelistBlacklist, fluid.name) then
                local e_fluid_box = external.focusedEntity.fluid_box
                local e_fluid = external.focusedEntity.thisEntity.fluidbox[e_fluid_box.index]
                if e_fluid == nil and e_fluid_box.filter ~= "" and e_fluid_box.filter ~= fluid.name then
                    network:remove_cache("import", "external", fluid.name)
                elseif e_fluid ~= nil and e_fluid.name ~= fluid.name then
                    network:remove_cache("import", "external", fluid.name)
                end
                extractSize = BaseNet.insert_fluid_into_external(external, extractSize, fluid_box, fluid, storedFluidTemperature, storedFluidAmount, from_tank)
                if extractSize <= 0 then return 0 end
            else
                network:remove_cache("import", "external", fluid.name)
            end
        end
    end
    for p = 1, Constants.Settings.RNS_Max_Priority*2 + 1 do
        local priorityF = network.FluidDriveTable[p]
        local priorityE = network.ExternalIOTable[p].fluid

        for _, drive in pairs(priorityF) do
            if drive:interactable() and Util.filter_accepts_fluid(drive.filters, drive.whitelistBlacklist, fluid.name) and drive:getRemainingStorageSize() > 0 then
                extractSize = BaseNet.insert_fluid_into_drive(drive, fluid, extractSize, storedFluidTemperature, storedFluidAmount, from_tank, fluid_box)
                if extractSize <= 0 then
                    network:put_cache("import", "drive", fluid.name, drive)
                    return 0
                end
            end
        end

        for _, external in pairs(priorityE) do
            if external.type == "fluid" and string.match(external.io, "input") ~= nil and string.match(external.focusedEntity.fluid_box.flow, "input")
            and external:interactable() and external:target_interactable() and Util.filter_accepts_fluid(external.filters.fluid, external.whitelistBlacklist, fluid.name) then
                local e_fluid_box = external.focusedEntity.fluid_box
                local e_fluid = external.focusedEntity.thisEntity.fluidbox[e_fluid_box.index]
                if e_fluid == nil and e_fluid_box.filter ~= "" and e_fluid_box.filter ~= fluid.name then
                    network:remove_cache("import", "external", fluid.name)
                elseif e_fluid ~= nil and e_fluid.name ~= fluid.name then
                    network:remove_cache("import", "external", fluid.name)
                end
                extractSize = BaseNet.insert_fluid_into_external(external, extractSize, fluid_box, fluid, storedFluidTemperature, storedFluidAmount, from_tank)
                if extractSize <= 0 then
                    network:put_cache("import", "external", fluid.name, external)
                    return 0
                end
            end
        end
    end

    return extractSize
end

function BaseNet.inventory_is_sortable(inv)
    return BaseNet.entity_is_sortable(inv.entity_owner)
end

function BaseNet.entity_is_sortable(ent)
    if ent ~= nil and ent.prototype.type == "lab" then return false end
    return true
end

--Meant for exporting from the network. Exporting is always whitelisted
function BaseNet.transfer_from_drive_to_inv(drive_inv, to_inv, itemstack_data, count, allowMetadata)
    allowMetadata = allowMetadata or false
    --drive_inv:get_sorted_and_merged_inventory()
    local amount = count
    local list = drive_inv.storageArray
    --local inventory = drive_inv.storageArray.inventory
    for i=1, 1 do
        if BaseNet.inventory_is_sortable(to_inv) then to_inv.sort_and_merge() end
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
        if amount <= 0 then amount = 0 break end
    end
    return count - amount
end

function BaseNet.transfer_from_inv_to_inv(from_inv, to_inv, itemstack_data, external_data, count, allowModified, whitelist)
    local amount = count
    allowModified = allowModified or false
    whitelist = whitelist or false
    if BaseNet.inventory_is_sortable(from_inv) then from_inv.sort_and_merge() end
    if BaseNet.inventory_is_sortable(to_inv) then to_inv.sort_and_merge() end
    
    for i = 1, #from_inv do
        local mod = false
        local itemstack = from_inv[i]
        if itemstack_data ~= nil and whitelist == true then
            itemstack, i = from_inv.find_item_stack(itemstack_data.cont.name)
            if itemstack == nil then break end
        end
        if itemstack.count <= 0 then goto continue end
        local itemstackC = Util.itemstack_convert(itemstack)
        if itemstack_data ~= nil then
            if whitelist == false then
                if game.item_prototypes[itemstackC.cont.name] == game.item_prototypes[itemstack_data.cont.name] then
                    goto continue
                else
                    itemstack_data = Util.itemstack_template(itemstackC.cont.name)
                end
            end
        else
            itemstack_data = Util.itemstack_template(itemstackC.cont.name)
        end
        if external_data ~= nil then
            if external_data.onlyModified == true and itemstack_data.modified == false and string.match(external_data.io, "input") ~= nil then goto continue end
            if not Util.filter_accepts_item(external_data.filters.item, external_data.whitelistBlacklist, itemstack_data.cont.name) then goto continue end
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
                    item1, j = to_inv.find_empty_stack(itemstackC.name)
                    if item1 == nil then break end
                    if item1.count > 0 then goto continue end
                    if item1.transfer_stack(itemstack) then
                        amount = amount - itemstack.count
                        break
                    end
                    ::continue::
                end
            end
        end
        if amount <= 0 then amount = 0 break end
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
    if BaseNet.inventory_is_sortable(from_inv) then from_inv.sort_and_merge() end

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
        end
        if amount <= 0 then break end
        ::continue::
    end
    return count - amount
end

function BaseNet.transfer_from_network_to_inv(network, target, itemstack_master, transferCapacity, supportModified)

    return transferCapacity
end

function BaseNet.insert_item_into_drive(item, inv_item, drive, transferCapacity, itemstack_master, remainingStorage)
    local extractSize = math.min(math.min(transferCapacity, inv_item.count), remainingStorage)
    local splitStack = inv_item:split(itemstack_master, extractSize, false)
    transferCapacity = transferCapacity - drive:add_or_merge_basic_item(splitStack, extractSize)
    item.count = inv_item.count
    if item.count > 0 then
        if inv_item.ammo ~= nil then item.ammo = inv_item.ammo end
        if inv_item.durability ~= nil then item.durability = inv_item.durability end
    end
    return transferCapacity
end

function BaseNet.insert_item_into_external(external, item, inv_item, itemstack_master, transferCapacity)
    for k = 1, external.focusedEntity.inventory.input.max do
        if transferCapacity <= 0 then break end
        local ext_inv = external.focusedEntity.thisEntity.get_inventory(external.focusedEntity.inventory.input.values[external.focusedEntity.inventory.input.index])
        local insertableAmount = ext_inv.get_insertable_count(inv_item.name)
        if insertableAmount > 0 then
            local extractSize = math.min(math.min(transferCapacity, inv_item.count), insertableAmount)
            local splitStack = inv_item:split(itemstack_master, extractSize, false)

            if inv_item.modified == false or inv_item.health ~= 1.0 then
                transferCapacity = transferCapacity - ext_inv.insert(splitStack)
                item.count = inv_item.count
                if item.count > 0 then
                    if inv_item.ammo ~= nil then item.ammo = inv_item.ammo end
                    if inv_item.durability ~= nil then item.durability = inv_item.durability end
                end
            else
                local slot, index = ext_inv.find_empty_stack(inv_item.name)
                if slot ~= nil then
                    transferCapacity = transferCapacity - (ext_inv[index].transfer_stack(item) and item.count or 0)
                    break
                end
            end
        end
        Util.next_index(external.focusedEntity.inventory.input)
    end
    return transferCapacity
end

function BaseNet.transfer_from_inv_to_network(network, from_inv, itemstack_master, filters, whitelistBlacklist, transferCapacity, supportModified)
    for i = 1, from_inv.inventory.output.max do
        local inv = from_inv.thisEntity.get_inventory(from_inv.inventory.output.values[from_inv.inventory.output.index])
        if BaseNet.inventory_is_sortable(inv) then inv.sort_and_merge() end
        for j = 1, #inv do
            if transferCapacity <= 0 then return 0 end
            local item = inv[j]
            if item == nil then return 0 end
            if item.valid_for_read == false or item.count <= 0 then return 0 end
            local master = itemstack_master or Itemstack.create_template(item.name)
            if whitelistBlacklist == "whitelist" then item, j = inv.find_item_stack(itemstack_master.name) end

            if Util.filter_accepts_item(filters, whitelistBlacklist, item.name) then
                local inv_item = Itemstack:new(item)
                if inv_item == nil then goto next end
                if supportModified == false and inv_item.modified == true then goto next end

                if network:has_cache("import", "drive", inv_item.name) and inv_item.modified == false then
                    local drive = network:get_cache("import", "drive", inv_item.name)
                    if drive.valid == false then
                        network:remove_cache("import", "drive", inv_item.name)
                    else
                        local remainingStorage = drive:getRemainingStorageSize()
                        if drive:interactable() and Util.filter_accepts_item(drive.filters, drive.whitelistBlacklist, inv_item.name) and remainingStorage > 0
                        and master:compare_itemstacks(inv_item) then
                            transferCapacity = BaseNet.insert_item_into_drive(item, inv_item, drive, transferCapacity, master, remainingStorage)
                            if transferCapacity <= 0 then return 0 end
                            if inv_item.count <= 0 then goto next end
                        else
                            network:remove_cache("import", "drive", item.name)
                        end
                    end
                end
                if network:has_cache("import", "external", item.name) then
                    local external = network:get_cache("import", "external", inv_item.name)
                    if external.valid == false then
                        network:remove_cache("import", "external", inv_item.name)
                    else
                        if external:interactable() and external:target_interactable() and string.match(external.io, "input") ~= nil and external.type == "item"
                        and Util.filter_accepts_item(external.filters.item, external.whitelistBlacklist, inv_item.name) and external.focusedEntity.inventory.input.max ~= 0
                        and master:compare_itemstacks(inv_item) then
                            transferCapacity = BaseNet.insert_item_into_external(external, item, inv_item, master, transferCapacity)
                            if transferCapacity <= 0 then return 0 end
                            if inv_item.count <= 0 then goto next end
                        else
                            network:remove_cache("import", "external", inv_item.name)
                        end
                    end
                end
                for p = 1, Constants.Settings.RNS_Max_Priority*2 + 1 do
                    local priorityD = network.ItemDriveTable[p]
                    local priorityE = network.ExternalIOTable[p].item
                    if inv_item.modified == false then
                        for _, drive in pairs(priorityD) do
                            local remainingStorage = drive:getRemainingStorageSize()
                            if drive:interactable() and Util.filter_accepts_item(drive.filters, drive.whitelistBlacklist, item.name) and remainingStorage > 0
                            and master:compare_itemstacks(inv_item) then
                                transferCapacity = BaseNet.insert_item_into_drive(item, inv_item, drive, transferCapacity, master, remainingStorage)
                                if transferCapacity <= 0 then
                                    network:put_cache("import", "drive", drive)
                                    return 0
                                end
                                if inv_item.count <= 0 then goto next end
                            end
                        end
                    end

                    for _, external in pairs(priorityE) do
                        if external:interactable() and external:target_interactable() and string.match(external.io, "input") ~= nil and external.type == "item"
                        and Util.filter_accepts_item(external.filters.item, external.whitelistBlacklist, inv_item.name) and external.focusedEntity.inventory.input.max ~= 0
                        and master:compare_itemstacks(inv_item) then
                            transferCapacity = BaseNet.insert_item_into_external(external, item, inv_item, master, transferCapacity)
                            if transferCapacity <= 0 then
                                network:put_cache("import", "external", external)
                                return 0
                            end
                            if inv_item.count <= 0 then goto next end
                        end
                    end
                end
            end
            ::next::
        end
        Util.next_index(from_inv.inventory.output)
    end
    return transferCapacity
end

function BaseNet.getOperableObjects(array, group)
    local objs = {}
    for p, priority in pairs(array) do
        if group == "io" then
            objs[p] = {
                input = {},
                output = {}
            }
            for mode, io in pairs(priority) do
                for _, o in pairs(io) do
                    if o.thisEntity.valid and o.thisEntity.to_be_deconstructed() == false then
                        objs[p][mode][o.entID] = o
                    end
                end
            end
        elseif group == "eo" then
            objs[p] = {
                item = {},
                fluid = {}
            }
            for mode, io in pairs(priority) do
                for _, o in pairs(io) do
                    if o.thisEntity.valid and o.thisEntity.to_be_deconstructed() == false then
                        objs[p][mode][o.entID] = o
                    end
                end
            end
        else
            objs[p] = {}
            for _, o in pairs(priority) do
                if o.thisEntity.valid and o.thisEntity.to_be_deconstructed() == false then
                    objs[p][o.entID] = o
                end
            end
        end
    end
    return objs
end

function BaseNet:filter_externalIO_by_valid_signal()
    local objs = {}
    for p, priority in pairs(self.ExternalIOTable) do
        objs[p] = {}
        for m, mode in pairs(priority) do
            objs[p][m] = {}
            for _, o in pairs(mode) do
                if o:signal_valid() == true then
                    o:check_focused_entity()
                    objs[p][m][o.entID] = o
                end
            end
        end
    end
    return objs
end

--Used for the External Bus
function BaseNet.filter_by_mode(mode, array)
    local objs = {}
    for p, priority in pairs(array) do
        objs[p] = {}
        for _, m in pairs(priority) do
            for _, o in pairs(m) do
                if string.match(o.io, mode) ~= nil then
                    objs[p][o.entID] = o
                end
            end
        end
    end
    return objs
end

--Used for the External Bus
function BaseNet.filter_by_type(type, array)
    local objs = {}
    for p, priority in pairs(array) do
        objs[p] = {}
        for _, o in pairs(priority[type]) do
            objs[p][o.entID] = o
        end
    end
    return objs
end

--Used for the Drives
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

function BaseNet.get_table_length_in_priority(array, hasIOGroup, getNil)
    local count = 0
    for _, p in pairs(array) do
        if hasIOGroup then
            for _, io in pairs(p) do
                count = count + (getNil and {Util.getTableLength_non_nil(io)} or {Util.getTableLength(io)})[1]
            end
        else
            count = count + (getNil and {Util.getTableLength_non_nil(p)} or {Util.getTableLength(p)})[1]
        end
    end
    return count
end

function BaseNet.get_powerusage(array, hasIOGroup)
    local power = 0
    for _, p in pairs(array) do
        if hasIOGroup then
            for _, io in pairs(p) do
                for _, o in pairs(io) do
                    power = power + o.powerUsage
                end
            end
        else
            for _, o in pairs(p) do
                power = power + o.powerUsage
            end
        end
        
    end
    return power
end

--Get total powerusage of connected objects
function BaseNet:getTotalObjects()
    return  BaseNet.get_powerusage(BaseNet.getOperableObjects(self.ItemDriveTable)) + BaseNet.get_powerusage(BaseNet.getOperableObjects(self.FluidDriveTable))
            + BaseNet.get_powerusage(BaseNet.getOperableObjects(self.ItemIOTable, "io"), true)*global.IIOMultiplier + BaseNet.get_powerusage(BaseNet.getOperableObjects(self.FluidIOTable, "io"), true)*global.FIOMultiplier
            + BaseNet.get_powerusage(BaseNet.getOperableObjects(self.ExternalIOTable, "eo"), true) + BaseNet.get_powerusage(BaseNet.getOperableObjects(self.NetworkInventoryInterfaceTable))
            + BaseNet.get_powerusage(BaseNet.getOperableObjects(self.WirelessTransmitterTable))*global.WTRangeMultiplier + BaseNet.get_powerusage(BaseNet.getOperableObjects(self.DetectorTable))
            + BaseNet.get_powerusage(BaseNet.getOperableObjects(self.TransmitterTable)) + BaseNet.get_powerusage(BaseNet.getOperableObjects(self.ReceiverTable))
end