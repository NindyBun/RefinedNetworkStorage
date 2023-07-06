--Creates the tables needed to store all the mods custom objects and the corresponding entity
function createObjectTables()
    global.objectTables = {}
    addOrCreateObjectTable{tableName="PlayerTable", tag="RNSP", objName="RNSPlayer"}
    addOrCreateObjectTable{tableName="NetworkControllerTable", tag="NC", objName=Constants.NetworkController.name}
--    addOrCreateObjectTable{tableName="NetworkInventoryInterfaceTable", tag="NII", objName=Constants.NetworkInventoryInterface.name}
    addOrCreateObjectTable{tableName="ItemDriveTable", tag="ID", objName=Constants.Drives.ItemDrive1k.name}
    addOrCreateObjectTable{tableName="ItemDriveTable", tag="ID", objName=Constants.Drives.ItemDrive4k.name}
    addOrCreateObjectTable{tableName="ItemDriveTable", tag="ID", objName=Constants.Drives.ItemDrive16k.name}
    addOrCreateObjectTable{tableName="ItemDriveTable", tag="ID", objName=Constants.Drives.ItemDrive64k.name}
    addOrCreateObjectTable{tableName="FluidDriveTable", tag="FD", objName=Constants.Drives.FluidDrive4k.name}
    addOrCreateObjectTable{tableName="FluidDriveTable", tag="FD", objName=Constants.Drives.FluidDrive16k.name}
    addOrCreateObjectTable{tableName="FluidDriveTable", tag="FD", objName=Constants.Drives.FluidDrive64k.name}
    addOrCreateObjectTable{tableName="FluidDriveTable", tag="FD", objName=Constants.Drives.FluidDrive256k.name}
    addOrCreateObjectTable{tableName="ItemIOTable", tag="IIO", objName=Constants.NetworkCables.IO.item.eName}
--    addOrCreateObjectTable{tableName="NetworkLaserTable", tag="NL", objName=Constants.NetworkLasers.NLI.name}
--    addOrCreateObjectTable{tableName="NetworkLaserTable", tag="NL", objName=Constants.NetworkLasers.NLS.name}
--    addOrCreateObjectTable{tableName="NetworkLaserTable", tag="NL", objName=Constants.NetworkLasers.NLT.name}
--    addOrCreateObjectTable{tableName="NetworkLaserTable", tag="NL", objName=Constants.NetworkLasers.NLC.name}
--    addOrCreateObjectTable{tableName="NetworkLaserTable", tag="NL", objName=Constants.NetworkLasers.NLE.name}
    addOrCreateObjectTable{tableName="NetworkCableTable", tag="NCbl", objName=Constants.NetworkCables.Cable.entity.name}
end

--Adds or Create a table to store the object
--@tableName - Name of the table
--@tag - Object constructor
--@objName - Name of the entity
function addOrCreateObjectTable(table)
    --Make the table if it doesn't exist yet
    if global.objectTables == nil then global.objectTables = {} end
    --Create the entity table and insert the table data
    global.objectTables[table.objName] = table
    --Initialize the entity table if it doesn't exist yet
    if table.tableName ~= nil and global[table.tableName] == nil then global[table.tableName] = {} end
end

function getNextAvailableNetworkID()
    if global.networkID == nil then global.networkID = {{id=0, used=false}} end
    for _, index in pairs(global.networkID) do
        if not index.used then
            index.used = true
            return index.id
        end
    end
    local id = #global.networkID
    table.insert(global.networkID, {id=id, used=true})
    return id
end

function valid(obj)
    if obj == nil then return false end
	if type(obj) ~= "table" then return false end
	if obj.valid == nil then return false end
	if type(obj.valid) == "boolean" then return obj.valid end
	if obj:valid() ~= true then return false end
	return true
end

function getRNSPlayer(player)
	if player == nil then return nil
	elseif type(player) == "number" then return global.playerTable[game.players[player].name]
	elseif type(player) == "string" then return global.playerTable[player]
	else error("bad argument to getRNSPlayer()") end
end

function getPlayer(id)
    return game.players[id]
end