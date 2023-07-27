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

function Util.itemstack_matches(itemstack1, itemstack2)
	if game.item_prototypes[itemstack1.name or itemstack1.cont.name] ~= game.item_prototypes[itemstack2.name or itemstack2.cont.name] then return false end
	if itemstack1.id ~= nil and itemstack2.id ~= nil and itemstack1.id == itemstack2.id then return true end
	if (itemstack1.is_item_with_tags or itemstack1.stack.is_item_with_tags) and (itemstack2.is_item_with_tags or itemstack2.stack.is_item_with_tags) then
		if Util.tagMatches(itemstack1.cont or itemstack1, itemstack2.cont or itemstack2) and (itemstack1.health or itemstack1.cont.health) == (itemstack2.health or itemstack2.cont.health) then return true end
	end
	if (itemstack1.durability or itemstack1.cont.durability) and (itemstack2.durability or itemstack2.cont.durability) then
		if (itemstack1.durability or itemstack1.cont.durability) == (itemstack2.durability or itemstack2.cont.durability) then return true end
	end
	if (itemstack1.ammo or itemstack1.cont.ammo) and (itemstack2.ammo or itemstack2.cont.ammo) then
		if (itemstack1.ammo or itemstack1.cont.ammo) == (itemstack2.ammo or itemstack2.cont.ammo) then return true end
	end
	if (itemstack1.health or itemstack1.cont.health) and (itemstack2.health or itemstack2.cont.health) then
		if (itemstack1.health or itemstack1.cont.health) == (itemstack2.health or itemstack2.cont.health) then return true end
	end
	return false
end

function Util.add_or_merge(itemstack, list)
	local found = false

	local n = itemstack.name
	local p = itemstack.prototype
	local h = itemstack.health
	local c = itemstack.count
	local d = itemstack.is_repair_tool and itemstack.durability or nil
	local t = itemstack.is_item_with_tags and itemstack.tags or {}
	local a = p.type == "ammo" and itemstack.ammo or nil

	
	if itemstack.is_blueprint or itemstack.is_blueprint_book or itemstack.is_upgrade_item or itemstack.is_deconstruction_item then
		table.insert(list, {id=itemstack.item_number or nil, stack=itemstack, cont={name=n, count=c, health=h, data=itemstack.export_stack(), label=itemstack.label}})
		return
	elseif itemstack.type == "spidertron-remote" then
		table.insert(list, {id=itemstack.item_number or nil, stack=itemstack, cont={name=n, count=c, health=h, linked=itemstack.connected_entity or nil}})
		return
	elseif itemstack.grid ~= nil then
		table.insert(list, {id=itemstack.item_number or nil, stack=itemstack, cont={name=n, count=c, health=h}})
		return
	end

	for i = 1, Util.getTableLength(list) do
		local l = list[i]

		if game.item_prototypes[l.cont.name] ~= p then goto continue end
		if itemstack.is_item_with_tags then
			if Util.tagMatches(l.cont, itemstack) and l.cont.health < 1 and h < 1 then
				l.cont.count = l.cont.count + c
				l.cont.health = math.min((l.cont.health + h)/2, 1)
				found = true
				goto continue
			else
				goto continue
			end
		end
		if d ~= nil and l.cont.durability ~= nil then
			l.cont.count = l.cont.count + c
			l.cont.durability = math.min((l.cont.durability + d)/2, p.durability)
			found = true
			goto continue
		end
		if a ~= nil and l.cont.ammo ~= nil then
			l.cont.count = l.cont.count + c
			l.cont.ammo = math.min((l.cont.ammo + a)/2, p.magazine_size)
			found = true
			goto continue
		end
		if l.cont.health == h then
			l.cont.count = l.cont.count + c
			l.cont.health = math.min((l.cont.health + h)/2, 1)
			found = true
			goto continue
		end
		
		::continue::
	end

	if not found then
		table.insert(list, {cont={name=n, count=c, health=h, ammo=a, durability=d, tags=t}})
		return
	end
end