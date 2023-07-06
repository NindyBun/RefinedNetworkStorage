FIO = {
    thisEntity = nil,
    entID = nil,
    direction = 1,
    connectionDirection = 1,
    realDirection = 1,
    networkController = nil,
    arms = nil,
    connectedObjs = nil,
    focusedEntity = nil,
    cardinals = nil,
    filters = nil,
    whitelist = false,
    io = "input"
}

function FIO:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = FIO
    t.thisEntity = object
    t.entID = object.unit_number
    rendering.draw_sprite{sprite="NetworkCableDot", target=t.thisEntity, surface=t.thisEntity.surface, render_layer="lower-object-above-shadow"}
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
    t.filters = {
        index = 1,
        values = {}
    }
    UpdateSys.addEntity(t)
    return t
end

function FIO:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = FIO
    setmetatable(object, mt)
end

function FIO:remove()
    UpdateSys.remove(self)
    if self.networkController ~= nil then
        self.networkController.network.FluidIOTable[self.entID] = nil
        self.networkController.network.shouldRefresh = true
    end
end

function FIO:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function FIO:update()
    if valid(self) == false then
        self:remove()
        return
    end
    if self.thisEntity.to_be_deconstructed() == true then return end
    self:createArms()
    --local tick = game.tick % (120/Constants.Settings.RNS_BaseItemIO_Speed) --based on belt speed
    --if tick >= 0.0 and tick < 1.0 then self:IO() end
end

function FIO:IO()
    if self.focusedEntity ~= nil and self.focusedEntity.valid == true then
        local foc = self.focusedEntity
        
    end
end

function FIO:resetConnection()
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

function FIO:getCheckArea()
    local x = self.thisEntity.position.x
    local y = self.thisEntity.position.y
    return {
        [1] = {direction = 1, startP = {x-0.5, y-1.5}, endP = {x+0.5, y-0.5}}, --North
        [2] = {direction = 2, startP = {x+0.5, y-0.5}, endP = {x+1.5, y+0.5}}, --East
        [4] = {direction = 4, startP = {x-0.5, y+0.5}, endP = {x+0.5, y+1.5}}, --South
        [3] = {direction = 3, startP = {x-1.5, y-0.5}, endP = {x-0.5, y+0.5}}, --West
    }
end

function FIO:createArms()
    local areas = self:getCheckArea()
    self:resetConnection()
    for _, area in pairs(areas) do
        local enti = 0
        local ents = self.thisEntity.surface.find_entities_filtered{area={area.startP, area.endP}}
        if area.direction == self.direction then --Draw the IO port in the right direction
            self.arms[area.direction] = rendering.draw_sprite{sprite=Constants.NetworkCables.IO.fluid.sprites[area.direction].name, target=self.thisEntity, surface=self.thisEntity.surface, render_layer="lower-object-above-shadow"}
        end
        for _, ent in pairs(ents) do
            if ent ~= nil and ent.valid == true then
                if ent ~= nil and global.entityTable[ent.unit_number] ~= nil and string.match(ent.name, "RNS_") ~= nil and ent.operable then
                    if area.direction ~= self.direction then --Prevent cable connection on the IO port
                        local obj = global.entityTable[ent.unit_number]
                        if string.match(obj.thisEntity.name, "RNS_NetworkCableIO") ~= nil and obj.connectionDirection == area.direction then
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
                            elseif obj.thisEntity.name == Constants.NetworkController.name then
                                obj.network.shouldRefresh = true
                            end
                        end
                        break
                    end
                elseif ent ~= nil and self.direction == area.direction then --Get entity with inventory
                    if Constants.Settings.RNS_TypesWithContainer[ent.type] == true then
                        self.focusedEntity = ent
                        break
                    end
                end
            end
        end
        if self.direction ~= area.direction then
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

function FIO:initializeDataOnCreated(dir)
    if dir == nil then return end
    if dir == defines.direction.north then
        self.direction = 1
        self.connectionDirection = 4
        self.realDirection = 1
    elseif dir == defines.direction.east then
        self.direction = 2
        self.connectionDirection = 3
        self.realDirection = 2
    elseif dir == defines.direction.south then
        self.direction = 4
        self.connectionDirection = 1
        self.realDirection = 3
    elseif dir == defines.direction.west then
        self.direction = 3
        self.connectionDirection = 2
        self.realDirection = 4
    end
    self:createArms()
end

function FIO:getTooltips()

end