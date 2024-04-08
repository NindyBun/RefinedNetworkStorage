WG = {
    thisEntity = nil,
    entID = nil,
    connected = nil,
    sortOrder = "HL"
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
    UpdateSys.add_to_entity_table(t)
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
    UpdateSys.remove_from_entity_table(self)
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
	if self.connected and (global.entityTable[self.connected] == nil or global.entityTable[self.connected].thisEntity == nil or global.entityTable[self.connected].thisEntity.valid == false) then
		self.connected = nil
		return
	end
end

function WG:copy_settings(obj)
	self.connected = obj.connected
	self.sortOrder = obj.sortOrder
end

function WG:serialize_settings()
    local tags = {}
    tags["connection"] = self.connected
	tags["sortOrder"] = self.sortOrder
    return tags
end

function WG:deserialize_settings(tags)
    self.connected= tags["connection"]
	self.sortOrder = tags["sortOrder"]
end

function WG:DataConvert_ItemToEntity(tag_contents)
    self.connected = tag_contents.connection
	self.sortOrder = tag_contents.sortOrder
end

function WG:DataConvert_EntityToItem(item)
	local description = {"", item.prototype.localised_description, {"item-description.RNS_WirelessGrid_SortOrder", self.sortOrder}}
	if self.connected then
        local obj = global.entityTable[self.connected]
        Util.add_list_into_table(description, {{"item-description.RNS_TransReceiverConnectionTag"}, obj.nametag})
    end
    item.set_tag(Constants.Settings.RNS_Tag, {connected=self.connected, sortOrder=self.sortOrder})
    item.custom_description = description
end

function WG:getTooltips(guiTable, mainFrame, justCreated)
    local RNSPlayer = guiTable.RNSPlayer

    if justCreated == true then
        -- Set the GUI Title --
		guiTable.vars.Gui_Title.caption = {"gui-description.RNS_WirelessGrid_Title"}

		-- Set the Main Frame Height --
		mainFrame.style.minimal_height = 450

		local storageFrame = GuiApi.add_frame(guiTable, "StorageFrame", mainFrame, "vertical", true)
		storageFrame.style = Constants.Settings.RNS_Gui.frame_1
		storageFrame.style.vertically_stretchable = true
		storageFrame.style.left_padding = 3
		storageFrame.style.right_padding = 3
		storageFrame.style.left_margin = 3
		storageFrame.style.right_margin = 3
		storageFrame.style.minimal_width = 250

		GuiApi.add_subtitle(guiTable, "", storageFrame, {"gui-description.RNS_NetworkStorageBars"})
		
		GuiApi.add_label(guiTable, "ItemDriveStorageLabel", storageFrame, {"gui-description.RNS_ItemDriveStorageLabel", 0}, Constants.Settings.RNS_Gui.white, nil, true)
		GuiApi.add_progress_bar(guiTable, "ItemDriveStorageBar", storageFrame, "", {"gui-description.RNS_ItemDriveStorageBar", 0, 0}, true, nil, 0, 200, 25)

		GuiApi.add_label(guiTable, "FluidDriveStorageLabel", storageFrame, {"gui-description.RNS_FluidDriveStorageLabel", 0}, Constants.Settings.RNS_Gui.white, nil, true)
		GuiApi.add_progress_bar(guiTable, "FluidDriveStorageBar", storageFrame, "", {"gui-description.RNS_FluidDriveStorageBar", 0, 0}, true, nil, 0, 200, 25)

		GuiApi.add_label(guiTable, "ExternalItemStorageLabel", storageFrame, {"gui-description.RNS_ExternalItemStorageLabel", 0}, Constants.Settings.RNS_Gui.white, nil, true)
		GuiApi.add_progress_bar(guiTable, "ExternalItemStorageBar", storageFrame, "", {"gui-description.RNS_ExternalItemStorageBar", 0, 0}, true, nil, 0, 200, 25)

		GuiApi.add_label(guiTable, "ExternalFluidStorageLabel", storageFrame, {"gui-description.RNS_ExternalFluidStorageLabel", 0}, Constants.Settings.RNS_Gui.white, nil, true)
		GuiApi.add_progress_bar(guiTable, "ExternalFluidStorageBar", storageFrame, "", {"gui-description.RNS_ExternalFluidStorageBar", 0, 0}, true, nil, 0, 200, 25)

		--local infoFrame = GuiApi.add_frame(guiTable, "InformationFrame", mainFrame, "vertical", true)
		--infoFrame.style = Constants.Settings.RNS_Gui.frame_1
		--infoFrame.style.vertically_stretchable = true
		--infoFrame.style.minimal_width = 200
		--infoFrame.style.left_margin = 3
		--infoFrame.style.left_padding = 3
		--infoFrame.style.right_padding = 3
		--GuiApi.add_subtitle(guiTable, "", infoFrame, {"gui-description.RNS_Information"})

		guiTable.vars.WG = {
			cache = {
				items = {},
				fluids = {}
			}
		}
		-- Create the Network Inventory Frame --
		local inventoryFrame = GuiApi.add_frame(guiTable, "InventoryFrame", mainFrame, "vertical", true)
		inventoryFrame.style = Constants.Settings.RNS_Gui.frame_1
		inventoryFrame.style.vertically_stretchable = true
		inventoryFrame.style.left_padding = 3
		inventoryFrame.style.right_padding = 3
		inventoryFrame.style.left_margin = 3
		inventoryFrame.style.right_margin = 3

		-- Add the Title --
		GuiApi.add_subtitle(guiTable, "", inventoryFrame, {"gui-description.RNS_NetworkInventory_Items"})

		-- Create the Network Inventory Scroll Pane --
		local inventoryScrollPaneItems = GuiApi.add_scroll_pane(guiTable, "InventoryScrollPaneItems", inventoryFrame, 500, true)
		inventoryScrollPaneItems.style = Constants.Settings.RNS_Gui.scroll_pane
		inventoryScrollPaneItems.style.minimal_width = 308
		inventoryScrollPaneItems.style.vertically_stretchable = true
		inventoryScrollPaneItems.style.bottom_margin = 3

		GuiApi.add_table(guiTable, "WirelessGridTableItems", inventoryScrollPaneItems, 8, true)

		-- Create the Player Inventory Frame --
		--[[local playerInventoryFrame = GuiApi.add_frame(guiTable, "PlayerInventoryFrame", mainFrame, "vertical", true)
		playerInventoryFrame.style = Constants.Settings.RNS_Gui.frame_1
		playerInventoryFrame.style.vertically_stretchable = true
		playerInventoryFrame.style.left_padding = 3
		playerInventoryFrame.style.left_margin = 3
		playerInventoryFrame.style.right_padding = 3
		playerInventoryFrame.style.right_margin = 3
		
		-- Add the Title --
		GuiApi.add_subtitle(guiTable, "", playerInventoryFrame, {"gui-description.RNS_PlayerInventory"})

		-- Create the Player Inventory Scroll Pane --
		local playerInventoryScrollPane = GuiApi.add_scroll_pane(guiTable, "PlayerInventoryScrollPane", playerInventoryFrame, 500, true)
		playerInventoryScrollPane.style = Constants.Settings.RNS_Gui.scroll_pane
		playerInventoryScrollPane.style.minimal_width = 308
		playerInventoryScrollPane.style.vertically_stretchable = true
		playerInventoryScrollPane.style.bottom_margin = 3
		
		GuiApi.add_table(guiTable, "PlayerInventoryTable", playerInventoryScrollPane, 8, true)]]

		-- Create the Information Frame --
		local informationFrame = GuiApi.add_frame(guiTable, "InformationFrame1", mainFrame, "vertical", true)
		informationFrame.style = Constants.Settings.RNS_Gui.frame_1
		informationFrame.style.vertically_stretchable = true
		informationFrame.style.left_padding = 3
		informationFrame.style.right_padding = 3
		informationFrame.style.right_margin = 3
		informationFrame.style.minimal_width = 200

		-- Add the Title --
		GuiApi.add_subtitle(guiTable, "", informationFrame, {"gui-description.RNS_Information"})

		--GuiApi.add_label(guiTable, "InventorySize", informationFrame, {"gui-description.RNS_Inventory_Size", 0, 0}, Constants.Settings.RNS_Gui.white, "", true, Constants.Settings.RNS_Gui.label_font)
--
		--GuiApi.add_line(guiTable, "", informationFrame, "horizontal")

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

		local state = "left"
		if self.sortOrder == "LH" then state = "right" end
		GuiApi.add_switch(guiTable, "RNS_WG_SortOrder", informationFrame, {"gui-description.RNS_Sort_HL"}, {"gui-description.RNS_Sort_LH"}, {"gui-description.RNS_SortOrder_HL"}, {"gui-description.RNS_SortOrder_LH"}, state, false, {ID=self.thisEntity.unit_number})

		-- Create the Help Table --
		local helpTable = GuiApi.add_table(guiTable, "", informationFrame, 1)

		-- Create the Information Labels --
		GuiApi.add_label(guiTable, "", helpTable, {"gui-description.RNS_HelpText1"}, Constants.Settings.RNS_Gui.white)
		GuiApi.add_label(guiTable, "", helpTable, {"gui-description.RNS_HelpText2"}, Constants.Settings.RNS_Gui.white)
		GuiApi.add_label(guiTable, "", helpTable, {"gui-description.RNS_HelpText3"}, Constants.Settings.RNS_Gui.white)
		GuiApi.add_label(guiTable, "", helpTable, {"gui-description.RNS_HelpText4"}, Constants.Settings.RNS_Gui.white)
		GuiApi.add_label(guiTable, "", helpTable, {"gui-description.RNS_HelpText5"}, Constants.Settings.RNS_Gui.white)
		--GuiApi.add_label(guiTable, "", helpTable, {"gui-description.RNS_HelpText6"}, Constants.Settings.RNS_Gui.white)

		
		GuiApi.add_subtitle(guiTable, "", informationFrame, {"gui-description.RNS_PlayerInventory"})
		local player_inventory_flow = GuiApi.add_flow(guiTable, "", informationFrame, "vertical")
		player_inventory_flow.style.vertical_align = "center"
		GuiApi.add_button(guiTable, "RNS_NII_Insert", player_inventory_flow, Constants.Icons.insert_arrow.name, nil, nil, {"gui-description.RNS_Insert_Item"}, 37, false, true, nil, "inventory_slot", {ID=self.entID})
		
		GuiApi.add_line(guiTable, "", informationFrame, "horizontal")

		local infoFlow = GuiApi.add_flow(guiTable, "", informationFrame, "vertical")

        if self.connected then
            if global.entityTable[self.connected] == nil or global.entityTable[self.connected].thisEntity == nil or global.entityTable[self.connected].thisEntity.valid == false then
                self.connected = nil
            end
        end

        GuiApi.add_subtitle(guiTable, "", infoFlow, {"gui-description.RNS_Connections"})

        local selected = 1
        local index = 1
        local values = {""}
        for id, obj in pairs(global.NetworkControllers) do
            if obj.thisEntity.valid then
                index = index + 1
                table.insert(values, obj.nametag)
                if self.connected and self.connected == id then selected = index end
            end
        end
		game.print(serpent.line(values[selected]))
        GuiApi.add_label(guiTable, "Connection", infoFlow, self.connected and {"gui-description.RNS_WirelessGrid_Available_Controllers_Connected"} or {"gui-description.RNS_WirelessGrid_Available_Controllers_Disconnected"}, Constants.Settings.RNS_Gui.white, "", true)
        GuiApi.add_dropdown(guiTable, "RNS_WG_Channels", infoFlow, values, selected, false, "", {ID=self.thisEntity.unit_number})

		GuiApi.add_subtitle(guiTable, "", informationFrame, {"gui-description.RNS_NetworkInventory_Fluids"})
		-- Create the Network Inventory Scroll Pane for Items --
		local inventoryScrollPaneFluids = GuiApi.add_scroll_pane(guiTable, "InventoryScrollPaneFluids", informationFrame, 500, true)
		inventoryScrollPaneFluids.style = Constants.Settings.RNS_Gui.scroll_pane
		inventoryScrollPaneFluids.style.minimal_width = 308
		inventoryScrollPaneFluids.style.vertically_stretchable = true
		inventoryScrollPaneFluids.style.bottom_margin = 3

		GuiApi.add_table(guiTable, "WirelessGridTableFluids", inventoryScrollPaneFluids, 8, true)

		--[[GuiApi.add_label(guiTable, "", informationFrame, {"gui-description.RNS_WirelessGrid_Target"}, Constants.Settings.RNS_Gui.white)

        local xflow = GuiApi.add_flow(guiTable, "", informationFrame, "horizontal")
        GuiApi.add_label(guiTable, "", xflow, {"gui-description.RNS_xPos"}, Constants.Settings.RNS_Gui.white)
        local xPos = GuiApi.add_text_field(guiTable, "RNS_WirelessGrid_xPos", xflow, self.network_controller_position.x == nil and "" or tostring(self.network_controller_position.x), {"gui-description.RNS_xPos_tooltip"}, true, true, true, true, false, {ID=self.entID})
        xPos.style.maximal_width = 50

        local yflow = GuiApi.add_flow(guiTable, "", informationFrame, "horizontal")
        GuiApi.add_label(guiTable, "", yflow, {"gui-description.RNS_yPos"}, Constants.Settings.RNS_Gui.white)
        local yPos = GuiApi.add_text_field(guiTable, "RNS_WirelessGrid_yPos", yflow, self.network_controller_position.y == nil and "" or tostring(self.network_controller_position.y), {"gui-description.RNS_yPos_tooltip"}, true, true, true, true, false, {ID=self.entID})
        yPos.style.maximal_width = 50

        local surfIDflow = GuiApi.add_flow(guiTable, "", informationFrame, "horizontal")
        GuiApi.add_label(guiTable, "", surfIDflow, {"gui-description.RNS_SurfaceID"}, Constants.Settings.RNS_Gui.white)
        local surfID = GuiApi.add_text_field(guiTable, "RNS_WirelessGrid_SurfaceID", surfIDflow, self.network_controller_surface == nil and "" or tostring(self.network_controller_surface), {"gui-description.RNS_SurfaceID_tooltip"}, true, true, false, false, false, {ID=self.entID})
        surfID.style.maximal_width = 50]]

		--GuiApi.add_label(guiTable, "", informationFrame, {"gui-description.RNS_Position", self.thisEntity.position.x, self.thisEntity.position.y}, Constants.Settings.RNS_Gui.white, "", false)
    end
    guiTable.vars.Connection.caption = self.connected and {"gui-description.RNS_WirelessGrid_Available_Controllers_Connected"} or {"gui-description.RNS_WirelessGrid_Available_Controllers_Disconnected"}

	--local inventoryScrollPane = guiTable.vars.InventoryScrollPane
	--local playerInventoryScrollPane = guiTable.vars.PlayerInventoryScrollPane
	local textField = guiTable.vars.RNS_SearchTextField

	--inventoryScrollPane.clear()
	--playerInventoryScrollPane.clear()

	--self:createPlayerInventory(guiTable, RNSPlayer, guiTable.vars.PlayerInventoryTable, textField.text)

    --if self.networkController == nil or not self.networkController.stable or (self.networkController.thisEntity ~= nil and self.networkController.thisEntity.valid == false) then return end
	--if self.network_controller_surface == nil or self.thisEntity.surface.index ~= self.network_controller_surface then return end
	--if self.network_controller_position.x == nil or self.network_controller_position.y == nil then return end
	--if game.surfaces[self.network_controller_surface].find_entity(Constants.NetworkController.main.name, self.network_controller_position) == nil then return end
	if self.connected == nil then return end

	if self.connected and global.entityTable[self.connected] and global.entityTable[self.connected]:find_wirelessgrid_with_wirelessTransmitter(self.thisEntity.unit_number) == false then
		if justCreated == true then RNSPlayer.thisEntity.print({"gui-description.RNS_NetworkController_Far"}) end
		return
	end

	self:createNetworkInventory(guiTable, RNSPlayer, textField.text)
end

--[[function WG:createPlayerInventory(guiTable, RNSPlayer, tableList, text)
	local inv = {}
	for i = 1, #RNSPlayer.thisEntity.get_main_inventory() do
		local item = RNSPlayer.thisEntity.get_main_inventory()[i]
		if item.count <= 0 then goto continue end
		RNSPlayer.thisEntity.request_translation(Util.get_item_name(item.name))
		if Util.get_item_name(item.name)[1] ~= nil then
			local locName = Util.get_item_name(item.name)[1]
			if text ~= nil and text ~= "" and locName ~= nil and string.match(string.lower(locName), string.lower(text)) == nil then goto continue end
		end
		Util.item_add_list_into_table(inv, Itemstack:new(item))
		::continue::
	end
	local itemIndex = 1
	for _, item in pairs(inv) do
		local buttonText = {"", "[color=blue]", item.extras.label or Util.get_item_name(item.name), "[/color]\n", {"gui-description.RNS_count"}, Util.toRNumber(item.count)}
		if item.health < 1 then
			table.insert(buttonText, "\n")
			table.insert(buttonText, {"gui-description.RNS_health"})
			table.insert(buttonText, math.floor(item.health*100) .. "%")
		end
		if item.extras.custom_description ~= "" and item.extras.custom_description ~= nil then
			table.insert(buttonText, "\n")
			table.insert(buttonText, item.extras.custom_description)
		elseif item.modified then
			table.insert(buttonText, "\n")
			table.insert(buttonText, {"gui-description.RNS_item_modified"})
		end
		
		if item.ammo ~= nil then
			table.insert(buttonText, "\n")
			table.insert(buttonText, {"gui-description.RNS_ammo"})
			table.insert(buttonText, item.ammo .. "/" .. game.item_prototypes[item.name].magazine_size)
		end
		if item.durability ~= nil then
			table.insert(buttonText, "\n")
			table.insert(buttonText, {"gui-description.RNS_durability"})
			table.insert(buttonText, item.durability .. "/" .. game.item_prototypes[item.name].durability)
		end
		if item.connected_entity ~= nil then
			table.insert(buttonText, "\n")
			table.insert(buttonText, {"gui-description.RNS_linked"})
			table.insert(buttonText, item.connected_entity.entity_label or Util.get_item_name(item.connected_entity.name))
		end
		if guiTable.vars.WG.player[itemIndex] == nil then
			table.insert(guiTable.vars.WG.player, GuiApi.add_button(guiTable, "RNS_WG_PInv_".. itemIndex, tableList, "item/" .. (item.name), "item/" .. (item.name), "item/" .. (item.name), buttonText, 37, false, true, item.count, ((item.modified or (item.ammo and item.ammo < game.item_prototypes[item.name].magazine_size) or (item.durability and item.durability < game.item_prototypes[item.name].durability)) and {Constants.Settings.RNS_Gui.button_2} or {Constants.Settings.RNS_Gui.button_1})[1], {ID=self.thisEntity.unit_number, name=(item.name), stack=item}))
		else
			local button = guiTable.vars.WG.player[itemIndex]
			if Itemstack:reload(button.tags.stack):compare_itemstacks(item, true, true) == false then
				button.destroy()
				guiTable.vars.WG.player[itemIndex] = GuiApi.add_button(guiTable, "RNS_WG_PInv_".. itemIndex, tableList, "item/" .. (item.name), "item/" .. (item.name), "item/" .. (item.name), buttonText, 37, false, true, item.count, ((item.modified or (item.ammo and item.ammo < game.item_prototypes[item.name].magazine_size) or (item.durability and item.durability < game.item_prototypes[item.name].durability)) and {Constants.Settings.RNS_Gui.button_2} or {Constants.Settings.RNS_Gui.button_1})[1], {ID=self.thisEntity.unit_number, name=(item.name), stack=item})
			end
			guiTable.vars.WG.player[itemIndex].tooltip = buttonText
			guiTable.vars.WG.player[itemIndex].number = item.count
			guiTable.vars.WG.player[itemIndex].tags.stack = item
		end
		itemIndex = itemIndex + 1
		::continue::
	end
	if #guiTable.vars.WG.player > #inv then
		for j = #guiTable.vars.WG.player, #inv, -1 do
			if guiTable.vars.WG.player[j] then
				guiTable.vars.WG.player[j].destroy()
			end
			table.remove(guiTable.vars.WG.player, j)
		end
	end
end]]

function WG:createNetworkInventory(guiTable, RNSPlayer, text)
	local inv = {}
	local fluid = {}

	local itemDriveStorage = 0
	local itemDriveCapacity = 0
	for _, priority in pairs(global.entityTable[self.connected].network.ItemDriveTable) do
		for _, drive in pairs(priority) do
			if drive:interactable() == false then goto continue end
			itemDriveCapacity = itemDriveCapacity + drive.maxStorage
			for _, v in pairs(drive.storageArray) do
				local item = Itemstack:reload(v)
				itemDriveStorage = itemDriveStorage + v.count
				RNSPlayer.thisEntity.request_translation(Util.get_item_name(item.name))
				if Util.get_item_name(item.name)[1] ~= nil then
					local locName = Util.get_item_name(item.name)[1]
					if text ~= nil and text ~= "" and locName ~= nil and string.match(string.lower(locName), string.lower(text)) == nil then goto continue end
				end
				Util.item_add_list_into_table(inv, item)
				--local c = Util.itemstack_template(v.name)
				--c.cont.count = v.count
				--if c.cont.ammo then c.cont.ammo = v.ammo end
				--if c.cont.durability then c.cont.durability = v.durability end
				--Util.add_or_merge(c, inv, true)
				::continue::
			end
			::continue::
		end
	end
	guiTable.vars.ItemDriveStorageLabel.caption = {"gui-description.RNS_ItemDriveStorageLabel", itemDriveCapacity ~= 0 and Util.sigfig_d((itemDriveStorage/itemDriveCapacity)*100, 2) or 0}
	guiTable.vars.ItemDriveStorageBar.value = itemDriveCapacity ~= 0 and (itemDriveStorage/itemDriveCapacity) or 0
	guiTable.vars.ItemDriveStorageBar.tooltip = {"gui-description.RNS_ItemDriveStorageBar", Util.toRNumber(itemDriveStorage), Util.toRNumber(itemDriveCapacity)}

	local fluidDriveStorage = 0
	local fluidDriveCapacity = 0
	for _, priority in pairs(global.entityTable[self.connected].network.FluidDriveTable) do
		for _, drive in pairs(priority) do
			if drive:interactable() == false then goto continue end
			fluidDriveCapacity = fluidDriveCapacity + drive.maxStorage
			for k, c in pairs(drive.fluidArray) do
				if c == nil then goto continue end
				fluidDriveStorage = fluidDriveStorage + c.amount
				RNSPlayer.thisEntity.request_translation(Util.get_fluid_name(c.name))
				if Util.get_fluid_name(c.name)[1] ~= nil then
					local locName = Util.get_fluid_name(c.name)[1]
					if text ~= nil and text ~= "" and locName ~= nil and string.match(string.lower(locName), string.lower(text)) == nil then goto continue end
				end
				Util.fluid_add_list_into_table(fluid, c)
				::continue::
			end
			::continue::
		end
	end
	guiTable.vars.FluidDriveStorageLabel.caption = {"gui-description.RNS_FluidDriveStorageLabel", fluidDriveCapacity ~= 0 and Util.sigfig_d((fluidDriveStorage/fluidDriveCapacity)*100, 2) or 0}
	guiTable.vars.FluidDriveStorageBar.value = fluidDriveCapacity ~= 0 and (fluidDriveStorage/fluidDriveCapacity) or 0
	guiTable.vars.FluidDriveStorageBar.tooltip = {"gui-description.RNS_FluidDriveStorageBar", Util.toRNumber(fluidDriveStorage), Util.toRNumber(fluidDriveCapacity)}

	local externalItemStorage = 0
	local externalFluidStorage = 0
	local externalItemCapacity = 0
	local externalFluidCapacity = 0
	for _, priority in pairs(global.entityTable[self.connected].network:filter_externalIO_by_valid_signal()) do
		for _, type in pairs(priority) do
			for _, external in pairs(type) do
				if external:interactable() and external:target_interactable() and string.match(external.io, "input") then
					if external.type == "item" then
						externalItemStorage = externalItemStorage + external.storedAmount
						externalItemCapacity = externalItemCapacity + external.capacity
						for i = 1, #external.cache do
							local cached = external.cache[i]
							if cached.name ~= "RNS_Empty" then
								RNSPlayer.thisEntity.request_translation(Util.get_item_name(cached.name))
								if Util.get_item_name(cached.name)[1] ~= nil then
									local locName = Util.get_item_name(cached.name)[1]
									if text ~= nil and text ~= "" and locName ~= nil and string.match(string.lower(locName), string.lower(text)) == nil then goto continue end
								end
								Util.item_add_list_into_table(inv, Itemstack:reload(cached))
							end
							::continue::
						end
					else
						local cached = external.cache[1]
						externalFluidStorage = externalFluidStorage + external.storedAmount
						externalFluidCapacity = externalFluidCapacity + external.capacity
						if cached ~= nil then
							RNSPlayer.thisEntity.request_translation(Util.get_fluid_name(cached.name))
							if Util.get_fluid_name(cached.name)[1] ~= nil then
								local locName = Util.get_fluid_name(cached.name)[1]
								if text ~= nil and text ~= "" and locName ~= nil and string.match(string.lower(locName), string.lower(text)) == nil then goto continue end
							end
							Util.fluid_add_list_into_table(fluid, cached)
						end
					end
				end
				::continue::
			end
		end
	end
	guiTable.vars.ExternalItemStorageLabel.caption = {"gui-description.RNS_ExternalItemStorageLabel", externalItemCapacity ~= 0 and Util.sigfig_d((externalItemStorage/externalItemCapacity)*100, 2) or 0}
	guiTable.vars.ExternalItemStorageBar.value = externalItemCapacity ~= 0 and (externalItemStorage/externalItemCapacity) or 0
	guiTable.vars.ExternalItemStorageBar.tooltip = {"gui-description.RNS_ExternalItemStorageBar", Util.toRNumber(externalItemStorage), Util.toRNumber(externalItemCapacity)}

	guiTable.vars.ExternalFluidStorageLabel.caption = {"gui-description.RNS_ExternalFluidStorageLabel", externalFluidCapacity ~= 0 and Util.sigfig_d((externalFluidStorage/externalFluidCapacity)*100, 2) or 0}
	guiTable.vars.ExternalFluidStorageBar.value = externalFluidCapacity ~= 0 and (externalFluidStorage/externalFluidCapacity) or 0
	guiTable.vars.ExternalFluidStorageBar.tooltip = {"gui-description.RNS_ExternalFluidStorageBar", Util.toRNumber(externalFluidStorage), Util.toRNumber(externalFluidCapacity)}
	
	-----------------------------------------------------------------------------------Items----------------------------------------------------------------------------------------
	local itemIndex = 0
	Util.merge_sort(inv, nil, nil, self.sortOrder)
	for _, item in pairs(inv) do
		itemIndex = itemIndex + 1
		local buttonText = {"", "[color=blue]", item.extras.label or Util.get_item_name(item.name), "[/color]\n", {"gui-description.RNS_count"}, Util.toRNumber(item.count)}
		if item.health < 1 then
			table.insert(buttonText, "\n")
			table.insert(buttonText, {"gui-description.RNS_health"})
			table.insert(buttonText, math.floor(item.health*100) .. "%")
		end
		
		if item.extras.custom_description ~= "" and item.extras.custom_description ~= nil then
			table.insert(buttonText, "\n")
			table.insert(buttonText, item.extras.custom_description)
		elseif item.modified then
			table.insert(buttonText, "\n")
			table.insert(buttonText, {"gui-description.RNS_item_modified"})
		end
		
		if item.ammo ~= nil then
			table.insert(buttonText, "\n")
			table.insert(buttonText, {"gui-description.RNS_ammo"})
			table.insert(buttonText, item.ammo .. "/" .. game.item_prototypes[item.name].magazine_size)
		end
		if item.durability ~= nil then
			table.insert(buttonText, "\n")
			table.insert(buttonText, {"gui-description.RNS_durability"})
			table.insert(buttonText, item.durability .. "/" .. game.item_prototypes[item.name].durability)
		end
		if item.connected_entity ~= nil then
			table.insert(buttonText, "\n")
			table.insert(buttonText, {"gui-description.RNS_linked"})
			table.insert(buttonText, item.connected_entity.entity_label or Util.get_item_name(item.connected_entity.name))
		end
		if guiTable.vars.WG.cache.items[itemIndex] == nil then
			table.insert(guiTable.vars.WG.cache.items, GuiApi.add_button(guiTable, "RNS_WG_IDInv_".. itemIndex, guiTable.vars.WirelessGridTableItems, "item/" .. (item.name), "item/" .. (item.name), "item/" .. (item.name), buttonText, 37, false, true, item.count, ((item.modified or (item.ammo and item.ammo < game.item_prototypes[item.name].magazine_size) or (item.durability and item.durability < game.item_prototypes[item.name].durability)) and {Constants.Settings.RNS_Gui.button_2} or {Constants.Settings.RNS_Gui.button_1})[1], {ID=self.thisEntity.unit_number, name=(item.name), stack=item}, itemIndex))
		else
			local button = guiTable.vars.WG.cache.items[itemIndex]
			if button.tags.stack == nil or Itemstack:reload(button.tags.stack):compare_itemstacks(item, true, true) == false then
				button.destroy()
				guiTable.vars.WG.cache.items[itemIndex] = GuiApi.add_button(guiTable, "RNS_WG_IDInv_".. itemIndex, guiTable.vars.WirelessGridTableItems, "item/" .. (item.name), "item/" .. (item.name), "item/" .. (item.name), buttonText, 37, false, true, item.count, ((item.modified or (item.ammo and item.ammo < game.item_prototypes[item.name].magazine_size) or (item.durability and item.durability < game.item_prototypes[item.name].durability)) and {Constants.Settings.RNS_Gui.button_2} or {Constants.Settings.RNS_Gui.button_1})[1], {ID=self.thisEntity.unit_number, name=(item.name), stack=item}, itemIndex)
			--elseif guiTable.vars.NII.item[itemIndex].number ~= item.count then
			--	button.destroy()
			--	guiTable.vars.NII.item[itemIndex] = GuiApi.add_button(guiTable, "RNS_NII_IDInv_".. itemIndex, tableList, "item/" .. (item.name), "item/" .. (item.name), "item/" .. (item.name), buttonText, 37, false, true, item.count, ((item.modified or (item.ammo and item.ammo < game.item_prototypes[item.name].magazine_size) or (item.durability and item.durability < game.item_prototypes[item.name].durability)) and {Constants.Settings.RNS_Gui.button_2} or {Constants.Settings.RNS_Gui.button_1})[1], {ID=self.thisEntity.unit_number, name=(item.name), stack=item})
			end
			guiTable.vars.WG.cache.items[itemIndex].number = item.count
			guiTable.vars.WG.cache.items[itemIndex].tags = {ID=self.thisEntity.unit_number, name=(item.name), stack=item}
			guiTable.vars.WG.cache.items[itemIndex].tooltip = buttonText
		end
		::continue::
	end
	--[[if #guiTable.vars.NII.cache > #inv then
		for j = #guiTable.vars.NII.cache, #inv, -1 do
			if guiTable.vars.NII.cache[j] then
				guiTable.vars.NII.cache[j].destroy()
			end
			table.remove(guiTable.vars.NII.cache, j)
		end
	end]]
	-----------------------------------------------------------------------------------Fluids----------------------------------------------------------------------------------------
	local fluidIndex = 0
	Util.merge_sort(fluid, nil, nil, self.sortOrder)
	for _, c in pairs(fluid) do
		fluidIndex = fluidIndex + 1
		local buttonText = {"", "[color=blue]", Util.get_fluid_name(c.name), "[/color]\n", {"gui-description.RNS_count"}, Util.toRNumber(c.amount), "\n", {"gui-description.RNS_Temperature"}, c.temperature or game.fluid_prototypes[c.name].default_temperature}
		if guiTable.vars.WG.cache.fluids[fluidIndex] == nil then
			table.insert(guiTable.vars.WG.cache.fluids, GuiApi.add_button(guiTable, "RNS_WG_FDInv_".. fluidIndex, guiTable.vars.WirelessGridTableFluids, "fluid/" .. (c.name), "fluid/" .. (c.name), "fluid/" .. (c.name), buttonText, 37, false, true, c.amount, Constants.Settings.RNS_Gui.button_1, {ID=self.entID, name=c.name}, fluidIndex))
		else
			local button = guiTable.vars.WG.cache.fluids[fluidIndex]
			if button.name ~= c.name then
				button.destroy()
				guiTable.vars.WG.cache.fluids[fluidIndex] = GuiApi.add_button(guiTable, "RNS_WG_FDInv_".. fluidIndex, guiTable.vars.WirelessGridTableFluids, "fluid/" .. (c.name), "fluid/" .. (c.name), "fluid/" .. (c.name), buttonText, 37, false, true, c.amount, Constants.Settings.RNS_Gui.button_1, {ID=self.entID, name=c.name}, fluidIndex)
			--elseif button.number ~= c.amount then
			--	button.destroy()
			--	guiTable.vars.NII.fluid[fluidIndex] = GuiApi.add_button(guiTable, "RNS_NII_FDInv_".. fluidIndex, tableList, "fluid/" .. (c.name), "fluid/" .. (c.name), "fluid/" .. (c.name), buttonText, 37, false, true, c.amount, Constants.Settings.RNS_Gui.button_1, {ID=self.entID, name=c.name})
			end
			guiTable.vars.WG.cache.fluids[fluidIndex].tooltip = buttonText
			guiTable.vars.WG.cache.fluids[fluidIndex].number = c.amount
			guiTable.vars.WG.cache.fluids[fluidIndex].tags = {ID=self.entID, name=c.name}
		end
		::continue::
	end
	if #guiTable.vars.WG.cache.items > itemIndex then
		for j = #guiTable.vars.WG.cache.items, itemIndex, -1 do
			if guiTable.vars.WG.cache.items[j] then
				guiTable.vars.WG.cache.items[j].destroy()
			end
			table.remove(guiTable.vars.WG.cache.items, j)
		end
	end
	if #guiTable.vars.WG.cache.fluids > fluidIndex then
		for j = #guiTable.vars.WG.cache.fluids, fluidIndex, -1 do
			if guiTable.vars.WG.cache.fluids[j] then
				guiTable.vars.WG.cache.fluids[j].destroy()
			end
			table.remove(guiTable.vars.WG.cache.fluids, j)
		end
	end
end


function WG.transfer_from_pinv(RNSPlayer, WG, tags, count)
	if RNSPlayer.thisEntity == nil or WG == nil then return end
	local network = WG.networkController ~= nil and WG.networkController.network or nil
	if network == nil then return end
	if network:is_full() then return end
	local itemstack = RNSPlayer.thisEntity.cursor_stack
	if itemstack.valid_for_read == false and count ~= -4 then return end
	
	local amount = 1
	if count == -1 and itemstack.count ~= 0 then amount = itemstack.count end
	if count == -2 and itemstack.count ~= 0 then amount = math.ceil(math.min(itemstack.count, game.item_prototypes[itemstack.name].stack_size/2)) end
	if count == -3 and itemstack.count ~= 0 then amount = game.item_prototypes[itemstack.name].stack_size*10 end
	if count == -4 then amount = (2^32) end

	local master = Itemstack:new(itemstack)

	if count == -4 and itemstack.count == 0 then
		BaseNet.transfer_from_inv_to_network(network, {thisEntity = RNSPlayer.thisEntity,inventory = {output = {index = 1, max = 1, values = {defines.inventory.character_main}}}}, nil, nil, "blacklist", amount, true, false)
	elseif itemstack.count ~= 0 and BaseNet.transfer_from_cursor_to_network(network, itemstack, amount) > 0 then
		BaseNet.transfer_from_inv_to_network(network, {thisEntity = RNSPlayer.thisEntity,inventory = {output = {index = 1, max = 1, values = {defines.inventory.character_main}}}}, master, nil, "whitelist", amount, true, false)
	end
end

function WG.transfer_from_idinv(RNSPlayer, WG, tags, count)
	if RNSPlayer.thisEntity == nil or WG == nil then return end
	local network = WG.connected and global.entityTable[WG.connected].network or nil
	if network == nil then return end
	if network:is_empty() then return end
	if tags == nil then return end
	local itemstack = Itemstack:reload(tags.stack)

	if count == -1 then count = game.item_prototypes[itemstack.name].stack_size end
	if count == -2 then count = math.max(1, game.item_prototypes[itemstack.name].stack_size/2) end
	if count == -3 then count = game.item_prototypes[itemstack.name].stack_size*10 end
	if count == -4 then count = (2^32)-1 end

	--local inv = RNSPlayer.thisEntity.get_main_inventory()
	local amount = math.min(itemstack.count, count)
	if amount <= 0 then return end

	BaseNet.transfer_from_network_to_inv(network, {thisEntity = RNSPlayer.thisEntity,inventory = {input = {index = 1, max = 1, values = {defines.inventory.character_main}}}}, itemstack, amount, true, true)
end

function WG.transfer_from_fdinv(RNSPlayer, WG, tags, count)
	if RNSPlayer.thisEntity == nil or WG.networkController == nil then return end
	local network = WG.networkController ~= nil and WG.networkController.network or nil
	if network == nil then return end
	if tags == nil then return end
	local fluid = tags.name

	--if count == -1 then count = game.item_prototypes[itemstack.cont.name].stack_size end
	--if count == -2 then count = math.max(1, game.item_prototypes[itemstack.cont.name].stack_size/2) end
	--if count == -3 then count = game.item_prototypes[itemstack.cont.name].stack_size*10 end
	--if count == -4 then count = (2^32)-1 end
--
	--local inv = RNSPlayer.thisEntity.get_main_inventory()
	--local amount = math.min(itemstack.cont.count, count)
	--if amount <= 0 then return end
--
	--for _, drive in pairs(network.getOperableObjects(network.ItemDriveTable)) do
	--	if RNSPlayer:has_room() then
	--		--local transfered = BaseNet.transfer_item(drive:get_sorted_and_merged_inventory(), inv, itemstack, math.min(amount, drive:has_item(itemstack)), false, true, "array_to_inv")
	--		amount = amount - BaseNet.transfer_from_drive_to_inv(drive, inv, itemstack, math.min(amount, drive:getRemainingStorageSize()), false)
	--		if amount <= 0 then return end
	--	else
	--		return
	--	end
	--end
end

function WG.interaction(event, RNSPlayer)
	if string.match(event.element.name, "RNS_SearchTextField") then return end
	if string.match(event.element.name, "RNS_WG_Channels") and event.name ~= defines.events.on_gui_click then
		local obj = global.entityTable[event.element.tags.ID]
		if obj == nil then return end
        local selected_index = event.element.selected_index
        local selected = event.element.items[selected_index]
        if selected == "" then
            obj.connected = nil
        else
            obj.connected = tonumber(selected[2])
            --RNSPlayer:push_varTable(event.element.tags.ID, true)
        end
		return
	end
	--[[if string.match(event.element.name, "xPos") then
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
	if string.match(event.element.name, "SurfaceID") then
		local obj = global.entityTable[event.element.tags.ID]
		if obj == nil then return end
        if event.element.text ~= "" then
            obj.network_controller_surface = tonumber(event.element.text)
        else
            obj.network_controller_surface = nil
        end
		return
	end]]
	if string.match(event.element.name, "RNS_WG_SortOrder") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        io.sortOrder = event.element.switch_state == "left" and "HL" or "LH"
		return
    end

	local count = 0
	if event.button == defines.mouse_button_type.left then count = 1 end --1 Item
	if event.button == defines.mouse_button_type.left and event.shift == true then count = -1 end --1 Stack
	if event.button == defines.mouse_button_type.right then count = -2 end --Half Stack
	if event.button == defines.mouse_button_type.right and event.shift == true then count = -3 end --10 Stacks
	if event.button == defines.mouse_button_type.left and event.control == true then count = -4 end --All Stacks

	local obj = global.entityTable[event.element.tags.ID]
	if obj.connected and (global.entityTable[obj.connected] == nil or global.entityTable[obj.connected].thisEntity == nil or global.entityTable[obj.connected].thisEntity.valid == false) then
		obj.connected = nil
		return
	end

	if string.match(event.element.name, "RNS_WG_PInv") then
		WG.transfer_from_pinv(RNSPlayer, obj, event.element.tags, count)
		return
	end

	if string.match(event.element.name, "RNS_WG_IDInv") then
		WG.transfer_from_idinv(RNSPlayer, obj, event.element.tags, count)
		return
	end

	if string.match(event.element.name, "RNS_WG_FDInv") then
		WG.transfer_from_fdinv(RNSPlayer, obj, event.element.tags, count)
		return
	end

end