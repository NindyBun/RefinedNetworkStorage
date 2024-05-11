DT = {
    thisEntity = nil,
    entID = nil,
    arms = nil,
    color = "RED",
    connectedObjs = nil,
    networkController = nil,
    type = "item",
    filters = nil,
    enabler = nil,
    cardinals = nil,
    combinator = nil,
    powerUsage = 40,
    disconnects = nil,
    icons = nil,
    oldState = false,
    newState = false,
    mode = "enable/disable",
    readFromNetwork = true
}

function DT:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = DT
    t.thisEntity = object
    t.entID = object.unit_number
    rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[t.color].sprites[5].name, target=t.thisEntity, surface=t.thisEntity.surface, render_layer="lower-object-above-shadow"}
    t.arms = {
        [1] = nil, --N
        [2] = nil, --E
        [3] = nil, --S
        [4] = nil, --W
    }
    t.connectedObjs = {
        [1] = {}, --N
        [2] = {}, --E
        [4] = {}, --S
        [3] = {}, --W
    }
    t.cardinals = {
        [1] = false, --N
        [2] = false, --E
        [3] = false, --S
        [4] = false, --W
    }
    t.disconnects = {
        [1] = false,
        [2] = false,
        [3] = false,
        [4] = false
    }
    t.icons = {
        [1] = nil,
        [2] = nil,
        [4] = nil,
        [3] = nil,
    }
    t.filters = {
        item = "",
        fluid = "",
        virtual = ""
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
        filter = "",
        numberOutput = 1
    }
    t.enablerCombinator = object.surface.create_entity{
        name="rns_Combinator_1",
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

function DT:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = DT
    setmetatable(object, mt)
end

function DT:remove()
    UpdateSys.remove_from_entity_table(self)
    BaseNet.postArms(self)
    if self.combinator ~= nil then self.combinator.destroy() end
    if self.enablerCombinator ~= nil then self.enablerCombinator.destroy() end
    --UpdateSys.remove(self)
    --[[if self.networkController ~= nil then
        self.networkController.network.DetectorTable[1][self.entID] = nil
        self.networkController.network.shouldRefresh = true
    end]]
    BaseNet.update_network_controller(self.networkController, self.entID)
end

function DT:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

--[[function DT:update()
    --if game.tick % 60 then
        self.lastUpdate = game.tick
        if valid(self) == false then
            self:remove()
            return
        end
        if valid(self.networkController) == false then
            self.networkController = nil
        end
        if self.thisEntity.to_be_deconstructed() == true then return end
        --if game.tick % 25 then self:createArms() end
    --end
end]]

function DT:update_signal()
    if self.mode == "enable/disable" then
        if self.filters[self.type] == "" or self.output == "" or self.enabler.filter == "" then return end
        local amount = self.networkController.network.Contents[self.type][self.filters[self.type]] or 0

        if self.networkController ~= nil and self.networkController.thisEntity ~= nil and self.networkController.thisEntity.valid == true and self.networkController.thisEntity.to_be_deconstructed() == false and Util.OperatorFunctions[self.enabler.operator](amount, self.enabler.number) == true then
            --self.combinator.get_or_create_control_behavior().set_signal(2,  (operatorFunctions[self.operator](amount, self.number) and {{signal={type="virtual", name="signal-red"}, count=1}} or {nil})[1])
            self.enablerCombinator.get_or_create_control_behavior().set_signal(1, {signal={type=self.enabler.filter.type, name=self.enabler.filter.name}, count=(self.enabler.numberOutput == 1 and 1 or amount)})
        else
            --self.combinator.get_or_create_control_behavior().set_signal(2,  nil)
            self.enablerCombinator.get_or_create_control_behavior().set_signal(1, nil)
        end
    elseif self.mode == "connect/disconnect" then
        if self.readFromNetwork == false and self.filters["virtual"] ~= "" and (self.enablerCombinator.get_circuit_network(defines.wire_type.red, defines.circuit_connector_id.constant_combinator) ~= nil or self.enablerCombinator.get_circuit_network(defines.wire_type.green, defines.circuit_connector_id.constant_combinator) ~= nil) then
            local amount = self.enablerCombinator.get_merged_signal({type=self.filters["virtual"].type, name=self.filters["virtual"].name}, defines.circuit_connector_id.constant_combinator)
            self.newState = Util.OperatorFunctions[self.enabler.operator](amount, self.enabler.number)
        elseif self.readFromNetwork == true and self.filters["virtual"] ~= "" then
            local amount = self.networkController.network.Contents.item[self.filters["virtual"]] or self.networkController.network.Contents.fluid[self.filters["virtual"]] or 0
            self.newState = Util.OperatorFunctions[self.enabler.operator](amount, self.enabler.number)
        end
        if self.oldState ~= self.newState then
            self.oldState = self.newState
            self:createArms()
            BaseNet.postArms(self)
            BaseNet.update_network_controller(self.networkController)
        end
    end
end

function DT:set_icons(index, name, type)
    self.combinator.get_or_create_control_behavior().set_signal(index, name ~= nil and {signal={type=type, name=name}, count=1} or nil)
end

function DT:toggleHoverIcon(hovering)
    if self.icons[1] ~= nil and hovering and rendering.get_only_in_alt_mode(self.icons[1]) then
        rendering.set_only_in_alt_mode(self.icons[1], false)
    elseif self.icons[1] ~= nil and not hovering and not rendering.get_only_in_alt_mode(self.icons[1]) then
        rendering.set_only_in_alt_mode(self.icons[1], true)
    end

    if self.icons[2] ~= nil and hovering and rendering.get_only_in_alt_mode(self.icons[2]) then
        rendering.set_only_in_alt_mode(self.icons[2], false)
    elseif self.icons[2] ~= nil and not hovering and not rendering.get_only_in_alt_mode(self.icons[2]) then
        rendering.set_only_in_alt_mode(self.icons[2], true)
    end

    if self.icons[3] ~= nil and hovering and rendering.get_only_in_alt_mode(self.icons[3]) then
        rendering.set_only_in_alt_mode(self.icons[3], false)
    elseif self.icons[3] ~= nil and not hovering and not rendering.get_only_in_alt_mode(self.icons[3]) then
        rendering.set_only_in_alt_mode(self.icons[3], true)
    end

    if self.icons[4] ~= nil and hovering and rendering.get_only_in_alt_mode(self.icons[4]) then
        rendering.set_only_in_alt_mode(self.icons[4], false)
    elseif self.icons[4] ~= nil and not hovering and not rendering.get_only_in_alt_mode(self.icons[4]) then
        rendering.set_only_in_alt_mode(self.icons[4], true)
    end
end

function DT:generateModeIcon()
    if self.icons[1] ~= nil then rendering.destroy(self.icons[1]) end
    self.icons[1] = nil
    if self.disconnects[1] == true then
        self.icons[1] = rendering.draw_sprite{
            sprite=Constants.Icons.line,
            target=self.thisEntity,
            target_offset={0,-0.5},
            surface=self.thisEntity.surface,
            only_in_alt_mode=true,
            orientation=0
        }
    end

    if self.icons[2] ~= nil then rendering.destroy(self.icons[2]) end
    self.icons[2] = nil
    if self.disconnects[2] == true then
        self.icons[2] = rendering.draw_sprite{
            sprite=Constants.Icons.line,
            target=self.thisEntity,
            target_offset={0.5, 0},
            surface=self.thisEntity.surface,
            only_in_alt_mode=true,
            orientation=0.25
        }
    end

    if self.icons[3] ~= nil then rendering.destroy(self.icons[3]) end
    self.icons[3] = nil
    if self.disconnects[3] == true then
        self.icons[3] = rendering.draw_sprite{
            sprite=Constants.Icons.line,
            target=self.thisEntity,
            target_offset={-0.5,0},
            surface=self.thisEntity.surface,
            only_in_alt_mode=true,
            orientation=0.25
        }
    end

    if self.icons[4] ~= nil then rendering.destroy(self.icons[4]) end
    self.icons[4] = nil
    if self.disconnects[4] == true then
        self.icons[4] = rendering.draw_sprite{
            sprite=Constants.Icons.line,
            target=self.thisEntity,
            target_offset={0,0.5},
            surface=self.thisEntity.surface,
            only_in_alt_mode=true,
            orientation=0
        }
    end
end

function DT:copy_settings(obj)
    self.color = obj.color
    self.enabler = obj.enabler
    self.type = obj.type
    self.filters = {
        item = obj.filters.item,
        fluid = obj.filters.fluid
    }
    self.mode = obj.mode
    self.disconnects = obj.disconnects
    self.readFromNetwork = obj.readFromNetwork
    self:set_icons(1, self.filters[self.type] ~= "" and self.filters[self.type] or nil, self.type)
    self:set_icons(2, self.enabler.filter.name ~= "" and self.enabler.filter.name or nil, self.enabler.filter.type)
    self:generateModeIcon()
end

function DT:serialize_settings()
    local tags = {}
    tags["color"] = self.color
    tags["enabler"] = self.enabler
    tags["filters"] = self.filters
    tags["type"] = self.type
    tags["mode"] = self.mode
    tags["disconnects"] = self.disconnects
    tags["readFromNetwork"] = self.readFromNetwork
    return tags
end

function DT:deserialize_settings(tags)
    self.color = tags["color"]
    self.type = tags["type"]
    self.enabler = tags["enabler"]
    self.filters = tags["filters"]
    self.mode = tags["mode"]
    self.disconnects = tags["disconnects"]
    self.readFromNetwork = tags["readFromNetwork"]
    self:set_icons(1, self.filters[self.type] ~= "" and self.filters[self.type] or nil, self.type)
    self:set_icons(2, self.enabler.filter.name ~= "" and self.enabler.filter.name or nil, self.enabler.filter.type)
    self:generateModeIcon()
end

function DT:resetConnection()
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

function DT:getCheckArea()
    local x = self.thisEntity.position.x
    local y = self.thisEntity.position.y
    return {
        [1] = {direction = 1, startP = {x-0.5, y-1.5}, endP = {x+0.5, y-0.5}}, --North
        [2] = {direction = 2, startP = {x+0.5, y-0.5}, endP = {x+1.5, y+0.5}}, --East
        [4] = {direction = 4, startP = {x-0.5, y+0.5}, endP = {x+0.5, y+1.5}}, --South
        [3] = {direction = 3, startP = {x-1.5, y-0.5}, endP = {x-0.5, y+0.5}}, --West
    }
end

function DT:is_disconnection_direction(dir)
    local d = 0
    if dir == 1 then
        d = 4
    elseif dir == 2 then
        d = 3
    elseif dir == 4 then
        d = 1
    elseif dir == 3 then
        d = 2
    end
    return self.disconnects[d]
end

function DT:createArms()
    BaseNet.generateArms(self)
    --[[local areas = self:getCheckArea()
    local selfP = self.thisEntity.position
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
        --[[local nearest = nil
        for _, ent in pairs(ents) do
            if ent ~= nil and ent.valid == true then
                if (nearest == nil or Util.distance(selfP, ent.position) < Util.distance(selfP, nearest.position)) and string.match(ent.name, "RNS_") ~= nil and (ent.operable or ent.minable or ent.destructible) then
                    nearest = ent
                end
            end
        end
        if nearest ~= nil and global.entityTable[nearest.unit_number] ~= nil then
            local obj = global.entityTable[nearest.unit_number]
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
            if self.cardinals[area.direction] == false then
                self.cardinals[area.direction] = true
                if valid(self.networkController) == true and self.networkController.thisEntity ~= nil and self.networkController.thisEntity.valid == true then
                    self.networkController.network.shouldRefresh = true
                elseif obj.thisEntity.name == Constants.NetworkController.main.name then
                    obj.network.shouldRefresh = true
                end
            end
        elseif nearest == nil then
            if self.cardinals[area.direction] == true then
                self.cardinals[area.direction] = false
                if valid(self.networkController) == true and self.networkController.thisEntity ~= nil and self.networkController.thisEntity.valid == true then
                    self.networkController.network.shouldRefresh = true
                end
            end
        end--
    end]]
end

function DT:getTooltips(guiTable, mainFrame, justCreated)
    if justCreated == true then
		guiTable.vars.Gui_Title.caption = {"gui-description.RNS_Detector_Title"}

        local colorFrame = GuiApi.add_frame(guiTable, "ColorFrame", mainFrame, "vertical", true)
		colorFrame.style = Constants.Settings.RNS_Gui.frame_1
		colorFrame.style.vertically_stretchable = true
		colorFrame.style.left_padding = 3
		colorFrame.style.right_padding = 3
		colorFrame.style.right_margin = 3
		colorFrame.style.width = 150

        GuiApi.add_subtitle(guiTable, "", colorFrame, {"gui-description.RNS_Connection_Color"})
        local colorDD = GuiApi.add_dropdown(guiTable, "RNS_Detector_Color", colorFrame, Constants.Settings.RNS_ColorG, Constants.Settings.RNS_Colors[self.color], false, {"gui-description.RNS_Connection_Color_tooltip"}, {ID=self.thisEntity.unit_number})
        colorDD.style.minimal_width = 100

        --Add the RNS_Detector
        local conditionFrame = GuiApi.add_frame(guiTable, "ConditionFrame", mainFrame, "vertical", true)
		conditionFrame.style = Constants.Settings.RNS_Gui.frame_1
		conditionFrame.style.vertically_stretchable = true
		conditionFrame.style.left_padding = 3
		conditionFrame.style.right_padding = 3
		conditionFrame.style.right_margin = 3
		conditionFrame.style.minimal_width = 300

        if self.mode == "enable/disable" then
            GuiApi.add_subtitle(guiTable, "", conditionFrame, {"gui-description.RNS_EnableDisable_Condition"})

            GuiApi.add_label(guiTable, "", conditionFrame, {"gui-description.RNS_EnableDisable_Condition"}, Constants.Settings.RNS_Gui.white)
            local cFlow = GuiApi.add_flow(guiTable, "", conditionFrame, "horizontal")
            cFlow.style.vertical_align = "center"
            local filter = GuiApi.add_filter(guiTable, "RNS_Detector_Filter", cFlow, "", true, self.type, 40, {ID=self.thisEntity.unit_number})
            guiTable.vars.filters = {}
            guiTable.vars.filters[self.type] = filter
            if self.filters[self.type] ~= "" then
                filter.elem_value = self.filters[self.type]
            end
            local opDD = GuiApi.add_dropdown(guiTable, "RNS_Detector_Operator", cFlow, Constants.Settings.RNS_OperatorN, Constants.Settings.RNS_Operators[self.enabler.operator], false, "", {ID=self.thisEntity.unit_number})
            opDD.style.minimal_width = 50
            
            local number = GuiApi.add_text_field(guiTable, "RNS_Detector_Number", cFlow, tostring(self.enabler.number), "", false, true, false, false, nil, {ID=self.thisEntity.unit_number})
            number.style.minimal_width = 100

            GuiApi.add_line(guiTable, "", conditionFrame, "horizontal")
            GuiApi.add_label(guiTable, "", conditionFrame, {"gui-description.RNS_Output"}, Constants.Settings.RNS_Gui.white)
            local oFlow = GuiApi.add_flow(guiTable, "", conditionFrame, "horizontal")
            oFlow.style.vertical_align = "center"
            local output = GuiApi.add_filter(guiTable, "RNS_Detector_Output", oFlow, "", true, "signal", 40, {ID=self.thisEntity.unit_number})

            guiTable.vars.output = output
            if self.enabler.filter ~= "" then
                output.elem_value = self.enabler.filter
            end
            GuiApi.add_label(guiTable, "", oFlow, "   ")
            local state = "left"
		    if self.enabler.numberOutput == 2 then state = "right" end
		    GuiApi.add_switch(guiTable, "RNS_Detector_Switch", oFlow, {"gui-description.RNS_Output1"}, {"gui-description.RNS_OutputN"}, {"gui-description.RNS_Output1_tooltip"}, {"gui-description.RNS_OutputN_tooltip"}, state, false, {ID=self.thisEntity.unit_number})
        elseif self.mode == "connect/disconnect" then
            GuiApi.add_subtitle(guiTable, "", conditionFrame, {"gui-description.RNS_ConnectDisconnect_Condition"})

            GuiApi.add_label(guiTable, "", conditionFrame, {"gui-description.RNS_ConnectDisconnect_Condition"}, Constants.Settings.RNS_Gui.white)
            local cFlow = GuiApi.add_flow(guiTable, "", conditionFrame, "horizontal")
            cFlow.style.vertical_align = "center"
            local filter = GuiApi.add_filter(guiTable, "RNS_Detector_Filter_1", cFlow, "", true, "signal", 40, {ID=self.thisEntity.unit_number})
            guiTable.vars.filters = {}
            guiTable.vars.filters["virtual"] = filter
            if self.filters["virtual"] ~= "" then
                filter.elem_value = self.filters["virtual"]
            end
            local opDD = GuiApi.add_dropdown(guiTable, "RNS_Detector_Operator", cFlow, Constants.Settings.RNS_OperatorN, Constants.Settings.RNS_Operators[self.enabler.operator], false, "", {ID=self.thisEntity.unit_number})
            opDD.style.minimal_width = 50
            local number = GuiApi.add_text_field(guiTable, "RNS_Detector_Number", cFlow, tostring(self.enabler.number), "", false, true, false, false, nil, {ID=self.thisEntity.unit_number})
            number.style.minimal_width = 100

            GuiApi.add_line(guiTable, "", conditionFrame, "horizontal")
            local pos = GuiApi.add_table(guiTable, "", conditionFrame, 3)

            GuiApi.add_checkbox(guiTable, "RNS_Detector_Checkbox_Blank_1", pos, nil, nil, false, false, {ID=self.entID}).style = Constants.Settings.RNS_Gui.checkbox_blank
            GuiApi.add_checkbox(guiTable, "RNS_Detector_Checkbox_North_2", pos, nil, nil, self.disconnects[1], false, {ID=self.entID}).style = Constants.Settings.RNS_Gui.checkbox
            GuiApi.add_checkbox(guiTable, "RNS_Detector_Checkbox_Blank_3", pos, nil, nil, false, false, {ID=self.entID}).style = Constants.Settings.RNS_Gui.checkbox_blank

            GuiApi.add_checkbox(guiTable, "RNS_Detector_Checkbox_West_4", pos, nil, nil, self.disconnects[3], false, {ID=self.entID}).style = Constants.Settings.RNS_Gui.checkbox
            GuiApi.add_checkbox(guiTable, "RNS_Detector_Checkbox_Middle_5", pos, nil, nil, false, false, {ID=self.entID}).style = Constants.Settings.RNS_Gui.checkbox_middle
            GuiApi.add_checkbox(guiTable, "RNS_Detector_Checkbox_East_6", pos, nil, nil, self.disconnects[2], false, {ID=self.entID}).style = Constants.Settings.RNS_Gui.checkbox
            
            GuiApi.add_checkbox(guiTable, "RNS_Detector_Checkbox_Blank_7", pos, nil, nil, false, false, {ID=self.entID}).style = Constants.Settings.RNS_Gui.checkbox_blank
            GuiApi.add_checkbox(guiTable, "RNS_Detector_Checkbox_South_8", pos, nil, nil, self.disconnects[4], false, {ID=self.entID}).style = Constants.Settings.RNS_Gui.checkbox
            GuiApi.add_checkbox(guiTable, "RNS_Detector_Checkbox_Blank_9", pos, nil, nil, false, false, {ID=self.entID}).style = Constants.Settings.RNS_Gui.checkbox_blank
        end

        --Add Item/Fluid Type
        local typeFrame = GuiApi.add_frame(guiTable, "TypeFrame", mainFrame, "vertical", true)
		typeFrame.style = Constants.Settings.RNS_Gui.frame_1
		typeFrame.style.vertically_stretchable = true
		typeFrame.style.left_padding = 3
		typeFrame.style.right_padding = 3
		typeFrame.style.right_margin = 3
		typeFrame.style.minimal_width = 200

		GuiApi.add_subtitle(guiTable, "", typeFrame, {"gui-description.RNS_Setting"})
        local typeFlow = GuiApi.add_flow(guiTable, "", typeFrame, "horizontal", false)

        --Fluid or Item Mode
        if self.mode == "enable/disable" then
            GuiApi.add_label(guiTable, "", typeFlow, {"gui-description.RNS_Type"}, Constants.Settings.RNS_Gui.white)
            local typeDD = GuiApi.add_dropdown(guiTable, "RNS_Detector_Type", typeFlow, {{"gui-description.RNS_Item"}, {"gui-description.RNS_Fluid"}}, Constants.Settings.RNS_Types[self.type], false, "", {ID=self.thisEntity.unit_number})
            typeDD.style.minimal_width = 100
        end

        local modeFlow = GuiApi.add_flow(guiTable, "", typeFrame, "vertical", false)
        GuiApi.add_radiobutton(guiTable, "RNS_Detector_EnableDisable", modeFlow, {"gui-description.RNS_EnableDisable"}, {"gui-description.RNS_EnableDisable_tooltip"}, self.mode == "enable/disable" and true or false, false, {ID=self.thisEntity.unit_number})
        GuiApi.add_radiobutton(guiTable, "RNS_Detector_ConnectDisconnect", modeFlow, {"gui-description.RNS_ConnectDisconnect"}, {"gui-description.RNS_ConnectDisconnect_tooltip"}, self.mode == "connect/disconnect" and true or false, false, {ID=self.thisEntity.unit_number})
        
        if self.mode == "connect/disconnect" then
            GuiApi.add_checkbox(guiTable, "RNS_Detector_ReadFromNetwork", modeFlow, {"gui-description.RNS_ReadFromNetwork"}, {"gui-description.RNS_ReadFromNetwork_tooltip"}, self.readFromNetwork, false, {ID=self.entID})
        end
    end
end

function DT.interaction(event, RNSPlayer)
    if string.match(event.element.name, "RNS_Detector_ReadFromNetwork") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        io.readFromNetwork = event.element.state
        return
    elseif string.match(event.element.name, "RNS_Detector_EnableDisable") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        if io.networkController ~= nil then
            io.networkController.network:transfer_io_mode(io, "detector", io.mode, "enable/disable")
        end
        io.mode = "enable/disable"
        for i, _ in pairs (io.icons) do
            if io.icons[i] ~= nil then rendering.destroy(io.icons[i]) end
            io.icons[i] = nil
        end
        RNSPlayer:push_varTable(id, true)
        return
    elseif string.match(event.element.name, "RNS_Detector_ConnectDisconnect") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        if io.networkController ~= nil then
            io.networkController.network:transfer_io_mode(io, "detector", io.mode, "connect/disconnect")
        end
        io.mode = "connect/disconnect"
        for i, _ in pairs (io.icons) do
            if io.icons[i] ~= nil then rendering.destroy(io.icons[i]) end
            io.icons[i] = nil
        end
        RNSPlayer:push_varTable(id, true)
        return
    elseif string.match(event.element.name, "RNS_Detector_Checkbox") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        if string.match(event.element.name, "North") ~= nil then
            io.disconnects[1] = event.element.state
        elseif string.match(event.element.name, "East") ~= nil then
            io.disconnects[2] = event.element.state
        elseif string.match(event.element.name, "South") ~= nil then
            io.disconnects[4] = event.element.state
        elseif string.match(event.element.name, "West") ~= nil then
            io.disconnects[3] = event.element.state
        end
        io:generateModeIcon()
        io:createArms()
        return
    elseif string.match(event.element.name, "RNS_Detector_Number") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local num = math.min(2^32, tonumber(event.element.text ~= "" and event.element.text or "0"))
        io.enabler.number = num
        event.element.text = tostring(num)
        return
    elseif string.match(event.element.name, "RNS_Detector_Filter_1") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        if event.element.elem_value ~= nil then
            io.filters["virtual"] = event.element.elem_value
            io.combinator.get_or_create_control_behavior().set_signal(1, {signal=event.element.elem_value, count=1})
        else
            io.filters["virtual"] = ""
            io.combinator.get_or_create_control_behavior().set_signal(1, nil)
        end
		return
    elseif string.match(event.element.name, "RNS_Detector_Filter") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        if event.element.elem_value ~= nil then
            io.filters[io.type] = event.element.elem_value
            io.combinator.get_or_create_control_behavior().set_signal(1, {signal={type=io.type, name=event.element.elem_value}, count=1})
        else
            io.filters[io.type] = ""
            io.combinator.get_or_create_control_behavior().set_signal(1, nil)
        end
		return
    elseif string.match(event.element.name, "RNS_Detector_Output") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        if event.element.elem_value ~= nil then
            io.enabler.filter = {type=event.element.elem_value.type, name=event.element.elem_value.name}
            io.combinator.get_or_create_control_behavior().set_signal(2, {signal={type=event.element.elem_value.type, name=event.element.elem_value.name}, count=1})
        else
            io.enabler.filter = ""
            io.combinator.get_or_create_control_behavior().set_signal(2, nil)
        end
		return
    elseif string.match(event.element.name, "RNS_Detector_Switch") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        io.enabler.numberOutput = event.element.switch_state == "left" and 1 or 2
		return
    elseif string.match(event.element.name, "RNS_Detector_Color") then
		local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local color = Constants.Settings.RNS_ColorN[event.element.selected_index]
        if color ~= io.color then
            io.color = color
            rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[io.color].sprites[5].name, target=io.thisEntity, surface=io.thisEntity.surface, render_layer="lower-object-above-shadow"}
            io:createArms()
            BaseNet.postArms(io)
            BaseNet.update_network_controller(io.networkController)
        end
		return
	elseif string.match(event.element.name, "RNS_Detector_Type") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local type = Constants.Settings.RNS_TypeN[event.element.selected_index]
        if type ~= io.type then
            io.type = type
            RNSPlayer:push_varTable(id, true)
            local filter = io.filters[io.type]
            io.combinator.get_or_create_control_behavior().set_signal(1, filter ~= "" and {signal={type=io.type, name=filter}, count=1} or nil)
            io.combinator.get_or_create_control_behavior().set_signal(2,  nil)
            io.enablerCombinator.get_or_create_control_behavior().set_signal(1, nil)
        end
		return
    elseif string.match(event.element.name, "RNS_Detector_Operator") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local operator = Constants.Settings.RNS_OperatorN[event.element.selected_index]
        if operator ~= io.enabler.operator then
            io.enabler.operator = operator
        end
		return
    end
end