if global.allowMigration == false then return end
for _, obj in pairs(global.objectTables) do
    if obj.tableName ~= nil and obj.tag ~= nil and _G[obj.tag] ~= nil then
        if obj.tag == "ID" then
            for _, entry in pairs(global[obj.tableName] or {}) do
                if entry.storedAmount == nil then
                    entry.storedAmount = 0
                    for _, v in pairs(entry.storageArray) do
                        if v ~= nil then
                            entry.storedAmount = entry.storedAmount + v.count
                        end
                    end
                end
            end
        end

        if obj.tag == "FD" then
            for _, entry in pairs(global[obj.tableName] or {}) do
                if entry.storedAmount == nil then
                    entry.storedAmount = 0
                    for _, v in pairs(entry.fluidArray) do
                        if v ~= nil then
                            entry.storedAmount = entry.storedAmount + v.amount
                        end
                    end
                end
            end
        end
    end
end