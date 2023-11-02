local d0 = {
    [1] = {x = {0, 0}, y = {-1, 0.1}},
    [2] = {x = {1, -0.1}, y = {0, 0}},
    [3] = {x = {0, 0}, y = {1, -0.1}},
    [4] = {x = {-1, 0.1}, y = {0, 0}},
}
IIO2 = {
    thisEntity = nil,
    entID = nil,
    networkController = nil,
    color = "RED",
    arms = nil,
    connectedObjs = nil,
    cardinals = nil,
    io = "output",
    processed = false,
    includeModified = false,
    priority = 0,
    powerUsage = 4,
    container = nil,
    port = nil
}

function IIO2:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = IIO2
    t.thisEntity = object
    t.entID = object.unit_number
    t.container = object.surface.create_entity{
        name="rns_Blank_Container",
        position=object.position,
        force="neutral"
    }
    t.container.destructible = false
    t.container.operable = false
    t.container.minable = false
    t.port = object.surface.create_entity{
        name="rns_Blank_ItemIO",
        position=object.position,
        direction=object.direction,
        force="neutral"
    }
    t.port.destructible = false
    t.port.minable = false
    rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[t.color].sprites[5].name, target=t.thisEntity, surface=t.thisEntity.surface, render_layer="lower-object-above-shadow"}
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
    t:change_IO_mode(t.io)
    t:createArms()
    UpdateSys.addEntity(t)
    return t
end

function IIO2:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = IIO2
    setmetatable(object, mt)
end

function IIO2:remove()
    self:return_items_on_removed()
    if self.container ~= nil then self.container.destroy() end
    if self.port ~= nil then self.port.destroy() end
    UpdateSys.remove(self)
    if self.networkController ~= nil then
        self.networkController.network.ItemIOV2Table[Constants.Settings.RNS_Max_Priority+1-self.priority][self.entID] = nil
        self.networkController.network.shouldRefresh = true
    end
end

function IIO2:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function IIO2:copy_settings(obj)
    self.color = obj.color
    self.io = obj.io
    self.priority = obj.priority
    self:change_IO_mode(self.io)
    self.port.set_filter(1, obj.port.get_filter(1))
    self.port.inserter_filter_mode = obj.port.inserter_filter_mode
    self.port.inserter_stack_size_override = self.port.inserter_target_pickup_count > Constants.Settings.RNS_BaseItemIO_TransferCapacity*global.IIOMultiplier and 1 or self.port.inserter_target_pickup_count

end

function IIO2:serialize_settings()
    local tags = {}

    tags["color"] = self.color
    tags["io"] = self.io
    tags["priority"] = self.priority
    tags["filter"] = self.port.get_filter(1)
    tags["filtermode"] = self.port.inserter_filter_mode
    tags["stacksize"] = self.port.inserter_stack_size_override

    return tags
end

function IIO2:deserialize_settings(tags)
    self.color = tags["color"]
    self.io = tags["io"]
    self.priority = tags["priority"]
    self:change_IO_mode(self.io)
    self.port.set_filter(1, tags["filter"])
    self.port.inserter_filter_mode = tags["filtermode"]
    self.port.inserter_stack_size_override = tags["stacksize"]

end

function IIO2:update()
    if valid(self) == false then
        self:remove()
        return
    end
    if valid(self.networkController) == false then
        self.networkController = nil
    end
    if self.thisEntity.to_be_deconstructed() == true then return end

    --Make sure the pickup and dropoff points are correct in case Bob's Adjustable Inserter Mod is active
    self:change_IO_mode(self.io)

    --inserter_filter_mode
    --inserter_target_pickup_count
    --inserter_stack_size_override

    self.port.inserter_stack_size_override = self.port.inserter_target_pickup_count > Constants.Settings.RNS_BaseItemIO_TransferCapacity*global.IIOMultiplier and 1 or self.port.inserter_target_pickup_count
end

function IIO2:rotate()
    self.port.direction = self.thisEntity.direction
end

function IIO2:return_items_on_removed()
    if self.container == nil then return end
    local container = self.container.get_inventory(defines.inventory.chest)
    for k=1, 1 do
        if self.networkController == nil or self.networkController.valid == false or self.networkController.stable == false then break end
        local network = self.networkController.network
        local itemDrives = BaseNet.getOperableObjects(network.ItemDriveTable)
        local externalInvs = BaseNet.filter_by_type("item", BaseNet.getOperableObjects(network:filter_externalIO_by_valid_signal()))
        for i = 1, Constants.Settings.RNS_Max_Priority*2 + 1 do
            local priorityD = itemDrives[i]
            local priorityE = externalInvs[i]
            if Util.getTableLength(priorityD) > 0 then
                for _, drive in pairs(priorityD) do
                    if not drive:has_room() then goto next end
                    BaseNet.transfer_from_inv_to_drive(container, drive, nil, nil, drive:getRemainingStorageSize(), true, false)
                    if container.is_empty() then goto exit end
                    ::next::
                end
            end
            if Util.getTableLength(priorityE) > 0 then
                for _, externalInv in pairs(priorityE) do
                    externalInv:reset_focused_entity()
                    if externalInv.focusedEntity.thisEntity ~= nil and externalInv.focusedEntity.thisEntity.valid and externalInv.focusedEntity.thisEntity.to_be_deconstructed() == false and externalInv.focusedEntity.inventory.values ~= nil then
                        if string.match(externalInv.io, "input") == nil then goto next end
                        local index2 = 0
                        repeat
                            local ii1 = Util.next(externalInv.focusedEntity.inventory)
                            local inv1 = externalInv.focusedEntity.thisEntity.get_inventory(ii1.slot)
                            if inv1 ~= nil then
                                --inv1.sort_and_merge()
                                if EIO.has_item_room(inv1) == true and IIO2.check_operable_mode(ii1.io, "input") then
                                    BaseNet.transfer_from_inv_to_inv(container, inv1, nil, externalInv, container.get_item_count(), externalInv.metadataMode, false)
                                    if container.is_empty() then goto exit end
                                end
                            end
                            index2 = index2 + 1
                        until index2 == Util.getTableLength(externalInv.focusedEntity.inventory.values)
                    end
                    ::next::
                end
            end
        end
        ::exit::
    end
    if not container.is_empty() then
        container.sort_and_merge()
        for i = 1, #container do
            if container[i].count <= 0 then break end
            self.thisEntity.surface.spill_item_stack(self.thisEntity.position, container[i], true, "neutral", false)
        end
    end
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

function IIO2.check_operable_mode(io, mode)
    return string.match(io, mode) ~= nil
end

function IIO2:IO()
    local container = self.container.get_inventory(defines.inventory.chest)
    local transportCapacity = Constants.Settings.RNS_BaseItemIO_TransferCapacity*global.IIOMultiplier
    for k=1, 1 do
        if self.io == "input" and container.is_empty() then break end
        if self.networkController == nil or self.networkController.valid == false or self.networkController.stable == false then break end
        local network = self.networkController.network
        local itemDrives = BaseNet.getOperableObjects(network.ItemDriveTable)
        local externalInvs = BaseNet.filter_by_type("item", BaseNet.getOperableObjects(network:filter_externalIO_by_valid_signal()))
        for i = 1, Constants.Settings.RNS_Max_Priority*2 + 1 do
            local priorityD = itemDrives[i]
            local priorityE = externalInvs[i]
            if Util.getTableLength(priorityD) > 0 then
                for _, drive in pairs(priorityD) do
                    if self.io == "input" then
                        if not drive:has_room() then goto next end
                        transportCapacity = transportCapacity - BaseNet.transfer_from_inv_to_drive(container, drive, nil, nil, math.min(transportCapacity, drive:getRemainingStorageSize()), true, false)
                        if transportCapacity <= 0 or container.is_empty() then goto exit end
                    elseif self.io == "output" and self.port.get_filter(1) ~= nil then
                        transportCapacity = transportCapacity - BaseNet.transfer_from_drive_to_inv(drive, container, Util.itemstack_template(self.port.get_filter(1)), transportCapacity, true)
                        if transportCapacity <= 0 or container.is_full() then goto exit end
                    end
                    ::next::
                end
            end
            if Util.getTableLength(priorityE) > 0 then
                for _, externalInv in pairs(priorityE) do
                    externalInv:reset_focused_entity()
                    if externalInv.focusedEntity.thisEntity ~= nil and externalInv.focusedEntity.thisEntity.valid and externalInv.focusedEntity.thisEntity.to_be_deconstructed() == false and externalInv.focusedEntity.inventory.values ~= nil then
                        if self.io == "input" then
                            if string.match(externalInv.io, "input") == nil then goto next end
                            local index2 = 0
                            repeat
                                local ii1 = Util.next(externalInv.focusedEntity.inventory)
                                local inv1 = externalInv.focusedEntity.thisEntity.get_inventory(ii1.slot)
                                if inv1 ~= nil then
                                    --inv1.sort_and_merge()
                                    if EIO.has_item_room(inv1) == true and IIO2.check_operable_mode(ii1.io, "input") then
                                        transportCapacity = transportCapacity - BaseNet.transfer_from_inv_to_inv(container, inv1, nil, externalInv, transportCapacity, true, false)
                                        if transportCapacity <= 0 or container.is_empty() then goto exit end
                                    end
                                end
                                index2 = index2 + 1
                            until index2 == Util.getTableLength(externalInv.focusedEntity.inventory.values)
                        elseif self.io == "output" and self.port.get_filter(1) ~= nil then
                            if string.match(externalInv.io, "output") == nil then goto next end
                            local itemstack = Util.itemstack_template(self.port.get_filter(1))
                                local index1 = 0
                                repeat
                                    local ii = Util.next(externalInv.focusedEntity.inventory)
                                    local inv = externalInv.focusedEntity.thisEntity.get_inventory(ii.slot)
                                    if inv ~= nil and IIO2.check_operable_mode(ii.io, "output") then
                                        inv.sort_and_merge()
                                        local has = EIO.has_item(inv, itemstack, self.includeModified)
                                        if has > 0 then
                                            transportCapacity = transportCapacity - BaseNet.transfer_from_inv_to_inv(inv, container, itemstack, nil, transportCapacity, self.includeModified, true)
                                            if transportCapacity <= 0 or container.is_full() then goto exit end
                                        end
                                    end
                                    index1 = index1 + 1
                                until index1 == Util.getTableLength(externalInv.focusedEntity.inventory.values)
                            goto next
                        end
                    end
                    ::next::
                end
            end
        end
        ::exit::
    end
    self.processed = transportCapacity < Constants.Settings.RNS_BaseItemIO_TransferCapacity*global.IIOMultiplier or container.is_full()
end

function IIO2:resetConnection()
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

function IIO2:getCheckArea()
    local x = self.thisEntity.position.x
    local y = self.thisEntity.position.y
    return {
        [1] = {direction = 1, startP = {x-0.5, y-1.5}, endP = {x+0.5, y-0.5}}, --North
        [2] = {direction = 2, startP = {x+0.5, y-0.5}, endP = {x+1.5, y+0.5}}, --East
        [4] = {direction = 4, startP = {x-0.5, y+0.5}, endP = {x+0.5, y+1.5}}, --South
        [3] = {direction = 3, startP = {x-1.5, y-0.5}, endP = {x-0.5, y+0.5}}, --West
    }
end

function IIO2:createArms()
    local areas = self:getCheckArea()
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
    end
end

function IIO2:getDirection()
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

function IIO2:getConnectionDirection()
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

function IIO2:getRealDirection()
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

function IIO2:change_IO_mode(io)
    local direction = d0[self:getRealDirection()]

    if io == "input" then
        self.port.pickup_position = {self.port.position.x + direction.x[1], self.port.position.y + direction.y[1]}
        self.port.drop_position = {self.port.position.x + direction.x[2], self.port.position.y + direction.y[2]}
    elseif io == "output" then
        self.port.pickup_position = {self.port.position.x + direction.x[2], self.port.position.y + direction.y[2]}
        self.port.drop_position = {self.port.position.x + direction.x[1], self.port.position.y + direction.y[1]}
    end
end

function IIO2:getTooltips(guiTable, mainFrame, justCreated)
    if justCreated == true then
		guiTable.vars.Gui_Title.caption = {"gui-description.RNS_NetworkCableIOV2_Item_Title"}
        local mainFlow = GuiApi.add_flow(guiTable, "", mainFrame, "vertical")
        local topFrame = GuiApi.add_flow(guiTable, "", mainFlow, "horizontal")
        
        local colorFrame = GuiApi.add_frame(guiTable, "ColorFrame", topFrame, "vertical", true)
		colorFrame.style = Constants.Settings.RNS_Gui.frame_1
		colorFrame.style.vertically_stretchable = true
		colorFrame.style.left_padding = 3
		colorFrame.style.right_padding = 3
		colorFrame.style.right_margin = 3
		colorFrame.style.minimal_width = 150

        GuiApi.add_subtitle(guiTable, "", colorFrame, {"gui-description.RNS_Connection_Color"})
        local colorDD = GuiApi.add_dropdown(guiTable, "RNS_NetworkCableIOV2_Item_Color", colorFrame, Constants.Settings.RNS_ColorG, Constants.Settings.RNS_Colors[self.color], false, {"gui-description.RNS_Connection_Color_tooltip"}, {ID=self.thisEntity.unit_number})
        colorDD.style.minimal_width = 100

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
        local priorityDD = GuiApi.add_dropdown(guiTable, "RNS_NetworkCableIOV2_Item_Priority", priorityFlow, Constants.Settings.RNS_Priorities, ((#Constants.Settings.RNS_Priorities+1)/2)-self.priority, false, "", {ID=self.thisEntity.unit_number})
        priorityDD.style.minimal_width = 100

        GuiApi.add_line(guiTable, "", settingsFrame, "horizontal")

        -- Input/Output mode
        local state1 = "left"
		if self.io == "output" then state1 = "right" end
		GuiApi.add_switch(guiTable, "RNS_NetworkCableIOV2_Item_IO", settingsFrame, {"gui-description.RNS_Input"}, {"gui-description.RNS_Output"}, "", "", state1, false, {ID=self.thisEntity.unit_number})
    
        -- Include Modified Items
        if self.io == "output" then
            GuiApi.add_checkbox(guiTable, "RNS_NetworkCableIOV2_Item_Modified", settingsFrame, {"gui-description.RNS_Modified_2"}, {"gui-description.RNS_Modified_2_description"}, self.includeModified, false, {ID=self.thisEntity.unit_number})
        end
    end
end

function IIO2.interaction(event, RNSPlayer)
    --[[if string.match(event.element.name, "RNS_NetworkCableIOV2_Item_Inv") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        RNSPlayer.thisEntity.opened = io.port
        return
    end]]

    if string.match(event.element.name, "RNS_NetworkCableIOV2_Item_Modified") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        io.includeModified = event.element.state
		return
    end

    if string.match(event.element.name, "RNS_NetworkCableIOV2_Item_Color") then
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

    if string.match(event.element.name, "RNS_NetworkCableIOV2_Item_Priority") then
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

    if string.match(event.element.name, "RNS_NetworkCableIOV2_Item_IO") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        io.io = event.element.switch_state == "left" and "input" or "output"
        io.processed = false
        io:change_IO_mode(io.io)
		return
    end

end