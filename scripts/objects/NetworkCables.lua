NCbl = {
    thisEntity = nil,
    entID = nil,
    arms = nil,
    updateTick = 60,
    lastUpdate = 0,
}

function NCbl:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = NCbl
    t.thisEntity = object
    t.entID = object.unit_number
    rendering.draw_sprite{sprite="NetworkCableDot", target=t.thisEntity, surface=t.thisEntity.surface, render_layer="lower-object-above-shadow"}
    t.arms = {
        [1] = nil, --N
        [2] = nil, --E
        [3] = nil, --S
        [4] = nil, --W
    }
    --t:createArm()
    UpdateSys.addEntity(t)
    return t
end

function NCbl:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = NCblL
    setmetatable(object, mt)
end

function NCbl:remove()
    for _, arm in pairs(self.arms) do
        if arm ~= nil then
            rendering.destroy(arm)
        end
    end
    UpdateSys.remove(self)
end

function NCbl:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid
end

function NCbl:update()
    --if game.tick % 60 then
        self.lastUpdate = game.tick
        if valid(self) == false then
            self:remove()
            return
        end
        self:createArms()
    --end
end

function NCbl:resetArms()
    for _, arm in pairs(self.arms) do
        if arm ~= nil then
            rendering.destroy(arm)
        end
    end
end

function NCbl:getCheckArea()
    local x = self.thisEntity.position.x
    local y = self.thisEntity.position.y
    return {
        [1] = {direction = 1, startP = {x-0.5, y-1.5}, endP = {x+0.5, y-0.5}}, --North
        [2] = {direction = 2, startP = {x+0.5, y-0.5}, endP = {x+1.5, y+0.5}}, --East
        [4] = {direction = 4, startP = {x-0.5, y+0.5}, endP = {x+0.5, y+1.5}}, --South
        [3] = {direction = 3, startP = {x-1.5, y-0.5}, endP = {x-0.5, y+0.5}}, --West
    }
end

function NCbl:createArms()
    local areas = self:getCheckArea()
    local selfP = self.thisEntity.position
    self:resetArms()
    for _, area in pairs(areas) do --for some reason it can't detect entities North and West
        local ents = self.thisEntity.surface.find_entities_filtered{area={area.startP, area.endP}}
        local nearest = nil
        for _, ent in pairs(ents) do
            if ent ~= nil and ent.valid == true then
                if (nearest == nil or Util.distance(selfP, ent.position) < Util.distance(selfP, nearest.position)) and string.match(ent.name, "RNS") ~= nil then
                    nearest = ent
                end
            end
        end
        if nearest ~= nil and global.entityTable[nearest.unit_number] ~= nil and nearest.name ~= Constants.NetworkController.name then
            self.arms[area.direction] = rendering.draw_sprite{sprite=Constants.NetworkCables.Sprites[area.direction].name, target=self.thisEntity, surface=self.thisEntity.surface, render_layer="lower-object-above-shadow"}
        end
    end
end

function NCbl:getTooltips()

end