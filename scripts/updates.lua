function UpdateSys.update(event)
    for _, table in pairs(global.objectTables) do
        if table ~= nil then
            for _, obj in pairs(table) do
                if obj ~= nil and getmetatable(obj) ~= nil and valid(obj) == false then
                    if obj.isValid ~= nil and obj:isValid() ~= true then
                        obj:remove()
                    else
                        if valid(obj) and obj.update ~= nil and obj.thisEntity ~= nil and obj.thisEntity.valid == true then
                            if safeCall(obj.update, obj, event) ~= true then
                                game.print("gui-description.UpdateSysEntity_Failed", obj.ent.name)
                            end
                        end
                    end
                end
            end
        end
    end
end