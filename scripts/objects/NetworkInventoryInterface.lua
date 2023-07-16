NII = {
    thisEntity = nil,
    entID = nil,
    networkController = nil,
    connectedObjs = nil,
    cardinals = nil,
    updateTick = 60,
    lastUpdate = 0,
}

function NII:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = NII
    t.thisEntity = object
    t.entID = object.unit_number
    t.cardinals = {
        [1] = false, --N
        [2] = false, --E
        [3] = false, --S
        [4] = false, --W
    }
    t.connectedObjs = {
        [1] = {}, --N
        [2] = {}, --E
        [3] = {}, --S
        [4] = {}, --W
    }
    t:collect()
    UpdateSys.addEntity(t)
    return t
end

function NII:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = NII
    setmetatable(object, mt)
end

function NII:remove()
    UpdateSys.remove(self)
    if self.networkController ~= nil then
        self.networkController.network.NetworkInventoryInterfaceTable[self.entID] = nil
        self.networkController.network.shouldRefresh = true
    end
end

function NII:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function NII:update()
    self.lastUpdate = game.tick
    if valid(self) == false then
        self:remove()
        return
    end
    if valid(self.networkController) == false then
        self.networkController = nil
    end
    if self.thisEntity.to_be_deconstructed() == true then return end
    self:collect()
end

function NII:resetCollection()
    self.connectedObjs = {
        [1] = {}, --N
        [2] = {}, --E
        [3] = {}, --S
        [4] = {}, --W
    }
end

function NII:getCheckArea()
    local x = self.thisEntity.position.x
    local y = self.thisEntity.position.y
    return {
        [1] = {direction = 1, startP = {x-0.5, y-1.5}, endP = {x+0.5, y-0.5}}, --North
        [2] = {direction = 2, startP = {x+0.5, y-0.5}, endP = {x+1.5, y+0.5}}, --East
        [4] = {direction = 4, startP = {x-0.5, y+0.5}, endP = {x+0.5, y+1.5}}, --South
        [3] = {direction = 3, startP = {x-1.5, y-0.5}, endP = {x-0.5, y+0.5}}, --West
    }
end

function NII:collect()
    local areas = self:getCheckArea()
    self:resetCollection()
    for _, area in pairs(areas) do
        local enti = 0
        local ents = self.thisEntity.surface.find_entities_filtered{area={area.startP, area.endP}}
        for _, ent in pairs(ents) do
            if ent ~= nil and ent.valid == true and string.match(ent.name, "RNS_") ~= nil and global.entityTable[ent.unit_number] ~= nil and ent.operable then
                local obj = global.entityTable[ent.unit_number]
                if string.match(obj.thisEntity.name, "RNS_NetworkCableIO") ~= nil and obj:getConnectionDirection() == area.direction then
                    --Do nothing
                else
                    table.insert(self.connectedObjs[area.direction], obj)
                    enti = enti + 1

                    if self.cardinals[area.direction] == false then
                        self.cardinals[area.direction] = true
                        if valid(self.networkController) == true and self.networkController.thisEntity ~= nil and self.networkController.thisEntity.valid == true then
                            self.networkController.network.shouldRefresh = true
                        elseif obj.thisEntity.name == Constants.NetworkController.slateEntity.name then
                            obj.network.shouldRefresh = true
                        end
                    end
                end
            end
        end
        if self.cardinals[area.direction] == true and enti == 0 then
            self.cardinals[area.direction] = false
            if valid(self.networkController) == true and self.networkController.thisEntity ~= nil and self.networkController.thisEntity.valid == true then
                self.networkController.network.shouldRefresh = true
            end
        end
    end
end

function NII:getTooltips(guiTable, mainFrame, justCreated)
    local RNSPlayer = guiTable.RNSPlayer

    if justCreated == true then
        -- Set the GUI Title --
		guiTable.vars.Gui_Title.caption = {"gui-description.RNS_NetworkInventoryInterface_Title"}

		-- Set the Main Frame Height --
		mainFrame.style.height = 450

		-- Create the Network Inventory Frame --
		local inventoryFrame = GuiApi.add_frame(guiTable, "InventoryFrame", mainFrame, "vertical", true)
		inventoryFrame.style = Constants.Settings.RNS_Gui.frame_1
		inventoryFrame.style.vertically_stretchable = true
		inventoryFrame.style.left_padding = 3
		inventoryFrame.style.right_padding = 3
		inventoryFrame.style.left_margin = 3
		inventoryFrame.style.right_margin = 3

		-- Add the Title --
		GuiApi.add_subtitle(guiTable, "", inventoryFrame, {"gui-description.NetworkInventory"})

		-- Create the Network Inventory Scroll Pane --
		local inventoryScrollPane = GuiApi.add_scroll_pane(guiTable, "InventoryScrollPane", inventoryFrame, 500, true)
		inventoryScrollPane.style = Constants.Settings.RNS_Gui.scroll_pane
		inventoryScrollPane.style.minimal_width = 308
		inventoryScrollPane.style.vertically_stretchable = true
		inventoryScrollPane.style.bottom_margin = 3

		-- Create the Player Inventory Frame --
		local playerInventoryFrame = GuiApi.add_frame(guiTable, "PlayerInventoryFrame", mainFrame, "vertical", true)
		playerInventoryFrame.style = Constants.Settings.RNS_Gui.frame_1
		playerInventoryFrame.style.vertically_stretchable = true
		playerInventoryFrame.style.left_padding = 3
		playerInventoryFrame.style.right_padding = 3
		playerInventoryFrame.style.right_margin = 3

		-- Add the Title --
		GuiApi.add_subtitle(guiTable, "", playerInventoryFrame, {"gui-description.PlayerInventory"})

		-- Create the Player Inventory Scroll Pane --
		local playerInventoryScrollPane = GuiApi.add_scroll_pane(guiTable, "PlayerInventoryScrollPane", playerInventoryFrame, 500, true)
		playerInventoryScrollPane.style = Constants.Settings.RNS_Gui.scroll_pane
		playerInventoryScrollPane.style.minimal_width = 308
		playerInventoryScrollPane.style.vertically_stretchable = true
		playerInventoryScrollPane.style.bottom_margin = 3

		-- Create the Information Frame --
		local informationFrame = GuiApi.add_frame(guiTable, "InformationFrame", mainFrame, "vertical", true)
		informationFrame.style = Constants.Settings.RNS_Gui.frame_1
		informationFrame.style.vertically_stretchable = true
		informationFrame.style.left_padding = 3
		informationFrame.style.right_padding = 3
		informationFrame.style.right_margin = 3
		informationFrame.style.minimal_width = 200

		-- Add the Title --
		GuiApi.add_subtitle(guiTable, "", informationFrame, {"gui-description.RNS_Information"})

		-- Create the Search Flow --
		local searchFlow = GuiApi.add_flow(guiTable, "", informationFrame, "horizontal")
		searchFlow.style.vertical_align = "center"
		
		-- Create the Search Label --
		GuiApi.add_label(guiTable, "Label", searchFlow, {"", {"gui-description.RNS_SearchText"}, ": "}, nil, {"gui-description.RNS_SearchText"}, false, nil, Constants.Settings.RNS_Gui.yellow_title)
		
		-- Create the Search TextField
		local textField = GuiApi.add_text_field(guiTable, "RNS_SearchTextField", searchFlow, "", "", true, false, false, false, false)
		textField.style.maximal_width = 130

		-- Add the Line --
		GuiApi.add_line(guiTable, "", informationFrame, "horizontal")

		-- Create the Inventory Labels --
		--GuiApi.add_label(guiTable, "RNSCapacityLabel", informationFrame, {"gui-description.Unknown"}, Constants.Settings.RNS_Gui.orange, "", true)

		-- Add the Line --
		--GuiApi.add_line(guiTable, "", informationFrame, "horizontal")

		-- Create the Help Table --
		local helpTable = GuiApi.add_table(guiTable, "", informationFrame, 1)

		-- Create the Information Labels --
		GuiApi.add_label(guiTable, "", helpTable, {"gui-description.RNS_HelpText1"}, Constants.Settings.RNS_Gui.white)
		GuiApi.add_label(guiTable, "", helpTable, {"gui-description.RNS_HelpText2"}, Constants.Settings.RNS_Gui.white)
		GuiApi.add_label(guiTable, "", helpTable, {"gui-description.RNS_HelpText3"}, Constants.Settings.RNS_Gui.white)
		GuiApi.add_label(guiTable, "", helpTable, {"gui-description.RNS_HelpText4"}, Constants.Settings.RNS_Gui.white)
		GuiApi.add_label(guiTable, "", helpTable, {"gui-description.RNS_HelpText5"}, Constants.Settings.RNS_Gui.white)
		GuiApi.add_label(guiTable, "", helpTable, {"gui-description.RNS_HelpText6"}, Constants.Settings.RNS_Gui.white)
    end

    -- Get the Scroll Pane and the Text Field --
	local inventoryScrollPane = guiTable.vars.InventoryScrollPane
	local playerInventoryScrollPane = guiTable.vars.PlayerInventoryScrollPane
	local textField = guiTable.vars.RNS_SearchTextField

	-- Clear the Scroll Panes --
	inventoryScrollPane.clear()
	playerInventoryScrollPane.clear()

    if self.networkController == nil and not self.networkController.stable then return end

	-- Create the Data Network Inventory --
	self:createNetworkInventory(guiTable, inventoryScrollPane, textField.text)

	-- Create the Player Inventory --
	self:createPlayerInventory(guiTable, RNSPlayer, playerInventoryScrollPane, textField.text)

	-- Update the Network Capacity Label --
	--local inv = self.dataNetwork.invObj
	--guiTable.vars.DNCapacityLabel.caption = {"" , {"gui-description.NENetworkCapacity"}, " [color=yellow]", Util.toRNumber(inv.usedCapacity), "/", Util.toRNumber(inv.maxCapacity), "[/color]"}
	--guiTable.vars.DNCapacityLabel.tooltip = "[color=yellow]" .. inv.usedCapacity .. "/" .. inv.maxCapacity .. "[/color]"

end