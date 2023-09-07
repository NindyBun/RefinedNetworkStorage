WG = {
    thisEntity = nil,
    entID = nil,
    target_position = nil,
    is_item = true,
    is_active = false
}

function WG:new(item)
    if item == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = WG
    t.thisEntity = item
    t.entID = item.item_number
    t.target_position = {
        x = nil,
        y = nil
    }
    UpdateSys.addItem(t)
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
    UpdateSys.removeItem(self)
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
    if self.thisEntity.valid_for_read == false then return end
    if self.target_position.x ~= nil and self.target_position.y ~= nil then
        self.thisEntity.label = "{" .. tostring(self.target_position.x) .. ", " .. tostring(self.target_position.y) .. "}"
    else
        self.thisEntity.label = ""
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

        local flow = GuiApi.add_flow(guiTable, "", infoFrame, "horizontal")
        flow.style.horizontal_align = "center"

        GuiApi.add_label(guiTable, "", flow, {"gui-description.RNS_xPos"}, Constants.Settings.RNS_Gui.white)
        local xPos = GuiApi.add_text_field(guiTable, "RNS_WirelessGrid_xPos", flow, self.target_position.x == nil and "" or tostring(self.target_position.x), {"gui-description.RNS_xPos_tooltip"}, true, true, true, true, false, {ID=self.thisEntity.item_number})
        xPos.style.maximal_width = 50

        GuiApi.add_label(guiTable, "", flow, "    ")

        GuiApi.add_label(guiTable, "", flow, {"gui-description.RNS_yPos"}, Constants.Settings.RNS_Gui.white)
        local yPos = GuiApi.add_text_field(guiTable, "RNS_WirelessGrid_yPos", flow, self.target_position.y == nil and "" or tostring(self.target_position.y), {"gui-description.RNS_yPos_tooltip"}, true, true, true, true, false, {ID=self.thisEntity.item_number})
        yPos.style.maximal_width = 50
    end
end

function WG.interaction(event, RNSPlayer)
    if string.match(event.element.name, "xPos") then
		local obj = global.itemTable[event.element.tags.ID]
		if obj == nil then return end
        if event.element.text ~= nil then
            obj.target_position.x = tonumber(event.element.text)
        else
            obj.target_position.x = nil
        end
		return
	end
    if string.match(event.element.name, "yPos") then
		local obj = global.itemTable[event.element.tags.ID]
		if obj == nil then return end
        if event.element.text ~= nil then
            obj.target_position.y = tonumber(event.element.text)
        else
            obj.target_position.y = nil
        end
		return
	end
end