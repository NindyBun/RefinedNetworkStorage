NCbl = {
    thisEntity = nil,
    entID = nil,
    arms = nil,
    color = "",
    connectedObjs = nil,
    networkController = nil,
    cardinals = nil,
}

function NCbl:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = NCbl
    t.thisEntity = object
    t.entID = object.unit_number
    for name, color in pairs(Constants.NetworkCables.Cables) do
        if object.name == color.cable.name then
            rendering.draw_sprite{sprite=color.sprites[5].name, target=t.thisEntity, surface=t.thisEntity.surface, render_layer="lower-object-above-shadow"}
            t.color = tostring(name)
            break
        end
    end
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

function NCbl:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = NCbl
    setmetatable(object, mt)
end

function NCbl:remove()
    --[[for _, arm in pairs(self.arms) do
        if arm ~= nil then
            rendering.destroy(arm)
        end
    end]]
    --global.placedCablesTable[self.thisEntity.surface.index][tostring(self.thisEntity.position)] = nil
    UpdateSys.remove(self)
    if self.networkController ~= nil then
        self.networkController.network.shouldRefresh = true
    end
end

function NCbl:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function NCbl:update()
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
        --if game.tick % 25 then self:createArms() end
    --end
end

function NCbl:resetConnection()
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
    self:resetConnection()
    for _, area in pairs(areas) do
        local ents = self.thisEntity.surface.find_entities_filtered{area={area.startP, area.endP}}
        local nearest = nil
        for _, ent in pairs(ents) do
            if ent ~= nil and ent.valid == true then
                if (nearest == nil or Util.distance(selfP, ent.position) < Util.distance(selfP, nearest.position)) and string.match(ent.name, "RNS_") ~= nil and ent.operable then
                    nearest = ent
                end
            end
        end
        if nearest ~= nil and global.entityTable[nearest.unit_number] ~= nil then
            local obj = global.entityTable[nearest.unit_number]
            if (string.match(obj.thisEntity.name, "RNS_NetworkCableIO") ~= nil and obj:getConnectionDirection() == area.direction) or (string.match(obj.thisEntity.name, "RNS_NetworkCableRamp") ~= nil and obj:getConnectionDirection() == area.direction) or obj.thisEntity.name == Constants.WirelessGrid.name then
                --Do nothing
            else
                if obj.color == nil then
                    self.arms[area.direction] = rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[self.color].sprites[area.direction].name, target=self.thisEntity, surface=self.thisEntity.surface, render_layer="lower-object-above-shadow"}
                    self.connectedObjs[area.direction] = {obj}
                elseif obj.color ~= "" and obj.color == self.color then
                    self.arms[area.direction] = rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[self.color].sprites[area.direction].name, target=self.thisEntity, surface=self.thisEntity.surface, render_layer="lower-object-above-shadow"}
                    self.connectedObjs[area.direction] = {obj}
                end
            end
            if self.cardinals[area.direction] == false then
                self.cardinals[area.direction] = true
                if valid(self.networkController) == true and self.networkController.thisEntity ~= nil and self.networkController.thisEntity.valid == true then
                    self.networkController.network.shouldRefresh = true
                elseif obj.thisEntity.name == Constants.NetworkController.main.name then
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

function NCbl:getTooltips(guiTable, mainFrame, justCreated)
    if justCreated == true then
        guiTable.vars.Gui_Title.caption = {"gui-description.RNS_NetworkCable_Title"}

        local infoFrame = GuiApi.add_frame(guiTable, "InformationFrame", mainFrame, "vertical", true)
		infoFrame.style = Constants.Settings.RNS_Gui.frame_1
		infoFrame.style.vertically_stretchable = true
		infoFrame.style.left_padding = 3
		infoFrame.style.right_padding = 3
		infoFrame.style.right_margin = 3

        GuiApi.add_subtitle(guiTable, "", infoFrame, {"gui-description.RNS_Information"})
        GuiApi.add_label(guiTable, "", infoFrame, {"gui-description.RNS_NetworkCable"}, Constants.Settings.RNS_Gui.white)
    end
end