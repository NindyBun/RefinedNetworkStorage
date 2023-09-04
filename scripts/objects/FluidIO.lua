FIO = {
    thisEntity = nil,
    entID = nil,
    networkController = nil,
    arms = nil,
    connectedObjs = nil,
    cardinals = nil,
    filter = nil,
    whitelist = false,
    ioIcon = nil,
    io = "output",
    processed=false,
    focusedEntity=nil,
    combinator=nil,
    priority = 0
}

function FIO:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = FIO
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
    t.filter = ""
    t.focusedEntity = {
        thisEntity = nil,
        fluid_box = {
            index = nil,
            filter = "",
            target_position = nil,
            flow = ""
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

function FIO:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = FIO
    setmetatable(object, mt)
end

function FIO:remove()
    if self.combinator ~= nil then self.combinator.destroy() end
    UpdateSys.remove(self)
    if self.networkController ~= nil then
        self.networkController.network.FluidIOTable[self.entID] = nil
        self.networkController.network.shouldRefresh = true
    end
end

function FIO:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function FIO:update()
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
end

function FIO:toggleHoverIcon(hovering)
    if self.ioIcon == nil then return end
    if hovering and rendering.get_only_in_alt_mode(self.ioIcon) then
        rendering.set_only_in_alt_mode(self.ioIcon, false)
    elseif not hovering and not rendering.get_only_in_alt_mode(self.ioIcon) then
        rendering.set_only_in_alt_mode(self.ioIcon, true)
    end
end

function FIO:generateModeIcon()
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
        sprite=Constants.Icons.fluid, 
        target=self.thisEntity, 
        target_offset=offset,
        surface=self.thisEntity.surface,
        only_in_alt_mode=true,
        orientation=self.io == "input" and ((self:getRealDirection()*0.25)+0.25)%1.00 or ((self:getRealDirection()*0.25)-0.25)
    }
end

function FIO:IO()
    local transportCapacity = Constants.Settings.RNS_BaseFluidIO_TransferCapacity
    --#tank.fluidbox returns number of pipe connections
    --tank.fluidbox.get_locked_fluid(index) returns filtered fluid at an index
    --tank.fluidbox[index] returns the contents of the fluidbox at an index
    --tank.fluidbox.get_pipe_connections(index)[1] returns the fluidbox prototype at a pipe index and fluidbox index, we can use flow_direction and target_position
    --tank.fluidbox[index] = nil sets the fluidbox empty
    --tank.fluidbox[index] = {name?, amount?, tempurature?} sets the fluidbox

    for i=1, 1 do
        if self.networkController == nil or self.networkController.valid == false or self.networkController.stable == false then break end
        local network = self.networkController.network
        if self.focusedEntity.thisEntity ~= nil and self.focusedEntity.thisEntity.valid == true then
            local fluid_box = self.focusedEntity.fluid_box
            if self.thisEntity.position.x ~= fluid_box.target_position.x or self.thisEntity.position.y ~= fluid_box.target_position.y then break end

            for _, drive in pairs(BaseNet.getOperableObjects(network.FluidDriveTable)) do
                if self.io == "input" then
                    if string.match(fluid_box.flow, "output") == nil then break end
                    if drive:has_room() == 0 then goto continue end
                    if (self.filter == fluid_box.filter and fluid_box.filter ~= "") or (self.filter ~= fluid_box.filter and fluid_box.filter == "") then
                        transportCapacity = transportCapacity - BaseNet.transfer_from_tank_to_drive(drive, self.focusedEntity.thisEntity, fluid_box.index, self.filter, math.min(transportCapacity, drive:getRemainingStorageSize()))
                    end
                elseif self.io == "output" then
                    if string.match(fluid_box.flow, "input") == nil then break end
                    if drive:has_fluid(self.filter) == 0 then break end
                    if (self.filter == fluid_box.filter and fluid_box.filter ~= "") or (self.filter ~= fluid_box.filter and fluid_box.filter == "") then
                        transportCapacity = transportCapacity - BaseNet.transfer_from_drive_to_tank(drive, self.focusedEntity.thisEntity, fluid_box.index, self.filter, math.min(transportCapacity, drive:has_fluid(self.filter)))
                    end
                end
                ::continue::
                if transportCapacity <= 0 then break end
            end
        end
    end
    self.processed = transportCapacity < Constants.Settings.RNS_BaseFluidIO_TransferCapacity
end

function FIO:resetConnection()
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

function FIO:reset_focused_entity()
    self.focusedEntity = {
        thisEntity = nil,
        fluid_box = {
            index = 1,
            filter = "",
            target_position = {},
            flow = ""
        }
    }
end

function FIO:getCheckArea()
    local x = self.thisEntity.position.x
    local y = self.thisEntity.position.y
    return {
        [1] = {direction = 1, startP = {x-0.5, y-1.5}, endP = {x+0.5, y-0.5}}, --North
        [2] = {direction = 2, startP = {x+0.5, y-0.5}, endP = {x+1.5, y+0.5}}, --East
        [4] = {direction = 4, startP = {x-0.5, y+0.5}, endP = {x+0.5, y+1.5}}, --South
        [3] = {direction = 3, startP = {x-1.5, y-0.5}, endP = {x-0.5, y+0.5}}, --West
    }
end

function FIO:createArms()
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
                    if #ent.fluidbox ~= 0 then
                        if self.focusedEntity.thisEntity == nil or (self.focusedEntity.thisEntity ~= nil and self.focusedEntity.thisEntity.valid == false) then
                            self:reset_focused_entity()
                            self.focusedEntity.thisEntity = ent
                            for i=1, #ent.fluidbox do
                                for j=1, #ent.fluidbox.get_pipe_connections(i) do
                                    local target = ent.fluidbox.get_pipe_connections(i)[j]
                                    if target.target_position.x == self.thisEntity.position.x and target.target_position.y == self.thisEntity.position.y then
                                        self.focusedEntity.fluid_box.index = i
                                        self.focusedEntity.fluid_box.flow =  target.flow_direction
                                        self.focusedEntity.fluid_box.target_position = target.target_position
                                        self.focusedEntity.fluid_box.filter =  (ent.fluidbox.get_locked_fluid(i) ~= nil and {ent.fluidbox.get_locked_fluid(i)} or {""})[1]
                                        break
                                    end
                                end
                            end
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

function FIO:getDirection()
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

function FIO:getConnectionDirection()
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

function FIO:getRealDirection()
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

function FIO:getTooltips(guiTable, mainFrame, justCreated)
    if justCreated == true then
		guiTable.vars.Gui_Title.caption = {"gui-description.RNS_NetworkCableIO_Fluid"}

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

        local filter = GuiApi.add_filter(guiTable, "RNS_NetworkCableIO_Fluid_Filter", filterFlow, "", true, "fluid", 40, {ID=self.thisEntity.unit_number})
		guiTable.vars.filter = filter
		if self.filter ~= "" then filter.elem_value = self.filter end

        local settingsFrame = GuiApi.add_frame(guiTable, "SettingsFrame", mainFrame, "vertical", true)
		settingsFrame.style = Constants.Settings.RNS_Gui.frame_1
		settingsFrame.style.vertically_stretchable = true
		settingsFrame.style.left_padding = 3
		settingsFrame.style.right_padding = 3
		settingsFrame.style.right_margin = 3
		settingsFrame.style.minimal_width = 200

		GuiApi.add_subtitle(guiTable, "", settingsFrame, {"gui-description.RNS_Setting"})
    
        local priorityFlow = GuiApi.add_flow(guiTable, "", settingsFrame, "horizontal", false)
        GuiApi.add_label(guiTable, "", priorityFlow, {"gui-description.RNS_Priority"}, Constants.Settings.RNS_Gui.white)
        local priorityDD = GuiApi.add_dropdown(guiTable, "RNS_NetworkCableIO_Fluid_Priority", priorityFlow, Constants.Settings.RNS_Priorities, ((#Constants.Settings.RNS_Priorities+1)/2)-self.priority, false, "", {ID=self.thisEntity.unit_number})
        priorityDD.style.minimal_width = 100

        -- Input/Output mode
        local state = "left"
		if self.io == "output" then state = "right" end
		GuiApi.add_switch(guiTable, "RNS_NetworkCableIO_Fluid_IO", settingsFrame, {"gui-description.RNS_Input"}, {"gui-description.RNS_Output"}, "", "", state, false, {ID=self.thisEntity.unit_number})

        GuiApi.add_line(guiTable, "", settingsFrame, "horizontal")

    end

    if self.filter ~= "" then
        guiTable.vars.filter.elem_value = self.filter
    end
    
end


function FIO.interaction(event, RNSPlayer)
    if string.match(event.element.name, "RNS_NetworkCableIO_Fluid_Filter") then
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
		return
	end

    if string.match(event.element.name, "RNS_NetworkCableIO_Fluid_Priority") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local priority = Constants.Settings.RNS_Priorities[event.element.selected_index]
        if priority ~= io.priority then
            io.priority = priority
            if io.networkController ~= nil and io.networkController.valid == true then
                io.networkController.network:sort_by_priority(io.networkController.network.FluidIOTable)
            end
            io.processed = false
        end
		return
    end

    if string.match(event.element.name, "RNS_NetworkCableIO_Fluid_IO") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        io.io = event.element.switch_state == "left" and "input" or "output"
        io.processed = false
        io:generateModeIcon()
		return
    end
end