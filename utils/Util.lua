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

Util.OperatorFunctions = {
    [">"] = function (filter, number)
        return (filter > number and {true} or {false})[1]
    end,
    ["<"] = function (filter, number)
        return (filter < number and {true} or {false})[1]
    end,
    ["="] = function (filter, number)
        return (filter == number and {true} or {false})[1]
    end,
    [">="] = function (filter, number)
        return (filter >= number and {true} or {false})[1]
    end,
    ["<="] = function (filter, number)
        return (filter <= number and {true} or {false})[1]
    end,
    ["!="] = function (filter, number)
        return (filter ~= number and {true} or {false})[1]
    end
}

function Util.positions_match(posA, posB)
	if posA.x == posB.x and posA.y == posB.y then return true end
	return false
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

function Util.next_non_nil(array)
	array.values = array.values or array
	array.index = array.index or 1
	local value = ""
	local initial = array.index
	repeat
		value = array.values[array.index]
		array.index = (array.index%Util.getTableLength(array.values))+1
	until (value ~= "" and value ~= nil) or initial == array.index
	return value
end

function Util.next(array)
	array.values = array.values or array
	array.index = array.index or 1
	local value = array.values[array.index]
	array.index = (array.index%Util.getTableLength(array.values))+1
	return value
end

function Util.next_index(arrayTable)
	local old = arrayTable.index
	local max = arrayTable.max
	local new = (old % max) + 1
	arrayTable.index = new
end

function Util.getTableLength(array)
	local count = 0
	for _, _ in pairs(array) do
		count = count + 1
	end
	return count
end

function Util.getTableLength_non_nil(array)
	local count = 0
	for _, v in pairs(array) do
		if type(v) == "table" then
			if #v > 0 then
				count = count + #v
			else
				count = count + Util.getTableLength_non_nil(v)
			end
		elseif v ~= nil and v ~= "" then
			count = count + 1
		end
	end
	return count
end

function Util.copy(array)
	local copy = {}
	for k, v in pairs(array) do
		if type(v) == "table" then
			copy[k] = Util.copy(v)
		else
			copy[k] = v
		end
	end
	return copy
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

function Util.get_fluid_name(fluidName)
	if game.fluid_prototypes[fluidName] ~= nil then
		return game.fluid_prototypes[fluidName].localised_name
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
function Util.itemstack_matches(itemstack_data, itemstack_to_be_checked, allowMetadata)
	allowMetadata = allowMetadata or false

	if itemstack_data.cont == nil or itemstack_to_be_checked.cont == nil then return false end

	if game.item_prototypes[itemstack_data.cont.name] ~= game.item_prototypes[itemstack_to_be_checked.cont.name] then return false end

	if itemstack_data.cont == nil or itemstack_to_be_checked.cont == nil then return false end
	if itemstack_data.cont.name and itemstack_to_be_checked.cont.name and game.item_prototypes[itemstack_data.cont.name] ~= game.item_prototypes[itemstack_to_be_checked.cont.name] then return false end

	if itemstack_data.cont.durability and itemstack_to_be_checked.cont.durability then
		if itemstack_data.cont.durability ~= itemstack_to_be_checked.cont.durability then
			if not allowMetadata then return false end
		end
	end
	if itemstack_data.cont.ammo and itemstack_to_be_checked.cont.ammo then
		if itemstack_data.cont.ammo ~= itemstack_to_be_checked.cont.ammo then
			if not allowMetadata then return false end
		end
	end
	--if itemstack_data.cont.health and itemstack_to_be_checked.cont.health and itemstack_data.cont.health ~= itemstack_to_be_checked.cont.health then
	--	if not allowMetadata then return false end
	--end
	if itemstack_data.modified ~= nil and itemstack_to_be_checked.modified ~= nil then
		if not allowMetadata then
			if itemstack_data.modified ~= itemstack_to_be_checked.modified then return false end
			if itemstack_data.modified == true and itemstack_to_be_checked.modified == true then
				if itemstack_data.cont.health and itemstack_to_be_checked.cont.health and itemstack_data.cont.health ~= itemstack_to_be_checked.cont.health and not allowMetadata then return false end
				if itemstack_data.label and itemstack_to_be_checked.label and itemstack_data.label ~= itemstack_to_be_checked.label and not allowMetadata then return false end
				if itemstack_data.linked ~= nil and itemstack_to_be_checked.linked ~= nil then
					if itemstack_data.linked ~= "" and itemstack_to_be_checked.linked ~= "" and itemstack_data.linked.unit_number ~= itemstack_to_be_checked.linked.unit_number then
						return false
					end
				end
			end
		end
	end

	if itemstack_data.type and itemstack_to_be_checked.type and itemstack_data.type == "item-with-tags" and itemstack_to_be_checked.type == "item-with-tags" and Util.tagMatches(itemstack_data.cont, itemstack_to_be_checked.cont) == false and not allowMetadata then return false end

	return true
end

function Util.itemstack_template(name)
	local item_prototype = game.item_prototypes[name]
	local template = {cont={}}
	template.modified = false
	template.cont.name = item_prototype.name
	template.cont.count = 1
	template.cont.health = 1
	template.cont.tags = {}
	template.type = item_prototype.type
	if item_prototype.durability then template.cont.durability = item_prototype.durability end
	if item_prototype.type == "ammo" then template.cont.ammo = item_prototype.magazine_size end
	return template
end

function Util.itemstack_convert(itemstack)
	local converted = {cont={}}

	converted.modified = false
	converted.cont.name = itemstack.name
	converted.cont.count = itemstack.count
	converted.cont.health = itemstack.health
	converted.type = itemstack.type
	
	if itemstack.durability then converted.cont.durability = itemstack.durability end
	if itemstack.type == "ammo" then converted.cont.ammo = itemstack.ammo end
	if itemstack.is_item_with_tags then
		converted.cont.tags = itemstack.tags
		if Util.getTableLength(converted.cont.tags) ~= 0 then converted.modified = true end
		converted.description = itemstack.custom_description
		if converted.description ~= "" then converted.modified = true end
	end

	if itemstack.item_number then converted.id = itemstack.item_number end
	if itemstack.type == "spidertron-remote" then
		converted.linked = itemstack.connected_entity or ""
		converted.modified = ((converted.linked ~= "" or converted.modified == true) and {true} or {false})[1]
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

	if itemstack.label ~= nil then
		converted.label = itemstack.label
		converted.modified = true
	end

	if itemstack.health ~= 1 then
		converted.modified = true
	end

	return converted
end

function Util.add_or_merge(itemstack, list, bypass)
	local found = false
	bypass = bypass or false

	local itemstackC = bypass and itemstack or Util.itemstack_convert(itemstack)

	for i = 1, Util.getTableLength(list) do
		local l = list[i]

		--if game.item_prototypes[l.cont.name] ~= game.item_prototypes[itemstackC.cont.name] then goto continue end
		if Util.itemstack_matches(l, itemstackC) then
			l.cont.count = l.cont.count + itemstackC.cont.count
			--l.cont.health = math.min((l.cont.health + itemstackC.cont.health)/2, 1)
			--if l.cont.durability then
			--	l.cont.durability = math.min((l.cont.durability + itemstackC.cont.durability)/2, game.item_prototypes[itemstackC.cont.name].durability)
			--end
			--if l.cont.ammo then
			--	l.cont.ammo = math.min((l.cont.ammo + itemstackC.cont.ammo)/2, game.item_prototypes[itemstackC.cont.name].magazine_size)
			--end
			found = true
		end
		--[[if itemstackC.modified ~= nil and l.modified ~= nil then
			if itemstackC.modified == false and l.modified == false then
				l.cont.health = math.min((l.cont.health + itemstackC.cont.health)/2, 1)
				found = true
				goto continue
			else
				if itemstackC.linked ~= nil and l.linked ~= nil then
					if itemstackC.linked ~= "" and l.linked ~= "" and itemstackC.linked.unit_number == l.linked.unit_number then
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
				l.cont.health = math.min((l.cont.health + itemstackC.cont.health)/2, 1)
				found = true
				goto continue
			else
				goto continue
			end
		end
		if itemstackC.cont.durability and l.cont.durability then
			l.cont.durability = math.min((l.cont.durability + itemstackC.cont.durability)/2, game.item_prototypes[itemstackC.cont.name].durability)
			found = true
			goto continue
		end
		if itemstackC.cont.ammo and l.cont.ammo then
			l.cont.ammo = math.min((l.cont.ammo + itemstackC.cont.ammo)/2, game.item_prototypes[itemstackC.cont.name].magazine_size)
			found = true
			goto continue
		end
		if l.cont.health == itemstackC.cont.health then
			l.cont.health = math.min((l.cont.health + itemstackC.cont.health)/2, 1)
			found = true
			goto continue
		end
		
		::continue::
		if found then
			l.cont.count = l.cont.count + itemstackC.cont.count
		end]]
		::continue::
	end

	if not found then
		if itemstackC.cont.durability and itemstackC.cont.count > 1 and itemstackC.cont.durability ~= game.item_prototypes[itemstackC.cont.name].durability then
			if bypass == false then
				local type1 = Util.itemstack_convert(itemstack)
				type1.cont.count = 1
				local type2 = Util.itemstack_convert(itemstack)
				type2.cont.count = type2.cont.count - 1
				type2.cont.durability = game.item_prototypes[type2.cont.name].durability
				Util.add_or_merge(type1, list, true)
				Util.add_or_merge(type2, list, true)
			else
				local type2 = Util.itemstack_template(itemstackC.cont.name)
				type2.cont.count = itemstackC.cont.count - 1
				itemstackC.cont.count = 1
				Util.add_or_merge(itemstackC, list, true)
				Util.add_or_merge(type2, list, true)
			end
			return
		end
		if itemstackC.cont.ammo and itemstackC.cont.count > 1 and itemstackC.cont.ammo ~= game.item_prototypes[itemstackC.cont.name].magazine_size then
			if bypass == false then
				local type1 = Util.itemstack_convert(itemstack)
				type1.cont.count = 1
				local type2 = Util.itemstack_convert(itemstack)
				type2.cont.count = type2.cont.count - 1
				type2.cont.ammo = game.item_prototypes[type2.cont.name].magazine_size
				Util.add_or_merge(type1, list, true)
				Util.add_or_merge(type2, list, true)
			else
				local type2 = Util.itemstack_template(itemstackC.cont.name)
				type2.cont.count = itemstackC.cont.count - 1
				itemstackC.cont.count = 1
				Util.add_or_merge(itemstackC, list, true)
				Util.add_or_merge(type2, list, true)
			end
			return
		end
		table.insert(list, itemstackC)
		return
	end
end

function Util.add_list_into_table(tab, list)
	for _, i in pairs(list) do
		table.insert(tab, i)
	end
end

function Util.filter_accepts_item(filter, mode, itemname)
	if mode == "whitelist" then
		return (filter[itemname] ~= nil and {true} or {false})[1]
	elseif mode == "blacklist" then
		return (filter[itemname] ~= nil and {false} or {true})[1]
	end

	return false
end

function Util.filter_accepts_fluid(filter, mode, fluidname)
	if mode == "whitelist" then
		return (filter[fluidname] ~= nil and {true} or {false})[1]
	elseif mode == "blacklist" then
		return (filter[fluidname] ~= nil and {false} or {true})[1]
	end

	return false
end