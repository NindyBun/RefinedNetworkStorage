function Event.initPlayer(event)
	local player = getPlayer(event.player_index)
	if player == nil then return end
	if player.controller_type == defines.controllers.cutscene then return end
	if getRNSPlayer(player.name) == nil then
		global.PlayerTable[player.name] = RNSP:new(player)
	end
end

function Event.tick(event)
    UpdateSys.update(event)
    GUI.update()
end

function Event.placed(event)
    local entity = event.created_entity or event.entity or event.destination
    if entity == nil or entity.last_user == nil then return end
    
    local type = entity.type
    local entName = type == "entity-ghost" and entity.ghost_name or entity.name

    local objInfo = global.objectTables[entName]

    if type == "entity-ghost" then return end

    if objInfo ~= nil and objInfo.tag ~= nil then
        local obj = _G[objInfo.tag]:new(entity)
        if objInfo.tableName ~= nil then
            global[objInfo.tableName][entity.unit_number] = obj
        end
        if event.tags and obj.deserialize_settings then
			obj:deserialize_settings(event.tags)
		end
        if event.stack ~= nil and event.stack.valid_for_read == true and event.stack.type == "item-with-tags" and obj.DataConvert_ItemToEntity ~= nil then
			local contents = event.stack.get_tag(Constants.Settings.RNS_Tag)
			if contents ~= nil then
				obj:DataConvert_ItemToEntity(contents)
			end
		end
		-- Validate properties taken from Blueprint or Item Tags
		if obj.validate then
			obj:validate()
		end
        
    end
end

function Event.removed(event)
    local entity = event.entity
    if entity == nil or entity.valid == false then return end
    
    local obj = global.entityTable[entity.unit_number]
    if obj == nil then return end

    if event.buffer ~= nil and event.buffer[1] ~= nil then
        local itemStack = event.buffer[1]
        itemStack.health = entity.health/entity.prototype.max_health
    end

    if obj.DataConvert_EntityToItem ~= nil and event.buffer ~= nil and event.buffer[1] ~= nil then
        obj:DataConvert_EntityToItem(event.buffer[1])
    end
    
    obj:remove()
    
    local objInfo = global.objectTables[entity.name]
    if objInfo == nil or objInfo.tableName == nil then return end
    global[objInfo.tableName][entity.unit_number] = nil

end

function Event.rotated(event)
    if global.entityTable[event.entity.unit_number] == nil then return end
    local obj = global.entityTable[event.entity.unit_number]
    if obj.generateModeIcon then
        obj:generateModeIcon()
    end
	if obj.createArms then
		obj:createArms()
		BaseNet.postArms(obj)
	end
	if obj.init_cache then
		
	end
	if obj.networkController ~= nil and BaseNet.exists_in_network(obj.networkController, obj.entID) then
		BaseNet.update_network_controller(obj.networkController, obj.entID)
	end
end

function Event.changed_selection(event)
    if event.last_entity == nil then return end
    if global.entityTable[event.last_entity.unit_number] == nil then return end
    local obj = global.entityTable[event.last_entity.unit_number]
    if obj.toggleHoverIcon then
        obj:toggleHoverIcon(false)
    end
end

function Event.clear_gui(event)
    local player = getPlayer(event.player_index)
    for _, gui in pairs(player.gui.screen.children) do
		if gui ~= nil and gui.valid == true and "__" .. gui.get_mod() .. "__" == Constants.MOD_ID then
			gui.destroy()
		end
	end
    getRNSPlayer(event.player_index).GUI = {}
    player.opened = nil
end

function Event.onBlueprintSetup(event)
    local player = game.players[event.player_index]
	local mapping = event.mapping.get()
	local blueprint = player.blueprint_to_setup
	if blueprint.valid_for_read == false then
		local cursor = player.cursor_stack
		if cursor and cursor.valid_for_read and cursor.name == "blueprint" then
			blueprint = cursor
			--return
		end
	end
	if blueprint == nil or blueprint.valid_for_read == false then return end

	for index, ent in pairs(mapping) do
		if ent == nil or ent.unit_number == nil then goto continue end
		local tags = ((global.entityTable[ent.unit_number] ~= nil and global.entityTable[ent.unit_number].serialize_settings ~= nil) and {global.entityTable[ent.unit_number]:serialize_settings()} or {nil})[1]
        if tags ~= nil then
            getRNSPlayer(event.player_index):push_varTable("BlueprintTags", tags)
			for tag, value in pairs(tags) do
				blueprint.set_blueprint_entity_tag(index, tag, value)
			end
		end
		::continue::
	end
end

function Event.onBlueprintConfigured(event)
    local player = game.players[event.player_index]
	local blueprint = player.blueprint_to_setup
	if blueprint.valid_for_read == false then
		local cursor = player.cursor_stack
		if cursor and cursor.valid_for_read and cursor.name == "blueprint" then
			blueprint = cursor
			--return
		end
	end
	if blueprint == nil or blueprint.valid_for_read == false then return end

	for index, ent in pairs(getRNSPlayer(event.player_index):pull_varTable("BlueprintTags")) do
		if ent == nil or ent.unit_number == nil then goto continue end --Will throw a "boolean value" error. Not something to worry about
		local tags = ((global.entityTable[ent.unit_number] ~= nil and global.entityTable[ent.unit_number].serialize_settings ~= nil) and {global.entityTable[ent.unit_number]:serialize_settings()} or {nil})[1]
        if tags ~= nil then
			for tag, value in pairs(tags) do
				blueprint.set_blueprint_entity_tag(index, tag, value)
			end
		end
		::continue::
	end
    getRNSPlayer(event.player_index):remove_varTable("BlueprintTags")
end

function Event.onSettingsPasted(event)
    if event.source == nil or event.source.valid == false then return end
	if event.destination == nil or event.destination.valid == false then return end

	local o1 = global.entityTable[event.source.unit_number]
	local o2 = global.entityTable[event.destination.unit_number]

	if o1 == nil then return end
	if o2 == nil then return end

	if o2.copy_settings == nil then return end
    if o1.thisEntity.name == o2.thisEntity.name then
		o2:copy_settings(o1)
    end
end

function printResearchBonus(type)
	if type == "item" then
		game.print({"gui-description.RNS_ItemTransferBonus", Constants.Settings.RNS_BaseItemIO_TransferCapacity*15*global.IIOMultiplier})
	elseif type == "fluid" then
		game.print({"gui-description.RNS_FluidTransferBonus", Constants.Settings.RNS_BaseFluidIO_TransferCapacity*12*global.FIOMultiplier})
	elseif type == "wireless" then
		game.print({"gui-description.RNS_WirelessRangeBonus", global.WTRangeMultiplier ~= -1 and Constants.Settings.RNS_Default_WirelessGrid_Distance*global.WTRangeMultiplier or "infinite"})
	end
end

function Event.finished_research(event)
	if event.research == nil then return end
	local name, _ = string.gsub(event.research.name, "%-", "_")
	local level = event.research.level
	if string.match(name, "RNS_item_transfer_bonus") ~= nil then
		local old = global.IIOMultiplier
		global.IIOMultiplier = string.match(name, "infinite") == nil and Constants.Settings.Multipliers.IIO[level] or (Constants.Settings.Multipliers.IIO[8] + 2*level)
		for _, obj in pairs(global["ItemIOTable"]) do
			obj.stackSize = obj.stackSize < old and obj.stackSize or global.IIOMultiplier
		end
		--printResearchBonus("item")
		return
	end
	if string.match(name, "RNS_fluid_transfer_bonus") ~= nil then
		local old = global.FIOMultiplier
		global.FIOMultiplier = string.match(name, "infinite") == nil and Constants.Settings.Multipliers.FIO[level] or (Constants.Settings.Multipliers.FIO[8] + 2*level)
		for _, obj in pairs(global["FluidIOTable"]) do
			obj.fluidSize = obj.fluidSize < old and obj.fluidSize or global.FIOMultiplier
		end
		--printResearchBonus("fluid")
		return
	end
	if string.match(name, "RNS_wireless_range_bonus") ~= nil then
		global.WTRangeMultiplier = string.match(name, "inf") == nil and Constants.Settings.Multipliers.WT[level] or -1
		--printResearchBonus("wireless")
		return
	end
end

function Event.reversed_research(event)
	if event.research == nil then return end
	local name, _ = string.gsub(event.research.name, "%-", "_")
	local level = event.research.level
	if string.match(name, "RNS_item_transfer_bonus") ~= nil then
		global.IIOMultiplier = string.match(name, "infinite") == nil and (Constants.Settings.Multipliers.IIO[level-1] or 1) or (Constants.Settings.Multipliers.IIO[8] + (2*(level-1) == 0 and 0 or 2*(level-1)))
		--printResearchBonus("item")
		return
	end
	if string.match(name, "RNS_fluid_transfer_bonus") ~= nil then
		global.FIOMultiplier = string.match(name, "infinite") == nil and (Constants.Settings.Multipliers.FIO[level-1] or 1) or (Constants.Settings.Multipliers.FIO[8] + (2*(level-1) == 0 and 0 or 2*(level-1)))
		--printResearchBonus("fluid")
		return
	end
	if string.match(name, "RNS_wireless_range_bonus") ~= nil then
		global.WTRangeMultiplier = string.match(name, "inf") == nil and Constants.Settings.Multipliers.WT[level-1] or 1
		--printResearchBonus("wireless")
		return
	end
end