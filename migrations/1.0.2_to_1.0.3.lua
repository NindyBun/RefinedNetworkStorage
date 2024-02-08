if global.allowMigration == false then return end

global.updateTable = global.updateTable or {}

for _, obj in pairs(global.objectTables) do
    if obj.tableName ~= nil and obj.tag ~= nil and _G[obj.tag] ~= nil then
        for _, entry in pairs(global[obj.tableName] or {}) do
            _G[obj.tag]:rebuild(entry)
        end
    end
end

local tempEntityTable = {}
local tempUpdateTable = {}
for id, obj in pairs(global.entityTable or {}) do
    if obj.thisEntity ~= nil and obj.thisEntity.valid then
        if obj.thisEntity.name == Constants.NetworkController.main.name then
            tempEntityTable[id] = obj
            tempUpdateTable[id] = obj
        else
            tempEntityTable[id] = obj
        end
    end
end

global.entityTable = tempEntityTable
global.updateTable = tempUpdateTable