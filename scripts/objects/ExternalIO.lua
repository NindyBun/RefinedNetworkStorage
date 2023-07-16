EIO = {
    thisEntity = nil,
    entID = nil,
    networkController = nil,
    arms = nil,
    connectedObjs = nil,
    focusedEntity = nil,
    cardinals = nil,
    filter = nil,
    state = nil,
    io = "both",
    ioIcon = nil
}

function EIO:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = EIO
    t.thisEntity = object
    t.entID = object.unit_number
    rendering.draw_sprite{sprite="NetworkCableDot", target=t.thisEntity, surface=t.thisEntity.surface, render_layer="lower-object-above-shadow"}
    t:generateModeIcon()
    t.cardinals = {
        [1] = false, --N
        [2] = false, --E
        [3] = false, --S
        [4] = false, --W
    }
    t.arms = {
        [1] = nil, --N
        [2] = nil, --E
        [3] = nil, --S
        [4] = nil, --W
    }
    t.connectedObjs = {
        [1] = {}, --N
        [2] = {}, --E
        [3] = {}, --S
        [4] = {}, --W
    }
    t.filter = {}
    UpdateSys.addEntity(t)
    return t
end

function EIO:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = EIO
    setmetatable(object, mt)
end

function EIO:remove()
    if self.state ~= nil then self.state.destroy() end
    UpdateSys.remove(self)
    if self.networkController ~= nil then
        self.networkController.network.ExternalIOTable[self.entID] = nil
        self.networkController.network.shouldRefresh = true
    end
end

function EIO:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function EIO:update()
    if valid(self) == false then
        self:remove()
        return
    end
    if valid(self.networkController) == false then
        self.networkController = nil
    end
    if self.thisEntity.to_be_deconstructed() == true then return end
    self:createArms()
end

function EIO:toggleHoverIcon(hovering)
    if self.ioIcon == nil then return end
    if hovering and rendering.get_only_in_alt_mode(self.ioIcon) then
        rendering.set_only_in_alt_mode(self.ioIcon, false)
    elseif not hovering and not rendering.get_only_in_alt_mode(self.ioIcon) then
        rendering.set_only_in_alt_mode(self.ioIcon, true)
    end
end

function EIO:generateModeIcon()
    if self.ioIcon ~= nil then rendering.destroy(self.ioIcon) end
    local offset = {0, 0}
    if self:getRealDirection() == 1 then
        offset = {0,-0.5}
    elseif self:getRealDirection() == 2 then
        offset = {0.5, 0}
    elseif self:getRealDirection() == 3 then
        offset = {0,0.5}
    elseif self:getRealDirection() == 4 then
        offset = {-0.5,0}
    end
    if self.io ~= "both" then
        self.ioIcon = rendering.draw_sprite{
            sprite=Constants.Icons.storage.name, 
            target=self.thisEntity, 
            target_offset=offset,
            surface=self.thisEntity.surface,
            only_in_alt_mode=true,
            orientation=self.io == "input" and (self:getRealDirection()*0.25)-0.25 or ((self:getRealDirection()*0.25)+0.25)%1.00
        }
    else
        self.ioIcon = rendering.draw_sprite{
            sprite=Constants.Icons.storage_bothways.name, 
            target=self.thisEntity, 
            target_offset=offset,
            surface=self.thisEntity.surface,
            only_in_alt_mode=true,
            orientation=(self:getRealDirection()*0.25)-0.25
        }
    end
    
end

function EIO:IO()
    if self.focusedEntity ~= nil and self.focusedEntity.valid == true then
        local foc = self.focusedEntity
    end
end

function EIO:resetConnection()
    self.connectedObjs = {
        [1] = {}, --N
        [2] = {}, --E
        [3] = {}, --S
        [4] = {}, --W
    }
    for _, arm in pairs(self.arms) do
        if arm ~= nil then
            rendering.destroy(arm)
        end
    end
end

function EIO:getCheckArea()
    local x = self.thisEntity.position.x
    local y = self.thisEntity.position.y
    return {
        [1] = {direction = 1, startP = {x-0.5, y-1.5}, endP = {x+0.5, y-0.5}}, --North
        [2] = {direction = 2, startP = {x+0.5, y-0.5}, endP = {x+1.5, y+0.5}}, --East
        [4] = {direction = 4, startP = {x-0.5, y+0.5}, endP = {x+0.5, y+1.5}}, --South
        [3] = {direction = 3, startP = {x-1.5, y-0.5}, endP = {x-0.5, y+0.5}}, --West
    }
end

function EIO:createArms()
    local areas = self:getCheckArea()
    self:resetConnection()
    for _, area in pairs(areas) do
        local enti = 0
        local ents = self.thisEntity.surface.find_entities_filtered{area={area.startP, area.endP}}
        for _, ent in pairs(ents) do
            if ent ~= nil and ent.valid == true then
                if ent ~= nil and global.entityTable[ent.unit_number] ~= nil and string.match(ent.name, "RNS_") ~= nil and ent.operable then
                    if area.direction ~= self:getDirection() then --Prevent cable connection on the IO port
                        local obj = global.entityTable[ent.unit_number]
                        if string.match(obj.thisEntity.name, "RNS_NetworkCableIO") ~= nil and obj:getConnectionDirection() == area.direction then
                            --Do nothing
                        else
                            self.arms[area.direction] = rendering.draw_sprite{sprite=Constants.NetworkCables.Sprites[area.direction].name, target=self.thisEntity, surface=self.thisEntity.surface, render_layer="lower-object-above-shadow"}
                            self.connectedObjs[area.direction] = {obj}
                            enti = enti + 1
                        end
                        --Update network connections if necessary
                        if self.cardinals[area.direction] == false then
                            self.cardinals[area.direction] = true
                            if valid(self.networkController) == true and self.networkController.thisEntity ~= nil and self.networkController.thisEntity.valid == true then
                                self.networkController.network.shouldRefresh = true
                            elseif obj.thisEntity.name == Constants.NetworkController.slateEntity.name then
                                obj.network.shouldRefresh = true
                            end
                        end
                        break
                    end
                elseif ent ~= nil and self:getDirection() == area.direction then --Get entity with inventory
                    if Constants.Settings.RNS_TypesWithContainer[ent.type] == true then
                        self.focusedEntity = ent
                        break
                    end
                end
            end
        end
        if self:getDirection() ~= area.direction then
            --Update network connections if necessary
            if self.cardinals[area.direction] == true and enti ~= 0 then
                self.cardinals[area.direction] = false
                if valid(self.networkController) == true and self.networkController.thisEntity ~= nil and self.networkController.thisEntity.valid == true then
                    self.networkController.network.shouldRefresh = true
                end
            end
        end
    end
end

function EIO:getDirection()
    local dir = self.thisEntity.direction
    if dir == defines.direction.north then
        return 1
    elseif dir == defines.direction.east then
        return 2
    elseif dir == defines.direction.south then
        return 4
    elseif dir == defines.direction.west then
        return 3
    end
end

function EIO:getConnectionDirection()
    local dir = self.thisEntity.direction
    if dir == defines.direction.north then
        return 4
    elseif dir == defines.direction.east then
        return 3
    elseif dir == defines.direction.south then
        return 1
    elseif dir == defines.direction.west then
        return 2
    end
end

function EIO:getRealDirection()
    local dir = self.thisEntity.direction
    if dir == defines.direction.north then
        return 1
    elseif dir == defines.direction.east then
        return 2
    elseif dir == defines.direction.south then
        return 3
    elseif dir == defines.direction.west then
        return 4
    end
end

function EIO:getTooltips(guiTable, mainFrame, justCreated)
    if justCreated == true then
        
    end
end