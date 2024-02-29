ID = {
    thisEntity = nil,
    entID = nil,
    networkController = nil,
    maxStorage = 0,
    powerUsage = 40,
    storageArray = nil,
    connectedObjs = nil,
    cardinals = nil,
    guiFilters = nil,
    filters = nil,
    whitelistBlacklist = "blacklist",
    priority = 0
}

function ID:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = ID
    t.thisEntity = object
    t.entID = object.unit_number
    t.maxStorage = Constants.Drives.ItemDrive[string.sub(object.name, 5)].max_size
    t.powerUsage = Constants.Drives.ItemDrive[string.sub(object.name, 5)].powerUsage
    t.storageArray = {}
    t.filters = {}
    t.guiFilters = {}
    for i=1, 5 do
        t.guiFilters[i] = ""
    end
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
    UpdateSys.add_to_entity_table(t)
    t:createArms()
    BaseNet.postArms(t)
    BaseNet.update_network_controller(t.networkController)
    --UpdateSys.addEntity(t)
    return t
end

function ID:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = ID
    setmetatable(object, mt)
end

function ID:remove()
    UpdateSys.remove_from_entity_table(self)
    BaseNet.postArms(self)
    --[[if self.networkController ~= nil then
        self.networkController.network.ItemDriveTable[Constants.Settings.RNS_Max_Priority+1-self.priority][self.entID] = nil
        self.networkController.network.shouldRefresh = true
    end]]
    BaseNet.update_network_controller(self.networkController, self.entID)
end

function ID:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function ID:interactable()
    return self.thisEntity ~= nil and self.thisEntity.valid and self.thisEntity.to_be_deconstructed() == false
end

--[[function ID:update()
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
end]]

function ID:copy_settings(obj)
    self.priority = obj.priority
    self.whitelistBlacklist = obj.whitelistBlacklist
    self.filters = obj.filters
    self.guiFilters = {}
    for i = 1, 5 do
        self.guiFilters[i] = obj.guiFilters[i]
    end
end

function ID:serialize_settings()
    local tags = {}
    tags["priority"] = self.priority
    tags["whitelistBlacklist"] = self.whitelistBlacklist
    tags["filters"] = self.filters
    tags["guiFilters"] = self.guiFilters
    return tags
end

function ID:deserialize_settings(tags)
    self.priority = tags["priority"]
    self.whitelistBlacklist = tags["whitelistBlacklist"]
    self.filters = tags["filters"]
    self.guiFilters = tags["guiFilters"]
end

function ID:resetCollection()
    self.connectedObjs = {
        [1] = {}, --N
        [2] = {}, --E
        [3] = {}, --S
        [4] = {}, --W
    }
end

function ID:getCheckArea()
    local x = self.thisEntity.position.x
    local y = self.thisEntity.position.y
    return {
        [1] = {direction = 1, startP = {x-1.0, y-2.0}, endP = {x+1.0, y-1.0}}, --North
        [2] = {direction = 2, startP = {x+1.0, y-1.0}, endP = {x+2.0, y+1.0}}, --East
        [4] = {direction = 4, startP = {x-1.0, y+1.0}, endP = {x+1.0, y+2.0}}, --South
        [3] = {direction = 3, startP = {x-2.0, y-1.0}, endP = {x-1.0, y+1.0}}, --West
    }
end

function ID:createArms()
    local areas = self:getCheckArea()
    self:resetCollection()
    for _, area in pairs(areas) do
        local ents = self.thisEntity.surface.find_entities_filtered{area={area.startP, area.endP}}
        for _, ent in pairs(ents) do
            if ent ~= nil and ent.valid == true and ent.to_be_deconstructed() == false and string.match(ent.name, "RNS_") ~= nil and global.entityTable[ent.unit_number] ~= nil then
                local obj = global.entityTable[ent.unit_number]
                if (string.match(obj.thisEntity.name, "RNS_NetworkCableIO") ~= nil and obj:getConnectionDirection() == area.direction) or (string.match(obj.thisEntity.name, "RNS_NetworkCableRamp") ~= nil and obj:getConnectionDirection() == area.direction) or obj.thisEntity.name == Constants.WirelessGrid.name then
                    --Do nothing
                else
                    table.insert(self.connectedObjs[area.direction], obj)
                    BaseNet.join_network(self, obj)
                end
            end
        end
    end
end

function ID:validate()
    for k, _ in pairs(self.storageArray) do
        if game.item_prototypes[k] == nil then
            self.storageArray[k] = nil
        end
    end
end

function ID:add_or_merge_basic_item(itemstack_data, amount)
    local inv = self.storageArray
    local min = math.min(self:getRemainingStorageSize(), amount)
    if min <= 0 then return 0 end
    if inv[itemstack_data.name] ~= nil then
        local data = inv[itemstack_data.name]
        data.count = data.count + min
        if data.ammo ~= nil then
            local a = (data.ammo+itemstack_data.ammo)%game.item_prototypes[data.name].magazine_size
            data.ammo = a == 0 and game.item_prototypes[data.name].magazine_size or a
        end
        if data.durability ~= nil then
            local d = (data.durability+itemstack_data.durability)%game.item_prototypes[data.name].durability
            data.durability = d == 0 and game.item_prototypes[data.name].durability or d
        end
    else
        inv[itemstack_data.name] = Itemstack.check_instance(itemstack_data)
    end
    return min
end

function ID:remove_item(itemstack_data, amount, exact)
    local inv = self.storageArray
    local data = inv[itemstack_data.name]
    if data == nil or amount <= 0 then return 0 end
    Itemstack.check_instance(inv[itemstack_data.name])
    local min = math.min(data.count, amount)
    local split = data:split(itemstack_data, min, exact)
    --[[if exact then
        if itemstack_data.ammo ~= nil and data.ammo ~= itemstack_data.ammo and data.count > 1 then
            local new_min = math.min(data.count - 1, min)
            return new_min, data:split(itemstack_data, new_min)
        else
            return 0
        end
    end]]
    if split == nil then return 0, nil end
    if data.count <= 0 then inv[itemstack_data.name] = nil end
    return split.count, split
end

--[[function ID:has_item(itemstack_data, getModified)
    local amount = 0
    local list = self.storageArray[itemstack_data.cont.name]
    if list ~= nil and itemstack_data.modified == false then
        if (list.ammo == itemstack_data.cont.ammo or list.durability == itemstack_data.cont.durability) and (list.ammo == game.item_prototypes[list.name].magazine_size or list.durability == game.item_prototypes[list.name].durability) then
            amount = amount + list.count
        else
            if getModified == true then
                if (list.ammo == itemstack_data.cont.ammo or list.durability == itemstack_data.cont.durability) and (list.ammo ~= game.item_prototypes[list.name].magazine_size or list.durability ~= game.item_prototypes[list.name].durability) then
                    amount = amount + 1
                end
            else
                amount = amount + list.count - 1
            end
        end
    end
    return amount
end]]

function ID:has_room()
    if self:getRemainingStorageSize() > 0 then return true end
    return false
end


function ID:getStorageSize()
    local count = 0
    local inv = self.storageArray
    for _, v in pairs(inv) do
        if v ~= nil then
            count = count + v.count
        end
    end
    return count
end

function ID:getRemainingStorageSize()
    return self.maxStorage - self:getStorageSize()
end

function ID:DataConvert_ItemToEntity(tag)
    self.storageArray = tag.storage or {}
    if tag.filters ~= nil then
        self.filters = tag.filters
        self.guiFilters = tag.guiFilters
    end
    if tag.priority ~= nil then self.priority = tag.priority end
    if tag.whitelistBlacklist ~= nil then self.whitelist = tag.whitelistBlacklist end
end

function ID:DataConvert_EntityToItem(tag)
    local tags = {}
    local description = {"", tag.prototype.localised_description}

    tags.storage = self.storageArray
    Util.add_list_into_table(description, {{"item-description.RNS_DriveTag_Storage", self:getStorageSize(), self.maxStorage}})

    tags.filters = self.filters
    tags.guiFilters = self.guiFilters
    local filterString = "{"
    local i = 1
    local ind = Util.getTableLength(self.filters)
    for n, _ in pairs(self.filters) do
        filterString = filterString .. "[color=yellow]" .. n .. "[/color]" .. (i < ind and ", " or "")
        i = i + 1
    end
    filterString = filterString .. "}"
    Util.add_list_into_table(description, {{"item-description.RNS_DriveTag_Filters", filterString}})

    tags.priority = self.priority
    Util.add_list_into_table(description, {{"item-description.RNS_DriveTag_Priority", self.priority}})

    tags.whitelistBlacklist = self.whitelistBlacklist
    Util.add_list_into_table(description, {{"item-description.RNS_DriveTag_WhitelistBlacklist", self.whitelistBlacklist}})

    tag.set_tag(Constants.Settings.RNS_Tag, tags)
    tag.custom_description = description
end

function ID:getTooltips(guiTable, mainFrame, justCreated)
    if justCreated == true then
        guiTable.vars.Gui_Title.caption = {"gui-description.RNS_ItemDrive_Title"}
        
        local infoFrame = GuiApi.add_frame(guiTable, "InformationFrame", mainFrame, "vertical", true)
		infoFrame.style = Constants.Settings.RNS_Gui.frame_1
		infoFrame.style.vertically_stretchable = true
		infoFrame.style.minimal_width = 200
		infoFrame.style.left_margin = 3
		infoFrame.style.left_padding = 3
		infoFrame.style.right_padding = 3
		GuiApi.add_subtitle(guiTable, "", infoFrame, {"gui-description.RNS_Information"})
     
        GuiApi.add_label(guiTable, "Capacity", infoFrame, {"gui-description.RNS_ItemDrive_Capacity", self:getStorageSize(), self.maxStorage}, Constants.Settings.RNS_Gui.orange, nil, true)
        GuiApi.add_progress_bar(guiTable, "CapacityBar", infoFrame, "", self:getStorageSize() .. "/" .. self.maxStorage, true, nil, self:getStorageSize()/self.maxStorage, 200, 25)
    
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
        --local filterTable = GuiApi.add_table(guiTable, "", filtersFrame, 1, false)
        guiTable.vars.filters = {}
        for i=1, 5 do
            local filter = GuiApi.add_filter(guiTable, "RNS_ItemDrive_Filter_"..i, filterFlow, "", true, "item", 40, {ID=self.thisEntity.unit_number, index=i})
            guiTable.vars.filters[i] = filter
            if self.guiFilters[i] ~= "" then
                filter.elem_value = self.guiFilters[i]
            end
        end

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
        local priorityDD = GuiApi.add_dropdown(guiTable, "RNS_ItemDrive_Priority", priorityFlow, Constants.Settings.RNS_Priorities, ((#Constants.Settings.RNS_Priorities+1)/2)-self.priority, false, "", {ID=self.thisEntity.unit_number})
        priorityDD.style.minimal_width = 100

        GuiApi.add_line(guiTable, "", settingsFrame, "horizontal")

        local state = "left"
        if self.whitelistBlacklist == "blacklist" then state = "right" end
        GuiApi.add_switch(guiTable, "RNS_ItemDrive_WhitelistBlacklist", settingsFrame, {"gui-description.RNS_Whitelist"}, {"gui-description.RNS_Blacklist"}, "", "", state, false, {ID=self.thisEntity.unit_number})

    end

    for i=1, 5 do
        if self.guiFilters[i] ~= "" then
            guiTable.vars.filters[i].elem_value = self.guiFilters[i]
        end
    end

    local capacity = guiTable.vars.Capacity
    local capacityBar = guiTable.vars.CapacityBar

    capacity.caption = {"gui-description.RNS_ItemDrive_Capacity", self:getStorageSize(), self.maxStorage}
    capacityBar.tooltip = self:getStorageSize() .. "/" .. self.maxStorage
    capacityBar.value = self:getStorageSize()/self.maxStorage
end

function ID.interaction(event, RNSPlayer)
    local guiTable = RNSPlayer.GUI[Constants.Settings.RNS_Gui.tooltip]

    if string.match(event.element.name, "RNS_ItemDrive_Priority") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local priority = Constants.Settings.RNS_Priorities[event.element.selected_index]
        if priority ~= io.priority then
            io.priority = priority
            local oldP = 1+Constants.Settings.RNS_Max_Priority-io.priority
            io.priority = priority
            if io.networkController ~= nil and io.networkController.valid == true then
                io.networkController.network.ItemDriveTable[oldP][io.entID] = nil
                io.networkController.network.ItemDriveTable[1+Constants.Settings.RNS_Max_Priority-priority][io.entID] = io
            end
        end
		return
    end

    if string.match(event.element.name, "RNS_ItemDrive_Filter") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        if event.element.elem_value ~= nil then
            io.guiFilters[event.element.tags.index] = event.element.elem_value
        else
            io.guiFilters[event.element.tags.index] = ""
        end

        io.filters = {}
        for i = 1, 5 do
            local filter = guiTable.vars.filters[i]
            if filter ~= nil and filter.elem_value ~= nil then
                io.filters[filter.elem_value] = true
            end
        end
		return
    end

    if string.match(event.element.name, "RNS_ItemDrive_WhitelistBlacklist") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        io.whitelistBlacklist = event.element.switch_state == "left" and "whitelist" or "blacklist"
		return
    end
end