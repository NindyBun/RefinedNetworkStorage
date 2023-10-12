IIO = {
    thisEntity = nil,
    entID = nil,
    networkController = nil,
    color = "RED",
    arms = nil,
    connectedObjs = nil,
    focusedEntity = nil,
    cardinals = nil,
    filters = nil,
    metadataMode = false,
    whitelist = true,
    io = "output",
    ioIcon = nil,
    enabler = nil,
    enablerCombinator = nil,
    combinator = nil,
    processed = false,
    priority = 0,
    powerUsage = 4,
}

function IIO:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = IIO
    t.thisEntity = object
    t.entID = object.unit_number
    --[[
    if global.placedCablesTable[tostring(object.surface.index)][tostring(object.position.x)] ~= nil and global.placedCablesTable[tostring(object.surface.index)][tostring(object.position.x)][tostring(object.position.y)] ~= nil then
        t.color = global.placedCablesTable[tostring(object.surface.index)][tostring(object.position.x)][tostring(object.position.y)].ent.color
    end
    ]]
    rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[t.color].sprites[5].name, target=t.thisEntity, surface=t.thisEntity.surface, render_layer="lower-object-above-shadow"}
    t:generateModeIcon()
    t.cardinals = {
        [1] = false, --N
        [2] = false, --E
        [3] = false, --S
        [4] = false, --W
    }
    t.arms = {
        [1] = nil, --N
        [2] = nil, --E
        [3] = nil, --S
        [4] = nil, --W
    }
    t.connectedObjs = {
        [1] = {}, --N
        [2] = {}, --E
        [3] = {}, --S
        [4] = {}, --W
    }
    t.filters = {
        index = 1,
        values = {
            [1] = "",
            [2] = ""
        }
    }
    t.focusedEntity = {
        thisEntity = nil,
        inventory = {
            index = 1,
            values = nil
        }
    }
    t:createArms()
    t.combinator = object.surface.create_entity{
        name="RNS_Combinator",
        position=object.position,
        force="neutral"
    }
    t.combinator.destructible = false
    t.combinator.operable = false
    t.combinator.minable = false
    t.enabler = {
        operator = "<",
        number = 0,
        filter = nil,
        numberOutput = 1
    }
    t.enablerCombinator = object.surface.create_entity{
        name="RNS_Combinator_2",
        position=object.position,
        force="neutral"
    }
    t.enablerCombinator.destructible = false
    t.enablerCombinator.operable = false
    t.enablerCombinator.minable = false
    UpdateSys.addEntity(t)
    return t
end

function IIO:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = IIO
    setmetatable(object, mt)
end

function IIO:remove()
    if self.combinator ~= nil then self.combinator.destroy() end
    if self.enablerCombinator ~= nil then self.enablerCombinator.destroy() end
    UpdateSys.remove(self)
    if self.networkController ~= nil then
        self.networkController.network.ItemIOTable[Constants.Settings.RNS_Max_Priority+1-self.priority][self.entID] = nil
        self.networkController.network.shouldRefresh = true
    end
end

function IIO:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function IIO:copy_settings(obj)
    self.color = obj.color
    self.metadataMode = obj.metadataMode
    self.whitelist = obj.whitelist
    self.io = obj.io
    self.enabler = obj.enabler

    self.filters = obj.filters
    self:set_icons(1, self.filters.values[1] ~= "" and self.filters.values[1] or nil)
    self:set_icons(2, self.filters.values[2] ~= "" and self.filters.values[2] or nil)

    self.priority = obj.priority
    self:generateModeIcon()
end

function IIO:serialize_settings()
    local tags = {}

    tags["color"] = self.color
    tags["filters"] = self.filters
    tags["metadataMode"] = self.metadataMode
    tags["whitelist"] = self.whitelist
    tags["io"] = self.io
    tags["priority"] = self.priority
    tags["enabler"] = self.enabler

    return tags
end

function IIO:deserialize_settings(tags)
    self.color = tags["color"]
    self.metadataMode = tags["metadataMode"]
    self.whitelist = tags["whitelist"]
    self.io = tags["io"]
    self.enabler = tags["enabler"]

    self.filters = tags["filters"]
    self:set_icons(1, self.filters.values[1] ~= "" and self.filters.values[1] or nil)
    self:set_icons(2, self.filters.values[2] ~= "" and self.filters.values[2] or nil)

    self.priority = tags["priority"]
    self:generateModeIcon()
end

function IIO:update()
    if valid(self) == false then
        self:remove()
        return
    end
    if valid(self.networkController) == false then
        self.networkController = nil
    end
    if self.thisEntity.to_be_deconstructed() == true then return end
    if self.focusedEntity.thisEntity ~= nil and self.focusedEntity.thisEntity.valid == false then
        self:reset_focused_entity()
    end
    --if game.tick % 25 then self:createArms() end
end

function IIO:toggleHoverIcon(hovering)
    if self.ioIcon == nil then return end
    if hovering and rendering.get_only_in_alt_mode(self.ioIcon) then
        rendering.set_only_in_alt_mode(self.ioIcon, false)
    elseif not hovering and not rendering.get_only_in_alt_mode(self.ioIcon) then
        rendering.set_only_in_alt_mode(self.ioIcon, true)
    end
end

function IIO:generateModeIcon()
    if self.ioIcon ~= nil then rendering.destroy(self.ioIcon) end
    local offset = {0, 0}
    if self:getRealDirection() == 1 then
        offset = {0,-0.5}
    elseif self:getRealDirection() == 2 then
        offset = {0.5, 0}
    elseif self:getRealDirection() == 3 then
        offset = {0,0.5}
    elseif self:getRealDirection() == 4 then
        offset = {-0.5,0}
    end
    self.ioIcon = rendering.draw_sprite{
        sprite=Constants.Icons.item, 
        target=self.thisEntity, 
        target_offset=offset,
        surface=self.thisEntity.surface,
        only_in_alt_mode=true,
        orientation=self.io == "input" and ((self:getRealDirection()*0.25)+0.25)%1.00 or ((self:getRealDirection()*0.25)-0.25)
    }
end

--Transport Belts do not have an inventory, only an array. Meaning we can only input/output default items, no modified items because we can't access the inventory.
--We are not using this at all due to the lack of lua access untill i can find a way to bypass it
--[[function IIO:transportIO()
    if self.networkController == nil or self.networkController.valid == false or self.networkController.stable == false then return end
    local network = self.networkController.network
    if self.focusedEntity ~= nil and self.focusedEntity.valid == true then
        local foc = self.focusedEntity
        if foc.type == "transport-belt" or foc.type == "underground-belt" or foc.type == "splitter" or foc.type == "loader" or foc.type == "loader-1x1" then
            local beltDir = Util.direction(foc)
            local ioDir = self:getRealDirection()
            local transportLine = nil
            if ioDir == beltDir then
                transportLine = "Back"
            elseif math.abs(ioDir-beltDir) == 2 then
                transportLine = "Front"
            elseif beltDir-1 == ioDir%4 then
                transportLine = "Right"
            elseif ioDir-1 == beltDir%4 then
                transportLine = "Left"
            end

            if Constants.Settings.RNS_BeltSides[transportLine] ~= nil and foc.type ~= "splitter" and foc.type ~= "loader" and foc.type ~= "loader-1x1" then
                local line = foc.get_transport_line(Constants.Settings.RNS_BeltSides[transportLine])
                if self.io == "input" then
                    local ind = self.filters.index
                    repeat
                        local a = line.remove_item(Util.next(self.filters))
                    until a ~= 0 or ind == self.filters.index
                    return
                elseif self.io == "output" then
                    local pos = 0.75
                    if foc.type == "underground-belt" then
                        pos = 0.25
                    end
                    if line.can_insert_at(pos) then
                        local ind = self.filters.index
                        repeat
                            local a = line.insert_at(pos, Util.next(self.filters))
                        until a == true or ind == self.filters.index
                    end
                    return
                end
            else
                local lineL = foc.get_transport_line(1)
                local lineR = foc.get_transport_line(2)
                
                if foc.type == "underground-belt" then
                    lineL = foc.get_transport_line(3)
                    lineR = foc.get_transport_line(4)
                elseif foc.type == "splitter" then
                    local axis = Util.axis(foc)
                    if (foc.position.x > self.thisEntity.position.x and axis == "y") or (foc.position.y > self.thisEntity.position.y and axis == "x") then
                        if transportLine == "Back" then
                            lineL = foc.get_transport_line(1)
                            lineR = foc.get_transport_line(2)
                        elseif transportLine == "Front" then
                            lineL = foc.get_transport_line(5)
                            lineR = foc.get_transport_line(6)
                        end
                    elseif (foc.position.x < self.thisEntity.position.x and axis == "y") or (foc.position.y < self.thisEntity.position.y and axis == "x") then
                        if transportLine == "Back" then
                            lineL = foc.get_transport_line(3)
                            lineR = foc.get_transport_line(4)
                        elseif transportLine == "Front" then
                            lineL = foc.get_transport_line(7)
                            lineR = foc.get_transport_line(8)
                        end
                    end
                end
                
                if self.io == "input" then
                    if transportLine == "Back" then
                        --Do nothing
                    elseif transportLine == "Front" then
                        if foc.type == "underground-belt" and foc.belt_to_ground_type == "input" then return end
                        if foc.type == "underground-belt" and foc.belt_to_ground_type == "output" then
                            lineL = foc.get_transport_line(1)
                            lineR = foc.get_transport_line(2)
                        end
                    end

                    local ind = self.filters.index
                    repeat
                        local a = lineL.remove_item(Util.next(self.filters))
                    until a ~= 0 or ind == self.filters.index

                    ind = self.filters.index
                    repeat
                        local a = lineR.remove_item(Util.next(self.filters))
                    until a ~= 0 or ind == self.filters.index

                    return
                elseif self.io == "output" then
                    local pos = 0.75
                    if transportLine == "Back" then
                        if foc.type == "loader" and foc.loader_type == "input" then
                            pos = 0.125
                        elseif foc.type == "splitter" then
                            pos = 0.125
                        end
                    elseif transportLine == "Front" and foc.type ~= "underground-belt" then
                        pos = 0.25
                        if foc.type == "loader-1x1" and foc.loader_type == "input" then return end
                        if foc.type == "loader" and foc.loader_type == "input" then return end
                        if foc.type == "loader" and foc.loader_type == "output" then
                            pos = 0.125
                        elseif foc.type == "splitter" then
                            pos = 0.125
                        end
                    end
                    
                    if lineL.can_insert_at(pos) then
                        local ind = self.filters.index
                        repeat
                            local a = lineL.insert_at(pos, Util.next(self.filters))
                        until a == true or ind == self.filters.index
                    end
                    if lineR.can_insert_at(pos) then
                        local ind = self.filters.index
                        repeat
                            local a = lineR.insert_at(pos, Util.next(self.filters))
                        until a == true or ind == self.filters.index
                    end

                    return
                end
            end
        end
    end
end]]

function IIO.has_item(inv, itemstack_data, metadataMode)
    local amount = 0
    for i = 1, #inv do
        local itemstack = inv[i]
        if itemstack.count <= 0 then goto continue end
        local itemstackC = Util.itemstack_convert(itemstack)
        if Util.itemstack_matches(itemstack_data, itemstackC, metadataMode) then
            if game.item_prototypes[itemstack_data.cont.name] == game.item_prototypes[itemstackC.cont.name] then
                if itemstack_data.cont.ammo and itemstackC.cont.ammo and itemstack_data.cont.ammo < game.item_prototypes[itemstackC.cont.name].magazine_size then
                    amount = amount + 1
                    goto continue
                end
                if itemstack_data.cont.durability and itemstackC.cont.durability and itemstack_data.cont.durability < game.item_prototypes[itemstackC.cont.name].durability then
                    amount = amount + 1
                    goto continue
                end
            end
            amount = amount + itemstack.count
        elseif game.item_prototypes[itemstack_data.cont.name] == game.item_prototypes[itemstackC.cont.name] then
            if itemstack_data.cont.ammo and itemstackC.cont.ammo and itemstack_data.cont.ammo > itemstackC.cont.ammo and itemstackC.cont.count > 1 then
                amount = amount + itemstack.count - 1
            end
            if itemstack_data.cont.durability and itemstackC.cont.durability and itemstack_data.cont.durability > itemstackC.cont.durability and itemstackC.cont.count > 1 then
                amount = amount + itemstack.count - 1
            end
        end
        ::continue::
    end
    return amount
end

function IIO.check_operable_mode(io, mode)
    return string.match(io, mode) ~= nil
end

function IIO.matches_filters(name, filters)
    for _, name1 in pairs(filters) do
        if name == name1 then return true end
    end
    return false
end

function IIO:IO()
    local transportCapacity = Constants.Settings.RNS_BaseItemIO_TransferCapacity*global.IIOMultiplier
    for k=1, 1 do
        if self.networkController == nil or self.networkController.valid == false or self.networkController.stable == false then break end
        local network = self.networkController.network
        if self.enablerCombinator.get_circuit_network(defines.wire_type.red, defines.circuit_connector_id.constant_combinator) ~= nil or self.enablerCombinator.get_circuit_network(defines.wire_type.green, defines.circuit_connector_id.constant_combinator) ~= nil then
            if self.enabler.filter == nil then break end
            local amount = self.enablerCombinator.get_merged_signal({type=self.enabler.filter.type, name=self.enabler.filter.name}, defines.circuit_connector_id.constant_combinator)
            if Util.OperatorFunctions[self.enabler.operator](amount, self.enabler.number) == false then break end
        end
        if self.focusedEntity.thisEntity ~= nil and self.focusedEntity.thisEntity.valid == true and self.focusedEntity.inventory.values ~= nil then
            local foc = self.focusedEntity.thisEntity
            local itemDrives = BaseNet.getOperableObjects(network.ItemDriveTable)
            local externalInvs = BaseNet.filter_by_type("item", BaseNet.getOperableObjects(network:filter_externalIO_by_valid_signal()))
            for i = 1, Constants.Settings.RNS_Max_Priority*2 + 1 do
                local priorityD = itemDrives[i]
                local priorityE = externalInvs[i]
                if Util.getTableLength(priorityD) > 0 then
                    for _, drive in pairs(priorityD) do
                        if self.io == "input" then
                            if not drive:has_room() then goto next end
                            if Util.getTableLength_non_nil(self.filters.values) > 0 then
                                local index = 0
                                repeat
                                    local nextItem = Util.next_non_nil(self.filters)
                                    if nextItem == "" then goto exit end
                                    local itemstack = Util.itemstack_template(nextItem)
                
                                    local index1 = 0
                                    repeat
                                        local ii = Util.next(self.focusedEntity.inventory)
                                        local inv = foc.get_inventory(ii.slot)
                                        if inv ~= nil then
                                            local isOperable = IIO.check_operable_mode(ii.io, "output") and not inv.is_empty()
                                            if isOperable == true then
                                                transportCapacity = transportCapacity - BaseNet.transfer_from_inv_to_drive(inv, drive, itemstack, self.filters.values, math.min(transportCapacity, drive:getRemainingStorageSize()), self.metadataMode, self.whitelist)
                                                if transportCapacity <= 0 then goto exit end
                                            end
                                        end
                                        index1 = index1 + 1
                                    until index1 == Util.getTableLength(self.focusedEntity.inventory.values)
                                    index = index + 1
                                until index == Util.getTableLength(self.filters.values)
                                goto next
                            elseif Util.getTableLength_non_nil(self.filters.values) == 0 and self.whitelist == false then
                                local index = 0
                                repeat
                                    local ii = Util.next(self.focusedEntity.inventory)
                                    local inv = foc.get_inventory(ii.slot)
                                    if inv ~= nil then
                                        local isOperable = IIO.check_operable_mode(ii.io, "output") and not inv.is_empty()
                                        if isOperable == true then
                                            transportCapacity = transportCapacity - BaseNet.transfer_from_inv_to_drive(inv, drive, nil, nil, math.min(transportCapacity, drive:getRemainingStorageSize()), self.metadataMode, false)
                                            if transportCapacity <= 0 then goto exit end
                                        end
                                    end
                                    index = index + 1
                                until index == Util.getTableLength(self.focusedEntity.inventory.values)
                                goto next
                            end
                        elseif self.io == "output" and self.whitelist == true and Util.getTableLength_non_nil(self.filters.values) > 0 then
                            local index = 0
                            repeat
                                local nextItem = Util.next_non_nil(self.filters)
                                if nextItem == "" then goto exit end
    
                                local itemstack = Util.itemstack_template(nextItem)
                                local has = drive:has_item(itemstack, self.metadataMode)
    
                                if has > 0 then
                                    local index1 = 0
                                    repeat
                                        local ii = Util.next(self.focusedEntity.inventory)
                                        local inv = foc.get_inventory(ii.slot)
                                        if inv ~= nil then
                                            local isOperable = IIO.check_operable_mode(ii.io, "input") and inv.can_insert(itemstack.cont)
                                            if isOperable == true then
                                                transportCapacity = transportCapacity - BaseNet.transfer_from_drive_to_inv(drive, inv, itemstack, transportCapacity, self.metadataMode)
                                                if transportCapacity <= 0 then goto exit end
                                            end
                                        end
                                        index1 = index1 + 1
                                    until index1 == Util.getTableLength(self.focusedEntity.inventory.values)
                                end
                                index = index + 1
                            until index == Util.getTableLength(self.filters.values)
                            goto next
                        end
                        ::next::
                    end
                end
                if Util.getTableLength(priorityE) > 0 then
                    for _, externalInv in pairs(priorityE) do
                        if externalInv.focusedEntity.thisEntity ~= nil and externalInv.focusedEntity.thisEntity.valid and externalInv.focusedEntity.thisEntity.to_be_deconstructed() == false and externalInv.focusedEntity.inventory.values ~= nil then
                            if self.io == "input" then
                                if string.match(externalInv.io, "input") == nil then goto next end
                                if Util.getTableLength_non_nil(self.filters.values) > 0 then
                                    local index = 0
                                    repeat
                                        local nextItem = Util.next_non_nil(self.filters)
                                        if nextItem == "" then goto exit end
                                        local itemstack = Util.itemstack_template(nextItem)
                                        if Util.getTableLength_non_nil(externalInv.filters.item.values) > 0 then
                                            if externalInv:matches_filters("item", itemstack.cont.name) == true then
                                                if externalInv.whitelist == false then goto next end
                                            else
                                                if externalInv.whitelist == true then goto next end
                                            end
                                        elseif Util.getTableLength_non_nil(externalInv.filters.item.values) == 0 then
                                            if externalInv.whitelist == true then goto next end
                                        end
                    
                                        local index1 = 0
                                        repeat
                                            local ii = Util.next(self.focusedEntity.inventory)
                                            local inv = foc.get_inventory(ii.slot)
                                            if inv ~= nil then
                                                local isOperable = IIO.check_operable_mode(ii.io, "output") and not inv.is_empty()
                                                if isOperable == true then
                                                    local index2 = 0
                                                    repeat
                                                        local ii1 = Util.next(externalInv.focusedEntity.inventory)
                                                        local inv1 = externalInv.focusedEntity.thisEntity.get_inventory(ii1.slot)
                                                        if inv1 ~= nil then
                                                            inv1.sort_and_merge()
                                                            if EIO.has_item_room(inv1) == true and IIO.check_operable_mode(ii1.io, "input") then
                                                                local meta = false
                                                                if self.metadataMode == externalInv.metadataMode and self.metadataMode == true then
                                                                    meta = true
                                                                end
                                                                transportCapacity = transportCapacity - BaseNet.transfer_from_inv_to_inv(inv, inv1, itemstack, nil, transportCapacity, meta, self.whitelist)
                                                                if transportCapacity <= 0 then goto exit end
                                                            end
                                                        end
                                                        index2 = index2 + 1
                                                    until index2 == Util.getTableLength(externalInv.focusedEntity.inventory.values)
                                                end
                                            end
                                            index1 = index1 + 1
                                        until index1 == Util.getTableLength(self.focusedEntity.inventory.values)
                                        index = index + 1
                                    until index == Util.getTableLength(self.filters.values)
                                    goto next
                                elseif Util.getTableLength_non_nil(self.filters.values) == 0 and self.whitelist == false then
                                    local index = 0
                                    repeat
                                        local ii = Util.next(self.focusedEntity.inventory)
                                        local inv = foc.get_inventory(ii.slot)
                                        if inv ~= nil then
                                            local isOperable = IIO.check_operable_mode(ii.io, "output") and not inv.is_empty()
                                            if isOperable == true then
                                                local index1 = 0
                                                repeat
                                                    local ii1 = Util.next(externalInv.focusedEntity.inventory)
                                                    local inv1 = externalInv.focusedEntity.thisEntity.get_inventory(ii1.slot)
                                                    if inv1 ~= nil then
                                                        inv1.sort_and_merge()
                                                        if EIO.has_item_room(inv1) == true and IIO.check_operable_mode(ii1.io, "input") then
                                                            if Util.getTableLength_non_nil(externalInv.filters.item.values) == 0 then
                                                                if externalInv.whitelist == true then goto next end
                                                            end
                                                            local meta = false
                                                            if self.metadataMode == externalInv.metadataMode and self.metadataMode == true then
                                                                meta = true
                                                            end
                                                            transportCapacity = transportCapacity - BaseNet.transfer_from_inv_to_inv(inv, inv1, nil, externalInv, transportCapacity, meta, false)
                                                            if transportCapacity <= 0 then goto exit end
                                                        end
                                                    end
                                                    index1 = index1 + 1
                                                until index1 == Util.getTableLength(externalInv.focusedEntity.inventory.values)
                                            end
                                        end
                                        index = index + 1
                                    until index == Util.getTableLength(self.focusedEntity.inventory.values)
                                    goto next
                                end
                            elseif self.io == "output" and self.whitelist == true and Util.getTableLength_non_nil(self.filters.values) > 0 then
                                if string.match(externalInv.io, "output") == nil then goto next end
                                local index = 0
                                repeat
                                    local nextItem = Util.next_non_nil(self.filters)
                                    if nextItem == "" then goto exit end
        
                                    local itemstack = Util.itemstack_template(nextItem)
                                    local index1 = 0
                                    repeat
                                        local ii = Util.next(externalInv.focusedEntity.inventory)
                                        local inv = externalInv.focusedEntity.thisEntity.get_inventory(ii.slot)
                                        if inv ~= nil and IIO.check_operable_mode(ii.io, "output") then
                                            inv.sort_and_merge()
                                            local has = EIO.has_item(inv, itemstack, self.metadataMode)
            
                                            if has > 0 then
                                                local index2 = 0
                                                repeat
                                                    local ii1 = Util.next(self.focusedEntity.inventory)
                                                    local inv1 = foc.get_inventory(ii1.slot)
                                                    if inv1 ~= nil then
                                                        local isOperable = IIO.check_operable_mode(ii1.io, "input") and inv1.can_insert(itemstack.cont)
                                                        if isOperable == true then
                                                            local meta = false
                                                            if self.metadataMode == externalInv.metadataMode and self.metadataMode == true then
                                                                meta = true
                                                            end
                                                            transportCapacity = transportCapacity - BaseNet.transfer_from_inv_to_inv(inv, inv1, itemstack, nil, transportCapacity, meta, true)
                                                            if transportCapacity <= 0 then goto exit end
                                                        end
                                                    end
                                                    index2 = index2 + 1
                                                until index2 == Util.getTableLength(self.focusedEntity.inventory.values)
                                            end
                                        end
                                        index1 = index1 + 1
                                    until index1 == Util.getTableLength(externalInv.focusedEntity.inventory.values)
                                    index = index + 1
                                until index == Util.getTableLength(self.filters.values)
                                goto next
                            end
                        end
                        ::next::
                    end
                end
            end
        end
        ::exit::
    end
    self.processed = transportCapacity < Constants.Settings.RNS_BaseItemIO_TransferCapacity
end

function IIO:resetConnection()
    self.connectedObjs = {
        [1] = {}, --N
        [2] = {}, --E
        [3] = {}, --S
        [4] = {}, --W
    }
    for _, arm in pairs(self.arms) do
        if arm ~= nil then
            rendering.destroy(arm)
        end
    end
end

function IIO:getCheckArea()
    local x = self.thisEntity.position.x
    local y = self.thisEntity.position.y
    return {
        [1] = {direction = 1, startP = {x-0.5, y-1.5}, endP = {x+0.5, y-0.5}}, --North
        [2] = {direction = 2, startP = {x+0.5, y-0.5}, endP = {x+1.5, y+0.5}}, --East
        [4] = {direction = 4, startP = {x-0.5, y+0.5}, endP = {x+0.5, y+1.5}}, --South
        [3] = {direction = 3, startP = {x-1.5, y-0.5}, endP = {x-0.5, y+0.5}}, --West
    }
end

function IIO:reset_focused_entity()
    self.focusedEntity = {
        thisEntity = nil,
        inventory = {
            index = 1,
            values = nil
        }
    }
end

function IIO:createArms()
    local areas = self:getCheckArea()
    self:resetConnection()
    for _, area in pairs(areas) do
        local enti = 0
        local ents = self.thisEntity.surface.find_entities_filtered{area={area.startP, area.endP}}
        for _, ent in pairs(ents) do
            if ent ~= nil and ent.valid == true then
                if ent ~= nil and global.entityTable[ent.unit_number] ~= nil and string.match(ent.name, "RNS_") ~= nil and ent.operable then
                    if area.direction ~= self:getDirection() then --Prevent cable connection on the IO port
                        local obj = global.entityTable[ent.unit_number]
                        if (string.match(obj.thisEntity.name, "RNS_NetworkCableIO") ~= nil and obj:getConnectionDirection() == area.direction) or (string.match(obj.thisEntity.name, "RNS_NetworkCableRamp") ~= nil and obj:getConnectionDirection() == area.direction) or obj.thisEntity.name == Constants.WirelessGrid.name then
                            --Do nothing
                        else
                            if obj.color == nil then
                                self.arms[area.direction] = rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[self.color].sprites[area.direction].name, target=self.thisEntity, surface=self.thisEntity.surface, render_layer="lower-object-above-shadow"}
                                self.connectedObjs[area.direction] = {obj}
                                enti = enti + 1
                            elseif obj.color ~= "" and obj.color == self.color then
                                self.arms[area.direction] = rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[self.color].sprites[area.direction].name, target=self.thisEntity, surface=self.thisEntity.surface, render_layer="lower-object-above-shadow"}
                                self.connectedObjs[area.direction] = {obj}
                                enti = enti + 1
                            end
                        end
                        --Update network connections if necessary
                        if self.cardinals[area.direction] == false then
                            self.cardinals[area.direction] = true
                            if valid(self.networkController) == true and self.networkController.thisEntity ~= nil and self.networkController.thisEntity.valid == true then
                                self.networkController.network.shouldRefresh = true
                            elseif obj.thisEntity.name == Constants.NetworkController.main.name then
                                obj.network.shouldRefresh = true
                            end
                        end
                        break
                    end
                elseif ent ~= nil and self:getDirection() == area.direction then --Get entity with inventory
                    if Constants.Settings.RNS_TypesWithContainer[ent.type] == true then
                        if self.focusedEntity.thisEntity == nil or (self.focusedEntity.thisEntity ~= nil and self.focusedEntity.thisEntity.valid == false) then
                            self:reset_focused_entity()
                            self.focusedEntity.thisEntity = ent
                            self.focusedEntity.inventory.values = Constants.Settings.RNS_Inventory_Types[ent.type]
                            break
                        end
                    end
                end
            end
        end
        if self:getDirection() ~= area.direction then
            --Update network connections if necessary
            if self.cardinals[area.direction] == true and enti ~= 0 then
                self.cardinals[area.direction] = false
                if valid(self.networkController) == true and self.networkController.thisEntity ~= nil and self.networkController.thisEntity.valid == true then
                    self.networkController.network.shouldRefresh = true
                end
            end
        end
    end
end

function IIO:getDirection()
    local dir = self.thisEntity.direction
    if dir == defines.direction.north then
        return 1
    elseif dir == defines.direction.east then
        return 2
    elseif dir == defines.direction.south then
        return 4
    elseif dir == defines.direction.west then
        return 3
    end
end

function IIO:getConnectionDirection()
    local dir = self.thisEntity.direction
    if dir == defines.direction.north then
        return 4
    elseif dir == defines.direction.east then
        return 3
    elseif dir == defines.direction.south then
        return 1
    elseif dir == defines.direction.west then
        return 2
    end
end

function IIO:getRealDirection()
    local dir = self.thisEntity.direction
    if dir == defines.direction.north then
        return 1
    elseif dir == defines.direction.east then
        return 2
    elseif dir == defines.direction.south then
        return 3
    elseif dir == defines.direction.west then
        return 4
    end
end

function IIO:getTooltips(guiTable, mainFrame, justCreated)
    if justCreated == true then
		guiTable.vars.Gui_Title.caption = {"gui-description.RNS_NetworkCableIO_Item_Title"}
        local mainFlow = GuiApi.add_flow(guiTable, "", mainFrame, "vertical")

        local rateFlow = GuiApi.add_flow(guiTable, "", mainFlow, "vertical")
        local rateFrame = GuiApi.add_frame(guiTable, "", rateFlow, "vertical")
		rateFrame.style = Constants.Settings.RNS_Gui.frame_1
		rateFrame.style.vertically_stretchable = true
		rateFrame.style.left_padding = 3
		rateFrame.style.right_padding = 3
		rateFrame.style.right_margin = 3
        GuiApi.add_label(guiTable, "TransferRate", rateFrame, {"gui-description.RNS_ItemTransferRate", Constants.Settings.RNS_BaseItemIO_TransferCapacity*15*global.IIOMultiplier}, Constants.Settings.RNS_Gui.white, "", true)

        local topFrame = GuiApi.add_flow(guiTable, "", mainFlow, "horizontal")
        local bottomFrame = GuiApi.add_flow(guiTable, "", mainFlow, "horizontal")
        
        local colorFrame = GuiApi.add_frame(guiTable, "ColorFrame", topFrame, "vertical", true)
		colorFrame.style = Constants.Settings.RNS_Gui.frame_1
		colorFrame.style.vertically_stretchable = true
		colorFrame.style.left_padding = 3
		colorFrame.style.right_padding = 3
		colorFrame.style.right_margin = 3
		colorFrame.style.minimal_width = 150

        GuiApi.add_subtitle(guiTable, "", colorFrame, {"gui-description.RNS_Connection_Color"})
        local colorDD = GuiApi.add_dropdown(guiTable, "RNS_NetworkCableIO_Item_Color", colorFrame, Constants.Settings.RNS_ColorG, Constants.Settings.RNS_Colors[self.color], false, {"gui-description.RNS_Connection_Color_tooltip"}, {ID=self.thisEntity.unit_number})
        colorDD.style.minimal_width = 100

        --Filters 2 max
        local filtersFrame = GuiApi.add_frame(guiTable, "FiltersFrame", topFrame, "vertical", true)
		filtersFrame.style = Constants.Settings.RNS_Gui.frame_1
		filtersFrame.style.vertically_stretchable = true
		filtersFrame.style.left_padding = 3
		filtersFrame.style.right_padding = 3
		filtersFrame.style.right_margin = 3
		filtersFrame.style.minimal_width = 100

        GuiApi.add_subtitle(guiTable, "", filtersFrame, {"gui-description.RNS_Filter"})

        local filterFlow = GuiApi.add_flow(guiTable, "", filtersFrame, "vertical")
        filterFlow.style.horizontal_align = "center"

        local filter1 = GuiApi.add_filter(guiTable, "RNS_NetworkCableIO_Item_Filter_1", filterFlow, "", true, "item", 40, {ID=self.thisEntity.unit_number})
		guiTable.vars.filter1 = filter1
		if self.filters.values[1] ~= "" then filter1.elem_value = self.filters.values[1] end

        local filter2 = GuiApi.add_filter(guiTable, "RNS_NetworkCableIO_Item_Filter_2", filterFlow, "", true, "item", 40, {ID=self.thisEntity.unit_number})
		guiTable.vars.filter2 = filter2
		if self.filters.values[2] ~= "" then filter2.elem_value = self.filters.values[2] end

        local settingsFrame = GuiApi.add_frame(guiTable, "SettingsFrame", topFrame, "vertical", true)
		settingsFrame.style = Constants.Settings.RNS_Gui.frame_1
		settingsFrame.style.vertically_stretchable = true
		settingsFrame.style.left_padding = 3
		settingsFrame.style.right_padding = 3
		settingsFrame.style.right_margin = 3
		settingsFrame.style.minimal_width = 200

		GuiApi.add_subtitle(guiTable, "", settingsFrame, {"gui-description.RNS_Setting"})

        local priorityFlow = GuiApi.add_flow(guiTable, "", settingsFrame, "horizontal", false)
        GuiApi.add_label(guiTable, "", priorityFlow, {"gui-description.RNS_Priority"}, Constants.Settings.RNS_Gui.white)
        local priorityDD = GuiApi.add_dropdown(guiTable, "RNS_NetworkCableIO_Item_Priority", priorityFlow, Constants.Settings.RNS_Priorities, ((#Constants.Settings.RNS_Priorities+1)/2)-self.priority, false, "", {ID=self.thisEntity.unit_number})
        priorityDD.style.minimal_width = 100

        GuiApi.add_line(guiTable, "", settingsFrame, "horizontal")

        -- Whitelist/Blacklist mode
        local state = "left"
		if self.whitelist == false then state = "right" end
		GuiApi.add_switch(guiTable, "RNS_NetworkCableIO_Item_Whitelist", settingsFrame, {"gui-description.RNS_Whitelist"}, {"gui-description.RNS_Blacklist"}, "", "", state, false, {ID=self.thisEntity.unit_number})
        
        -- Input/Output mode
        local state1 = "left"
		if self.io == "output" then state1 = "right" end
		GuiApi.add_switch(guiTable, "RNS_NetworkCableIO_Item_IO", settingsFrame, {"gui-description.RNS_Input"}, {"gui-description.RNS_Output"}, "", "", state1, false, {ID=self.thisEntity.unit_number})

        -- Match metadata mode
        GuiApi.add_checkbox(guiTable, "RNS_NetworkCableIO_Item_Metadata", settingsFrame, {"gui-description.RNS_Metadata"}, {"gui-description.RNS_Metadata_description"}, self.metadataMode, false, {ID=self.thisEntity.unit_number})
    
        if self.enablerCombinator.get_circuit_network(defines.wire_type.red, defines.circuit_connector_id.constant_combinator) ~= nil or self.enablerCombinator.get_circuit_network(defines.wire_type.green, defines.circuit_connector_id.constant_combinator) ~= nil then
            local enableFrame = GuiApi.add_frame(guiTable, "EnableFrame", bottomFrame, "vertical")
            enableFrame.style = Constants.Settings.RNS_Gui.frame_1
            enableFrame.style.vertically_stretchable = true
            enableFrame.style.left_padding = 3
            enableFrame.style.right_padding = 3
            enableFrame.style.right_margin = 3
    
            GuiApi.add_subtitle(guiTable, "ConditionSub", enableFrame, {"gui-description.RNS_Condition"})
            local cFlow = GuiApi.add_flow(guiTable, "", enableFrame, "horizontal")
            cFlow.style.vertical_align = "center"
            local filter = GuiApi.add_filter(guiTable, "RNS_NetworkCableIO_Item_Enabler", cFlow, "", true, "signal", 40, {ID=self.thisEntity.unit_number})
            guiTable.vars.enabler = filter
            if self.enabler.filter ~= nil then
                filter.elem_value = self.enabler.filter
            end
            local opDD = GuiApi.add_dropdown(guiTable, "RNS_NetworkCableIO_Item_Operator", cFlow, Constants.Settings.RNS_OperatorN, Constants.Settings.RNS_Operators[self.enabler.operator], false, "", {ID=self.thisEntity.unit_number})
            opDD.style.minimal_width = 50
            --local number = GuiApi.add_filter(guiTable, "RNS_Detector_Number", cFlow, "", true, "signal", 40, {ID=self.thisEntity.unit_number})
            --number.elem_value = {type="virtual", name="constant-number"}
            local number = GuiApi.add_text_field(guiTable, "RNS_NetworkCableIO_Item_Number", cFlow, tostring(self.enabler.number), "", false, true, false, false, nil, {ID=self.thisEntity.unit_number})
            number.style.minimal_width = 100
        end
    end

    guiTable.vars.TransferRate.caption = {"gui-description.RNS_ItemTransferRate", Constants.Settings.RNS_BaseItemIO_TransferCapacity*15*global.IIOMultiplier}

    if self.filters.values[1] ~= "" then
        guiTable.vars.filter1.elem_value = self.filters.values[1]
    end
    if self.filters.values[2] ~= "" then
        guiTable.vars.filter2.elem_value = self.filters.values[2]
    end
    if self.enabler.filter ~= nil and (self.enablerCombinator.get_circuit_network(defines.wire_type.red) ~= nil or self.enablerCombinator.get_circuit_network(defines.wire_type.green) ~= nil) then
        guiTable.vars.enabler.elem_value = self.enabler.filter
    end
end

function IIO:set_icons(index, name)
    self.combinator.get_or_create_control_behavior().set_signal(index, name ~= nil and {signal={type="item", name=name}, count=1} or nil)
end

function IIO.interaction(event, RNSPlayer)
    if string.match(event.element.name, "RNS_NetworkCableIO_Item_Number") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local num = math.min(2^32, tonumber(event.element.text ~= "" and event.element.text or "0"))
        io.enabler.number = num
        event.element.text = tostring(num)
        return
    end
    if string.match(event.element.name, "RNS_NetworkCableIO_Item_Operator") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local operator = Constants.Settings.RNS_OperatorN[event.element.selected_index]
        if operator ~= io.enabler.operator then
            io.enabler.operator = operator
        end
		return
    end
    if string.match(event.element.name, "RNS_NetworkCableIO_Item_Enabler") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        if event.element.elem_value ~= nil then
            io.enabler.filter = event.element.elem_value
        else
            io.enabler.filter = nil
        end
		return
    end
    if string.match(event.element.name, "RNS_NetworkCableIO_Item_Filter") then
		local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local index = 0
        if string.match(event.element.name, "1") then
            index = 1
        elseif string.match(event.element.name, "2") then
            index = 2
        end
        if index ~= 0 then
            if event.element.elem_value ~= nil then
                io.filters.values[index] = event.element.elem_value
                --io.combinator.get_or_create_control_behavior().set_signal(index, {signal={type="item", name=event.element.elem_value}, count=1})
                io:set_icons(index, event.element.elem_value)
            else
                io.filters.values[index] = ""
                --io.combinator.get_or_create_control_behavior().set_signal(index, nil)
                io:set_icons(index, nil)
            end
            io.processed = false
        end
		return
	end

    if string.match(event.element.name, "RNS_NetworkCableIO_Item_Color") then
		local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local color = Constants.Settings.RNS_ColorN[event.element.selected_index]
        if color ~= io.color then
            io.color = color
            rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[io.color].sprites[5].name, target=io.thisEntity, surface=io.thisEntity.surface, render_layer="lower-object-above-shadow"}
            io.processed = false
        end
		return
	end

    if string.match(event.element.name, "RNS_NetworkCableIO_Item_Priority") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local priority = Constants.Settings.RNS_Priorities[event.element.selected_index]
        if priority ~= io.priority then
            io.priority = priority
            local oldP = 1+Constants.Settings.RNS_Max_Priority-io.priority
            io.priority = priority
            if io.networkController ~= nil and io.networkController.valid == true then
                io.networkController.network.ItemIOTable[oldP][io.entID] = nil
                io.networkController.network.ItemIOTable[1+Constants.Settings.RNS_Max_Priority-priority][io.entID] = io
            end
            io.processed = false
        end
		return
    end

    if string.match(event.element.name, "RNS_NetworkCableIO_Item_Whitelist") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        io.whitelist = event.element.switch_state == "left" and true or false
        io.processed = false
		return
    end

    if string.match(event.element.name, "RNS_NetworkCableIO_Item_Metadata") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        io.metadataMode = event.element.state
        io.processed = false
		return
    end

    if string.match(event.element.name, "RNS_NetworkCableIO_Item_IO") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        io.io = event.element.switch_state == "left" and "input" or "output"
        io.processed = false
        io:generateModeIcon()
		return
    end

end