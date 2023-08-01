--NetworkController object
NC = {
    thisEntity = nil,
    entID = nil,
    updateTick = 300,
    lastUpdate = 0,
    stable = false,
    state = nil,
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
    t:setState(Constants.NetworkController.statesEntity.unstable)
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
    if self.state ~= nil then self.state.destroy() end
    UpdateSys.remove(self)
end
--Is valid
function NC:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function NC:setState(state)
    if self.state ~= nil then self.state.destroy() end
    self.state = self.thisEntity.surface.create_entity{name=state, position=self.thisEntity.position, force="neutral"}
    self.state.destructible = false
    self.state.operable = false
    self.state.minable = false
end

function NC:setActive(set)
    self.stable = set
    if set == true then
        self:setState(Constants.NetworkController.statesEntity.stable)
    elseif set == false then
        self:setState(Constants.NetworkController.statesEntity.unstable)
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
    self.thisEntity.electric_buffer_size = math.max(powerDraw*300, 300) --Takes Joules as a param
    
    if self.thisEntity.energy >= powerDraw and self.thisEntity.energy ~= 0 then
        self:setActive(true)
    else
        self:setActive(false)
    end

    if not self.stable then return end
    local tickItemIO = game.tick % (120/Constants.Settings.RNS_BaseItemIO_Speed) --based on belt speed
    if tickItemIO >= 0.0 and tickItemIO < 1.0 then self:updateItemIO() end

    if game.tick % 60 == 0.0 then self:updateFluidIO() end
end

function NC:updateItemIO()
    for _, item in pairs(self.network.ItemIOTable) do
        item:IO()
    end
end

function NC:updateFluidIO()
    for _, fluid in pairs(self.network.FluidIOTable) do
        fluid:IO()
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
            if ent ~= nil and ent.valid == true and string.match(ent.name, "RNS_") ~= nil and ent.operable then
                if global.entityTable[ent.unit_number] ~= nil then
                    local obj = global.entityTable[ent.unit_number]
                    if string.match(obj.thisEntity.name, "RNS_NetworkCableIO") ~= nil and obj:getConnectionDirection() == area.direction then
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
function NC:getTooltips(guiTable, mainFrame, justCreated)
    if justCreated == true then
        guiTable.vars.Gui_Title.caption = {"gui-description.RNS_NetworkController_Title"}
        mainFrame.style.height = 450

        local infoFrame = GuiApi.add_frame(guiTable, "InformationFrame", mainFrame, "vertical", true)
		infoFrame.style = Constants.Settings.RNS_Gui.frame_1
		infoFrame.style.vertically_stretchable = true
		infoFrame.style.minimal_width = 200
		infoFrame.style.left_margin = 3
		infoFrame.style.left_padding = 3
		infoFrame.style.right_padding = 3

        GuiApi.add_subtitle(guiTable, "", infoFrame, {"gui-description.RNS_Information"})
        --GuiApi.add_label(guiTable, "EnergyUsage", infoFrame, {"gui-description.RNS_NetworkController_EnergyUsage", self.thisEntity.power_usage}, Constants.Settings.RNS_Gui.orange, nil, true)
        --GuiApi.add_label(guiTable, "EnergyBuffer", infoFrame, {"gui-description.RNS_NetworkController_EnergyBuffer", self.thisEntity.electric_buffer_size}, Constants.Settings.RNS_Gui.orange, nil, true)
        
        local connectedStructuresFrame = GuiApi.add_frame(guiTable, "", mainFrame, "vertical")
		connectedStructuresFrame.style = Constants.Settings.RNS_Gui.frame_1
		connectedStructuresFrame.style.vertically_stretchable = true
		connectedStructuresFrame.style.minimal_width = 350
		connectedStructuresFrame.style.left_margin = 3
		connectedStructuresFrame.style.left_padding = 3
		connectedStructuresFrame.style.right_padding = 3

        GuiApi.add_subtitle(guiTable, "", connectedStructuresFrame, {"gui-description.RNS_NetworkController_Connections"})

        local connectedStructuresSP = GuiApi.add_scroll_pane(guiTable, "", connectedStructuresFrame, nil, false)
		connectedStructuresSP.style.vertically_stretchable = true
		connectedStructuresSP.style.bottom_margin = 3

        GuiApi.add_table(guiTable, "ConnectedStructuresTable", connectedStructuresSP, 2, true)
    end

    local infoFrame = guiTable.vars.InformationFrame
    GuiApi.add_label(guiTable, "Status", infoFrame, {"gui-description.RNS_NetworkController_Status", self.stable and "Active" or "Inactive"}, Constants.Settings.RNS_Gui.orange, nil, false)
    GuiApi.add_label(guiTable, "Energy", infoFrame, {"gui-description.RNS_NetworkController_EnergyUsage", self.thisEntity.power_usage}, Constants.Settings.RNS_Gui.orange, nil, false)
    GuiApi.add_progress_bar(guiTable, "EnergyBar", infoFrame, "", self.thisEntity.energy .. "/" .. self.thisEntity.electric_buffer_size, false, nil, self.thisEntity.energy/self.thisEntity.electric_buffer_size, 200, 25)
        
    local ConnectedStructuresTable = guiTable.vars.ConnectedStructuresTable
    ConnectedStructuresTable.clear()

    for _, t in pairs(Constants.Drives.ItemDrive) do
        local name = t.name
        local count = Util.getTableLength(self.network.getOperableObjects(self.network.filter(name, self.network.ItemDriveTable)))
        if count > 0 then
            GuiApi.add_item_frame(guiTable, "", ConnectedStructuresTable, name, count, 64, Constants.Settings.RNS_Gui.label_font_2)
        end
    end

    for _, t in pairs(Constants.Drives.FluidDrive) do
        local name = t.name
        local count = Util.getTableLength(self.network.getOperableObjects(self.network.filter(name, self.network.FluidDriveTable)))
        if count > 0 then
            GuiApi.add_item_frame(guiTable, "", ConnectedStructuresTable, name, count, 64, Constants.Settings.RNS_Gui.label_font_2)
        end
    end

    local itemIOcount = Util.getTableLength(self.network.getOperableObjects(self.network.ItemIOTable))
    if itemIOcount > 0 then
        GuiApi.add_item_frame(guiTable, "", ConnectedStructuresTable, Constants.NetworkCables.itemIO.itemEntity.name, itemIOcount, 64, Constants.Settings.RNS_Gui.label_font_2)
    end

    local fluidIOcount = Util.getTableLength(self.network.getOperableObjects(self.network.FluidIOTable))
    if fluidIOcount > 0 then
        GuiApi.add_item_frame(guiTable, "", ConnectedStructuresTable, Constants.NetworkCables.fluidIO.itemEntity.name, fluidIOcount, 64, Constants.Settings.RNS_Gui.label_font_2)
    end

    local externalIOcount = Util.getTableLength(self.network.getOperableObjects(self.network.ExternalIOTable))
    if externalIOcount > 0 then
        GuiApi.add_item_frame(guiTable, "", ConnectedStructuresTable, Constants.NetworkCables.externalIO.itemEntity.name, externalIOcount, 64, Constants.Settings.RNS_Gui.label_font_2)
    end

    local interfacecount = Util.getTableLength(self.network.getOperableObjects(self.network.NetworkInventoryInterfaceTable))
    if interfacecount > 0 then
        GuiApi.add_item_frame(guiTable, "", ConnectedStructuresTable, Constants.NetworkInventoryInterface.name, interfacecount, 64, Constants.Settings.RNS_Gui.label_font_2)
    end

end