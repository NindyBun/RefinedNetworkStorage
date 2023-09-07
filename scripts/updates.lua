require("scripts.Functions")
--Adds object to the update system
function UpdateSys.addEntity(obj)
    if valid(obj) == false then return end
    if global.entityTable == nil then global.entityTable = {} end
    
    if obj ~= nil and getmetatable(obj) ~= nil then
        if obj:valid() ~= true then
            obj:remove()
        elseif obj.thisEntity ~= nil and obj.thisEntity.valid == true then
            global.entityTable[obj.entID] = obj
        end
    end
end

function UpdateSys.addItem(obj)
    if valid(obj) == false then return end
    if global.itemTable == nil then global.itemTable = {} end
    
    if obj ~= nil and getmetatable(obj) ~= nil then
        if obj:valid() ~= true then
            obj:remove()
        elseif obj.thisEntity ~= nil and obj.thisEntity.valid == true then
            global.itemTable[obj.entID] = obj
        end
    end
end

function UpdateSys.remove(obj)
    if obj.entID ~= nil then
        global.entityTable[obj.entID] = nil
    end
end

function UpdateSys.removeItem(obj)
    if obj.entID ~= nil then
        global.itemTable[obj.entID] = nil
    end
end

function UpdateSys.update(event)
    for _, obj in pairs(global.entityTable) do
        if valid(obj) == true and obj.update ~= nil then
            if Util.safeCall(obj.update, obj, event) == false then
                game.print({"gui-description.UpdateSysEntity_Failed", obj.thisEntity.name})
            end
        end
    end
    for _, obj in pairs(global.itemTable) do
        if valid(obj) == true and obj.update ~= nil then
            if Util.safeCall(obj.update, obj, event) == false then
                game.print({"gui-description.UpdateSysItem_Failed", obj.thisEntity.name})
            end
        end
    end
end