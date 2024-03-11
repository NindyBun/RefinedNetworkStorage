if global.allowMigration == false then return end

--[[for _, obj in pairs(global.objectTables) do
    if obj.tableName ~= nil and obj.tag ~= nil and _G[obj.tag] ~= nil then
        for _, entry in pairs(global[obj.tableName] or {}) do
            _G[obj.tag]:rebuild(entry)
        end
    end
end]]

for _, obj in pairs(global.objectTables) do
    if obj.tableName ~= nil and obj.tag ~= nil and _G[obj.tag] ~= nil then
        if obj.tag == "NC" then
            for _, entry in pairs(global[obj.tableName] or {}) do
                entry.network.Contents = {
                    item = {},
                    fluid = {}
                }
                entry.network.importDriveCache = {}
                entry.network.importExternalCache = {}
                entry.network.exportDriveCache = {}
                entry.network.exportExternalCache = {}
                entry.shouldRefresh = true
            end
        end

        if obj.tag == "ID" then
            for _, entry in pairs(global[obj.tableName] or {}) do
                entry.filters = {}
                entry.guiFilters = {}
                for i = 1, 5 do
                    entry.guiFilters[i] = ""
                end
                entry.whitelistBlacklist = entry.whitelist and "whitelist" or "blacklist"
                entry.whitelist = nil
                for n, v in pairs(entry.storageArray) do
                    local t = {}
                    local mt = {}
                    setmetatable(t, mt)
                    mt.__index = Itemstack
                    t.name = v.name
                    t.type = game.item_prototypes[v.name].type
                    t.count = v.count
                    t.health = 1.0
                    t.ammo = v.ammo
                    t.durability = v.durability
                    t.extras = {}
                    entry.storageArray[n] = t
                end
            end
        end

        if obj.tag == "FD" then
            for _, entry in pairs(global[obj.tableName] or {}) do
                entry.filters = {}
                entry.guiFilters = {}
                for i = 1, 5 do
                    entry.guiFilters[i] = ""
                end
                entry.whitelistBlacklist = entry.whitelist and "whitelist" or "blacklist"
                entry.whitelist = nil
                --[[if entry.networkController ~= nil and BaseNet.exists_in_network(entry.networkController, entry.thisEntity.unit_number) then
                    for n, v in pairs(entry.fluidArray) do
                        entry.networkController.network:increase_tracked_fluid_amount(n, v.amount)
                    end
                end]]
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
                entry:init_cache()
            end
        end

        if obj.tag == "IIO3" then
            for _, entry in pairs(global[obj.tableName] or {}) do
                entry.whitelistBlacklist = entry.whitelist and "whitelist" or "blacklist"
                entry.supportModified = entry.metadataMode
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
                        entry.filters.max = entry.filters.max + 1
                        entry.filters.values[oldFilters.values[i]] = true
                        entry.filters.values[i] = oldFilters.values[i]
                    end
                end
                entry.filters.index = entry.filters.max ~= 0 and 1 or 0
            end
        end
    end
end