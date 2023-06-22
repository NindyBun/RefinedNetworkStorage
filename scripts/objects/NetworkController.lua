--NetworkController object
NC = {
    thisEntity = nil,
    entID = nil,
    updateTick = 300,
    lastUpdate = 0,
    stable = false,
    stateSprite = nil,
    network = nil
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
    t.stateSprite = rendering.draw_sprite{sprite=Constants.NetworkController.name.."_unstable", target=t.thisEntity, surface=t.thisEntity.surface, render_layer=131}
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
    return self.thisEntity ~= nil and self.thisEntity.valid
end

function NC:setActive(set)
    self.stable = set
    if set == true then
        rendering.destroy(self.stateSprite)
        self.stateSprite = rendering.draw_sprite{sprite=Constants.NetworkController.name.."_stable", target=self.thisEntity, surface=self.thisEntity.surface, render_layer=131}
    elseif set == false then
        rendering.destroy(self.stateSprite)
        self.stateSprite = rendering.draw_sprite{sprite=Constants.NetworkController.name.."_unstable", target=self.thisEntity, surface=self.thisEntity.surface, render_layer=131}
    end
end

function NC:update()
    self.lastUpdate = game.tick
    if valid(self) == false then
        self:remove()
        return
    end

    local powerDraw = math.max(self.network:getTotalObjects(), 1)
    --1.8MW buffer but 15KW energy at 900KMW- input
    --1.8MW buffer but 30KW energy at 1.8MW- input
    --1.8MW buffer but 1.8MW energy at 1.8MW+ input
    --Can check if energy*60 >= buffer then NC is stable
    --1 Joule converts to 60 Watts? How strange
    self.thisEntity.power_usage = powerDraw --Takes Joules as a param
    self.thisEntity.electric_buffer_size = powerDraw--Takes Joules as a param
    
    if self.thisEntity.energy >= powerDraw then
        self:setActive(true)
    else
        self:setActive(false)
    end


end

--Tooltips
function NC:getTooltips(GUI)
    
end