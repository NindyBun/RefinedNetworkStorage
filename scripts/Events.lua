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
    
    if entName == Constants.NetworkCables.Cable.item.name and type ~= "entity-ghost" then
        entName = Constants.NetworkCables.Cable.entity.name
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

function Event.ghost(event)

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