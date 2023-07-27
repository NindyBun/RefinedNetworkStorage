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
		GuiApi.add_subtitle(guiTable, "", inventoryFrame, {"gui-description.RNS_NetworkInventory"})

		-- Create the Network Inventory Scroll Pane --
		local inventoryScrollPane = GuiApi.add_scroll_pane(guiTable, "InventoryScrollPane", inventoryFrame, 500, true)
		inventoryScrollPane.style = Constants.Settings.RNS_Gui.scroll_pane
		inventoryScrollPane.style.minimal_width = 304
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
		GuiApi.add_subtitle(guiTable, "", playerInventoryFrame, {"gui-description.RNS_PlayerInventory"})

		-- Create the Player Inventory Scroll Pane --
		local playerInventoryScrollPane = GuiApi.add_scroll_pane(guiTable, "PlayerInventoryScrollPane", playerInventoryFrame, 500, true)
		playerInventoryScrollPane.style = Constants.Settings.RNS_Gui.scroll_pane
		playerInventoryScrollPane.style.minimal_width = 304
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
		GuiApi.add_label(guiTable, "Label", searchFlow, {"", {"gui-description.RNS_SearchText"}, ": "}, nil, {"gui-description.RNS_SearchText"}, false)
		
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
		--GuiApi.add_label(guiTable, "", helpTable, {"gui-description.RNS_HelpText6"}, Constants.Settings.RNS_Gui.white)
    end

	local inventoryScrollPane = guiTable.vars.InventoryScrollPane
	local playerInventoryScrollPane = guiTable.vars.PlayerInventoryScrollPane
	local textField = guiTable.vars.RNS_SearchTextField

	inventoryScrollPane.clear()
	playerInventoryScrollPane.clear()

    if self.networkController == nil or not self.networkController.stable then return end

	--self:createNetworkInventory(guiTable, inventoryScrollPane, textField.text)

	self:createPlayerInventory(guiTable, RNSPlayer, playerInventoryScrollPane, textField.text)

end

function NII:createPlayerInventory(guiTable, RNSPlayer, scrollPane, text)
	local tableList = GuiApi.add_table(guiTable, "", scrollPane, 8)
	local inv = RNSPlayer:get_inventory()
	if Util.getTableLength(inv) == 0 then return end

	for i = 1, Util.getTableLength(inv) do
		local item = inv[i]
		if guiTable.vars.tmpLocal ~= nil and Util.get_item_name(item.cont.name)[1] ~= nil then
			local locName = guiTable.vars.tmpLocal[Util.get_item_name(item.cont.name)[1]]
			if text ~= nil and text ~= "" and locName ~= nil and string.match(string.lower(locName), string.lower(text)) == nil then goto continue end
		end

		local buttonText = {"", "[color=blue]", item.cont.label or Util.get_item_name(item.cont.name), "[/color]"}
		if item.cont.health < 1 then
			table.insert(buttonText, "\n")
			table.insert(buttonText, {"gui-description.RNS_health"})
			table.insert(buttonText, math.floor(item.cont.health*100) .. "%")
		end
		
		if item.cont.tags ~= nil and Util.getTableLength(item.cont.tags) ~= 0 then
			table.insert(buttonText, "\n")
			table.insert(buttonText, {"gui-description.RNS_tags"})
		elseif item.cont.data ~= nil then
			table.insert(buttonText, "\n")
			table.insert(buttonText, {"gui-description.RNS_data"})
			table.insert(buttonText, item.id)
		elseif item.id ~= nil then
			table.insert(buttonText, "\n")
			table.insert(buttonText, {"gui-description.RNS_item_number"})
			table.insert(buttonText, item.id)
		end
		
		if item.cont.ammo ~= nil then
			table.insert(buttonText, "\n")
			table.insert(buttonText, {"gui-description.RNS_ammo"})
			table.insert(buttonText, item.cont.ammo .. "/" .. game.item_prototypes[item.cont.name].magazine_size)
		end
		if item.cont.durability ~= nil then
			table.insert(buttonText, "\n")
			table.insert(buttonText, {"gui-description.RNS_durability"})
			table.insert(buttonText, item.cont.durability .. "/" .. game.item_prototypes[item.cont.name].durability)
		end
		if item.cont.linked ~= nil then
			table.insert(buttonText, "\n")
			table.insert(buttonText, {"gui-description.RNS_linked"})
			table.insert(buttonText, item.cont.linked.entity_label or Util.get_item_name(item.cont.linked.name))
		end
		GuiApi.add_button(guiTable, "RNS_NII_PInv_" .. i, tableList, "item/" .. (item.cont.name), "item/" .. (item.cont.name), "item/" .. (item.cont.name), buttonText, 38, false, true, item.cont.count, Constants.Settings.RNS_Gui.button_1, {ID=self.entID, name=(item.cont.name), stack=item})
		
		::continue::
	end
end

function NII:createNetworkInventory(guiTable, inventoryScrollPane, text)
	local tableList = GuiApi.add_table(guiTable, "", inventoryScrollPane, 8)

	for _, drive in pairs(self.networkController.network.ItemDriveTable) do
		local inv = drive:get_inventory()
		if Util.getTableLength(inv) == 0 then goto continue end

		for i = 1, Util.getTableLength(inv) do
			local item = inv[i]
			if guiTable.vars.tmpLocal ~= nil and Util.get_item_name(item.cont.name)[1] ~= nil then
				local locName = guiTable.vars.tmpLocal[Util.get_item_name(item.cont.name)[1]]
				if text ~= nil and text ~= "" and locName ~= nil and string.match(string.lower(locName), string.lower(text)) == nil then goto continue end
			end

			local buttonText = {"", "[color=blue]", item.cont.label or Util.get_item_name(item.cont.name), "[/color]"}
			if item.cont.health < 1 then
				table.insert(buttonText, "\n")
				table.insert(buttonText, {"gui-description.RNS_health"})
				table.insert(buttonText, math.floor(item.cont.health*100) .. "%")
			end
			
			if item.cont.tags ~= nil and Util.getTableLength(item.cont.tags) ~= 0 then
				table.insert(buttonText, "\n")
				table.insert(buttonText, {"gui-description.RNS_tags"})
				table.insert(buttonText, item.id)
			elseif item.cont.data ~= nil then
				table.insert(buttonText, "\n")
				table.insert(buttonText, {"gui-description.RNS_data"})
				table.insert(buttonText, item.id)
			elseif item.id ~= nil then
				table.insert(buttonText, "\n")
				table.insert(buttonText, {"gui-description.RNS_item_number"})
				table.insert(buttonText, item.id)
			end
			
			if item.cont.ammo ~= nil then
				table.insert(buttonText, "\n")
				table.insert(buttonText, {"gui-description.RNS_ammo"})
				table.insert(buttonText, item.cont.ammo .. "/" .. game.item_prototypes[item.cont.name].magazine_size)
			end
			if item.cont.durability ~= nil then
				table.insert(buttonText, "\n")
				table.insert(buttonText, {"gui-description.RNS_durability"})
				table.insert(buttonText, item.cont.durability .. "/" .. game.item_prototypes[item.cont.name].durability)
			end
			if item.cont.linked ~= nil then
				table.insert(buttonText, "\n")
				table.insert(buttonText, {"gui-description.RNS_linked"})
				table.insert(buttonText, item.cont.linked.entity_label or Util.get_item_name(item.cont.linked.name))
			end
			GuiApi.add_button(guiTable, "RNS_NII_IDInv_" .. drive.entID .. "_".. i, tableList, "item/" .. (item.cont.name), "item/" .. (item.cont.name), "item/" .. (item.cont.name), buttonText, 38, false, true, item.cont.count, Constants.Settings.RNS_Gui.button_1, {ID=self.entID, name=(item.cont.name), stack=item})
			
			::continue::
		end
		::continue::
	end
end

function NII.transfer_from_pinv(RNSPlayer, NII, tags, count)
	if RNSPlayer.thisEntity == nil or NII == nil then return end
	local network = NII.networkController ~= nil and NII.networkController.network or nil
	if network == nil then return end
	if tags == nil then return end

	if count == -1 then count = game.item_prototypes[tags.cont.name].stack_size end
	if count == -2 then count = game.item_prototypes[tags.cont.name].stack_size/2 end
	if count == -3 then count = game.item_prototypes[tags.cont.name].stack_size*10 end
	if count == -4 then count = (2^32)-1 end

	local inv = RNSPlayer.thisEntity.get_main_inventory()
	local amount = math.min(tags.cont.count, count)
	if amount <= 0 then return end

	for i = 1, #inv do
		local itemstack1 = inv[i]
		local itemstack2 = tags
		if Util.itemstack_matches(itemstack1, itemstack2) then
			for _, drive in pairs(network.ItemDriveTable) do
				if drive:has_room() then
					amount = amount - drive:insert(itemstack2, amount, itemstack1)
					if amount <= 0 then return end
				end
			end
		end
	end
	
end

function NII.interaction(event, playerIndex)
	if string.match(event.element.name, "RNS_SearchTextField") then return end
	local count = 0
	if event.button == defines.mouse_button_type.left then count = 1 end --1 Item
	if event.button == defines.mouse_button_type.left and event.shift == true then count = -1 end --1 Stack
	if event.button == defines.mouse_button_type.right then count = -2 end --Half Stack
	if event.button == defines.mouse_button_type.right and event.shift == true then count = -3 end --10 Stacks
	if event.button == defines.mouse_button_type.left and event.control == true then count = -4 end --All Stacks

	if string.match(event.element.name, "RNS_NII_PInv") then
		local obj = global.entityTable[event.element.tags.ID]
		NII.transfer_from_pinv(getRNSPlayer(playerIndex), obj, event.element.tags, count)
		return
	end

end