DT = {
    thisEntity = nil,
    entID = nil,
    arms = nil,
    color = "RED",
    connectedObjs = nil,
    networkController = nil,
    type = "item",
    filters = nil,
    operator = "<",
    number = 0,
    cardinals = nil,
    combinator = nil,
    combinator1 = nil
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
    t.filters = {
        item = "",
        fluid = ""
    }
    t.combinator = object.surface.create_entity{
        name="rns-combinator",
        position=object.position,
        force="neutral"
    }
    t.combinator.destructible = false
    t.combinator.operable = false
    t.combinator.minable = false
    t.combinator1 = object.surface.create_entity{
        name="RNS_Combinator_1",
        position=object.position,
        force="neutral"
    }
    t.combinator1.destructible = false
    t.combinator1.operable = false
    t.combinator1.minable = false
    t:createArms()
    UpdateSys.addEntity(t)
    return t
end

function DT:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = DT
    setmetatable(object, mt)
end

function DT:remove()
    if self.combinator ~= nil then self.combinator.destroy() end
    if self.combinator1 ~= nil then self.combinator1.destroy() end
    UpdateSys.remove(self)
    if self.networkController ~= nil then
        self.networkController.network.DetectorTable[1][self.entID] = nil
        self.networkController.network.shouldRefresh = true
    end
end

function DT:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function DT:update()
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
        self:createArms()
    --end
end

local operatorFunctions = {
    [">"] = function (filter, number)
        return (filter > number and {true} or {false})[1]
    end,
    ["<"] = function (filter, number)
        return (filter < number and {true} or {false})[1]
    end,
    ["="] = function (filter, number)
        return (filter == number and {true} or {false})[1]
    end,
    [">="] = function (filter, number)
        return (filter >= number and {true} or {false})[1]
    end,
    ["<="] = function (filter, number)
        return (filter <= number and {true} or {false})[1]
    end,
    ["!="] = function (filter, number)
        return (filter ~= number and {true} or {false})[1]
    end
}

function DT:update_signal()
    if self.filters[self.type] == "" then return end
    if self.networkController ~= nil and self.networkController.thisEntity ~= nil and self.networkController.thisEntity.valid == true and self.networkController.thisEntity.to_be_deconstructed() == false then
        local amount = self.networkController.network.Contents[self.type][self.filters[self.type]] or 0
        self.combinator.get_or_create_control_behavior().set_signal(2,  (operatorFunctions[self.operator](amount, self.number) and {{signal={type="virtual", name="signal-red"}, count=1}} or {nil})[1])
        self.combinator1.get_or_create_control_behavior().set_signal(1, (operatorFunctions[self.operator](amount, self.number) and {{signal={type="virtual", name="signal-red"}, count=1}} or {nil})[1])
    else
        self.combinator.get_or_create_control_behavior().set_signal(2,  nil)
        self.combinator1.get_or_create_control_behavior().set_signal(1, nil)
    end
end

function DT:copy_settings(obj)
    self.color = obj.color
end

function DT:serialize_settings()
    local tags = {}
    tags["color"] = self.color
    return tags
end

function DT:deserialize_settings(tags)
    self.color = tags["color"]
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

function DT:createArms()
    local areas = self:getCheckArea()
    local selfP = self.thisEntity.position
    self:resetConnection()
    for _, area in pairs(areas) do
        local ents = self.thisEntity.surface.find_entities_filtered{area={area.startP, area.endP}}
        local nearest = nil
        for _, ent in pairs(ents) do
            if ent ~= nil and ent.valid == true then
                if (nearest == nil or Util.distance(selfP, ent.position) < Util.distance(selfP, nearest.position)) and string.match(ent.name, "RNS_") ~= nil and ent.operable then
                    nearest = ent
                end
            end
        end
        if nearest ~= nil and global.entityTable[nearest.unit_number] ~= nil then
            local obj = global.entityTable[nearest.unit_number]
            if (string.match(obj.thisEntity.name, "RNS_NetworkCableIO") ~= nil and obj:getConnectionDirection() == area.direction) or obj.thisEntity.name == Constants.WirelessGrid.name then
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
                elseif obj.thisEntity.name == Constants.NetworkController.slateEntity.name then
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
        end
    end
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
		GuiApi.add_subtitle(guiTable, "", conditionFrame, {"gui-description.RNS_Condition"})

        GuiApi.add_label(guiTable, "", conditionFrame, {"gui-description.RNS_Condition"}, Constants.Settings.RNS_Gui.white)
        local cFlow = GuiApi.add_flow(guiTable, "", conditionFrame, "horizontal")
        cFlow.style.vertical_align = "center"
        local filter = GuiApi.add_filter(guiTable, "RNS_Detector_Filter", cFlow, "", true, self.type, 40, {ID=self.thisEntity.unit_number})
        guiTable.vars.filters = {}
        guiTable.vars.filters[self.type] = filter
        if self.filters[self.type] ~= "" then
            filter.elem_value = self.filters[self.type]
        end
        local opDD = GuiApi.add_dropdown(guiTable, "RNS_Detector_Operator", cFlow, Constants.Settings.RNS_OperatorN, Constants.Settings.RNS_Operators[self.operator], false, "", {ID=self.thisEntity.unit_number})
        opDD.style.minimal_width = 50
        --local number = GuiApi.add_filter(guiTable, "RNS_Detector_Number", cFlow, "", true, "signal", 40, {ID=self.thisEntity.unit_number})
        --number.elem_value = {type="virtual", name="constant-number"}
        local number = GuiApi.add_text_field(guiTable, "RNS_Detector_Number", cFlow, tostring(self.number), "", false, true, false, false, nil, {ID=self.thisEntity.unit_number})
        number.style.minimal_width = 100

        GuiApi.add_line(guiTable, "", conditionFrame, "horizontal")
        GuiApi.add_label(guiTable, "", conditionFrame, {"gui-description.RNS_Output"}, Constants.Settings.RNS_Gui.white)
        local oFlow = GuiApi.add_flow(guiTable, "", conditionFrame, "horizontal")
        local output = GuiApi.add_filter(guiTable, "", oFlow, "", false, "signal", 40, {ID=self.thisEntity.unit_number})
        output.elem_value = {type="virtual", name="signal-red"}
        output.enabled = false

        --Add Item/Fluid Type
        local typeFrame = GuiApi.add_frame(guiTable, "TypeFrame", mainFrame, "vertical", true)
		typeFrame.style = Constants.Settings.RNS_Gui.frame_1
		typeFrame.style.vertically_stretchable = true
		typeFrame.style.left_padding = 3
		typeFrame.style.right_padding = 3
		typeFrame.style.right_margin = 3
		typeFrame.style.minimal_width = 200

		GuiApi.add_subtitle(guiTable, "", typeFrame, {"gui-description.RNS_Setting"})

        --Fluid or Item Mode
        local typeFlow = GuiApi.add_flow(guiTable, "", typeFrame, "horizontal", false)
        GuiApi.add_label(guiTable, "", typeFlow, {"gui-description.RNS_Type"}, Constants.Settings.RNS_Gui.white)
        local typeDD = GuiApi.add_dropdown(guiTable, "RNS_Detector_Type", typeFlow, {{"gui-description.RNS_Item"}, {"gui-description.RNS_Fluid"}}, Constants.Settings.RNS_Types[self.type], false, "", {ID=self.thisEntity.unit_number})
        typeDD.style.minimal_width = 100
    end
end

function DT.interaction(event, RNSPlayer)
    if string.match(event.element.name, "RNS_Detector_Number") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local num = math.min(2^32, tonumber(event.element.text ~= "" and event.element.text or "0"))
        io.number = num
        event.element.text = tostring(num)
        return
    end
    if string.match(event.element.name, "RNS_Detector_Filter") then
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
    end
    if string.match(event.element.name, "RNS_Detector_Color") then
		local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local color = Constants.Settings.RNS_ColorN[event.element.selected_index]
        if color ~= io.color then
            io.color = color
            rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[io.color].sprites[5].name, target=io.thisEntity, surface=io.thisEntity.surface, render_layer="lower-object-above-shadow"}
        end
		return
	end
    if string.match(event.element.name, "RNS_Detector_Type") then
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
            io.combinator1.get_or_create_control_behavior().set_signal(1, nil)
        end
		return
    end
    if string.match(event.element.name, "RNS_Detector_Operator") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local operator = Constants.Settings.RNS_OperatorN[event.element.selected_index]
        if operator ~= io.operator then
            io.operator = operator
        end
		return
    end
end