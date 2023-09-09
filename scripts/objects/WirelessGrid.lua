WG = {
    thisEntity = nil,
    entID = nil,
    network_controller_position = nil
}

function WG:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = WG
    t.thisEntity = object
    t.entID = object.unit_number
    t.network_controller_position = {
        x = nil,
        y = nil
    }
    UpdateSys.addEntity(t)
    return t
end

function WG:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = WG
    setmetatable(object, mt)
end

--Deconstructor
function WG:remove()
    UpdateSys.remove(self)
end
--Is valid
function WG:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function WG:update()
    if valid(self) == false then
        self:remove()
        return
    end
end

function WG:getTooltips(guiTable, mainFrame, justCreated)
    if justCreated == true then
        guiTable.vars.Gui_Title.caption = {"gui-description.RNS_WirelessGrid_Title"}

        local infoFrame = GuiApi.add_frame(guiTable, "InformationFrame", mainFrame, "vertical", true)
		infoFrame.style = Constants.Settings.RNS_Gui.frame_1
		infoFrame.style.vertically_stretchable = true
		infoFrame.style.minimal_width = 200
		infoFrame.style.left_margin = 3
		infoFrame.style.left_padding = 3
		infoFrame.style.right_padding = 3
		GuiApi.add_subtitle(guiTable, "", infoFrame, {"gui-description.RNS_Information"})

        GuiApi.add_label(guiTable, "", infoFrame, {"gui-description.RNS_WirelessGrid_Target"}, Constants.Settings.RNS_Gui.white)

        local xflow = GuiApi.add_flow(guiTable, "", infoFrame, "horizontal")
        --xflow.style.horizontal_align = "center"

        GuiApi.add_label(guiTable, "", xflow, {"gui-description.RNS_xPos"}, Constants.Settings.RNS_Gui.white)
        local xPos = GuiApi.add_text_field(guiTable, "RNS_WirelessGrid_xPos", xflow, self.network_controller_position.x == nil and "" or tostring(self.network_controller_position.x), {"gui-description.RNS_xPos_tooltip"}, true, true, true, true, false, {ID=self.entID})
        xPos.style.maximal_width = 50

        --GuiApi.add_label(guiTable, "", flow, "    ")
        local yflow = GuiApi.add_flow(guiTable, "", infoFrame, "horizontal")
        GuiApi.add_label(guiTable, "", yflow, {"gui-description.RNS_yPos"}, Constants.Settings.RNS_Gui.white)
        local yPos = GuiApi.add_text_field(guiTable, "RNS_WirelessGrid_yPos", yflow, self.network_controller_position.y == nil and "" or tostring(self.network_controller_position.y), {"gui-description.RNS_yPos_tooltip"}, true, true, true, true, false, {ID=self.entID})
        yPos.style.maximal_width = 50
    end
end

function WG.interaction(event, RNSPlayer)
    if string.match(event.element.name, "xPos") then
		local obj = global.entityTable[event.element.tags.ID]
		if obj == nil then return end
        if event.element.text ~= "" then
            obj.network_controller_position.x = tonumber(event.element.text)
        else
            obj.network_controller_position.x = nil
        end
		return
	end
    if string.match(event.element.name, "yPos") then
		local obj = global.entityTable[event.element.tags.ID]
		if obj == nil then return end
        if event.element.text ~= "" then
            obj.network_controller_position.y = tonumber(event.element.text)
        else
            obj.network_controller_position.y = nil
        end
		return
	end
end