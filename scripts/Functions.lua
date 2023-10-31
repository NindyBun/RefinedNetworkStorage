--Creates the tables needed to store all the mods custom objects and the corresponding entity
function createObjectTables()
    global.objectTables = {}
    addOrCreateObjectTable{tableName="PlayerTable", tag="RNSP", objName="RNSPlayer"}
    addOrCreateObjectTable{tableName="NetworkControllerTable", tag="NC", objName=Constants.NetworkController.main.name}
    addOrCreateObjectTable{tableName="NetworkInventoryInterfaceTable", tag="NII", objName=Constants.NetworkInventoryInterface.name}

    addOrCreateObjectTable{tableName="WirelessGridTable", tag="WG", objName=Constants.WirelessGrid.name}
    addOrCreateObjectTable{tableName="WirelessTransmitterTable", tag="WT", objName=Constants.NetworkCables.wirelessTransmitter.name}
    addOrCreateObjectTable{tableName="DetectorTable", tag="DT", objName=Constants.Detector.name}

    for _, iD in pairs(Constants.Drives.ItemDrive) do
        addOrCreateObjectTable{tableName="ItemDriveTable", tag="ID", objName=iD.name}
    end
    for _, iF in pairs(Constants.Drives.FluidDrive) do
        addOrCreateObjectTable{tableName="FluidDriveTable", tag="FD", objName=iF.name}
    end

    addOrCreateObjectTable{tableName="ItemIOV2Table", tag="IIO2", objName="RNS_NetworkCableIOV2_Item"}
    addOrCreateObjectTable{tableName="FluidIOV2Table", tag="FIO2", objName="RNS_NetworkCableIOV2_Fluid"}

    --addOrCreateObjectTable{tableName="ItemDriveTable", tag="ID", objName=Constants.Drives.ItemDrive.ItemDrive1k.name}
    --addOrCreateObjectTable{tableName="ItemDriveTable", tag="ID", objName=Constants.Drives.ItemDrive.ItemDrive4k.name}
    --addOrCreateObjectTable{tableName="ItemDriveTable", tag="ID", objName=Constants.Drives.ItemDrive.ItemDrive16k.name}
    --addOrCreateObjectTable{tableName="ItemDriveTable", tag="ID", objName=Constants.Drives.ItemDrive.ItemDrive64k.name}
    --addOrCreateObjectTable{tableName="FluidDriveTable", tag="FD", objName=Constants.Drives.FluidDrive.FluidDrive4k.name}
    --addOrCreateObjectTable{tableName="FluidDriveTable", tag="FD", objName=Constants.Drives.FluidDrive.FluidDrive16k.name}
    --addOrCreateObjectTable{tableName="FluidDriveTable", tag="FD", objName=Constants.Drives.FluidDrive.FluidDrive64k.name}
    --addOrCreateObjectTable{tableName="FluidDriveTable", tag="FD", objName=Constants.Drives.FluidDrive.FluidDrive256k.name}

    addOrCreateObjectTable{tableName="ItemIOTable", tag="IIO", objName=Constants.NetworkCables.itemIO.name}
    addOrCreateObjectTable{tableName="FluidIOTable", tag="FIO", objName=Constants.NetworkCables.fluidIO.name}
    addOrCreateObjectTable{tableName="ExternalIOTable", tag="EIO", objName=Constants.NetworkCables.externalIO.name}
    for _, color in pairs(Constants.NetworkCables.Cables) do
        addOrCreateObjectTable{tableName="NetworkCableTable", tag="NCbl", objName=color.cable.name}
        addOrCreateObjectTable{tableName="NetworkCableRampTable", tag="NCug", objName=color.underground.name}
    end
    for _, tr in pairs(Constants.NetworkTransReceiver) do
        addOrCreateObjectTable{tableName="TransReceiverTable", tag="TR", objName=tr.name}
    end
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

--[[function getNextAvailableNetworkID()
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
end]]

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
	elseif type(player) == "number" then return global.PlayerTable[game.players[player].name]
	elseif type(player) == "string" then return global.PlayerTable[player]
	else error("bad argument to getRNSPlayer()") end
end

function getPlayer(id)
    return game.players[id]
end

function getRGBA()
    return {
        r=settings.global[Constants.Settings.RNS_RGBA_R].value,
        g=settings.global[Constants.Settings.RNS_RGBA_G].value,
        b=settings.global[Constants.Settings.RNS_RGBA_B].value,
        a=settings.global[Constants.Settings.RNS_RGBA_A].value
    }
end