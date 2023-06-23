NL = {
    thisEntity = nil,
    entID = nil,
    networkController = nil,
    type = "",
    sourceObj = nil,
    focusedObjs = nil,
    beams = nil,
    beamsPos = nil,
    updateTick = 60,
    lastUpdate = 0,
}

function NL:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = NL
    t.thisEntity = object
    t.entID = object.unit_number
    t.type = object.name
    t.beams = {
        [1] = nil,
        [2] = nil,
        [3] = nil,
        [4] = nil
    }
    t.beamsPos = {
        [1] = {},
        [2] = {},
        [3] = {},
        [4] = {}
    }
    t.focusedObjs = {
        [1] = nil,
        [2] = nil,
        [3] = nil,
        [4] = nil
    }
    t:getNetworkController()
    t:getBeamPosition(nil, nil)
    UpdateSys.addEntity(t)
    return t
end

function NL:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = NL
    setmetatable(object, mt)
end

function NL:remove()
    for _, beam in pairs(self.beams) do
        if beam ~= nil and beam.valid == true then
            beam.destroy()
        end
    end
    UpdateSys.remove(self)
end

function NL:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid
end

function NL:update()
    --if self.lastUpdate == 0 or game.tick - self.lastUpdate > self.updateTick*2 then
        self.lastUpdate = game.tick
        if valid(self) == false then
            self:remove()
            return
        end
        if valid(self.sourceObj) == false then
            self.sourceObj = nil
        end
        if self.type == Constants.NetworkLasers.NLI.name then
            self:getNetworkController()
        end
        self:connectLasers()
    --end
end

function NL:resetBeams()
    self.beamsPos = {
        [1] = {},
        [2] = {},
        [3] = {},
        [4] = {}
    }
    self.focusedObjs = {
        [1] = nil,
        [2] = nil,
        [3] = nil,
        [4] = nil
    }
    for _, beam in pairs(self.beams) do
        if beam ~= nil and beam.valid == true then
            beam.destroy()
        end
    end
end

function NL:getBeamPosition(ent, selfD)
    local selfP = self.thisEntity.position
    local entX = nil
    local entY = nil
    local entW = 0
    local entH = 0
    
    if ent ~= nil then
        entX = ent.position.x
        entY = ent.position.y
        local entBB = ent.bounding_box
        entW = entBB.right_bottom.x - entBB.left_top.x
        entH = entBB.right_bottom.y - entBB.left_top.y
    end

    if selfD == 1 then
        self.beamsPos[1].startP = {x = selfP.x, y = selfP.y - 0.2}
        self.beamsPos[1].endP = {x = selfP.x, y = (entY or (selfP.y-64)) - 0.5 + entH/2 + 0.2 }
    elseif selfD == 2 then
        self.beamsPos[2].startP = {x = selfP.x + 0.2, y = selfP.y}
        self.beamsPos[2].endP = {x = (entX or (selfP.x+64)) + 0.5 - entW/2 - 0.2, y = selfP.y}
    elseif selfD == 3 then
        self.beamsPos[3].startP = {x = selfP.x, y = selfP.y + 0.2}
        self.beamsPos[3].endP = {x = selfP.x, y = (entY or (selfP.y+64)) + 0.5 - entH/2 - 0.2}
    elseif selfD == 4 or selfD == 0 then
        self.beamsPos[4].startP = {x = selfP.x - 0.2, y = selfP.y}
        self.beamsPos[4].endP = {x = (entX or (selfP.x-64)) - 0.5 + entW/2 + 0.2, y = selfP.y }
    else
        local direction = self:directionAsCardinal()
        local cardinals = self:getCardinals()
        for _, c in pairs(cardinals) do
            local d = (direction + c) % 4
            if d == 1 then --North
                self.beamsPos[1].startP = selfP
                self.beamsPos[1].endP = selfP
            elseif d == 2 then --East
                self.beamsPos[2].startP = selfP
                self.beamsPos[2].endP = selfP
            elseif d == 3 then --South
                self.beamsPos[3].startP = selfP
                self.beamsPos[3].endP = selfP
            elseif d == 4 or d == 0 then --West
                self.beamsPos[4].startP = selfP
                self.beamsPos[4].endP = selfP
            end
        end
    end
end

function NL:directionAsCardinal()
    local direction = self.thisEntity.direction
    if direction == defines.direction.north then
        return 1
    elseif direction == defines.direction.east then
        return 2
    elseif direction == defines.direction.south then
        return 3
    elseif direction == defines.direction.west then
        return 4
    end
    return 1
end

function NL:cardinalsAfterDirection()
    local cardinal = {}
    local direction = self:directionAsCardinal()
    local cardinals = self:getCardinals()
    for _, c in pairs(cardinals) do
        table.insert(cardinal, (direction + c) % 4)
    end
    return cardinal
end

function NL:getCardinals()
    local type = self.type
    if type == Constants.NetworkLasers.NLI.name then
        return {0}
    elseif type == Constants.NetworkLasers.NLE.name then
        return {0, 1}
    elseif type == Constants.NetworkLasers.NLS.name then
        return {0, 2}
    elseif type == Constants.NetworkLasers.NLT.name then
        return {0, 1, 3}
    elseif type == Constants.NetworkLasers.NLC.name then
        return {0, 1, 2, 3}
    else
        return {0}
    end
end

function NL:getCheckArea()
    local direction = self:directionAsCardinal()
    local cardinals = self:getCardinals()
    local x = self.thisEntity.position.x
    local y = self.thisEntity.position.y
    local areas = {}

    for _, c in pairs(cardinals) do
        local d = (direction + c) % 4
        if d == 1 then --North
            table.insert(areas, {direction = 1, startP = {x-0.5, y-64.5}, endP = {x+0.5, y-0.5}})
        elseif d == 2 then --East
            table.insert(areas, {direction = 2, startP = {x+0.5, y-0.5}, endP = {x+64.5, y+0.5}})
        elseif d == 3 then --South
            table.insert(areas, {direction = 3, startP = {x-0.5, y+0.5}, endP = {x+0.5, y+64.5}})
        elseif d == 4 or d == 0 then --West
            table.insert(areas, {direction = 4, startP = {x-64.5, y-0.5}, endP = {x-0.5, y+0.5}})
        else
            table.insert(areas, {direction = 1, startP = {0, 0}, endP = {0, 0}})
        end
    end

    return areas
end

function NL:connectLasers()
    local areas = self:getCheckArea()
    local selfP = self.thisEntity.position
    self:resetBeams()
    for _, area in pairs(areas) do --for some reason it can't detect entities North and West
        local ents = self.thisEntity.surface.find_entities_filtered{area={area.startP, area.endP}}
        local nearest = nil
        for _, ent in pairs(ents) do
            if ent ~= nil and ent.valid == true then
                if (nearest == nil or Util.distance(selfP, ent.position) < Util.distance(selfP, nearest.position)) 
                and string.match(ent.name, "Beam") == nil 
                and ent.name ~= "character"
                --and ent.name ~= Constants.NetworkLasers.NLI.name 
                --and ent.name ~= Constants.NetworkController.name 
                then
                    nearest = ent
                end
            end
        end
        if nearest ~= nil and global.entityTable[nearest.unit_number] ~= nil then
            local obj = global.entityTable[nearest.unit_number]
            --Prevent itself
            if self.focusedObjs[area.direction] ~= nil and self.focusedObjs[area.direction].entID == obj.entID then return end
            --Prevent more than one laser from attaching
            --if obj.sourceObj ~= nil then return end
            --Prevent overriding other networks
            --if self.networkController ~= nil and obj.networkController.network.ID ~= self.networkController.network.ID then return end

            --obj.sourceObj = global.entityTable[self.entID]
            --obj.networkController = self.networkController

            if string.match(obj.thisEntity.name, "RNS_NetworkLaser") ~= nil then
                local thisD = (area.direction+2)%4
                local objC = obj:cardinalsAfterDirection()

                local empty = true
                for _, c in pairs(objC) do
                    if thisD == c then
                        empty = false
                        goto continue
                    end
                    ::continue::
                end
                if empty == true then 
                    self.focusedObjs[area.direction] = nil
                    self:getBeamPosition(nearest, area.direction)
                    self.beams[area.direction] = self.thisEntity.surface.create_entity{name=Constants.Beams.IddleBeam.name, position=self.beamsPos[area.direction].startP, target_position=self.beamsPos[area.direction].endP, source=self.beamsPos[area.direction].startP}
                    goto continue
                end
            end

            self.focusedObjs[area.direction] = obj
            self:getBeamPosition(obj.thisEntity, area.direction)
            self.beams[area.direction] = self.thisEntity.surface.create_entity{name=Constants.Beams.ConnectedBeam.name, position=self.beamsPos[area.direction].startP, target_position=self.beamsPos[area.direction].endP, source=self.beamsPos[area.direction].startP}
        elseif nearest ~= nil then
            self.focusedObjs[area.direction] = nil
            self:getBeamPosition(nearest, area.direction)
            self.beams[area.direction] = self.thisEntity.surface.create_entity{name=Constants.Beams.IddleBeam.name, position=self.beamsPos[area.direction].startP, target_position=self.beamsPos[area.direction].endP, source=self.beamsPos[area.direction].startP}
        elseif nearest == nil then
            self.focusedObjs[area.direction] = nil
            self:getBeamPosition(nil, area.direction)
            self.beams[area.direction] = self.thisEntity.surface.create_entity{name=Constants.Beams.IddleBeam.name, position=self.beamsPos[area.direction].startP, target_position=self.beamsPos[area.direction].endP, source=self.beamsPos[area.direction].startP}
        end
        ::continue::
    end
end

function NL:getNetworkController()
    local selfX = self.thisEntity.position.x
    local selfY = self.thisEntity.position.y
    local selfD = (self:directionAsCardinal()+2)%4
    local bb = {
        startP = {selfX, selfY},
        endP = {selfX, selfY}
    }

    if selfD == 1 then
        bb = {
            startP = {selfX-0.5, selfY-1.5},
            endP = {selfX+0.5, selfY-0.5}
        }
    elseif selfD == 2 then
        bb = {
            startP = {selfX+0.5, selfY-0.5},
            endP = {selfX+1.5, selfY+0.5}
        }
    elseif selfD == 3 then
        bb = {
            startP = {selfX-0.5, selfY+0.5},
            endP = {selfX+0.5, selfY+1.5}
        }
    elseif selfD == 4 or selfD == 0 then
        bb = {
            startP = {selfX-1.5, selfY-0.5},
            endP = {selfX-0.5, selfY+0.5}
        }
    end
    
    local networkController = self.thisEntity.surface.find_entities_filtered{area={bb.startP, bb.endP}, name=Constants.NetworkController.name}[1]
    if networkController == nil or networkController.valid == false then return end

    networkController = global.entityTable[networkController.unit_number]
    if valid(networkController) == false then return end

    self.networkController = networkController
    self.sourceObj = networkController
end

function NL:getTooltips()

end