IIO = {
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

function IIO:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = IIO
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
        values = {
            {name="iron-plate", count=1},
            {name="copper-plate", count=1}
        }
    }
    UpdateSys.addEntity(t)
    return t
end

function IIO:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = IIO
    setmetatable(object, mt)
end

function IIO:remove()
    UpdateSys.remove(self)
    if self.networkController ~= nil then
        self.networkController.network.ItemIOTable[self.entID] = nil
        self.networkController.network.shouldRefresh = true
    end
end

function IIO:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function IIO:update()
    if valid(self) == false then
        self:remove()
        return
    end
    if self.thisEntity.to_be_deconstructed() == true then return end
    self:createArms()
    local tick = game.tick % (120/Constants.Settings.RNS_BaseItemIO_Speed) --based on belt speed
    if tick >= 0.0 and tick < 1.0 then self:IO() end
end

function IIO:IO()
    if self.focusedEntity ~= nil and self.focusedEntity.valid == true then
        local foc = self.focusedEntity
        if foc.type == "transport-belt" or foc.type == "underground-belt" or foc.type == "splitter" or foc.type == "loader" or foc.type == "loader-1x1" then
            local beltDir = Util.direction(foc)
            local ioDir = self.realDirection
            local transportLine = nil
            if ioDir == beltDir then
                transportLine = "Back"
            elseif math.abs(ioDir-beltDir) == 2 then
                transportLine = "Front"
            elseif beltDir-1 == ioDir%4 then
                transportLine = "Right"
            elseif ioDir-1 == beltDir%4 then
                transportLine = "Left"
            end

            if Constants.Settings.RNS_BeltSides[transportLine] ~= nil and foc.type ~= "splitter" and foc.type ~= "loader" and foc.type ~= "loader-1x1" then
                local line = foc.get_transport_line(Constants.Settings.RNS_BeltSides[transportLine])
                if self.io == "input" then
                    local ind = self.filters.index
                    repeat
                        local a = line.remove_item(Util.next(self.filters))
                    until a ~= 0 or ind == self.filters.index
                    return
                elseif self.io == "output" then
                    local pos = 0.75
                    if foc.type == "underground-belt" then
                        pos = 0.25
                    end
                    if line.can_insert_at(pos) then
                        local ind = self.filters.index
                        repeat
                            local a = line.insert_at(pos, Util.next(self.filters))
                        until a == true or ind == self.filters.index
                    end
                    return
                end
            else
                local lineL = foc.get_transport_line(1)
                local lineR = foc.get_transport_line(2)
                
                if foc.type == "underground-belt" then
                    lineL = foc.get_transport_line(3)
                    lineR = foc.get_transport_line(4)
                elseif foc.type == "splitter" then
                    local axis = Util.axis(foc)
                    if (foc.position.x > self.thisEntity.position.x and axis == "y") or (foc.position.y > self.thisEntity.position.y and axis == "x") then
                        if transportLine == "Back" then
                            lineL = foc.get_transport_line(1)
                            lineR = foc.get_transport_line(2)
                        elseif transportLine == "Front" then
                            lineL = foc.get_transport_line(5)
                            lineR = foc.get_transport_line(6)
                        end
                    elseif (foc.position.x < self.thisEntity.position.x and axis == "y") or (foc.position.y < self.thisEntity.position.y and axis == "x") then
                        if transportLine == "Back" then
                            lineL = foc.get_transport_line(3)
                            lineR = foc.get_transport_line(4)
                        elseif transportLine == "Front" then
                            lineL = foc.get_transport_line(7)
                            lineR = foc.get_transport_line(8)
                        end
                    end
                end
                
                if self.io == "input" then
                    if transportLine == "Back" then
                        --Do nothing
                    elseif transportLine == "Front" then
                        if foc.type == "underground-belt" and foc.belt_to_ground_type == "input" then return end
                        if foc.type == "underground-belt" and foc.belt_to_ground_type == "output" then
                            lineL = foc.get_transport_line(1)
                            lineR = foc.get_transport_line(2)
                        end
                    end

                    local ind = self.filters.index
                    repeat
                        local a = lineL.remove_item(Util.next(self.filters))
                    until a ~= 0 or ind == self.filters.index

                    ind = self.filters.index
                    repeat
                        local a = lineR.remove_item(Util.next(self.filters))
                    until a ~= 0 or ind == self.filters.index

                    return
                elseif self.io == "output" then
                    local pos = 0.75
                    if transportLine == "Back" then
                        if foc.type == "loader" and foc.loader_type == "input" then
                            pos = 0.125
                        elseif foc.type == "splitter" then
                            pos = 0.125
                        end
                    elseif transportLine == "Front" and foc.type ~= "underground-belt" then
                        pos = 0.25
                        if foc.type == "loader-1x1" and foc.loader_type == "input" then return end
                        if foc.type == "loader" and foc.loader_type == "input" then return end
                        if foc.type == "loader" and foc.loader_type == "output" then
                            pos = 0.125
                        elseif foc.type == "splitter" then
                            pos = 0.125
                        end
                    end
                    
                    if lineL.can_insert_at(pos) then
                        local ind = self.filters.index
                        repeat
                            local a = lineL.insert_at(pos, Util.next(self.filters))
                        until a == true or ind == self.filters.index
                    end
                    if lineR.can_insert_at(pos) then
                        local ind = self.filters.index
                        repeat
                            local a = lineR.insert_at(pos, Util.next(self.filters))
                        until a == true or ind == self.filters.index
                    end

                    return
                end
            end
        else
            local ind = self.filters.index
            repeat
                local a = 0
                if self.io == "input" then
                    foc.remove_item(Util.next(self.filters))
                elseif self.io == "output" then
                    foc.insert(Util.next(self.filters))
                end
            until a ~= 0 or ind == self.filters.index
            return
        end
    end
end

function IIO:resetConnection()
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

function IIO:getCheckArea()
    local x = self.thisEntity.position.x
    local y = self.thisEntity.position.y
    return {
        [1] = {direction = 1, startP = {x-0.5, y-1.5}, endP = {x+0.5, y-0.5}}, --North
        [2] = {direction = 2, startP = {x+0.5, y-0.5}, endP = {x+1.5, y+0.5}}, --East
        [4] = {direction = 4, startP = {x-0.5, y+0.5}, endP = {x+0.5, y+1.5}}, --South
        [3] = {direction = 3, startP = {x-1.5, y-0.5}, endP = {x-0.5, y+0.5}}, --West
    }
end

function IIO:createArms()
    local areas = self:getCheckArea()
    self:resetConnection()
    for _, area in pairs(areas) do
        local enti = 0
        local ents = self.thisEntity.surface.find_entities_filtered{area={area.startP, area.endP}}
        if area.direction == self.direction then --Draw the IO port in the right direction
            self.arms[area.direction] = rendering.draw_sprite{sprite=Constants.NetworkCables.IO.item.sprites[area.direction].name, target=self.thisEntity, surface=self.thisEntity.surface, render_layer="lower-object-above-shadow"}
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

function IIO:initializeDataOnCreated(dir)
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

function IIO:getTooltips()

end