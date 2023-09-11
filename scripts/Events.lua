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
    
    if string.match(entName, "RNS_NetworkCable_I") ~= nil and type ~= "entity-ghost" then
        --entName = Constants.NetworkCables.Cable.entity.name
        for _, color in pairs(Constants.NetworkCables.Cables) do
            if entName == color.cable.item.name then
                entName = color.cable.entity.name
            end
        end
        local surf = entity.surface
        local ply = entity.last_user
        local pos = entity.position
        local fr = entity.force
        local health = entity.health
        entity.destroy()
        entity = surf.create_entity{name=entName, position=pos, force=fr, player=ply}
        entity.health = health
    elseif entName == Constants.NetworkController.itemEntity.name and type ~= "entity-ghost" then
        entName =  Constants.NetworkController.slateEntity.name
        local surf = entity.surface
        local ply = entity.last_user
        local pos = entity.position
        local fr = entity.force
        local health = entity.health
        entity.destroy()
        entity = surf.create_entity{name=entName, position=pos, force=fr, player=ply}
        entity.health = health
    elseif entName == Constants.NetworkCables.itemIO.itemEntity.name and type ~= "entity-ghost" then
        entName = Constants.NetworkCables.itemIO.slateEntity.name
        local surf = entity.surface
        local ply = entity.last_user
        local pos = entity.position
        local fr = entity.force
        local dir = entity.direction
        local health = entity.health
        entity.destroy()
        entity = surf.create_entity{name=entName, position=pos, force=fr, player=ply, direction=dir}
        entity.health = health
    elseif entName == Constants.NetworkCables.fluidIO.itemEntity.name and type ~= "entity-ghost" then
        entName = Constants.NetworkCables.fluidIO.slateEntity.name
        local surf = entity.surface
        local ply = entity.last_user
        local pos = entity.position
        local fr = entity.force
        local dir = entity.direction
        local health = entity.health
        entity.destroy()
        entity = surf.create_entity{name=entName, position=pos, force=fr, player=ply, direction=dir}
        entity.health = health
    elseif entName == Constants.NetworkCables.externalIO.itemEntity.name and type ~= "entity-ghost" then
        entName = Constants.NetworkCables.externalIO.slateEntity.name
        local surf = entity.surface
        local ply = entity.last_user
        local pos = entity.position
        local fr = entity.force
        local dir = entity.direction
        local health = entity.health
        entity.destroy()
        entity = surf.create_entity{name=entName, position=pos, force=fr, player=ply, direction=dir}
        entity.health = health
    elseif entName == Constants.NetworkCables.wirelessTransmitter.itemEntity.name and type ~= "entity-ghost" then
        entName = Constants.NetworkCables.wirelessTransmitter.slateEntity.name
        local surf = entity.surface
        local ply = entity.last_user
        local pos = entity.position
        local fr = entity.force
        local health = entity.health
        entity.destroy()
        entity = surf.create_entity{name=entName, position=pos, force=fr, player=ply}
        entity.health = health
    end

    local objInfo = global.objectTables[entName]

    game.print(serpent.block(event.tags))
    if type == "entity-ghost" then return end

    if objInfo ~= nil and objInfo.tag ~= nil then
        local obj = _G[objInfo.tag]:new(entity)
        if objInfo.tableName ~= nil then
            global[objInfo.tableName][entity.unit_number] = obj
        end
        if event.tags and obj.deserialize_settings then
			obj:deserialize_settings(event.tags)
		end
        if event.stack ~= nil and event.stack.valid_for_read == true and event.stack.type == "item-with-tags" then
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
		if gui ~= nil and gui.valid == true and gui.get_mod() == "RefinedNetworkStorage" then
			gui.destroy()
		end
	end
    getRNSPlayer(event.player_index).GUI = {}
    player.opened = nil
end

function Event.onBlueprint(event)
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
		local tags = ((global.entityTable[ent.unit_number] ~= nil and global.entityTable[ent.unit_number].serialize_settings ~= nil) and {global.entityTable[ent.unit_number]:serialize_settings()} or {nil})[1]
        if tags ~= nil then
			for tag, value in pairs(tags) do
				blueprint.set_blueprint_entity_tag(index, tag, value)
			end
		end
	end
end

function Event.onSettingsPasted(event)
    if event.source == nil or event.source.valid == false then return end
	if event.destination == nil or event.destination.valid == false then return end

	local o1 = global.entityTable[event.source.unit_number]
	local o2 = global.entityTable[event.destination.unit_number]

	if o1 == nil then return end
	if o2 == nil then return end
	if o1.thisEntity.name ~= o2.thisEntity.name then return end

	if o2.copy_settings ~= nil then
		o2:copy_settings(o1)
	end
end