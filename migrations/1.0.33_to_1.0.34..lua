if global.allowMigration == false then return end

for id, obj in pairs(global.entityTable) do
    if obj.thisEntity.valid and obj.thisEntity.name == Constants.Detector.name then
        DT:rebuild(obj)
        obj.icons = {
            [1] = nil,
            [2] = nil,
            [4] = nil,
            [3] = nil,
        }
        obj.disconnects = {
            [1] = false,
            [2] = false,
            [3] = false,
            [4] = false
        }
        obj.filters.virtual = ""
    end
    if obj.thisEntity.valid and string.match(obj.thisEntity.name, "RNS_ItemDrive") ~= nil then
        ID:rebuild(obj)
        obj.icons = {}
        obj:regenerate_icons()
    end
    if obj.thisEntity.valid and string.match(obj.thisEntity.name, "RNS_FluidDrive") ~= nil then
        FD:rebuild(obj)
        obj.icons = {}
        obj:regenerate_icons()
    end
end