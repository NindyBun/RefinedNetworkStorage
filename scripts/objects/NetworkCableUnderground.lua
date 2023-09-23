NCug = {
    thisEntity = nil,
    entID = nil,
    arms = nil,
    color = "",
    connectedObjs = nil,
    networkController = nil,
    cardinals = nil,
    targetEntity = nil,
    targetIcon = nil,
    gapIcons = nil
}

function NCug:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = NCug
    t.thisEntity = object
    t.entID = object.unit_number
    for name, color in pairs(Constants.NetworkCables.Cables) do
        if object.name == color.underground.name then
            rendering.draw_sprite{sprite=color.sprites[5].name, target=t.thisEntity, surface=t.thisEntity.surface, render_layer="lower-object-above-shadow"}
            t.color = tostring(name)
            break
        end
    end
    t.gapIcons = {}
    t.arms = {
        [1] = nil, --N
        [2] = nil, --E
        [3] = nil, --S
        [4] = nil, --W
    }
    t.connectedObjs = {
        [1] = {}, --N
        [2] = {}, --E
        [4] = {}, --S
        [3] = {}, --W
    }
    t.cardinals = {
        [1] = false, --N
        [2] = false, --E
        [3] = false, --S
        [4] = false, --W
    }
    t:createArms()
    UpdateSys.addEntity(t)
    return t
end

function NCug:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = NCug
    setmetatable(object, mt)
end

function NCug:remove()
    if self.targetIcon ~= nil then
        rendering.destroy(self.targetIcon)
    end
    UpdateSys.remove(self)
    if self.networkController ~= nil then
        self.networkController.network.shouldRefresh = true
    end
end

function NCug:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function NCug:update()
    --if game.tick % 60 then
        self.lastUpdate = game.tick
        if valid(self) == false then
            self:remove()
            return
        end
        if valid(self.networkController) == false then
            self.networkController = nil
        end
        if self.thisEntity.to_be_deconstructed() == true then return end
        self:createArms()
    --end
end

function NCug:toggleHoverIcon(hovering)
    if hovering then
        self:generateModeIcon()
    elseif not hovering then
        if self.targetIcon ~= nil then rendering.destroy(self.targetIcon) end
        for _, gap in pairs(self.gapIcons) do
            if gap ~= nil then rendering.destroy(gap) end
        end
    end
end

function NCug:generateModeIcon()
    --if self.targetIcon ~= nil then rendering.destroy(self.targetIcon) end
    --for _, gap in pairs(self.gapIcons) do
    --    if gap ~= nil then rendering.destroy(gap) end
    --end
    if self.targetEntity == nil then return end
    if self.targetEntity ~= nil and self.targetEntity.thisEntity ~= nil and self.targetEntity.thisEntity.valid == false then return end
    --self.targetIcon = rendering.draw_sprite{
    --    sprite=Constants.Icons.underground.target.name, 
    --    target=self.targetEntity.thisEntity, 
    --    surface=self.thisEntity.surface,
    --}
    rendering.draw_sprite{
        sprite=Constants.Icons.underground.target.name, 
        target=self.targetEntity.thisEntity, 
        surface=self.thisEntity.surface,
        time_to_live=1
    }
    local dist = math.floor(Util.distance(self.targetEntity.thisEntity.position, self.thisEntity.position))-1
    local xO = 0
    local yO = 0
    if self:getRealDirection() == 1 then
        yO = -1
    elseif self:getRealDirection() == 2 then
        xO = 1
    elseif self:getRealDirection() == 4 then
        xO = -1
    elseif self:getRealDirection() == 3 then
        yO = 1
    end
    if dist <= 0 then return end
    for i=1, dist do
        --self.gapIcons[i] = rendering.draw_sprite{
        --    sprite=Constants.Icons.underground.gap.name, 
        --    target=self.thisEntity,
        --    target_offset = {
        --        xO*i,
        --        yO*i
        --    },
        --    surface=self.thisEntity.surface,
        --    orientation=self:getRealDirection()%2 == 0 and 0.25 or 0,
        --}
        self.gapIcons[i] = rendering.draw_sprite{
            sprite=Constants.Icons.underground.gap.name, 
            target=self.thisEntity,
            target_offset = {
                xO*i,
                yO*i
            },
            surface=self.thisEntity.surface,
            orientation=self:getRealDirection()%2 == 0 and 0.25 or 0,
            time_to_live=1
        }
    end
end

function NCug:resetConnection()
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
    self.targetEntity = nil
    --if self.targetIcon ~= nil then rendering.destroy(self.targetIcon) end
    --for _, gap in pairs(self.gapIcons) do
    --    if gap ~= nil then rendering.destroy(gap) end
    --end
end

function NCug:getCheckArea()
    local x = self.thisEntity.position.x
    local y = self.thisEntity.position.y
    return {
        [1] = {direction = 1, startP = {x-0.5, y-1.5-(self:getDirection() == 1 and Constants.Settings.RNS_CableUnderground_Reach or 0)}, endP = {x+0.5, y-0.5}}, --North
        [2] = {direction = 2, startP = {x+0.5, y-0.5}, endP = {x+1.5+(self:getDirection() == 2 and Constants.Settings.RNS_CableUnderground_Reach or 0), y+0.5}}, --East
        [4] = {direction = 4, startP = {x-0.5, y+0.5}, endP = {x+0.5, y+1.5+(self:getDirection() == 4 and Constants.Settings.RNS_CableUnderground_Reach or 0)}}, --South
        [3] = {direction = 3, startP = {x-1.5-(self:getDirection() == 3 and Constants.Settings.RNS_CableUnderground_Reach or 0), y-0.5}, endP = {x-0.5, y+0.5}}, --West
    }
end

function NCug:createArms()
    local areas = self:getCheckArea()
    local selfP = self.thisEntity.position
    self:resetConnection()
    for _, area in pairs(areas) do
        local ents = self.thisEntity.surface.find_entities_filtered{area={area.startP, area.endP}}
        local nearest = nil
        for _, ent in pairs(ents) do
            if ent ~= nil and ent.valid == true and string.match(ent.name, "RNS_") ~= nil and ent.operable then
                local obj = global.entityTable[ent.unit_number]
                if area.direction == self:getDirection() then
                    if string.match(ent.name, "RNS_NetworkCableRamp") ~= nil and obj.color == self.color and (nearest == nil or Util.distance(selfP, ent.position) < Util.distance(selfP, nearest.position)) then
                        if self:getDirection() == obj:getConnectionDirection() or self:getDirection() == obj:getDirection() then
                            nearest = ent --Need to find a way to isolate ramps from other ramps on the same line
                        end
                    end
                elseif (nearest == nil or Util.distance(selfP, ent.position) < Util.distance(selfP, nearest.position)) then
                    nearest = ent
                end
            end
        end
        if nearest ~= nil and global.entityTable[nearest.unit_number] ~= nil then
            local obj = global.entityTable[nearest.unit_number]
            if (string.match(obj.thisEntity.name, "RNS_NetworkCableIO") ~= nil and obj:getConnectionDirection() == area.direction) or (string.match(obj.thisEntity.name, "RNS_NetworkCableRamp") ~= nil and obj:getConnectionDirection() == area.direction and obj.color ~= self.color) or obj.thisEntity.name == Constants.WirelessGrid.name then
                --Do nothing
            else
                if obj.color == nil and self:getDirection() ~= area.direction then
                    self.arms[area.direction] = rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[self.color].sprites[area.direction].name, target=self.thisEntity, surface=self.thisEntity.surface, render_layer="lower-object-above-shadow"}
                    self.connectedObjs[area.direction] = {obj}
                elseif obj.color ~= "" and obj.color == self.color then
                    if string.match(obj.thisEntity.name, "RNS_NetworkCableRamp") ~= nil then
                        if self:getDirection() == area.direction then
                            if self:getDirection() == obj:getConnectionDirection() then
                                self.targetEntity = obj
                                self.connectedObjs[area.direction] = {obj}
                            end
                        elseif area.direction ~= obj:getConnectionDirection() then
                            self.arms[area.direction] = rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[self.color].sprites[area.direction].name, target=self.thisEntity, surface=self.thisEntity.surface, render_layer="lower-object-above-shadow"}
                            self.connectedObjs[area.direction] = {obj}
                        end
                    else
                        self.arms[area.direction] = rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[self.color].sprites[area.direction].name, target=self.thisEntity, surface=self.thisEntity.surface, render_layer="lower-object-above-shadow"}
                        self.connectedObjs[area.direction] = {obj}
                    end
                end
            end
            if self.cardinals[area.direction] == false then
                self.cardinals[area.direction] = true
                if valid(self.networkController) == true and self.networkController.thisEntity ~= nil and self.networkController.thisEntity.valid == true then
                    self.networkController.network.shouldRefresh = true
                elseif obj.thisEntity.name == Constants.NetworkController.slateEntity.name then
                    obj.network.shouldRefresh = true
                end
            end
        elseif nearest == nil then
            if self.cardinals[area.direction] == true then
                self.cardinals[area.direction] = false
                if valid(self.networkController) == true and self.networkController.thisEntity ~= nil and self.networkController.thisEntity.valid == true then
                    self.networkController.network.shouldRefresh = true
                end
            end
        end
    end
end

function NCug:getTooltips(guiTable, mainFrame, justCreated)
    if justCreated == true then
        guiTable.vars.Gui_Title.caption = {"gui-description.RNS_NetworkCableRamp_Title"}

        local infoFrame = GuiApi.add_frame(guiTable, "InformationFrame", mainFrame, "vertical", true)
		infoFrame.style = Constants.Settings.RNS_Gui.frame_1
		infoFrame.style.vertically_stretchable = true
		infoFrame.style.left_padding = 3
		infoFrame.style.right_padding = 3
		infoFrame.style.right_margin = 3

        GuiApi.add_subtitle(guiTable, "", infoFrame, {"gui-description.RNS_Information"})
        GuiApi.add_label(guiTable, "", infoFrame, {"gui-description.RNS_NetworkCableRamp"}, Constants.Settings.RNS_Gui.white)
    end
end


function NCug:getDirection()
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

function NCug:getConnectionDirection()
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

function NCug:getRealDirection()
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