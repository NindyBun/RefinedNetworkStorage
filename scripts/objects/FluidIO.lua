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
    color = "RED",
    io = "output",
    processed=false,
    focusedEntity=nil,
    enabler = nil,
    enablerCombinator = nil,
    combinator=nil,
    priority = 0,
    powerUsage = 4,
}

function FIO:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = FIO
    t.thisEntity = object
    t.entID = object.unit_number
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
    t:createArms()
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
    if self.enablerCombinator ~= nil then self.enablerCombinator.destroy() end
    UpdateSys.remove(self)
    if self.networkController ~= nil then
        self.networkController.network.FluidIOTable[Constants.Settings.RNS_Max_Priority+1-self.priority][self.entID] = nil
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
    --if game.tick % 25 then self:createArms() end
end

function FIO:copy_settings(obj)
    self.color = obj.color
    self.whitelist = obj.whitelist
    self.io = obj.io
    self.enabler = obj.enabler

    self.filter = obj.filter
    self:set_icons(1, self.filter ~= "" and self.filter or nil)

    self.priority = obj.priority
    self:generateModeIcon()
end

function FIO:serialize_settings()
    local tags = {}

    tags["color"] = self.color
    tags["filter"] = self.filter
    tags["whitelist"] = self.whitelist
    tags["io"] = self.io
    tags["priority"] = self.priority
    tags["enabler"] = self.enabler

    return tags
end

function FIO:deserialize_settings(tags)
    self.color = tags["color"]
    self.whitelist = tags["whitelist"]
    self.io = tags["io"]
    self.enabler = tags["enabler"]

    self.filter = tags["filter"]
    self:set_icons(1, self.filter ~= "" and self.filter or nil)

    self.priority = tags["priority"]
    self:generateModeIcon()
end

function FIO:set_icons(index, name)
    self.combinator.get_or_create_control_behavior().set_signal(index, name ~= nil and {signal={type="fluid", name=name}, count=1} or nil)
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
    self:reset_focused_entity()
    if self.focusedEntity.thisEntity == nil then self.processed = true return end
    if self.networkController == nil or self.networkController.valid == false or self.networkController.stable == false then self.processed = true return end
    local network = self.networkController.network
    if self.enablerCombinator.get_circuit_network(defines.wire_type.red, defines.circuit_connector_id.constant_combinator) ~= nil or self.enablerCombinator.get_circuit_network(defines.wire_type.green, defines.circuit_connector_id.constant_combinator) ~= nil then
        if self.enabler.filter == nil then self.processed = true return end
        local amount = self.enablerCombinator.get_merged_signal({type=self.enabler.filter.type, name=self.enabler.filter.name}, defines.circuit_connector_id.constant_combinator)
        if Util.OperatorFunctions[self.enabler.operator](amount, self.enabler.number) == false then self.processed = true return end
    end
    local fluid_box = self.focusedEntity.fluid_box
    if self.thisEntity.position.x ~= fluid_box.target_position.x or self.thisEntity.position.y ~= fluid_box.target_position.y then self.processed = true return end
    
    local transportCapacity = Constants.Settings.RNS_BaseFluidIO_TransferCapacity*global.FIOMultiplier
    --#tank.fluidbox returns number of pipe connections
    --tank.fluidbox.get_locked_fluid(index) returns filtered fluid at an index
    --tank.fluidbox[index] returns the contents of the fluidbox at an index
    --tank.fluidbox.get_pipe_connections(index)[1] returns the fluidbox prototype at a pipe index and fluidbox index, we can use flow_direction and target_position
    --tank.fluidbox[index] = nil sets the fluidbox empty
    --tank.fluidbox[index] = {name?, amount?, tempurature?} sets the fluidbox
    for i=1, 1 do
        if self.focusedEntity.thisEntity ~= nil and self.focusedEntity.thisEntity.valid == true then
            local fluidDrives = BaseNet.getOperableObjects(network.FluidDriveTable)
            local externalTanks = BaseNet.filter_by_type("fluid", BaseNet.getOperableObjects(network:filter_externalIO_by_valid_signal()))
            for p = 1, Constants.Settings.RNS_Max_Priority*2 + 1 do
                local priorityF = fluidDrives[p]
                local priorityE = externalTanks[p]
                --if Util.getTableLength(priorityF) > 0 then
                    for _, drive in pairs(priorityF) do
                        if self.io == "input" then
                            if string.match(fluid_box.flow, "output") == nil then goto exit end
                            local remaining = drive:getRemainingStorageSize()
                            if remaining <= 0 then goto continue end
                            if (self.filter == fluid_box.filter and fluid_box.filter ~= "") or (self.filter ~= fluid_box.filter and fluid_box.filter == "") then
                                transportCapacity = transportCapacity - BaseNet.transfer_from_tank_to_drive(self.focusedEntity.thisEntity, drive, fluid_box.index, self.filter, math.min(transportCapacity, remaining))
                                if transportCapacity <= 0 or self.focusedEntity.thisEntity.fluidbox[fluid_box.index] == nil then goto exit end
                            end
                        elseif self.io == "output" then
                            if string.match(fluid_box.flow, "input") == nil then goto exit end
                            if drive:has_fluid(self.filter) == 0 then goto continue end
                            if (self.filter == fluid_box.filter and fluid_box.filter ~= "") or (self.filter ~= fluid_box.filter and fluid_box.filter == "") then
                                transportCapacity = transportCapacity - BaseNet.transfer_from_drive_to_tank(drive, self.focusedEntity.thisEntity, fluid_box.index, self.filter, math.min(transportCapacity, drive:has_fluid(self.filter)))
                                if transportCapacity <= 0 or self.focusedEntity.thisEntity.fluidbox[fluid_box.index].amount == self.focusedEntity.thisEntity.fluidbox.get_capacity(fluid_box.index) then goto exit end
                            end
                        end
                        ::continue::
                    end
                --end
                --if Util.getTableLength(priorityE) > 0 then
                    for _, externalTank in pairs(priorityE) do
                        if  externalTank.focusedEntity.thisEntity ~= nil and externalTank.focusedEntity.thisEntity.valid and externalTank.focusedEntity.thisEntity.to_be_deconstructed() == false and externalTank.focusedEntity.fluid_box.index ~= nil then
                            local fluid_boxE = externalTank.focusedEntity.fluid_box
                            if self.io == "input" then
                                if string.match(fluid_box.flow, "output") == nil then goto exit end
                                if string.match(fluid_boxE.flow, "input") == nil then goto continue end
                                if string.match(externalTank.io, "input") == nil then goto continue end
                                if (self.filter == fluid_box.filter and fluid_box.filter ~= "") or (self.filter ~= fluid_box.filter and fluid_box.filter == "") then
                                    if Util.getTableLength_non_nil(externalTank.filters.fluid.values) > 0 then
                                        if externalTank:matches_filters("fluid", self.filter) == true then
                                            if externalTank.whitelist == false then goto continue end
                                        else
                                            if externalTank.whitelist == true then goto continue end
                                        end
                                    elseif Util.getTableLength_non_nil(externalTank.filters.fluid.values) == 0 then
                                        if externalTank.whitelist == true then goto continue end
                                    end
                                    transportCapacity = transportCapacity - BaseNet.transfer_from_tank_to_tank(self.focusedEntity.thisEntity, externalTank.focusedEntity.thisEntity, fluid_box.index, fluid_boxE.index, self.filter, transportCapacity)
                                    if transportCapacity <= 0 or self.focusedEntity.thisEntity.fluidbox[fluid_box.index] == nil then goto exit end
                                end
                            elseif self.io == "output" then
                                if string.match(fluid_box.flow, "input") == nil then goto exit end
                                if string.match(fluid_boxE.flow, "output") == nil then goto continue end
                                if string.match(externalTank.io, "output") == nil then goto continue end
                                if (self.filter == fluid_box.filter and fluid_box.filter ~= "") or (self.filter ~= fluid_box.filter and fluid_box.filter == "") then
                                    if Util.getTableLength_non_nil(externalTank.filters.fluid.values) > 0 then
                                        if externalTank:matches_filters("fluid", self.filter) == true then
                                            if externalTank.whitelist == false then goto continue end
                                        else
                                            if externalTank.whitelist == true then goto continue end
                                        end
                                    elseif Util.getTableLength_non_nil(externalTank.filters.fluid.values) == 0 then
                                        if externalTank.whitelist == true then goto continue end
                                    end
                                    transportCapacity = transportCapacity - BaseNet.transfer_from_tank_to_tank(externalTank.focusedEntity.thisEntity, self.focusedEntity.thisEntity, fluid_box.index, fluid_boxE.index, self.filter, transportCapacity)
                                    if transportCapacity <= 0 or (self.focusedEntity.thisEntity.fluidbox[fluid_box.index] ~= nil and self.focusedEntity.thisEntity.fluidbox[fluid_box.index].amount == self.focusedEntity.thisEntity.fluidbox.get_capacity(fluid_box.index)) then goto exit end
                                end
                            end
                            ::continue::
                        end
                    end
                --end
            end
        end
        ::exit::
    end
    self.processed = transportCapacity < Constants.Settings.RNS_BaseFluidIO_TransferCapacity*global.FIOMultiplier or (self.focusedEntity.thisEntity ~= nil and self:checkFullness())
end

function FIO:checkFullness()
    local fluid_box = self.focusedEntity.fluid_box
    if self.io == "output" and (self.focusedEntity.thisEntity.fluidbox[fluid_box.index] ~= nil and self.focusedEntity.thisEntity.fluidbox[fluid_box.index].amount == self.focusedEntity.thisEntity.fluidbox.get_capacity(fluid_box.index)) then return true end
    return false
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

    local selfP = self.thisEntity.position
    local area = self:getCheckArea()[self:getDirection()]
    local ents = self.thisEntity.surface.find_entities_filtered{area={area.startP, area.endP}}
    local nearest = nil

    for _, ent in pairs(ents) do
        if ent ~= nil and ent.valid == true and string.match(ent.name, "RNS_") == nil and ent.operable and global.entityTable[ent.unit_number] == nil then
            if (nearest == nil or Util.distance(selfP, ent.position) < Util.distance(selfP, nearest.position)) then
                nearest = ent
            end
        end
    end

    if nearest == nil then return end
    if #nearest.fluidbox ~= 0 then
        if self.focusedEntity.thisEntity == nil or (self.focusedEntity.thisEntity ~= nil and self.focusedEntity.thisEntity.valid == false) then
            self.focusedEntity.thisEntity = nearest
            for i=1, #nearest.fluidbox do
                for j=1, #nearest.fluidbox.get_pipe_connections(i) do
                    local target = nearest.fluidbox.get_pipe_connections(i)[j]
                    if target.target_position.x == self.thisEntity.position.x and target.target_position.y == self.thisEntity.position.y then
                        self.focusedEntity.fluid_box.index = i
                        self.focusedEntity.fluid_box.flow =  target.flow_direction
                        self.focusedEntity.fluid_box.target_position = target.target_position
                        self.focusedEntity.fluid_box.filter =  (nearest.fluidbox.get_locked_fluid(i) ~= nil and {nearest.fluidbox.get_locked_fluid(i)} or {""})[1]
                        break
                    end
                end
            end
        end
    end
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
		guiTable.vars.Gui_Title.caption = {"gui-description.RNS_NetworkCableIO_Fluid_Title"}
        local mainFlow = GuiApi.add_flow(guiTable, "", mainFrame, "vertical")

        local rateFlow = GuiApi.add_flow(guiTable, "", mainFlow, "vertical")
        local rateFrame = GuiApi.add_frame(guiTable, "", rateFlow, "vertical")
		rateFrame.style = Constants.Settings.RNS_Gui.frame_1
		rateFrame.style.vertically_stretchable = true
		rateFrame.style.left_padding = 3
		rateFrame.style.right_padding = 3
		rateFrame.style.right_margin = 3
        GuiApi.add_label(guiTable, "TransferRate", rateFrame, {"gui-description.RNS_FluidTransferRate", Constants.Settings.RNS_BaseFluidIO_TransferCapacity*12*global.FIOMultiplier}, Constants.Settings.RNS_Gui.white, "", true)

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
        local colorDD = GuiApi.add_dropdown(guiTable, "RNS_NetworkCableIO_Fluid_Color", colorFrame, Constants.Settings.RNS_ColorG, Constants.Settings.RNS_Colors[self.color], false, {"gui-description.RNS_Connection_Color_tooltip"}, {ID=self.thisEntity.unit_number})
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

        local filter = GuiApi.add_filter(guiTable, "RNS_NetworkCableIO_Fluid_Filter", filterFlow, "", true, "fluid", 40, {ID=self.thisEntity.unit_number})
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
        local priorityDD = GuiApi.add_dropdown(guiTable, "RNS_NetworkCableIO_Fluid_Priority", priorityFlow, Constants.Settings.RNS_Priorities, ((#Constants.Settings.RNS_Priorities+1)/2)-self.priority, false, "", {ID=self.thisEntity.unit_number})
        priorityDD.style.minimal_width = 100

        -- Input/Output mode
        local state = "left"
		if self.io == "output" then state = "right" end
		GuiApi.add_switch(guiTable, "RNS_NetworkCableIO_Fluid_IO", settingsFrame, {"gui-description.RNS_Input"}, {"gui-description.RNS_Output"}, "", "", state, false, {ID=self.thisEntity.unit_number})

        GuiApi.add_line(guiTable, "", settingsFrame, "horizontal")

        if self.enablerCombinator.get_circuit_network(defines.wire_type.red) ~= nil or self.enablerCombinator.get_circuit_network(defines.wire_type.green) ~= nil then
            local enableFrame = GuiApi.add_frame(guiTable, "EnableFrame", bottomFrame, "vertical")
            enableFrame.style = Constants.Settings.RNS_Gui.frame_1
            enableFrame.style.vertically_stretchable = true
            enableFrame.style.left_padding = 3
            enableFrame.style.right_padding = 3
            enableFrame.style.right_margin = 3
    
            GuiApi.add_subtitle(guiTable, "ConditionSub", enableFrame, {"gui-description.RNS_Condition"})
            local cFlow = GuiApi.add_flow(guiTable, "", enableFrame, "horizontal")
            cFlow.style.vertical_align = "center"
            local filter = GuiApi.add_filter(guiTable, "RNS_NetworkCableIO_Fluid_Enabler", cFlow, "", true, "signal", 40, {ID=self.thisEntity.unit_number})
            guiTable.vars.enabler = filter
            if self.enabler.filter ~= nil then
                filter.elem_value = self.enabler.filter
            end
            local opDD = GuiApi.add_dropdown(guiTable, "RNS_NetworkCableIO_Fluid_Operator", cFlow, Constants.Settings.RNS_OperatorN, Constants.Settings.RNS_Operators[self.enabler.operator], false, "", {ID=self.thisEntity.unit_number})
            opDD.style.minimal_width = 50
            --local number = GuiApi.add_filter(guiTable, "RNS_Detector_Number", cFlow, "", true, "signal", 40, {ID=self.thisEntity.unit_number})
            --number.elem_value = {type="virtual", name="constant-number"}
            local number = GuiApi.add_text_field(guiTable, "RNS_NetworkCableIO_Fluid_Number", cFlow, tostring(self.enabler.number), "", false, true, false, false, nil, {ID=self.thisEntity.unit_number})
            number.style.minimal_width = 100
        end
    end

    guiTable.vars.TransferRate.caption = {"gui-description.RNS_FluidTransferRate", Constants.Settings.RNS_BaseFluidIO_TransferCapacity*12*global.FIOMultiplier}

    if self.filter ~= "" then
        guiTable.vars.filter.elem_value = self.filter
    end
    if self.enabler.filter ~= nil and (self.enablerCombinator.get_circuit_network(defines.wire_type.red) ~= nil or self.enablerCombinator.get_circuit_network(defines.wire_type.green) ~= nil) then
        guiTable.vars.enabler.elem_value = self.enabler.filter
    end
    
end


function FIO.interaction(event, RNSPlayer)
    if string.match(event.element.name, "RNS_NetworkCableIO_Fluid_Number") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local num = math.min(2^32, tonumber(event.element.text ~= "" and event.element.text or "0"))
        io.enabler.number = num
        event.element.text = tostring(num)
        return
    end
    if string.match(event.element.name, "RNS_NetworkCableIO_Fluid_Operator") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local operator = Constants.Settings.RNS_OperatorN[event.element.selected_index]
        if operator ~= io.enabler.operator then
            io.enabler.operator = operator
        end
		return
    end
    if string.match(event.element.name, "RNS_NetworkCableIO_Fluid_Enabler") then
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
        io.processed = false
		return
	end

    if string.match(event.element.name, "RNS_NetworkCableIO_Fluid_Color") then
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

    if string.match(event.element.name, "RNS_NetworkCableIO_Fluid_Priority") then
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