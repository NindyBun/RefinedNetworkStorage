FIO2 = {
    thisEntity = nil,
    entID = nil,
    networkController = nil,
    arms = nil,
    connectedObjs = nil,
    cardinals = nil,
    filter = nil,
    --ioIcon = nil,
    color = "RED",
    io = "input",
    processed=false,
    combinator=nil,
    priority = 0,
    powerUsage = 4,
    port = nil
}

function FIO2:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = FIO2
    t.thisEntity = object
    t.entID = object.unit_number
    rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[t.color].sprites[5].name, target=t.thisEntity, surface=t.thisEntity.surface, render_layer="lower-object-above-shadow"}
    --t:generateModeIcon()
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
    t.filter = ""
    t.combinator = object.surface.create_entity{
        name="rns_Combinator",
        position=object.position,
        force="neutral"
    }
    t.combinator.destructible = false
    t.combinator.operable = false
    t.combinator.minable = false
    t:change_pump(t.io)
    t:createArms()
    UpdateSys.addEntity(t)
    return t
end

function FIO2:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = FIO2
    setmetatable(object, mt)
end

function FIO2:remove()
    self:return_fluid_on_removed()
    if self.combinator ~= nil then self.combinator.destroy() end
    if self.port ~= nil then self.port.destroy() end
    UpdateSys.remove(self)
    if self.networkController ~= nil then
        self.networkController.network.FluidIOV2Table[Constants.Settings.RNS_Max_Priority+1-self.priority][self.entID] = nil
        self.networkController.network.shouldRefresh = true
    end
end

function FIO2:rotate()
    self.port.direction = self.thisEntity.direction
end

function FIO2:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function FIO2:update()
    if valid(self) == false then
        self:remove()
        return
    end
    if valid(self.networkController) == false then
        self.networkController = nil
    end
    if self.thisEntity.to_be_deconstructed() == true then return end
end

function FIO2:copy_settings(obj)
    self.color = obj.color
    self.io = obj.io

    self.filter = obj.filter
    self:set_icons(1, self.filter ~= "" and self.filter or nil)

    self.priority = obj.priority
    self:change_pump(self.io)
end

function FIO2:serialize_settings()
    local tags = {}

    tags["color"] = self.color
    tags["filter"] = self.filter
    tags["io"] = self.io
    tags["priority"] = self.priority

    return tags
end

function FIO2:deserialize_settings(tags)
    self.color = tags["color"]
    self.io = tags["io"]

    self.filter = tags["filter"]
    self:set_icons(1, self.filter ~= "" and self.filter or nil)

    self.priority = tags["priority"]
    self:change_pump(self.io)
end

function FIO2:set_icons(index, name)
    self.combinator.get_or_create_control_behavior().set_signal(index, name ~= nil and {signal={type="fluid", name=name}, count=1} or nil)
end

function FIO2:return_fluid_on_removed()
    if self.port == nil then return end
    if self.port.fluidbox[1] == nil then return end
    if self.networkController == nil or self.networkController.valid == false or self.networkController.stable == false then return end
    local network = self.networkController.network
    local fluidDrives = BaseNet.getOperableObjects(network.FluidDriveTable)
    local externalTanks = BaseNet.filter_by_type("fluid", BaseNet.getOperableObjects(network:filter_externalIO_by_valid_signal()))
    for p = 1, Constants.Settings.RNS_Max_Priority*2 + 1 do
        local priorityF = fluidDrives[p]
        local priorityE = externalTanks[p]
        if Util.getTableLength(priorityF) > 0 then
            for _, drive in pairs(priorityF) do
                if not drive:has_room() then goto continue end
                BaseNet.transfer_from_tank_to_drive(self.port, drive, 1, self.port.fluidbox[1].name, math.min(self.port.get_fluid_count(), drive:getRemainingStorageSize()))
                if self.port.fluidbox[1] == nil then return end
                ::continue::
            end
        end
        if Util.getTableLength(priorityE) > 0 then
            for _, externalTank in pairs(priorityE) do
                if externalTank.focusedEntity.thisEntity ~= nil and externalTank.focusedEntity.thisEntity.valid and externalTank.focusedEntity.thisEntity.to_be_deconstructed() == false and externalTank.focusedEntity.fluid_box.index ~= nil then
                    local fluid_boxE = externalTank.focusedEntity.fluid_box
                    if string.match(fluid_boxE.flow, "input") == nil then goto continue end
                    if string.match(externalTank.io, "input") == nil then goto continue end
                    if Util.getTableLength_non_nil(externalTank.filters.fluid.values) > 0 then
                        if externalTank:matches_filters("fluid", self.port.fluidbox[1].name) == true then
                            if externalTank.whitelist == false then goto continue end
                        else
                            if externalTank.whitelist == true then goto continue end
                        end
                    elseif Util.getTableLength_non_nil(externalTank.filters.fluid.values) == 0 then
                        if externalTank.whitelist == true then goto continue end
                    end
                    BaseNet.transfer_from_tank_to_tank(self.port, externalTank.focusedEntity.thisEntity, 1, fluid_boxE.index, self.port.fluidbox[1].name, self.port.get_fluid_count())
                    if self.port.fluidbox[1] == nil then return end
                    ::continue::
                end
            end
        end
    end
end

function FIO2:IO()
    --self:reset_focused_entity()
    local transportCapacity = Constants.Settings.RNS_BaseFluidIO_TransferCapacity*global.FIOMultiplier
    --#tank.fluidbox returns number of pipe connections
    --tank.fluidbox.get_locked_fluid(index) returns filtered fluid at an index
    --tank.fluidbox[index] returns the contents of the fluidbox at an index
    --tank.fluidbox.get_pipe_connections(index)[1] returns the fluidbox prototype at a pipe index and fluidbox index, we can use flow_direction and target_position
    --tank.fluidbox[index] = nil sets the fluidbox empty
    --tank.fluidbox[index] = {name?, amount?, tempurature?} sets the fluidbox

    for i=1, 1 do
        if self.io == "input" and self.port.fluidbox[1] == nil then break end
        if self.io == "input" and self.filter ~= self.port.fluidbox[1].name then break end
        if self.networkController == nil or self.networkController.valid == false or self.networkController.stable == false then break end
        local network = self.networkController.network
        local fluidDrives = BaseNet.getOperableObjects(network.FluidDriveTable)
        local externalTanks = BaseNet.filter_by_type("fluid", BaseNet.getOperableObjects(network:filter_externalIO_by_valid_signal()))
        for p = 1, Constants.Settings.RNS_Max_Priority*2 + 1 do
            local priorityF = fluidDrives[p]
            local priorityE = externalTanks[p]
            if Util.getTableLength(priorityF) > 0 then
                for _, drive in pairs(priorityF) do
                    if self.io == "input" then
                        if not drive:has_room() then goto continue end
                        transportCapacity = transportCapacity - BaseNet.transfer_from_tank_to_drive(self.port, drive, 1, self.filter, math.min(transportCapacity, drive:getRemainingStorageSize()))
                        if transportCapacity <= 0 or self.port.fluidbox[1] == nil then goto exit end
                    elseif self.io == "output" then
                        if drive:has_fluid(self.filter) == 0 then goto continue end
                        transportCapacity = transportCapacity - BaseNet.transfer_from_drive_to_tank(drive, self.port, 1, self.filter, math.min(transportCapacity, drive:has_fluid(self.filter)))
                        if transportCapacity <= 0 or self.port.get_fluid_count() == self.port.fluidbox.get_capacity(1) then goto exit end
                    end
                    ::continue::
                end
            end
            if Util.getTableLength(priorityE) > 0 then
                for _, externalTank in pairs(priorityE) do
                    if  externalTank.focusedEntity.thisEntity ~= nil and externalTank.focusedEntity.thisEntity.valid and externalTank.focusedEntity.thisEntity.to_be_deconstructed() == false and externalTank.focusedEntity.fluid_box.index ~= nil then
                        local fluid_boxE = externalTank.focusedEntity.fluid_box
                        if Util.getTableLength_non_nil(externalTank.filters.fluid.values) > 0 then
                            if externalTank:matches_filters("fluid", self.filter) == true then
                                if externalTank.whitelist == false then goto continue end
                            else
                                if externalTank.whitelist == true then goto continue end
                            end
                        elseif Util.getTableLength_non_nil(externalTank.filters.fluid.values) == 0 then
                            if externalTank.whitelist == true then goto continue end
                        end

                        if self.io == "input" then
                            if string.match(fluid_boxE.flow, "input") == nil then goto continue end
                            if string.match(externalTank.io, "input") == nil then goto continue end
                            transportCapacity = transportCapacity - BaseNet.transfer_from_tank_to_tank(self.port, externalTank.focusedEntity.thisEntity, 1, fluid_boxE.index, self.filter, transportCapacity)
                            if transportCapacity <= 0 or self.port.fluidbox[1] == nil then goto exit end
                        elseif self.io == "output" then
                            if string.match(fluid_boxE.flow, "output") == nil then goto continue end
                            if string.match(externalTank.io, "output") == nil then goto continue end
                            transportCapacity = transportCapacity - BaseNet.transfer_from_tank_to_tank(externalTank.focusedEntity.thisEntity, self.port, fluid_boxE.index, 1, self.filter, transportCapacity)
                            if transportCapacity <= 0 or self.port.get_fluid_count() == self.port.fluidbox.get_capacity(1) then goto exit end
                        end
                        ::continue::
                    end
                end
            end
            ::exit::
        end
    end
    self.processed = transportCapacity <= Constants.Settings.RNS_BaseFluidIO_TransferCapacity*global.FIOMultiplier
end

function FIO2:resetConnection()
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

function FIO2:getCheckArea()
    local x = self.thisEntity.position.x
    local y = self.thisEntity.position.y
    return {
        [1] = {direction = 1, startP = {x-0.5, y-1.5}, endP = {x+0.5, y-0.5}}, --North
        [2] = {direction = 2, startP = {x+0.5, y-0.5}, endP = {x+1.5, y+0.5}}, --East
        [4] = {direction = 4, startP = {x-0.5, y+0.5}, endP = {x+0.5, y+1.5}}, --South
        [3] = {direction = 3, startP = {x-1.5, y-0.5}, endP = {x-0.5, y+0.5}}, --West
    }
end

function FIO2:createArms()
    local areas = self:getCheckArea()
    self:resetConnection()
    for _, area in pairs(areas) do
        local enti = 0
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
                                enti = enti + 1
                            elseif obj.color ~= "" and obj.color == self.color then
                                self.arms[area.direction] = rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[self.color].sprites[area.direction].name, target=self.thisEntity, surface=self.thisEntity.surface, render_layer="lower-object-above-shadow"}
                                self.connectedObjs[area.direction] = {obj}
                                enti = enti + 1
                            end
                        end
                        break
                    end
                end
            end
        end
    end
end

function FIO2:getDirection()
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

function FIO2:getConnectionDirection()
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

function FIO2:getRealDirection()
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

function FIO2:getTooltips(guiTable, mainFrame, justCreated)
    if justCreated == true then
		guiTable.vars.Gui_Title.caption = {"gui-description.RNS_NetworkCableIOV2_Fluid_Title"}
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
        local colorDD = GuiApi.add_dropdown(guiTable, "RNS_NetworkCableIOV2_Fluid_Color", colorFrame, Constants.Settings.RNS_ColorG, Constants.Settings.RNS_Colors[self.color], false, {"gui-description.RNS_Connection_Color_tooltip"}, {ID=self.thisEntity.unit_number})
        colorDD.style.minimal_width = 100

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

        local filter = GuiApi.add_filter(guiTable, "RNS_NetworkCableIOV2_Fluid_Filter", filterFlow, "", true, "fluid", 40, {ID=self.thisEntity.unit_number})
		guiTable.vars.filter = filter
		if self.filter ~= "" then filter.elem_value = self.filter end

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
        local priorityDD = GuiApi.add_dropdown(guiTable, "RNS_NetworkCableIOV2_Fluid_Priority", priorityFlow, Constants.Settings.RNS_Priorities, ((#Constants.Settings.RNS_Priorities+1)/2)-self.priority, false, "", {ID=self.thisEntity.unit_number})
        priorityDD.style.minimal_width = 100

        GuiApi.add_line(guiTable, "", settingsFrame, "horizontal")

        -- Input/Output mode
        local state = "left"
		if self.io == "output" then state = "right" end
		GuiApi.add_switch(guiTable, "RNS_NetworkCableIOV2_Fluid_IO", settingsFrame, {"gui-description.RNS_Input"}, {"gui-description.RNS_Output"}, "", "", state, false, {ID=self.thisEntity.unit_number})
    end

    if self.filter ~= "" then
        guiTable.vars.filter.elem_value = self.filter
    end
end

function FIO2:change_pump(io)
    self:return_fluid_on_removed()
    if self.port ~= nil then self.port.destroy() end
    self.port = self.thisEntity.surface.create_entity{
        name="rns_Fluid_"..io,
        direction=self.thisEntity.direction,
        position=self.thisEntity.position,
        force="neutral"
    }
    self.port.destructible = false
    self.port.minable = false
end

function FIO2.interaction(event, RNSPlayer)
    if string.match(event.element.name, "RNS_NetworkCableIOV2_Fluid_Filter") then
		local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        if event.element.elem_value ~= nil then
            io.filter = event.element.elem_value
            io.combinator.get_or_create_control_behavior().set_signal(1, {signal={type="fluid", name=event.element.elem_value}, count=1})
        else
            io.filter = ""
            io.combinator.get_or_create_control_behavior().set_signal(1, nil)
        end
        io.processed = false
		return
	end

    if string.match(event.element.name, "RNS_NetworkCableIOV2_Fluid_Color") then
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

    if string.match(event.element.name, "RNS_NetworkCableIOV2_Fluid_Priority") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local priority = Constants.Settings.RNS_Priorities[event.element.selected_index]
        if priority ~= io.priority then
            local oldP = 1+Constants.Settings.RNS_Max_Priority-io.priority
            io.priority = priority
            if io.networkController ~= nil and io.networkController.valid == true then
                io.networkController.network.FluidIOTable[oldP][io.entID] = nil
                io.networkController.network.FluidIOTable[1+Constants.Settings.RNS_Max_Priority-priority][io.entID] = io
            end
            io.processed = false
        end
		return
    end

    if string.match(event.element.name, "RNS_NetworkCableIOV2_Fluid_IO") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        io.io = event.element.switch_state == "left" and "input" or "output"
        io.processed = false
        io:change_pump(io.io)
		return
    end
end