if global.allowMigration == false then return end

for id, obj in pairs(global.entityTable) do
    if obj.type then
        if obj.type == "transmitter" or obj.type == "receiver" then
            obj.nametag = {"gui-description.RNS_TransReceiver_ID", obj.thisEntity.unit_number, obj.thisEntity.surface.name, tostring(serpent.line(obj.thisEntity.position))}
        end
    end
    if obj.thisEntity.valid and obj.thisEntity.name == Constants.NetworkController.main.name then
        obj.nametag = {"gui-description.RNS_TransReceiver_ID", obj.thisEntity.unit_number, obj.thisEntity.surface.name, tostring(serpent.line(obj.thisEntity.position))}
    end
end