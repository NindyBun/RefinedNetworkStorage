IIO = {
    thisEntity = nil,
    entID = nil,
    networkController = nil,
    arms = nil,
    connectedObjs = nil,
    focusedEntity = nil,
    cardinals = nil,
    filters = nil,
    metadataMode = false,
    whitelist = true,
    io = "output",
    ioIcon = nil,
    combinator = nil
}

function IIO:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = IIO
    t.thisEntity = object
    t.entID = object.unit_number
    rendering.draw_sprite{sprite="NetworkCableDot", target=t.thisEntity, surface=t.thisEntity.surface, render_layer="lower-object-above-shadow"}
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
    t.combinator = object.surface.create_entity{
        name="rns-combinator",
        position=object.position,
        force="neutral"
    }
    t.combinator.destructible = false
    t.combinator.operable = false
    t.combinator.minable = false
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
    UpdateSys.remove(self)
    if self.networkController ~= nil then
        self.networkController.network.ItemIOTable[self.entID] = nil
        self.networkController.network.shouldRefresh = true
    end
end

function IIO:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
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
    self:createArms()
    --local tick = game.tick % (120/Constants.Settings.RNS_BaseItemIO_Speed) --based on belt speed
    --if tick >= 0.0 and tick < 1.0 then self:IO() end --This is done in the Network Controller
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

function IIO:transportIO()
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
end

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

function IIO:IO()
    if self.networkController == nil or self.networkController.valid == false or self.networkController.stable == false then return end
    local network = self.networkController.network
    if self.focusedEntity.thisEntity ~= nil and self.focusedEntity.thisEntity.valid == true and self.focusedEntity.inventory.values ~= nil then
        local foc = self.focusedEntity.thisEntity
        if self.io == "input" then
            if Util.getTableLength_non_nil(self.filters.values) > 0 then
                local initialItem = self.filters.index
                local nextItem = ""
                local itemstack = nil
                local has = 0

                local isOperable = false
                local inv = nil
                local initialIndex = self.focusedEntity.inventory.index

                repeat
                    local ii = Util.next(self.focusedEntity.inventory)
                    inv = foc.get_inventory(ii.slot)
                    if inv ~= nil then
                        isOperable = IIO.check_operable_mode(ii.io, "output")
                        if isOperable == true then
                            repeat
                                nextItem = Util.next_non_nil(self.filters)
                                if nextItem == "" then return end
                                itemstack = Util.itemstack_template(nextItem)
                                has = IIO.has_item(inv, itemstack, self.metadataMode)
                            until has > 0 or initialItem == self.filters.index
                        end
                    end
                until isOperable == true or initialIndex == self.focusedEntity.inventory.index

                if has > 0 and isOperable == true and inv ~= nil then
                    for _, drive in pairs(network.getOperableObjects(network.ItemDriveTable)) do
                        if drive:has_room() then
                            BaseNet.transfer_item(inv, drive:get_sorted_and_merged_inventory(), itemstack, math.min(1, math.min(has, drive:getRemainingStorageSize())), self.metadataMode, self.whitelist, "inv_to_array")
                        end
                    end
                end
            elseif Util.getTableLength_non_nil(self.filters.values) == 0 and self.whitelist == false then
                for _, drive in pairs(network.getOperableObjects(network.ItemDriveTable)) do
                    if drive:has_room() then --#kDrives have #k slots so as long as the drive has room then it also has a slot open
                        local isOperable = false
                        local inv = nil
                        local initialIndex = self.focusedEntity.inventory.index
                        repeat
                            local ii = Util.next(self.focusedEntity.inventory)
                            inv = foc.get_inventory(ii.slot)
                            if inv ~= nil then
                                isOperable = IIO.check_operable_mode(ii.io, "output")
                            end
                        until isOperable == true or initialIndex == self.focusedEntity.inventory.index
                        if isOperable == true and inv ~= nil then
                            BaseNet.transfer_item(inv, drive:get_sorted_and_merged_inventory(), nil, math.min(1, drive:getRemainingStorageSize()), self.metadataMode, false, "inv_to_array")
                        end
                    end
                end
            end
        elseif self.io == "output" and self.whitelist == true and Util.getTableLength_non_nil(self.filters.values) > 0 then
            for _, drive in pairs(network.getOperableObjects(network.ItemDriveTable)) do
                local initialItem = self.filters.index
                local nextItem = ""
                local itemstack = nil
                local has = 0

                local isOperable = false
                local inv = nil
                repeat
                    nextItem = Util.next_non_nil(self.filters)
                    if nextItem == "" then return end
                    itemstack = Util.itemstack_template(nextItem)
                    has = drive:has_item(itemstack, self.metadataMode)
                    local initialIndex = self.focusedEntity.inventory.index
                    if has > 0 then
                        repeat
                            local ii = Util.next(self.focusedEntity.inventory)
                            inv = foc.get_inventory(ii.slot)
                            if inv ~= nil then
                                isOperable = IIO.check_operable_mode(ii.io, "input") and inv.can_insert(itemstack.cont)
                            end
                        until isOperable == true or initialIndex == self.focusedEntity.inventory.index
                    end
                until has > 0 or initialItem == self.filters.index

                if has > 0 and isOperable == true and inv ~= nil then
                    BaseNet.transfer_item(drive:get_sorted_and_merged_inventory(), inv, itemstack, math.min(1, drive:getRemainingStorageSize()), self.metadataMode, true, "array_to_inv")
                end
            end
        end
    end
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
                        if string.match(obj.thisEntity.name, "RNS_NetworkCableIO") ~= nil and obj:getConnectionDirection() == area.direction then
                            --Do nothing
                        else
                            self.arms[area.direction] = rendering.draw_sprite{sprite=Constants.NetworkCables.Sprites[area.direction].name, target=self.thisEntity, surface=self.thisEntity.surface, render_layer="lower-object-above-shadow"}
                            self.connectedObjs[area.direction] = {obj}
                            enti = enti + 1
                        end
                        --Update network connections if necessary
                        if self.cardinals[area.direction] == false then
                            self.cardinals[area.direction] = true
                            if valid(self.networkController) == true and self.networkController.thisEntity ~= nil and self.networkController.thisEntity.valid == true then
                                self.networkController.network.shouldRefresh = true
                            elseif obj.thisEntity.name == Constants.NetworkController.slateEntity.name then
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
		guiTable.vars.Gui_Title.caption = {"gui-description.RNS_NetworkCableIO_Item"}

        --Filters 2 max
        local filtersFrame = GuiApi.add_frame(guiTable, "FiltersFrame", mainFrame, "vertical", true)
		filtersFrame.style = Constants.Settings.RNS_Gui.frame_1
		filtersFrame.style.vertically_stretchable = true
		filtersFrame.style.left_padding = 3
		filtersFrame.style.right_padding = 3
		filtersFrame.style.right_margin = 3
		filtersFrame.style.width = 100

        GuiApi.add_subtitle(guiTable, "", filtersFrame, {"gui-description.RNS_Filter"})

        local filterFlow = GuiApi.add_flow(guiTable, "", filtersFrame, "vertical")
        filterFlow.style.horizontal_align = "center"

        local filter1 = GuiApi.add_filter(guiTable, "RNS_NetworkCableIO_Item_Filter_1", filterFlow, "", true, "item", 40, {ID=self.thisEntity.unit_number})
		guiTable.vars.filter1 = filter1
		if self.filters.values[1] ~= "" then filter1.elem_value = self.filters.values[1] end

        local filter2 = GuiApi.add_filter(guiTable, "RNS_NetworkCableIO_Item_Filter_2", filterFlow, "", true, "item", 40, {ID=self.thisEntity.unit_number})
		guiTable.vars.filter2 = filter2
		if self.filters.values[2] ~= "" then filter2.elem_value = self.filters.values[2] end

        local settingsFrame = GuiApi.add_frame(guiTable, "SettingsFrame", mainFrame, "vertical", true)
		settingsFrame.style = Constants.Settings.RNS_Gui.frame_1
		settingsFrame.style.vertically_stretchable = true
		settingsFrame.style.left_padding = 3
		settingsFrame.style.right_padding = 3
		settingsFrame.style.right_margin = 3
		settingsFrame.style.minimal_width = 200

		GuiApi.add_subtitle(guiTable, "", settingsFrame, {"gui-description.RNS_Setting"})

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
    end

    if self.filters.values[1] ~= "" then
        guiTable.vars.filter1.elem_value = self.filters.values[1]
    end
    if self.filters.values[2] ~= "" then
        guiTable.vars.filter2.elem_value = self.filters.values[2]
    end

end

function IIO.interaction(event, player)
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
                io.combinator.get_or_create_control_behavior().set_signal(index, {signal={type="item", name=event.element.elem_value}, count=1})
            else
                io.filters.values[index] = ""
                io.combinator.get_or_create_control_behavior().set_signal(index, nil)
            end
        end
		GUI.update(true)
		return
	end

    if string.match(event.element.name, "RNS_NetworkCableIO_Item_Whitelist") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        io.whitelist = event.element.switch_state == "left" and true or false
		GUI.update(true)
		return
    end

    if string.match(event.element.name, "RNS_NetworkCableIO_Item_Metadata") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        io.metadataMode = event.element.state
		GUI.update(true)
		return
    end

    if string.match(event.element.name, "RNS_NetworkCableIO_Item_IO") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        io.io = event.element.switch_state == "left" and "input" or "output"
        io:generateModeIcon()
		GUI.update(true)
		return
    end

end