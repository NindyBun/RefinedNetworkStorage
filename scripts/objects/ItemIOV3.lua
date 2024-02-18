IIO3 = {
    thisEntity = nil,
    entID = nil,
    networkController = nil,
    color = "RED",
    arms = nil,
    connectedObjs = nil,
    focusedEntity = nil,
    cardinals = nil,
    filters = nil,
    guiFilters = nil,
    --metadataMode = false,
    whitelistBlacklist = "blacklist",
    io = "output",
    ioIcon = nil,
    enabler = nil,
    enablerCombinator = nil,
    combinator = nil,
    processed = false,
    priority = 0,
    powerUsage = 80,
    stackSize = 1
}

function IIO3:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = IIO3
    t.thisEntity = object
    t.entID = object.unit_number
    rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[t.color].sprites[5].name, target=t.thisEntity, surface=t.thisEntity.surface, render_layer="lower-object-above-shadow"}
    t:generateModeIcon()
    t.stackSize = global.IIOMultiplier
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
    t.guiFilters = {
        [1] = "",
        [2] = ""
    }
    t.filters = {
        index = 0,
        max = 0,
        values = {}
    }
    t.focusedEntity = {
        thisEntity = nil,
        oldPosition = nil,
        inventory = {
            input = {
                index = 0,
                max = 0,
                values = {}
            },
            output = {
                index = 0,
                max = 0,
                values = {}
            }
        }
    }
    t.combinator = object.surface.create_entity{
        name="rns_Combinator",
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
        name="rns_Combinator_2",
        position=object.position,
        force="neutral"
    }
    t.enablerCombinator.destructible = false
    t.enablerCombinator.operable = false
    t.enablerCombinator.minable = false
    UpdateSys.add_to_entity_table(t)
    t:createArms()
    BaseNet.postArms(t)
    BaseNet.update_network_controller(t.networkController)
    --UpdateSys.addEntity(t)
    return t
end

function IIO3:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = IIO3
    setmetatable(object, mt)
end

function IIO3:remove()
    if self.combinator ~= nil then self.combinator.destroy() end
    if self.enablerCombinator ~= nil then self.enablerCombinator.destroy() end
    UpdateSys.remove_from_entity_table(self)
    BaseNet.postArms(self)
    --[[if self.networkController ~= nil then
        self.networkController.network.ItemIOTable[Constants.Settings.RNS_Max_Priority+1-self.priority][self.entID] = nil
        self.networkController.network.shouldRefresh = true
    end]]
    BaseNet.update_network_controller(self.networkController, self.entID)
end

function IIO3:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function IIO3:copy_settings(obj)
    self.color = obj.color
    --self.metadataMode = obj.metadataMode
    self.whitelistBlacklist = obj.whitelistBlacklist
    self.io = obj.io
    self.enabler = obj.enabler
    self.stackSize = obj.stackSize

    --Filters has do be done this way because for some reason they link to other objects
    self.guiFilters = {
        [1] = obj.guiFilters.values[1],
        [2] = obj.guiFilters.values[2]
    }
    self.filters = {
        index = obj.filters.max == 0 and 0 or 1,
        max = obj.filters.max,
        values = obj.filters.values
    }
    self:set_icons(1, self.guiFilters[1] ~= "" and self.guiFilters[1] or nil)
    self:set_icons(2, self.guiFilters[2] ~= "" and self.guiFilters[2] or nil)

    self.priority = obj.priority
    self:generateModeIcon()
end

function IIO3:serialize_settings()
    local tags = {}

    tags["color"] = self.color
    tags["filters"] = {
        max = self.filters.max,
        values = self.filters.values
    }
    tags["guiFilters"] = self.guiFilters
    --tags["metadataMode"] = self.metadataMode
    tags["whitelistBlacklist"] = self.whitelistBlacklist
    tags["io"] = self.io
    tags["priority"] = self.priority
    tags["enabler"] = self.enabler
    tags["stackSize"] = self.stackSize

    return tags
end

function IIO3:deserialize_settings(tags)
    self.color = tags["color"]
    --self.metadataMode = tags["metadataMode"]
    self.whitelistBlacklist = tags["whitelistBlacklist"]
    self.io = tags["io"]
    self.enabler = tags["enabler"]
    self.stackSize = tags["stackSize"]

    self.filters = {
        index = tags["filters"].max == 0 and 0 or 1,
        max = tags["filters"].max,
        values = tags["filters"].values
    }
    self.guiFilters = tags["guiFilters"]
    self:set_icons(1, self.guiFilters.values[1] ~= "" and self.guiFilters.values[1] or nil)
    self:set_icons(2, self.guiFilters.values[2] ~= "" and self.guiFilters.values[2] or nil)

    self.priority = tags["priority"]
    self:generateModeIcon()
end

--[[function IIO3:update()
    if valid(self) == false then
        self:remove()
        return
    end
    if valid(self.networkController) == false then
        self.networkController = nil
    end
    if self.thisEntity.to_be_deconstructed() == true then return end
    --if self.focusedEntity.thisEntity ~= nil and self.focusedEntity.thisEntity.valid == false then
    --    self:reset_focused_entity()
    --end
    --if game.tick % 25 then self:createArms() end
end]]

function IIO3:toggleHoverIcon(hovering)
    if self.ioIcon == nil then return end
    if hovering and rendering.get_only_in_alt_mode(self.ioIcon) then
        rendering.set_only_in_alt_mode(self.ioIcon, false)
    elseif not hovering and not rendering.get_only_in_alt_mode(self.ioIcon) then
        rendering.set_only_in_alt_mode(self.ioIcon, true)
    end
end

function IIO3:generateModeIcon()
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

function IIO3.check_operable_mode(io, mode)
    return string.match(io, mode) ~= nil
end

function IIO3.matches_filters(name, filters)
    for _, name1 in pairs(filters) do
        if name == name1 then return true end
    end
    return false
end

function IIO3:interactable()
    return self.thisEntity ~= nil and self.thisEntity.valid and self.thisEntity.to_be_deconstructed() == false
end

function IIO3:target_interactable()
    self:check_focused_entity()
    return self.focusedEntity.thisEntity ~= nil and self.focusedEntity.thisEntity.valid and self.focusedEntity.thisEntity.to_be_deconstructed() == false
end

--[[function IIO3:IO()
    if self.enablerCombinator.get_circuit_network(defines.wire_type.red, defines.circuit_connector_id.constant_combinator) ~= nil or self.enablerCombinator.get_circuit_network(defines.wire_type.green, defines.circuit_connector_id.constant_combinator) ~= nil then
        if self.enabler.filter == nil then self.processed = true return end
        local amount = self.enablerCombinator.get_merged_signal({type=self.enabler.filter.type, name=self.enabler.filter.name}, defines.circuit_connector_id.constant_combinator)
        if Util.OperatorFunctions[self.enabler.operator](amount, self.enabler.number) == false then self.processed = true return end
    end
    
    if self.networkController == nil or (self.networkController ~= nil and self.networkController.valid) == false or (self.networkController ~= nil and self.networkController.stable == false) then self.processed = true return end
    local network = self.networkController.network
    self:reset_focused_entity()
    if self.focusedEntity.thisEntity == nil then self.processed = true return end
    if self.io == "input" and self.focusedEntity.inventory.output.values == nil then self.processed = true return end
    if self.io == "output" and self.focusedEntity.inventory.input.values == nil then self.processed = true return end

    local transportCapacity = self.stackSize * Constants.Settings.RNS_BaseItemIO_TransferCapacity--*global.IIOMultiplier
    for k=1, 1 do
        if self.focusedEntity.thisEntity ~= nil and self.focusedEntity.thisEntity.valid == true then
            local foc = self.focusedEntity.thisEntity
            local itemDrives = network.ItemDriveTable --BaseNet.getOperableObjects(network.ItemDriveTable)
            local externalInvs = network:filter_externalIO_by_valid_signal() --BaseNet.filter_by_type("item", BaseNet.getOperableObjects(network:filter_externalIO_by_valid_signal()))
            for i = 1, Constants.Settings.RNS_Max_Priority*2 + 1 do
                local priorityD = itemDrives[i]
                local priorityE = externalInvs[i]
                --if Util.getTableLength(priorityD) > 0 then
                    for _, drive in pairs(priorityD) do
                        if drive.thisEntity ~= nil and drive.thisEntity.valid and drive.thisEntity.to_be_deconstructed() == false then
                            local remaining = drive:getRemainingStorageSize()
                            if self.io == "input" then
                                if remaining <= 0 then goto next end
                                local index = 0
                                repeat
                                    local filterstack = nil
                                    local nextItem = Util.next_non_nil(self.filters)
                                    if nextItem ~= "" then
                                        filterstack = Util.itemstack_template(nextItem)
                                    elseif self.whitelist == true then
                                        goto exit
                                    end
                
                                    local index1 = 0
                                    repeat
                                        local inv = foc.get_inventory(Util.next(self.focusedEntity.inventory.output))
                                        if inv ~= nil and not inv.is_empty() then
                                            transportCapacity = transportCapacity - BaseNet.transfer_from_inv_to_drive(inv, drive, filterstack, filterstack ~= nil and self.filters.values or nil, math.min(transportCapacity, remaining), self.metadataMode, filterstack ~= nil and self.whitelist or false)
                                            --if transportCapacity <= 0 or inv.is_empty() then goto exit end
                                            if transportCapacity <= 0 then goto exit end
                                        end
                                        index1 = index1 + 1
                                    until index1 == Util.getTableLength(self.focusedEntity.inventory.output.values)
                                    index = index + 1
                                until index == Util.getTableLength(self.filters.values)
                            elseif self.io == "output" and self.whitelist == true and Util.getTableLength_non_nil(self.filters.values) > 0 then
                                if remaining >= drive.maxStorage then goto next end
                                local index = 0
                                repeat
                                    local nextItem = Util.next_non_nil(self.filters)
                                    if nextItem == "" then goto exit end
                                    local itemstack = Util.itemstack_template(nextItem)
                                    local has = drive:has_item(itemstack, self.metadataMode)
        
                                    if has > 0 then
                                        local index1 = 0
                                        repeat
                                            local inv = foc.get_inventory(Util.next(self.focusedEntity.inventory.input))
                                            if inv ~= nil and not inv.is_full() then
                                                transportCapacity = transportCapacity - BaseNet.transfer_from_drive_to_inv(drive, inv, itemstack, transportCapacity, self.metadataMode)
                                                --if transportCapacity <= 0 or inv.is_full() then goto exit end
                                                if transportCapacity <= 0 then goto exit end
                                            end
                                            index1 = index1 + 1
                                        until index1 == Util.getTableLength(self.focusedEntity.inventory.input.values)
                                    end
                                    index = index + 1
                                until index == Util.getTableLength(self.filters.values)
                            end
                        end
                        ::next::
                    end
                --end
                ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
                --if Util.getTableLength(priorityE) > 0 then
                    for _, externalInv in pairs(priorityE) do
                        if externalInv.type == "item" and externalInv.thisEntity ~= nil and externalInv.thisEntity.valid and externalInv.thisEntity.to_be_deconstructed() == false and externalInv.focusedEntity.thisEntity ~= nil and externalInv.focusedEntity.thisEntity.valid and externalInv.focusedEntity.thisEntity.to_be_deconstructed() == false and externalInv.focusedEntity.inventory[self.io].values ~= nil then
                            if self.io == "input" then
                                if string.match(externalInv.io, "input") == nil then goto next end
                                local index = 0
                                repeat
                                    local nextItem = Util.next_non_nil(self.filters)
                                    local filterstack = nil
                                    if nextItem ~= "" then
                                        filterstack = Util.itemstack_template(nextItem)
                                    elseif self.whitelist == true then
                                        goto exit
                                    end

                                    if Util.getTableLength_non_nil(externalInv.filters.item.values) > 0 then
                                        if filterstack ~= nil and externalInv:matches_filters("item", filterstack.cont.name) == true then
                                            if externalInv.whitelist == false then goto next end
                                        else
                                            if externalInv.whitelist == true then goto next end
                                        end
                                    elseif Util.getTableLength_non_nil(externalInv.filters.item.values) == 0 then
                                        if externalInv.whitelist == true then goto next end
                                    end

                                    local index1 = 0
                                    repeat
                                        local inv = externalInv.focusedEntity.thisEntity.get_inventory(Util.next(externalInv.focusedEntity.inventory.input))
                                        if inv ~= nil and not inv.is_full() then
                                            local index2 = 0
                                            repeat
                                                local inv1 = foc.get_inventory(Util.next(self.focusedEntity.inventory.output))
                                                if inv1 ~= nil and not inv1.is_empty() then
                                                    local meta = (self.metadataMode == externalInv.metadataMode and self.metadataMode == true)
                                                    transportCapacity = transportCapacity - BaseNet.transfer_from_inv_to_inv(inv1, inv, filterstack, filterstack == nil and externalInv or nil, transportCapacity, meta, (filterstack == nil and {true} or {false})[1])
                                                    --if transportCapacity <= 0 or inv1.is_empty() then goto exit end
                                                    if transportCapacity <= 0 then goto exit end
                                                end
                                                index2 = index2 + 1
                                            until index2 == Util.getTableLength(self.focusedEntity.inventory.output.values)
                                        end
                                        index1 = index1 + 1
                                    until index1 == Util.getTableLength(externalInv.focusedEntity.inventory.input.values)
                                    index = index + 1
                                until index == Util.getTableLength(self.filters.values)
                            elseif self.io == "output" and self.whitelist == true and Util.getTableLength_non_nil(self.filters.values) > 0 then
                                if string.match(externalInv.io, "output") == nil then goto next end
                                local index = 0
                                repeat
                                    local nextItem = Util.next_non_nil(self.filters)
                                    if nextItem == "" then goto exit end
        
                                    local itemstack = Util.itemstack_template(nextItem)
                                    local index1 = 0
                                    repeat
                                        local inv = externalInv.focusedEntity.thisEntity.get_inventory(Util.next(externalInv.focusedEntity.inventory.output))
                                        if inv ~= nil and inv.get_contents()[itemstack.cont.name] ~= nil then
                                            local index2 = 0
                                            repeat
                                                local inv1 = foc.get_inventory(Util.next(self.focusedEntity.inventory.input))
                                                if inv1 ~= nil and not inv1.is_full() then
                                                    local meta = (self.metadataMode == externalInv.metadataMode and self.metadataMode == true)
                                                    transportCapacity = transportCapacity - BaseNet.transfer_from_inv_to_inv(inv, inv1, itemstack, nil, transportCapacity, meta, true)
                                                    --if transportCapacity <= 0 or inv.is_full() then goto exit end
                                                    if transportCapacity <= 0 then goto exit end
                                                end
                                                index2 = index2 + 1
                                            until index2 == Util.getTableLength(self.focusedEntity.inventory.input.values)
                                        end
                                        index1 = index1 + 1
                                    until index1 == Util.getTableLength(externalInv.focusedEntity.inventory.output.values)
                                    index = index + 1
                                until index == Util.getTableLength(self.filters.values)
                            end
                        end
                        ::next::
                    end
                --end
            end
        end
        ::exit::
    end
    self.processed = transportCapacity < self.stackSize * Constants.Settings.RNS_BaseItemIO_TransferCapacity --*global.IIOMultiplier
        or (self.focusedEntity.thisEntity ~= nil and self:checkFullness())
end]]

function IIO3:IO()
    if self:interactable() == false then self.processed = true return end
    if self:target_interactable() == false then self.processed = true return end

    if self.enablerCombinator.get_circuit_network(defines.wire_type.red, defines.circuit_connector_id.constant_combinator) ~= nil or self.enablerCombinator.get_circuit_network(defines.wire_type.green, defines.circuit_connector_id.constant_combinator) ~= nil then
        if self.enabler.filter == nil then self.processed = true return end
        local amount = self.enablerCombinator.get_merged_signal({type=self.enabler.filter.type, name=self.enabler.filter.name}, defines.circuit_connector_id.constant_combinator)
        if Util.OperatorFunctions[self.enabler.operator](amount, self.enabler.number) == false then self.processed = true return end
    end
    
    if self.networkController == nil or self.networkController.valid == false or self.networkController.stable == false then self.processed = true return end
    local network = self.networkController.network

    local target = self.focusedEntity

    local storedAmount = target.thisEntity.get_item_count()
    local transportCapacity = self.stackSize * Constants.Settings.RNS_BaseItemIO_TransferCapacity--*global.IIOMultiplier

    if self.io == "input" and target.inventory.output.max ~= 0 then
        BaseNet.transfer_from_inv_to_network(network, target, nil, self.filters, self.whitelistBlacklist, transportCapacity)
    elseif self.io == "output" and target.inventory.input.max ~= 0 ~= nil then
        --BaseNet.transfer_from_network_to_inv()
    end

    if self.io == "input" and target.thisEntity.get_item_count() < storedAmount then self.processed = true return end
    if self.io == "output" and target.thisEntity.get_item_count() > storedAmount then self.processed = true return end
    self.processed = false
end

function IIO3:checkFullness()
    local i = 0
    local ii = #self.focusedEntity.inventory["output"].values
    for _, slot in pairs(self.focusedEntity.inventory[self.io].values) do
        if self.io == "output" and self.focusedEntity.thisEntity.get_inventory(slot) == nil then
            ii = ii - 1
            goto next
        end
        if self.io == "output" and self.focusedEntity.thisEntity.get_inventory(slot).is_full() then i = i + 1 end
        if self.io == "output" and i == ii then return true end
        ::next::
    end

    return false
end

function IIO3:resetConnection()
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

function IIO3:getCheckArea()
    local x = self.thisEntity.position.x
    local y = self.thisEntity.position.y
    return {
        [1] = {direction = 1, startP = {x-0.5, y-1.5}, endP = {x+0.5, y-0.5}}, --North
        [2] = {direction = 2, startP = {x+0.5, y-0.5}, endP = {x+1.5, y+0.5}}, --East
        [4] = {direction = 4, startP = {x-0.5, y+0.5}, endP = {x+0.5, y+1.5}}, --South
        [3] = {direction = 3, startP = {x-1.5, y-0.5}, endP = {x-0.5, y+0.5}}, --West
    }
end

function IIO3:reset_focused_entity()
    self.focusedEntity = {
        thisEntity = nil,
        oldPosition = nil,
        inventory = {
            input = {
                index = 0,
                max = 0,
                values = {}
            },
            output = {
                index = 0,
                max = 0,
                values = {}
            }
        }
    }

    local selfP = self.thisEntity.position
    local area = self:getCheckArea()[self:getDirection()]
    local ents = self.thisEntity.surface.find_entities_filtered{area={area.startP, area.endP}}
    local nearest = nil

    for _, ent in pairs(ents) do
        if ent ~= nil and ent.valid == true and ent.to_be_deconstructed() == false and string.match(string.upper(ent.name), "RNS_") == nil and ent.operable and global.entityTable[ent.unit_number] == nil then
            if (nearest == nil or Util.distance(selfP, ent.position) < Util.distance(selfP, nearest.position)) then
                nearest = ent
            end
        end
    end

    if nearest == nil then return end
    if Constants.Settings.RNS_TypesWithContainer[nearest.type] == true then
        self.focusedEntity.thisEntity = nearest
        self.focusedEntity.oldPosition = nearest.position
        for _, inv_index in pairs(Constants.Settings.RNS_Inventory_Types[nearest.type].input) do
            if nearest.get_inventory(inv_index) ~= nil then
                self.focusedEntity.inventory.input.max = self.focusedEntity.inventory.input.max + 1
                table.insert(self.focusedEntity.inventory.input.values, inv_index)
            end
        end
        for _, inv_index in pairs(Constants.Settings.RNS_Inventory_Types[nearest.type].output) do
            if nearest.get_inventory(inv_index) ~= nil then
                self.focusedEntity.inventory.output.max = self.focusedEntity.inventory.output.max + 1
                table.insert(self.focusedEntity.inventory.output.values, inv_index)
            end
        end
        if self.focusedEntity.inventory.input.max ~= 0 then self.focusedEntity.inventory.input.index = 1 end
        if self.focusedEntity.inventory.output.max ~= 0 then self.focusedEntity.inventory.output.index = 1 end
    end
end

function IIO3:check_focused_entity()
    if self.focusedEntity.thisEntity == nil or self.focusedEntity.thisEntity.valid == false or self.focusedEntity.thisEntity.to_be_deconstructed() then self:reset_focused_entity() return end
    --if Util.positions_match(self.focusedEntity.thisEntity.position, self.focusedEntity.oldPosition) == false then self:reset_focused_entity() return end
    if self.focusedEntity.inventory.input.max == 0 and self.io == "output" then return self:reset_focused_entity() end
    if self.focusedEntity.inventory.output.max == 0 and self.io == "input" then return self:reset_focused_entity() end
    
    if self.io == "output" then
        for _, i in pairs(self.focusedEntity.inventory.input.values) do
            if self.focusedEntity.thisEntity.get_inventory(i) == nil then self:reset_focused_entity() end
        end
    end
    if self.io == "input" then
        for _, i in pairs(self.focusedEntity.inventory.input.values) do
            if self.focusedEntity.thisEntity.get_inventory(i) == nil then self:reset_focused_entity() end
        end
    end
end

function IIO3:createArms()
    BaseNet.generateArms(self)
    --[[local areas = self:getCheckArea()
    self:resetConnection()
    for _, area in pairs(areas) do
        local ents = self.thisEntity.surface.find_entities_filtered{area={area.startP, area.endP}}
        for _, ent in pairs(ents) do
            if ent ~= nil and ent.valid == true then
                if ent ~= nil and global.entityTable[ent.unit_number] ~= nil and string.match(ent.name, "RNS_") ~= nil then
                    if area.direction ~= self:getDirection() then --Prevent cable connection on the IO port
                        local obj = global.entityTable[ent.unit_number]
                        if (string.match(obj.thisEntity.name, "RNS_NetworkCableIO") ~= nil and obj:getConnectionDirection() == area.direction) or (string.match(obj.thisEntity.name, "RNS_NetworkCableRamp") ~= nil and obj:getConnectionDirection() == area.direction) or obj.thisEntity.name == Constants.WirelessGrid.name then
                            --Do nothing
                        else
                            if obj.color == nil then
                                self.arms[area.direction] = rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[self.color].sprites[area.direction].name, target=self.thisEntity, surface=self.thisEntity.surface, render_layer="lower-object-above-shadow"}
                                self.connectedObjs[area.direction] = {obj}
                            elseif obj.color ~= "" and obj.color == self.color then
                                self.arms[area.direction] = rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[self.color].sprites[area.direction].name, target=self.thisEntity, surface=self.thisEntity.surface, render_layer="lower-object-above-shadow"}
                                self.connectedObjs[area.direction] = {obj}
                            end
                        end
                        break
                    end
                end
            end
        end
    end]]
end

function IIO3:getDirection()
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

function IIO3:getConnectionDirection()
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

function IIO3:getRealDirection()
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

function IIO3:getTooltips(guiTable, mainFrame, justCreated)
    if justCreated == true then
		guiTable.vars.Gui_Title.caption = {"gui-description.RNS_NetworkCableIO_Item_Title"}
        local mainFlow = GuiApi.add_flow(guiTable, "", mainFrame, "vertical")

        local rateFlow = GuiApi.add_flow(guiTable, "", mainFlow, "vertical")
        local rateFrame = GuiApi.add_frame(guiTable, "", rateFlow, "horizontal")
		rateFrame.style = Constants.Settings.RNS_Gui.frame_1
		rateFrame.style.vertically_stretchable = true
		rateFrame.style.left_padding = 3
		rateFrame.style.right_padding = 3
		rateFrame.style.right_margin = 3
        GuiApi.add_label(guiTable, "TransferRate", rateFrame, {"gui-description.RNS_ItemTransferRate", self.stackSize*15*Constants.Settings.RNS_BaseItemIO_TransferCapacity}, Constants.Settings.RNS_Gui.white, "", true)

        if global.IIOMultiplier > 1 then
            local stackFrame = GuiApi.add_frame(guiTable, "", rateFlow, "horizontal")
            stackFrame.style = Constants.Settings.RNS_Gui.frame_1
            stackFrame.style.vertically_stretchable = true
            stackFrame.style.left_padding = 3
            stackFrame.style.right_padding = 3
            stackFrame.style.right_margin = 3
            GuiApi.add_label(guiTable, "", stackFrame, {"gui-description.RNS_ItemStackSize"}, Constants.Settings.RNS_Gui.white, "")
            
            local slider = GuiApi.add_slider(guiTable, "RNS_NetworkCableIO_Item_StackSizeSlider", stackFrame, 1, global.IIOMultiplier, self.stackSize, 1, true, "", {ID=self.thisEntity.unit_number})
            slider.style = "notched_slider"
            slider.style.minimal_width = 250
            slider.style.maximal_width = 300
            GuiApi.add_text_field(guiTable, "RNS_NetworkCableIO_Item_StackSizeText", stackFrame, tostring(self.stackSize), "", true, true, false, false, false, {ID=self.thisEntity.unit_number})
            --GuiApi.add_label(guiTable, "TransferRate", rateFrame, {"gui-description.RNS_ItemTransferRate", Constants.Settings.RNS_BaseItemIO_TransferCapacity*15*global.IIOMultiplier}, Constants.Settings.RNS_Gui.white, "", true)
        end
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
        local filtersFrame = GuiApi.add_frame(guiTable, "", topFrame, "vertical")
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
		if self.guiFilters[1] ~= "" then filter1.elem_value = self.guiFilters[1] end

        local filter2 = GuiApi.add_filter(guiTable, "RNS_NetworkCableIO_Item_Filter_2", filterFlow, "", true, "item", 40, {ID=self.thisEntityr})
		guiTable.vars.filter2 = filter2
		if self.guiFilters[2] ~= "" then filter2.elem_value = self.guiFilters[2] end

        local settingsFrame = GuiApi.add_frame(guiTable, "", topFrame, "vertical")
		settingsFrame.style = Constants.Settings.RNS_Gui.frame_1
		settingsFrame.style.vertically_stretchable = true
		settingsFrame.style.left_padding = 3
		settingsFrame.style.right_padding = 3
		settingsFrame.style.right_margin = 3
		settingsFrame.style.minimal_width = 200

		GuiApi.add_subtitle(guiTable, "", settingsFrame, {"gui-description.RNS_Setting"})

        local priorityFlow = GuiApi.add_flow(guiTable, "", settingsFrame, "horizontal")
        GuiApi.add_label(guiTable, "", priorityFlow, {"gui-description.RNS_Priority"}, Constants.Settings.RNS_Gui.white)
        local priorityDD = GuiApi.add_dropdown(guiTable, "RNS_NetworkCableIO_Item_Priority", priorityFlow, Constants.Settings.RNS_Priorities, ((#Constants.Settings.RNS_Priorities+1)/2)-self.priority, false, "", {ID=self.thisEntity.unit_number})
        priorityDD.style.minimal_width = 100

        GuiApi.add_line(guiTable, "", settingsFrame, "horizontal")

        -- Whitelist/Blacklist mode
        if self.io == "input" then
            local state = "left"
		    if self.whitelistBlacklist == "blacklist" then state = "right" end
		    GuiApi.add_switch(guiTable, "RNS_NetworkCableIO_Item_WhitelistBlacklist", settingsFrame, {"gui-description.RNS_Whitelist"}, {"gui-description.RNS_Blacklist"}, "", "", state, false, {ID=self.thisEntity.unit_number})
        end
        
        -- Input/Output mode
        local state1 = "left"
		if self.io == "output" then state1 = "right" end
		GuiApi.add_switch(guiTable, "RNS_NetworkCableIO_Item_IO", settingsFrame, {"gui-description.RNS_Input"}, {"gui-description.RNS_Output"}, "", "", state1, false, {ID=self.thisEntity.unit_number})

        -- Match metadata mode
        --GuiApi.add_checkbox(guiTable, "RNS_NetworkCableIO_Item_Metadata", settingsFrame, {"gui-description.RNS_Modified_2"}, {"gui-description.RNS_Modified_2_description"}, self.metadataMode, false, {ID=self.thisEntity.unit_number})
    
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

    guiTable.vars.TransferRate.caption = {"gui-description.RNS_ItemTransferRate", self.stackSize*15*Constants.Settings.RNS_BaseItemIO_TransferCapacity}

    if self.guiFilters[1] ~= "" then
        guiTable.vars.filter1.elem_value = self.guiFilters[1]
    end
    if self.guiFilters[2] ~= "" then
        guiTable.vars.filter2.elem_value = self.guiFilters[2]
    end
    if self.enabler.filter ~= nil and (self.enablerCombinator.get_circuit_network(defines.wire_type.red) ~= nil or self.enablerCombinator.get_circuit_network(defines.wire_type.green) ~= nil) then
        guiTable.vars.enabler.elem_value = self.enabler.filter
    end
end

function IIO3:set_icons(index, name)
    self.combinator.get_or_create_control_behavior().set_signal(index, name ~= nil and {signal={type="item", name=name}, count=1} or nil)
end

function IIO3.interaction(event, RNSPlayer)
    local guiTable = RNSPlayer.GUI[Constants.Settings.RNS_Gui.tooltip]
    if string.match(event.element.name, "RNS_NetworkCableIO_Item_StackSizeSlider") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        io.stackSize = event.element.slider_value
        guiTable.vars["RNS_NetworkCableIO_Item_StackSizeText"].text = tostring(io.stackSize)
        return
    end
    if string.match(event.element.name, "RNS_NetworkCableIO_Item_StackSizeText") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        io.stackSize = math.max(1, math.min(tonumber(event.element.text) or 0, global.IIOMultiplier))
        guiTable.vars["RNS_NetworkCableIO_Item_StackSizeSlider"].slider_value = io.stackSize
        guiTable.vars["RNS_NetworkCableIO_Item_StackSizeText"].text = tostring(io.stackSize)
        return
    end
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
                io.guiFilters[index] = event.element.elem_value
                io:set_icons(index, event.element.elem_value)
            else
                io.guiFilters[index] = ""
                io:set_icons(index, nil)
            end
            io.processed = false
        end

        io.filters = {
            index = 0,
            max = 0,
            values = {}
        }
        for _, filter in pairs(io.guiFilters) do
            if filter ~= "" then
                io.filters.max = io.filters.max + 1
                io.filters.values[filter] = true --For filtering blacklisted imports
                io.filters.values[io.filters.max] = filter --For specific exports and imports
            end
		end
        io.filters.index = io.filters.max == 0 and 0 or 1
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
            if io.networkController ~= nil and io.networkController.valid == true and io.networkController.network.ItemIOTable[oldP][io.io][io.entID] ~= nil then
                io.networkController.network.ItemIOTable[oldP][io.io][io.entID] = nil
                io.networkController.network.ItemIOTable[1+Constants.Settings.RNS_Max_Priority-priority][io.io][io.entID] = io
            end
            io.processed = false
        end
		return
    end

    if string.match(event.element.name, "RNS_NetworkCableIO_Item_WhitelistBlacklist") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        io.whitelistBlacklist = event.element.switch_state == "left" and "whitelist" or "blacklist"
        io.processed = false
		return
    end

    --[[if string.match(event.element.name, "RNS_NetworkCableIO_Item_Metadata") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        io.metadataMode = event.element.state
        io.processed = false
		return
    end]]

    if string.match(event.element.name, "RNS_NetworkCableIO_Item_IO") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local from = io.io
        local to = event.element.switch_state == "left" and "input" or "output"
        if io.networkController ~= nil then
            io.networkController.network:transfer_io_mode(io, "item", from, to)
        end
        io.io = to
        io.processed = false
        io:generateModeIcon()
		return
    end

end