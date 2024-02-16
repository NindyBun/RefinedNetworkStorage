if global.allowMigration == false then return end

for _, obj in pairs(global.objectTables) do
    if obj.tableName ~= nil and obj.tag ~= nil and _G[obj.tag] ~= nil then
        for _, entry in pairs(global[obj.tableName] or {}) do
            _G[obj.tag]:rebuild(entry)
        end
    end
end

for _, obj in pairs(global.objectTables) do
    if obj.tableName ~= nil and obj.tag ~= nil and _G[obj.tag] ~= nil then
        if obj.tag == "NC" then
            for _, entry in pairs(global[obj.tableName] or {}) do
                
                entry.network.importDriveCache = {}
                entry.network.importExternalCache = {}
                entry.network.exportDriveCache = {}
                entry.network.exportExternalCache = {}
                
                local temp = {}
                for n, v in pairs(entry.network.Contents.item) do
                    temp[n] = v
                end
                for n, v in pairs(entry.network.Contents.fluid) do
                    temp[n] = v
                end
                entry.network.Contents = temp
            end
        end

        if obj.tag == "ID" or obj.tag == "FD" then
            for _, entry in pairs(global[obj.tableName] or {}) do
                entry.filters = {}
                entry.guiFilters = {}
                for i = 1, 5 do
                    entry.guiFilters[i] = ""
                end
                entry.whitelistBlacklist = entry.whitelist and "whitelist" or "blacklist"
                entry.whitelist = nil
            end
        end

        if obj.tag == "EIO" then
            for _, entry in pairs(global[obj.tableName] or {}) do
                entry.whitelistBlacklist = entry.whitelist and "whitelist" or "blacklist"
                entry.whitelist = nil
                local oldFilters = entry.filters
                entry.filters = {
                    item = {},
                    fluid = {}
                }
                entry.guiFilters = {
                    item = {},
                    fluid = {}
                }
                for i = 1, 10 do
                    entry.guiFilters.item[i] = oldFilters.item.values[i]
                    if oldFilters.item.values[i] ~= "" then
                        entry.filters.item[oldFilters.item.values[i]] = true
                    end

                    entry.guiFilters.fluid[i] = oldFilters.fluid.values[i]
                    if oldFilters.fluid.values[i] ~= "" then
                        entry.filters.fluid[oldFilters.fluid.values[i]] = true
                    end
                end
            end
        end

        if obj.tag == "IIOV3" then
            for _, entry in pairs(global[obj.tableName] or {}) do
                entry.whitelistBlacklist = entry.whitelist and "whitelist" or "blacklist"
                entry.whitelist = nil
                entry.metadatamode = nil
                local oldFilters = entry.filters
                entry.filters = {
                    index = 0,
                    max = 0,
                    values = {}
                }
                entry.guiFilters = {}
                for i = 1, 2 do
                    entry.guiFilters[i] = oldFilters.values[i]
                    if oldFilters.values[i] ~= "" then
                        entry.filters.values[oldFilters.values[i]] = true
                        entry.filters.values[i] = oldFilters.values[i]
                    end
                end
            end
        end
    end
end