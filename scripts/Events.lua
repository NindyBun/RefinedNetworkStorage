function Event.initPlayer(event)
	local player = getPlayer(event.player_index)
	if player == nil then return end
	if player.controller_type == defines.controllers.cutscene then return end
	if getRNSPlayer(player.name) == nil then
		global.playerTable[player.name] = RNSP:new(player)
	end
end

function Event.tick(event)
    UpdateSys.update(event)
end

function Event.placed(event)
    local entity = event.created_entity or event.entity or event.destination
    if entity == nil or entity.last_user == nil then return end
    
    local type = entity.type
    local entName = type == "entity-ghost" and entity.ghost_name or entity.name
    local destroyedEntDir = nil
    if entName == Constants.NetworkCables.Cable.item.name and type ~= "entity-ghost" then
        entName = Constants.NetworkCables.Cable.entity.name
        local surf = entity.surface
        local ply = entity.last_user
        local pos = entity.position
        local fr = entity.force
        entity.destroy()
        entity = surf.create_entity{name=entName, position=pos, force=fr, player=ply}
    elseif entName == Constants.NetworkController.item.name and type ~= "entity-ghost" then
        entName = Constants.NetworkController.entity.name
        local surf = entity.surface
        local ply = entity.last_user
        local pos = entity.position
        local fr = entity.force
        entity.destroy()
        entity = surf.create_entity{name=entName, position=pos, force=fr, player=ply}
    elseif entName == Constants.NetworkCables.IO.item.iName and type ~= "entity-ghost" then
        entName = Constants.NetworkCables.IO.item.eName
        local surf = entity.surface
        local ply = entity.last_user
        local pos = entity.position
        local fr = entity.force
        destroyedEntDir = entity.direction
        entity.destroy()
        entity = surf.create_entity{name=entName, position=pos, force=fr, player=ply}
    end

    local objInfo = global.objectTables[entName]

    if type == "entity-ghost" then return end

    if objInfo ~= nil and objInfo.tag ~= nil then
        local obj = _G[objInfo.tag]:new(entity)
        if objInfo.tableName ~= nil then
            global[objInfo.tableName][entity.unit_number] = obj
        end
        if event.stack ~= nil and event.stack.valid_for_read == true and event.stack.type == "item-with-tags" then
			local tags = event.stack.get_tag(Constants.Settings.RNS_Tag)
			if tags ~= nil then
				obj:DataConvert_ItemToEntity(tags)
			end
		end
		-- Validate properties taken from Blueprint or Item Tags
		if obj.validate then
			obj:validate()
		end

        if obj.initializeDataOnCreated and destroyedEntDir ~= nil then
            obj:initializeDataOnCreated(destroyedEntDir)
        end
        
    end
end

function Event.removed(event)
    local entity = event.entity
    if entity == nil or entity.valid == false then return end
    
    local obj = global.entityTable[entity.unit_number]
    if obj == nil then return end

    if obj.DataConvert_EntityToItem ~= nil and event.buffer ~= nil and event.buffer[1] ~= nil then
        obj:DataConvert_EntityToItem(event.buffer[1])
    end
    
    obj:remove()
    
    local objInfo = global.objectTables[entity.name]
    if objInfo == nil or objInfo.tableName == nil then return end
    global[objInfo.tableName][entity.unit_number] = nil

end

function Event.ghost(event)

end