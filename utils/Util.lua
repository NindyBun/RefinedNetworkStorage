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

function Util.dataMatches(itemstack1, itemstack2)
	if itemstack1.health ~= itemstack2.health then return false end
	if itemstack1.count ~= itemstack2.count then return false end
	return true
end

function Util.itemstack_equals(itemstack1, itemstack2, limitTags)
	if itemstack1.count <= 0 then
		return itemstack2.count <= 0
	else
		return itemstack2.count > 0 and itemstack1.prototype == itemstack2.prototype and (limitTags and {Util.dataMatches(itemstack1, itemstack2)} or {Util.tagMatches(itemstack1, itemstack2)})[1]
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

function Util.copy_table(t1)
	local t2 = {}
	for k, j in pairs(t1 or {}) do
		t2[k] = j
	end
	return t2
end