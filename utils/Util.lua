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
	if posA == nil or posB == nil then return false end
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
			count = count + Util.getTableLength_non_nil(v)
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

function Util.add_list_into_table(tab, list)
	for _, i in pairs(list) do
		table.insert(tab, i)
	end
end

function Util.item_add_list_into_table(tab, list)
	list = list:copy()
	for _, v in pairs(tab) do
		if v:compare_itemstacks(list, true, true) then
			v.count = v.count + list.count
			return
		end
	end
	if list.ammo ~= nil and list.count > 1 and list.ammo ~= game.item_prototypes[list.name].magazine_size then
		Util.item_add_list_into_table(tab, list:split(list, 1, true))
		if list.count > 0 then
			Util.item_add_list_into_table(tab, list)
		end
		return
	end
	if list.durability ~= nil and list.count > 1 and list.durability ~= game.item_prototypes[list.name].durability then
		Util.item_add_list_into_table(tab, list:split(list, 1, true))
		if list.count > 0 then
			Util.item_add_list_into_table(tab, list)
		end
		return
	end
	table.insert(tab, list)
end

function Util.fluid_add_list_into_table(tab, list)
	list = {
		name = list.name,
		amount = list.amount,
		temperature = list.temperature
	}
	for _, v in pairs(tab) do
		if v.name == list.name then
			v.amount = v.amount + list.amount
			v.temperature = (v.temperature * v.amount + list.amount * (list.temperature or game.fluid_prototypes[list.name].default_temperature)) / (v.amount + list.amount)
			return
		end
	end
	table.insert(tab, list)
end

function Util.filter_accepts_item(filter, mode, itemname)
	if filter == nil then return true end
	if mode == "whitelist" then
		return (filter[itemname] ~= nil and {true} or {false})[1]
	elseif mode == "blacklist" then
		return (filter[itemname] ~= nil and {false} or {true})[1]
	end

	return false
end

function Util.filter_accepts_fluid(filter, mode, fluidname)
	if filter == nil then return true end
	if mode == "whitelist" then
		return (filter[fluidname] ~= nil and {true} or {false})[1]
	elseif mode == "blacklist" then
		return (filter[fluidname] ~= nil and {false} or {true})[1]
	end

	return false
end

function Util.sigfig_d(number, range)
	local n = tostring(number)
	return tonumber(string.find(n, "%.") and string.sub(n, 1, string.find(n, "%.")+range) or n)
end


local function merge(array, s, e, direction)
	local l = s
	local lt = math.floor((s+e)/2)
	local r = lt+1
	local temp = Util.copy(array)

	for i = s, e do
		if r > e or ((direction == "HL" and (array[l].count or array[l].amount) >= (array[r].count or array[r].amount)) or (direction == "LH" and (array[l].count or array[l].amount) <= (array[r].count or array[r].amount))) and l <= lt then
			temp[i] = array[l]
			l = l + 1
		else
			temp[i] = array[r]
			r = r + 1
		end
	end

	for i = s, e do
		array[i] = temp[i]
	end
end

function Util.merge_sort(array, s, e, direction)
	local s = s or 1
	local e = e or #array
	if s >= e then return array end
	local m = math.floor((s+e)/2)
	Util.merge_sort(array, s, m, direction)
	Util.merge_sort(array, m+1, e, direction)
	merge(array, s, e, direction)
end

function Util.signal_to_rich_text(signal)
	if signal and signal.name then
	  if signal.type == "item" then
		return "[img=item."..signal.name.."]"
	  elseif signal.type == "fluid" then
		return "[img=fluid."..signal.name.."]"
	  elseif signal.type == "virtual" then
		return "[img=virtual-signal."..signal.name.."]"
	  end
	end
	return ""
  end