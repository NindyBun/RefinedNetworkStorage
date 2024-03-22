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
            
            if not self.thisEntity.can_reach_entity(obj.thisEntity) then
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
                
                local itemstack = Itemstack.create_template(name)

                if add > 0 then
                    local worked = add - BaseNet.transfer_from_network_to_inv(network, {thisEntity = self.thisEntity,inventory = {input = {index = 1, max = 1, values = {defines.inventory.character_main}}}}, itemstack, add, true, false)
                    port.energy = port.energy - worked*Constants.Settings.RNS_PlayerPort_Consumption
                    if port.energy < Constants.Settings.RNS_PlayerPort_Consumption then return end
                end
                if remove > 0 then
                    local worked = remove - BaseNet.transfer_from_inv_to_network(network, {thisEntity = self.thisEntity,inventory = {output = {index = 1, max = 1, values = {defines.inventory.character_main}}}}, itemstack, nil, "whitelist", remove, true, false)
                    port.energy = port.energy - worked*Constants.Settings.RNS_PlayerPort_Consumption
                    if port.energy < Constants.Settings.RNS_PlayerPort_Consumption then return end
                end
            end
        end
    end

    local player_trash = self.thisEntity.get_inventory(defines.inventory.character_trash)
    if player_trash ~= nil and not player_trash.is_empty() then
        local player_trash_contents = player_trash.get_contents()
        for name, count in pairs(player_trash_contents) do
            local itemstack = Itemstack.create_template(name)
            local remove = math.min(count*Constants.Settings.RNS_PlayerPort_Consumption, port.energy)/Constants.Settings.RNS_PlayerPort_Consumption
            local worked = remove - BaseNet.transfer_from_inv_to_network(network, {thisEntity = self.thisEntity,inventory = {output = {index = 1, max = 1, values = {defines.inventory.character_trash}}}}, itemstack, nil, "whitelist", remove, true, false)
            port.energy = port.energy - worked*Constants.Settings.RNS_PlayerPort_Consumption
            if port.energy < Constants.Settings.RNS_PlayerPort_Consumption then return end
        end
    end
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