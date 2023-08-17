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
    ioIcon = nil
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
        values = {}
    }
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
    self:createArms()
    --local tick = game.tick % (120/Constants.Settings.RNS_BaseItemIO_Speed) --based on belt speed
    --if tick >= 0.0 and tick < 1.0 then self:IO() end
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

function IIO:IO()
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
        else
            local ind = self.filters.index
            local inv = foc.get_inventory(defines.inventory.chest)
            repeat
                local a = 0
                if self.io == "input" then
                    a = foc.remove_item(Util.next(self.filters))
                elseif self.io == "output" and self.whitelist == true and Util.getTableLength(self.filters.values) > 0 then
                    local nextItem = Util.next(self.filters)
                    if nextItem == nil then return end
                    local itemstack = Util.itemstack_template(nextItem)
                    for _, drive in pairs(network.getOperableObjects(network.ItemDriveTable)) do
                        if not inv.is_full() and drive:has_item(itemstack, self.metadataMode) > 0 then
                            a = BaseNet.transfer_basic_item(drive.storage, inv, itemstack, 1, self.metadataMode)
                        else
                            return
                        end
                    end
                end
            until a ~= 0 or ind == self.filters.index
            return
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
                        self.focusedEntity = ent
                        break
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
		if self.filters.values[1] ~= nil then filter1.elem_value = self.filters.values[1] end

        local filter2 = GuiApi.add_filter(guiTable, "RNS_NetworkCableIO_Item_Filter_2", filterFlow, "", true, "item", 40, {ID=self.thisEntity.unit_number})
		guiTable.vars.filter2 = filter2
		if self.filters.values[2] ~= nil then filter2.elem_value = self.filters.values[2] end

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

    if self.filters[1] ~= nil then
        guiTable.vars.filter1.elem_value = self.filters.values[1]
    end
    if self.filters[2] ~= nil then
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
            else
                io.filters.values[index] = nil
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