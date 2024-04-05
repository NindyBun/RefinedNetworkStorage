if global.allowMigration == false then return end
global.TransReceiverChannels = global.TransReceiverChannels or {transmitters = {}, receivers = {}}
global.NetworkControllers = global.NetworkControllers or {}

for id, obj in pairs(global.entityTable) do
    if obj.type and obj.receiver then
        obj.receiver = nil
        if obj.type == "transmitter" then
            global.TransReceiverChannels.transmitters[id] = obj
        elseif obj.type == "receiver" then
            global.TransReceiverChannels.receivers[id] = obj
        end
    end
    if obj.network then
        global.NetworkControllers[id] = obj
    end
end