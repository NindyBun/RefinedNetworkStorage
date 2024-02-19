--RNSPlayer object
RNSP = {
    thisEntity = nil,
    entID = nil,
    name = nil,
    networkID = nil,
    GUI = nil,
    varTable = nil,
}

--Constructor
function RNSP:new(player)
    if player == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt) --this is necessary for all objects so the objects can be reloaded when the save loads up
    mt.__index = RNSP
    t.thisEntity = player
    t.entID = player.index
    t.name = player.name
    t.GUI = {}
    t.varTable = {}
    UpdateSys.addEntity(t)
    UpdateSys.add_to_entity_table(t)
    return t
end

--Reconstructor
function RNSP:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = RNSP
    setmetatable(object, mt)
end

function RNSP:update_gui_distance_validity()
    --Update to use LuaEntity.can_reach_entity(entity) instead
    for _, guiTable in pairs(self.GUI or {}) do
        if guiTable.gui ~= nil and guiTable.gui.valid == true then
            local obj = guiTable.vars.currentObject
            if obj == nil then goto next end
            if obj ~= nil and obj.thisEntity == nil then goto next end
            if obj ~= nil and obj.thisEntity ~= nil and obj.thisEntity.valid == false then goto next end
            
            local characters = obj.thisEntity.surface.find_entities_filtered{
                type = "character",
                area = {
                    {obj.thisEntity.bounding_box.left_top.x-Constants.Settings.RNS_Default_Gui_Distance, obj.thisEntity.bounding_box.left_top.y-Constants.Settings.RNS_Default_Gui_Distance}, --top left
                    {obj.thisEntity.bounding_box.right_bottom.x+Constants.Settings.RNS_Default_Gui_Distance, obj.thisEntity.bounding_box.right_bottom.y+Constants.Settings.RNS_Default_Gui_Distance} --bottom right
                }
            }
            local found = false
            for _, character in pairs(characters) do
                if character.player ~= nil and character.player.name == self.thisEntity.name then
                    found = true
                    break
                end
            end
            if not found then
                GUI.remove_gui(guiTable, self.thisEntity)
                return
            end
        end
        ::next::
    end
end

function RNSP:update()
    self:update_gui_distance_validity()
    if self.thisEntity.selected ~= nil then
        local entity = self.thisEntity.selected
        if string.match(entity.name, "RNS_NetworkCableIO") or string.match(entity.name, "RNS_NetworkCableRamp") then
            local obj = global[global.objectTables[entity.name].tableName][entity.unit_number]
            if obj ~= nil and obj.valid and obj.toggleHoverIcon then
                obj:toggleHoverIcon(true)
            end
        end
    end
end

--Deconstructor
function RNSP:remove()
    
end

function RNSP:resetConnection()

end

--Is valid
function RNSP:valid()
    return true
end

function RNSP:process_logistic_slots(network)
    if self.thisEntity == nil or self.thisEntity.valid == false then return end
    if not self.thisEntity.is_shortcut_toggled(Constants.Settings.RNS_Player_Port_Shortcut) then return end
    if self.thisEntity.get_inventory(defines.inventory.character_armor) == nil then return end
    local armorSlot = self.thisEntity.get_inventory(defines.inventory.character_armor)
    if armorSlot[1].count <= 0 then return end
    if armorSlot[1].grid == nil then return end
    if armorSlot[1].grid.find(Constants.PlayerPort.name) == nil then return end
    local port = armorSlot[1].grid.find(Constants.PlayerPort.name)
    if port == nil then return end
    if port.energy < Constants.Settings.RNS_PlayerPort_Consumption then return end
    local player_inv = self.thisEntity.get_main_inventory()
    local highest = self.thisEntity.character.request_slot_count
    if highest > 0 then
        for i=1, highest do
            local slot = self.thisEntity.character.get_personal_logistic_slot(i)
            if slot ~= nil and slot.name ~= nil then
                local min = slot.min
                local max = slot.max
                local name = slot.name
                local amount = (player_inv.get_contents()[name] or 0) + ((self.thisEntity.cursor_stack and self.thisEntity.cursor_stack.valid_for_read and self.thisEntity.cursor_stack.name == name) and self.thisEntity.cursor_stack.count or 0)
                local add = (amount <= min) and min-amount or 0
                add = math.min(add*Constants.Settings.RNS_PlayerPort_Consumption, port.energy)/Constants.Settings.RNS_PlayerPort_Consumption
                local remove = (amount > max) and amount-max or 0
                remove = math.min(remove*Constants.Settings.RNS_PlayerPort_Consumption, port.energy)/Constants.Settings.RNS_PlayerPort_Consumption
                local itemstack = Util.itemstack_template(name)
                if add > 0 then
                    local itemDrives = BaseNet.getOperableObjects(network.ItemDriveTable)
                    local externalItems = BaseNet.filter_by_mode("output", BaseNet.filter_by_type("item", BaseNet.getOperableObjects(network:filter_externalIO_by_valid_signal())))
                    for a = 1, Constants.Settings.RNS_Max_Priority*2 + 1 do
                        local priorityD = itemDrives[a]
                        local priorityE = externalItems[a]
                        if Util.getTableLength(priorityD) > 0 then
                            for _, drive in pairs(priorityD) do
                                local has = drive:has_item(itemstack, true)
                                if has > 0 and self:has_room() == true then
                                    local added = BaseNet.transfer_from_drive_to_inv(drive, player_inv, itemstack, math.min(add, has), true)
                                    add = add - added
                                    port.energy = port.energy - added*Constants.Settings.RNS_PlayerPort_Consumption
                                    if port.energy < Constants.Settings.RNS_PlayerPort_Consumption then return end
                                    if add <= 0 then goto next end
                                end
                            end
                        end
                        if Util.getTableLength(priorityE) > 0 then
                            for _, external in pairs(priorityE) do
                                if external.focusedEntity.thisEntity ~= nil and external.focusedEntity.thisEntity.valid and external.focusedEntity.thisEntity.to_be_deconstructed() == false then
                                    if external.type == "item" and external.focusedEntity.inventory.values ~= nil then
                                        local index = 0
                                        repeat
                                            local ii = Util.next(external.focusedEntity.inventory)
                                            local inv1 = external.focusedEntity.thisEntity.get_inventory(ii.slot)
                                            if inv1 ~= nil and IIO.check_operable_mode(ii.io, "output") then
                                                inv1.sort_and_merge()
                                                local has = EIO.has_item(inv1, itemstack, true)
                                                if has > 0 and self:has_room() == true then
                                                    local added = BaseNet.transfer_from_inv_to_inv(inv1, player_inv, itemstack, nil, math.min(has, add), true, true)
                                                    add = add - added
                                                    port.energy = port.energy - added*Constants.Settings.RNS_PlayerPort_Consumption
                                                    if port.energy < Constants.Settings.RNS_PlayerPort_Consumption then return end
                                                    if add <= 0 then goto next end
                                                end
                                            end
                                            index = index + 1
                                        until index == Util.getTableLength(external.focusedEntity.inventory.values)
                                    end
                                end
                            end
                        end
                    end
                end
                if remove > 0 then
                    local itemDrives = BaseNet.getOperableObjects(network.ItemDriveTable)
                    local externalItems = BaseNet.filter_by_mode("input", BaseNet.filter_by_type("item", BaseNet.getOperableObjects(network:filter_externalIO_by_valid_signal())))
                    for r = 1, Constants.Settings.RNS_Max_Priority*2 + 1 do
                        local priorityD = itemDrives[r]
                        local priorityE = externalItems[r]
                        if Util.getTableLength(priorityD) > 0 then
                            for _, drive in pairs(priorityD) do
                                if drive:has_room() then
                                    local removed = BaseNet.transfer_from_inv_to_drive(player_inv, drive, itemstack, nil, math.min(remove, drive:getRemainingStorageSize()), true, true)
                                    remove = remove - removed
                                    port.energy = port.energy - removed*Constants.Settings.RNS_PlayerPort_Consumption
                                    if port.energy < Constants.Settings.RNS_PlayerPort_Consumption then return end
                                    if remove <= 0 then goto next end
                                end
                            end
                        end
                        if Util.getTableLength(priorityE) > 0 then
                            for _, external in pairs(priorityE) do
                                if external.focusedEntity.thisEntity ~= nil and external.focusedEntity.thisEntity.valid and external.focusedEntity.thisEntity.to_be_deconstructed() == false then
                                    if external.type == "item" and external.focusedEntity.inventory.values ~= nil then
                                        local index = 0
                                        repeat
                                            local ii = Util.next(external.focusedEntity.inventory)
                                            local inv1 = external.focusedEntity.thisEntity.get_inventory(ii.slot)
                                            if inv1 ~= nil and IIO.check_operable_mode(ii.io, "input") then
                                                inv1.sort_and_merge()
                                                if EIO.has_item_room(inv1) == true then
                                                    local removed = BaseNet.transfer_from_inv_to_inv(player_inv, inv1, itemstack, external, remove, true, true)
                                                    remove = remove - removed
                                                    port.energy = port.energy - removed*Constants.Settings.RNS_PlayerPort_Consumption
                                                    if port.energy < Constants.Settings.RNS_PlayerPort_Consumption then return end
                                                    if remove <= 0 then goto next end
                                                end
                                            end
                                            index = index + 1
                                        until index == Util.getTableLength(external.focusedEntity.inventory.values)
                                    end
                                end
                                ::continue::
                            end
                        end
                    end
                end
            end
            ::next::
        end
    end

    local player_trash = self.thisEntity.get_inventory(defines.inventory.character_trash)
    if player_trash ~= nil and not player_trash.is_empty() then
        local player_trash_contents = player_trash.get_contents()
        local itemDrives = BaseNet.getOperableObjects(network.ItemDriveTable)
        local externalItems = BaseNet.filter_by_mode("input", BaseNet.filter_by_type("item", BaseNet.getOperableObjects(network:filter_externalIO_by_valid_signal())))
        for name, count in pairs(player_trash_contents) do
            local itemstack = Util.itemstack_template(name)
            local remove = count
            for r = 1, Constants.Settings.RNS_Max_Priority*2 + 1 do
                local priorityD = itemDrives[r]
                local priorityE = externalItems[r]
                if Util.getTableLength(priorityD) > 0 then
                    for _, drive in pairs(priorityD) do
                        if drive:has_room() then
                            local removed = BaseNet.transfer_from_inv_to_drive(player_trash, drive, itemstack, nil, math.min(remove, drive:getRemainingStorageSize()), true, true)
                            remove = remove - removed
                            port.energy = port.energy - removed*Constants.Settings.RNS_PlayerPort_Consumption
                            if port.energy < Constants.Settings.RNS_PlayerPort_Consumption then return end
                            if remove <= 0 then goto next end
                        end
                    end
                end
                if Util.getTableLength(priorityE) > 0 then
                    for _, external in pairs(priorityE) do
                        if external.focusedEntity.thisEntity ~= nil and external.focusedEntity.thisEntity.valid and external.focusedEntity.thisEntity.to_be_deconstructed() == false then
                            if external.type == "item" and external.focusedEntity.inventory.values ~= nil then
                                local index = 0
                                repeat
                                    local ii = Util.next(external.focusedEntity.inventory)
                                    local inv1 = external.focusedEntity.thisEntity.get_inventory(ii.slot)
                                    if inv1 ~= nil and IIO.check_operable_mode(ii.io, "input") then
                                        inv1.sort_and_merge()
                                        if EIO.has_item_room(inv1) == true then
                                            local removed = BaseNet.transfer_from_inv_to_inv(player_trash, inv1, itemstack, external, remove, true, true)
                                            remove = remove - removed
                                            port.energy = port.energy - removed*Constants.Settings.RNS_PlayerPort_Consumption
                                            if port.energy < Constants.Settings.RNS_PlayerPort_Consumption then return end
                                            if remove <= 0 then goto next end
                                        end
                                    end
                                    index = index + 1
                                until index == Util.getTableLength(external.focusedEntity.inventory.values)
                            end
                        end
                        ::continue::
                    end
                end
            end
            ::next::
        end
    end
end

function RNSP:has_room()
    local inv = self.thisEntity.get_main_inventory()
    for i = 1, #inv do
        if inv[i].count <= 0 then return true end
    end
    if not self.thisEntity.get_main_inventory().is_full() then return true end
    if self.thisEntity.get_main_inventory().is_empty() then return true end
    return false
end

function RNSP:has_empty_slot()
    local inv = self.thisEntity.get_main_inventory()
    for i = 1, #inv do
        if inv[i].count <= 0 then return true end
    end
    return false
end

function RNSP:get_inventory()
    local contents = {}
    local inv = self.thisEntity.get_main_inventory()
    for i = 1, #inv do
        local itemstack = inv[i]
        if itemstack.count <= 0 then goto continue end
        Util.add_or_merge(itemstack, contents)
        ::continue::
    end
    return contents
end

function RNSP:pull_varTable(name)
    return self.varTable[name]
end

function RNSP:remove_varTable(name)
    local exists = self.varTable[name]
    if exists ~= nil then self.varTable[name] = nil end
end

function RNSP:push_varTable(name, value)
    self.varTable[name] = value
end

--Tooltips
function RNSP:getTooltips(guiTable, mainFrame, justCreated)
    
end