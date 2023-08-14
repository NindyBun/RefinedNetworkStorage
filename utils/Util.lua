Util = Util or {}

function Util.safeCall(fName, ...)
	-- Dont use pcall() if the game is in Instrument mode --
	if game.active_mods["debugadapter"] then
		fName(...)
		return
	end
	-- Secure call the Function --
	local result, error = pcall(fName, ...)

	-- Check if the Function was correctly executed --
	if result == false then
		-- Display the Error to all Player --
		game.print(error)
		return false
	end
end

function Util.distance(startP, endP)
	local xS = startP[1] or startP.x
	local yS = startP[2] or startP.y
	local xE = endP[1] or endP.x
	local yE = endP[2] or endP.y
	return math.sqrt( (xS-xE)^2 + (yS-yE)^2 )
end

function Util.direction(object)
	if object.direction == defines.direction.north then
		return 1
	elseif object.direction == defines.direction.east then
		return 2
	elseif object.direction == defines.direction.south then
		return 3
	elseif object.direction == defines.direction.west then
		return 4
	end
end

function Util.axis(object)
	if object.direction == defines.direction.north or object.direction == defines.direction.south then
		return "y"
	elseif object.direction == defines.direction.east or object.direction == defines.direction.west then
		return "x"
	end
end

function Util.next(array)
	array.values = array.values or array
	array.index = array.index or 1
	local value = array.values[array.index]
	array.index = (array.index%Util.getTableLength(array.values))+1
	return value
end

function Util.getTableLength(array)
	local count = 0
	for _, _ in pairs(array) do
		count = count + 1
	end
	return count
end

function Util.tagEquals(tag1, tag2)
	for n, o in pairs(tag1) do
		if tag2[n] ~= nil then
			if type(tag2[n]) ~= "table" then
				if o ~= tag2[n] then return false end
			else
				if not Util.tagEquals(o, tag2[n]) then return false end
			end
		else
			return false
		end
	end
	return true
end

function Util.tagMatches(itemstack1, itemstack2)
	if itemstack1.count <= 0 and itemstack2.count <= 0 then
		return true
	elseif itemstack1.count > 0 and itemstack2.count > 0 then
		if Util.getTableLength(itemstack1.tags) ~= Util.getTableLength(itemstack2.tags) then
			return false
		else
			return Util.tagEquals(itemstack1.tags, itemstack2.tags)
		end
	else
		return false
	end
end

function Util.get_item_name(itemName)
	if game.item_prototypes[itemName] ~= nil then
		return game.item_prototypes[itemName].localised_name
	end
end

function Util.toRNumber(number)
	if number == nil then return 0 end
	local rNumber = number
	local rSuffix = "";
	if number >= 1000000000 then
		rNumber = number/1000000000
		rSuffix = " G"
	elseif number >= 1000000 then
		rNumber = number/1000000
		rSuffix = " M"
	elseif number >= 1000 then
		rNumber = number/1000 
		rSuffix = " k"
	end

	return string.format("%.2f", rNumber):gsub("%.0+$", "") .. rSuffix
end

-- Only takes converted itemstacks
-- Doesn't check linked entity or if an item is modified or it's item number
function Util.itemstack_matches(itemstack1, itemstack2, checkLinked)
	--Need to fix, it doesn't work properly for advanced items
	if type(itemstack1) ~= "table" or type(itemstack2) ~= "table" then return false end

	if game.item_prototypes[itemstack1.cont.name] ~= game.item_prototypes[itemstack2.cont.name] then return false end

	if itemstack1.cont == nil or itemstack2.cont == nil then return false end
	if itemstack1.cont.name and itemstack2.cont.name and game.item_prototypes[itemstack1.cont.name] ~= game.item_prototypes[itemstack2.cont.name] then return false end
	if itemstack1.cont.durability and itemstack2.cont.durability and itemstack1.cont.durability ~= itemstack2.cont.durability then return false end
	if itemstack1.cont.ammo and itemstack2.cont.ammo and itemstack1.cont.ammo ~= itemstack2.cont.ammo then return false end
	if itemstack1.cont.health and itemstack2.cont.health and itemstack1.cont.health ~= itemstack2.cont.health then return false end

	if itemstack1.modified ~= nil and itemstack2.modified ~= nil then
		if itemstack1.modified ~= itemstack2.modified then return false end
		if itemstack1.modified == true and itemstack2.modified == true then
			if itemstack1.linked ~= nil and itemstack2.linked ~= nil then
				if itemstack1.linked ~= "" and itemstack2.linked ~= "" and itemstack1.linked.unit_number ~= itemstack2.linked.unit_number then
					return false
				end
			end
		end
	end

	if itemstack1.label and itemstack2.label and itemstack1.label ~= itemstack2.label then return false end

	if itemstack1.type and itemstack2.type and itemstack1.type == "item-with-tags" and itemstack2.type == "item-with-tags" and Util.tagMatches(itemstack1.cont, itemstack2.cont) == false then return false end

	return true
end

function Util.itemstack_convert(itemstack)
	local converted = {cont={}}

	converted.cont.name = itemstack.name
	converted.cont.count = itemstack.count
	converted.cont.health = itemstack.health
	converted.type = itemstack.type
	
	if itemstack.durability then converted.cont.durability = itemstack.durability end
	if itemstack.type == "ammo" then converted.cont.ammo = itemstack.ammo end
	if itemstack.is_item_with_tags then
		converted.cont.tags = itemstack.tags
		converted.description = itemstack.custom_description
	end

	if itemstack.item_number then converted.id = itemstack.item_number end
	if itemstack.label then converted.label = itemstack.label end
	if itemstack.type == "spidertron-remote" then
		converted.linked = itemstack.connected_entity or ""
		converted.modified = converted.linked ~= "" and true or false
	end
	if itemstack.grid then converted.modified = (itemstack.grid.count() <= 0 and {false} or {true})[1] end
	if itemstack.is_blueprint then converted.modified = itemstack.is_blueprint_setup() end
	if itemstack.is_blueprint_book then converted.modified = ((#itemstack.get_inventory(defines.inventory.item_main) <= 0) and {false} or {true})[1] end
	if itemstack.is_deconstruction_item then
		converted.modified = ((#itemstack.entity_filters > 0 or #itemstack.tile_filters > 0 or itemstack.label or itemstack.trees_and_rocks_only or itemstack.entity_filter_mode ~= 0 or itemstack.tile_filter_mode ~= 0 or itemstack.tile_selection_mode ~= 0) and {true} or {false})[1]
	end
	if itemstack.is_upgrade_item then
		converted.modified = (itemstack.label and {true} or {false})[1]
		if not converted.modified then 
			for i = 1, itemstack.prototype.mapper_count do
				if itemstack.get_mapper(i, "from").name ~= nil or itemstack.get_mapper(i, "to").name ~= nil then
					converted.modified = true
					break
				end
			end
		end
	end

	return converted
end

function Util.add_or_merge(itemstack, list)
	local found = false

	local itemstackC = Util.itemstack_convert(itemstack)

	for i = 1, Util.getTableLength(list) do
		local l = list[i]

		if game.item_prototypes[l.cont.name] ~= game.item_prototypes[itemstackC.cont.name] then goto continue end
		if itemstackC.modified ~= nil and l.modified ~= nil then
			if itemstackC.modified == false and l.modified == false then
				l.cont.count = l.cont.count + itemstackC.cont.count
				l.cont.health = math.min((l.cont.health + itemstackC.cont.health)/2, 1)
				found = true
				goto continue
			else
				if itemstackC.linked ~= nil and l.linked ~= nil then
					if itemstackC.linked ~= "" and l.linked ~= "" and itemstackC.linked.unit_number == l.linked.unit_number then
						l.cont.count = l.cont.count + itemstackC.cont.count
						l.cont.health = math.min((l.cont.health + itemstackC.cont.health)/2, 1)
						found = true
						goto continue
					end
				end
				goto continue
			end
		end
		if itemstackC.type == "item-with-tags" and l.type == "item-with-tags" then
			if Util.tagMatches(l.cont, itemstackC.cont) and l.cont.health < 1 and itemstackC.cont.health < 1 then
				l.cont.count = l.cont.count + itemstackC.cont.count
				l.cont.health = math.min((l.cont.health + itemstackC.cont.health)/2, 1)
				found = true
				goto continue
			else
				goto continue
			end
		end
		if itemstackC.cont.durability and l.cont.durability then
			l.cont.count = l.cont.count + itemstackC.cont.count
			l.cont.durability = math.min((l.cont.durability + itemstackC.cont.durability)/2, game.item_prototypes[itemstackC.cont.name].durability)
			found = true
			goto continue
		end
		if itemstackC.cont.ammo and l.cont.ammo then
			l.cont.count = l.cont.count + itemstackC.cont.count
			l.cont.ammo = math.min((l.cont.ammo + itemstackC.cont.ammo)/2, game.item_prototypes[itemstackC.cont.name].magazine_size)
			found = true
			goto continue
		end
		if l.cont.health == itemstackC.cont.health then
			l.cont.count = l.cont.count + itemstackC.cont.count
			l.cont.health = math.min((l.cont.health + itemstackC.cont.health)/2, 1)
			found = true
			goto continue
		end
		
		::continue::
	end

	if not found then
		table.insert(list, itemstackC)
		return
	end
end