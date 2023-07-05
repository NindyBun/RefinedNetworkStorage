--NetworkController object
NC = {
    thisEntity = nil,
    entID = nil,
    updateTick = 300,
    lastUpdate = 0,
    stable = false,
    stateSprite = nil,
    network = nil,
    connectedObjs = nil
}

--Constructor
function NC:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = NC
    t.thisEntity = object
    t.entID = object.unit_number
    t.network = t.network or BaseNet:new()
    t.network.networkController = t
    t.stateSprite = rendering.draw_sprite{sprite=Constants.NetworkController.entity.name.."_unstable", target=t.thisEntity, surface=t.thisEntity.surface, render_layer=131}
    t.connectedObjs = {
        [1] = {}, --N
        [2] = {}, --E
        [3] = {}, --S
        [4] = {}, --W
    }
    t:collect()
    t.network.shouldRefresh = true
    UpdateSys.addEntity(t)
    return t
end

--Reconstructor
function NC:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = NC
    setmetatable(object, mt)
    BaseNet:rebuild(object.network)
end

--Deconstructor
function NC:remove()
    global.networkID[self.network.ID+1].used = false
    UpdateSys.remove(self)
end
--Is valid
function NC:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function NC:setActive(set)
    self.stable = set
    if set == true then
        rendering.destroy(self.stateSprite)
        self.stateSprite = rendering.draw_sprite{sprite=Constants.NetworkController.entity.name.."_stable", target=self.thisEntity, surface=self.thisEntity.surface, render_layer="lower-object-above-shadow"}
    elseif set == false then
        rendering.destroy(self.stateSprite)
        self.stateSprite = rendering.draw_sprite{sprite=Constants.NetworkController.entity.name.."_unstable", target=self.thisEntity, surface=self.thisEntity.surface, render_layer="lower-object-above-shadow"}
    end
end

function NC:update()
    self.lastUpdate = game.tick
    if valid(self) == false then
        self:remove()
        return
    end
    if self.thisEntity.to_be_deconstructed() == true then return end
    self:collect()
    if game.tick % 600 == 0 or self.network.shouldRefresh == true then --Refreshes connections every 10 seconds
        self.network:doRefresh(self)
    end
    local powerDraw = self.network:getTotalObjects()
    --1.8MW buffer but 15KW energy at 900KMW- input
    --1.8MW buffer but 30KW energy at 1.8MW- input
    --1.8MW buffer but 1.8MW energy at 1.8MW+ input
    --Can check if energy*60 >= buffer then NC is stable
    --1 Joule converts to 60 Watts? How strange
    self.thisEntity.power_usage = powerDraw --Takes Joules as a param
    self.thisEntity.electric_buffer_size = math.max(powerDraw*300, 1) --Takes Joules as a param
    
    if self.thisEntity.energy >= powerDraw and self.thisEntity.energy ~= 0 then
        self:setActive(true)
    else
        self:setActive(false)
    end

    if not self.stable then return end
    local tickItemIO = game.tick % (120/Constants.Settings.RNS_BaseItemIO_Speed) --based on belt speed
    if tickItemIO >= 0.0 and tickItemIO < 1.0 then self:updateItemIO() end
end

function NC:updateItemIO()
    for _, item in pairs(self.network.ItemIOTable) do
        item:IO()
    end
end

function NC:resetCollection()
    self.connectedObjs = {
        [1] = {}, --N
        [2] = {}, --E
        [3] = {}, --S
        [4] = {}, --W
    }
end

function NC:getCheckArea()
    local x = self.thisEntity.position.x
    local y = self.thisEntity.position.y
    return {
        [1] = {direction = 1, startP = {x-1.5, y-2.5}, endP = {x+1.5, y-1.5}}, --North
        [2] = {direction = 2, startP = {x+1.5, y-1.5}, endP = {x+2.5, y+1.5}}, --East
        [4] = {direction = 4, startP = {x-1.5, y+1.5}, endP = {x+1.5, y+2.5}}, --South
        [3] = {direction = 3, startP = {x-2.5, y-1.5}, endP = {x-1.5, y+1.5}}, --West
    }
end

function NC:collect()
    local areas = self:getCheckArea()
    self:resetCollection()
    for _, area in pairs(areas) do
        local ents = self.thisEntity.surface.find_entities_filtered{area={area.startP, area.endP}}
        for _, ent in pairs(ents) do
            if ent ~= nil and ent.valid == true and string.match(ent.name, "RNS_") ~= nil then
                if global.entityTable[ent.unit_number] ~= nil then
                    local obj = global.entityTable[ent.unit_number]
                    if string.match(obj.thisEntity.name, "RNS_NetworkCableIO") ~= nil and obj.connectionDirection == area.direction then
                        --Do nothing
                    else
                        table.insert(self.connectedObjs[area.direction], obj)
                    end
                end
            end
        end
    end
end

--Tooltips
function NC:getTooltips(GUI)
    
end