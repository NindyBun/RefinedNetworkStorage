--NetworkController object
NC = {
    thisEntity = nil,
    entID = nil,
    updateTick = 600,
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
    t:setState(Constants.NetworkController.states.unstable)
    t.connectedObjs = {
        [1] = {}, --N
        [2] = {}, --E
        [3] = {}, --S
        [4] = {}, --W
    }
    t:createArms()
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
    self.network:doRefresh(self)
    if self.state ~= nil then rendering.destroy(self.state) end
    UpdateSys.remove(self)
end
--Is valid
function NC:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function NC:setState(state)
    if self.state ~= nil then rendering.destroy(self.state) end
    self.state = rendering.draw_sprite{sprite=state, target=self.thisEntity, surface=self.thisEntity.surface, render_layer="lower-object-above-shadow"}
end

function NC:setActive(set)
    self.stable = set
    if set == true then
        self:setState(Constants.NetworkController.states.stable)
    elseif set == false then
        self:setState(Constants.NetworkController.states.unstable)
    end
end

function NC:update()
    self.lastUpdate = game.tick
    if valid(self) == false then
        self:remove()
        return
    end
    if self.thisEntity.to_be_deconstructed() == true then return end
    --if game.tick % 25 then self:createArms() end
    if game.tick % self.updateTick == 0 or self.network.shouldRefresh == true or game.tick > self.lastUpdate then --Refreshes connections every 10 seconds
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

    if game.tick % Constants.Settings.RNS_CollectContents_Tick == 0 then self:collectContents() end
    if game.tick % Constants.Settings.RNS_Detector_Tick == 0 then self:updateDetectors() end

    if game.tick % Constants.Settings.RNS_ItemIO_Tick == 0 then self:updateItemIO() end --Base is every 4 ticks to match yellow belt speed at 15/s
    --local tickItemBeltIO = game.tick % (120/Constants.Settings.RNS_BaseItemIO_TickSpeed) --speed based on 1 side of a belt
    --if tickItemBeltIO >= 0.0 and tickItemBeltIO < 1.0 then self:updateItemIO(true) end

    if game.tick % Constants.Settings.RNS_FluidIO_Tick == 0 then self:updateFluidIO() end --Base is every 5 ticks to match offshore pump speed at 1200/s

    if game.tick % Constants.Settings.RNS_WirelessTransmitter_Tick == 0 then self:find_players_with_wirelessTransmitter() end --Updates every 30 ticks
end

function NC:updateDetectors()
    for _, detector in pairs(BaseNet.getOperableObjects(self.network.DetectorTable)[1]) do
        if detector.thisEntity ~= nil and detector.thisEntity.valid == true and detector.thisEntity.to_be_deconstructed() == false then
            detector:update_signal()
        end
    end
end

function NC:collectContents()
    self.network.Contents = {
        item = {},
        fluid = {}
    }
    local itemDrives = BaseNet.getOperableObjects(self.network.ItemDriveTable)
    local fluidDrives = BaseNet.getOperableObjects(self.network.FluidDriveTable)
    local validExternals = self.network:filter_externalIO_by_valid_signal()
    local externalInvs = BaseNet.filter_by_mode("output", BaseNet.filter_by_type("item", BaseNet.getOperableObjects(validExternals)))
    local externalTanks = BaseNet.filter_by_mode("output", BaseNet.filter_by_type("fluid", BaseNet.getOperableObjects(validExternals)))

    for i = 1, Constants.Settings.RNS_Max_Priority*2+1 do
        local priorityItems = itemDrives[i]
        local priorityFluids = fluidDrives[i]
        local priorityInvs = externalInvs[i]
        local priorityTanks = externalTanks[i]

        if Util.getTableLength(priorityItems) > 0 then
            for _, drive in pairs(priorityItems) do
                for name, content in pairs(drive.storageArray) do
                    self.network.Contents.item[name] = math.min((self.network.Contents.item[name] or 0) + content.count, 2^32)
                end
            end
        end
        if Util.getTableLength(priorityFluids) > 0 then
            for _, drive in pairs(priorityFluids) do
                for name, content in pairs(drive.fluidArray) do
                    self.network.Contents.fluid[name] = math.min((self.network.Contents.fluid[name] or 0) + content.amount, 2^32)
                end
            end
        end
        if Util.getTableLength(priorityInvs) > 0 then
            for _, eInv in pairs(priorityInvs) do
                if string.match(eInv.io, "output") == nil then goto next end
                if eInv.focusedEntity.thisEntity ~= nil and eInv.focusedEntity.thisEntity.valid == true and eInv.focusedEntity.thisEntity.to_be_deconstructed() == false and eInv.focusedEntity.inventory.values ~= nil then
                    local index = 0
                    repeat
                        local ii = Util.next(eInv.focusedEntity.inventory)
                        local inv = eInv.focusedEntity.thisEntity.get_inventory(ii.slot)
                        if inv ~= nil and IIO.check_operable_mode(ii.io, "output") then
                            for name, count in pairs(inv.get_contents()) do
                                self.network.Contents.item[name] = math.min((self.network.Contents.item[name] or 0) + count, 2^32)
                            end
                        end
                        index = index + 1
                    until index == Util.getTableLength(eInv.focusedEntity.inventory.values)
                end
                ::next::
            end
        end
        if Util.getTableLength(priorityTanks) > 0 then
            for _, eTank in pairs(priorityTanks) do
                local fluid_box = eTank.focusedEntity.fluid_box
                if string.match(fluid_box.flow, "output") == nil then goto next end
                if eTank.focusedEntity.thisEntity ~= nil and eTank.focusedEntity.thisEntity.valid == true and eTank.focusedEntity.thisEntity.to_be_deconstructed() == false and eTank.focusedEntity.fluid_box.index ~= nil then
                    local tank = eTank.focusedEntity.thisEntity.fluidbox[fluid_box.index]
                    if tank == nil then goto next end
                    self.network.Contents.fluid[tank.name] = math.min((self.network.Contents.fluid[tank.name] or 0) + tank.amount, 2^32)
                end
                ::next::
            end
        end
    end
end

function NC:find_players_with_wirelessTransmitter()
    local processed_players = {}
    for _, transmitter in pairs(BaseNet.getOperableObjects(self.network.WirelessTransmitterTable)[1]) do
        --For Players
        if global.WTRangeMultiplier ~= -1 then
            local characters = self.thisEntity.surface.find_entities_filtered{
                type = "character",
                area = {
                    {transmitter.thisEntity.position.x-0.5-Constants.Settings.RNS_Default_WirelessGrid_Distance*global.WTRangeMultiplier, transmitter.thisEntity.position.y-0.5-Constants.Settings.RNS_Default_WirelessGrid_Distance*global.WTRangeMultiplier}, --top left
                    {transmitter.thisEntity.position.x+0.5+Constants.Settings.RNS_Default_WirelessGrid_Distance*global.WTRangeMultiplier, transmitter.thisEntity.position.y+0.5+Constants.Settings.RNS_Default_WirelessGrid_Distance*global.WTRangeMultiplier} --bottom right
                }
            }
            for _, character in pairs(characters) do
                if character.player ~= nil and self.network.PlayerPorts[character.player.name] ~= nil then
                    local RNSPlayer = getRNSPlayer(character.player.index)
                    if RNSPlayer ~= nil and RNSPlayer.thisEntity ~= nil and RNSPlayer.thisEntity.valid == true and processed_players[character.player.index] == nil then
                        RNSPlayer:process_logistic_slots(self.network)
                        processed_players[character.player.index] = RNSPlayer
                    end
                end
            end
        else
            for _, RNSPlayer in pairs(global.playerTable) do
                if RNSPlayer ~= nil and RNSPlayer.thisEntity ~= nil and RNSPlayer.thisEntity.valid == true and self.network.PlayerPorts[RNSPlayer.thisEntity.name] ~= nil and processed_players[RNSPlayer.thisEntity.name] == nil then
                    if RNSPlayer.thisEntity.surface.index ~= transmitter.thisEntity.surface.index then goto next end
                    --local RNSPlayer = getRNSPlayer(player.index)
                    --if RNSPlayer ~= nil and RNSPlayer.thisEntity ~= nil and RNSPlayer.thisEntity.valid == true and processed_players[RNSPlayer.thisEntity.name] == nil then
                        RNSPlayer:process_logistic_slots(self.network)
                        processed_players[RNSPlayer.thisEntity.name] = RNSPlayer
                    --end
                end
                ::next::
            end
        end
    end

end

function NC:find_wirelessgrid_with_wirelessTransmitter(id)
    for _, transmitter in pairs(BaseNet.getOperableObjects(self.network.WirelessTransmitterTable)[1]) do
        --For Portable Wireless Grids
        if global.WTRangeMultiplier ~= -1 then
            local interfaces = self.thisEntity.surface.find_entities_filtered{
                    name = Constants.WirelessGrid.name,
                    area = {
                        {transmitter.thisEntity.position.x-0.5-Constants.Settings.RNS_Default_WirelessGrid_Distance*global.WTRangeMultiplier, transmitter.thisEntity.position.y-0.5-Constants.Settings.RNS_Default_WirelessGrid_Distance*global.WTRangeMultiplier}, --top left
                        {transmitter.thisEntity.position.x+0.5+Constants.Settings.RNS_Default_WirelessGrid_Distance*global.WTRangeMultiplier, transmitter.thisEntity.position.y+0.5+Constants.Settings.RNS_Default_WirelessGrid_Distance*global.WTRangeMultiplier} --bottom right
                    }
                }
            for _, interface in pairs(interfaces) do
                if interface.unit_number == id then
                    local inter = global.entityTable[interface.unit_number]
                    if inter ~= nil and inter.thisEntity ~= nil and inter.thisEntity.valid == true then
                        if inter.network_controller_position.x ~= nil and inter.network_controller_position.y ~= nil and inter.network_controller_surface ~= nil then
                            if inter.network_controller_surface == self.thisEntity.surface.index and Util.positions_match(inter.network_controller_position, self.thisEntity.position) == true then
                                return true
                            end
                        end
                    end
                end
            end
        else
            local inter = global.entityTable[id]
            if inter ~= nil and inter.thisEntity ~= nil and inter.thisEntity.valid == true then
                if inter.network_controller_position.x ~= nil and inter.network_controller_position.y ~= nil and inter.network_controller_surface ~= nil then
                    if inter.network_controller_surface == self.thisEntity.surface.index and Util.positions_match(inter.network_controller_position, self.thisEntity.position) == true then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function NC:updateItemIO()
    local import = {}
    local export = {}
    local processed = 0
    for p, priority in pairs(BaseNet.getOperableObjects(self.network.ItemIOTable)) do
        import[p] = {}
        export[p] = {}
        for _, item in pairs(priority) do
            if item.io == "input" then table.insert(import[p], item) end
            if item.io == "output" then table.insert(export[p], item) end
        end
    end
    for _, priority in pairs(import) do
        for _, item in pairs(priority) do
            item:IO()
        end
    end
    for _, priority in pairs(export) do
        for _, item in pairs(priority) do
            if item.processed == false and settings.global[Constants.Settings.RNS_RoundRobin].value == true then
                item:IO()
            elseif settings.global[Constants.Settings.RNS_RoundRobin].value == false then
                item:IO()
            end
            if item.processed == true then processed = processed + 1 end
        end
    end
    if processed == BaseNet.get_table_length_in_priority(export) and settings.global[Constants.Settings.RNS_RoundRobin].value == true then
        for _, priority in pairs(export) do
            for _, item in pairs(priority) do
                item.processed = false
            end
        end
    end
end

function NC:updateFluidIO()
    local import = {}
    local export = {}
    local processed = 0
    for p, priority in pairs(BaseNet.getOperableObjects(self.network.FluidIOV2Table)) do
        import[p] = {}
        export[p] = {}
        for _, fluid in pairs(priority) do
            if fluid.io == "input" then table.insert(import[p], fluid) end
            if fluid.io == "output" then table.insert(export[p], fluid) end
        end
    end
    for _, priority in pairs(import) do
        for _, fluid in pairs(priority) do
            fluid:IO()
        end
    end
    for _, priority in pairs(export) do
        for _, fluid in pairs(priority) do
            if fluid.processed == false and settings.global[Constants.Settings.RNS_RoundRobin].value == true then
                fluid:IO()
            elseif settings.global[Constants.Settings.RNS_RoundRobin].value == false then
                fluid:IO()
            end
            if fluid.processed == true then processed = processed + 1 end
        end
    end
    if processed == BaseNet.get_table_length_in_priority(export) and settings.global[Constants.Settings.RNS_RoundRobin].value == true then
        for _, priority in pairs(export) do
            for _, fluid in pairs(priority) do
                fluid.processed = false
            end
        end
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

function NC:createArms()
    local areas = self:getCheckArea()
    self:resetCollection()
    for _, area in pairs(areas) do
        local ents = self.thisEntity.surface.find_entities_filtered{area={area.startP, area.endP}}
        for _, ent in pairs(ents) do
            if ent ~= nil and ent.valid == true and string.match(ent.name, "RNS_") ~= nil then
                if global.entityTable[ent.unit_number] ~= nil then
                    local obj = global.entityTable[ent.unit_number]
                    if (string.match(obj.thisEntity.name, "RNS_NetworkCableIO") ~= nil and obj:getConnectionDirection() == area.direction) or (string.match(obj.thisEntity.name, "RNS_NetworkCableRamp") ~= nil and obj:getConnectionDirection() == area.direction) or obj.thisEntity.name == Constants.WirelessGrid.name then
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

        GuiApi.add_label(guiTable, "EnergyUsage", infoFrame, {"gui-description.RNS_NetworkController_EnergyUsage", self.thisEntity.power_usage}, Constants.Settings.RNS_Gui.orange, nil, true)
        GuiApi.add_label(guiTable, "EnergyBuffer", infoFrame, {"gui-description.RNS_NetworkController_EnergyBuffer", self.thisEntity.electric_buffer_size}, Constants.Settings.RNS_Gui.orange, nil, true)
        GuiApi.add_progress_bar(guiTable, "EnergyBar", infoFrame, "", self.thisEntity.energy .. "/" .. self.thisEntity.electric_buffer_size, true, nil, self.thisEntity.energy/self.thisEntity.electric_buffer_size, 200, 25)
        
        GuiApi.add_label(guiTable, "", infoFrame, {"gui-description.RNS_Position", self.thisEntity.position.x, self.thisEntity.position.y}, Constants.Settings.RNS_Gui.white, "", false)
        GuiApi.add_label(guiTable, "", infoFrame, {"gui-description.RNS_Surface", self.thisEntity.surface.index}, Constants.Settings.RNS_Gui.white, "", false)

        --local connectedStructuresFrame = GuiApi.add_frame(guiTable, "", mainFrame, "vertical")
		--connectedStructuresFrame.style = Constants.Settings.RNS_Gui.frame_1
		--connectedStructuresFrame.style.vertically_stretchable = true
		--connectedStructuresFrame.style.minimal_width = 350
		--connectedStructuresFrame.style.left_margin = 3
		--connectedStructuresFrame.style.left_padding = 3
		--connectedStructuresFrame.style.right_padding = 3

        local connectedStructuresFlow = GuiApi.add_flow(guiTable, "", mainFrame, "vertical")

        GuiApi.add_subtitle(guiTable, "", connectedStructuresFlow, {"gui-description.RNS_NetworkController_Connections"})

        local connectedStructuresSP = GuiApi.add_scroll_pane(guiTable, "", connectedStructuresFlow, nil, false)
		connectedStructuresSP.style.vertically_stretchable = true
		connectedStructuresSP.style.bottom_margin = 3

        GuiApi.add_table(guiTable, "ConnectedStructuresTable", connectedStructuresSP, 2, true)
    end

    local energyUsage = guiTable.vars.EnergyUsage
    local energyBuffer = guiTable.vars.EnergyBuffer
    local energyBar = guiTable.vars.EnergyBar

    energyUsage.caption = {"gui-description.RNS_NetworkController_EnergyUsage", self.thisEntity.power_usage}
    energyBuffer.caption = {"gui-description.RNS_NetworkController_EnergyBuffer", self.thisEntity.electric_buffer_size}
    energyBar.tooltip = self.thisEntity.energy .. "/" .. self.thisEntity.electric_buffer_size
    energyBar.value = self.thisEntity.energy/self.thisEntity.electric_buffer_size

    local ConnectedStructuresTable = guiTable.vars.ConnectedStructuresTable
    ConnectedStructuresTable.clear()

    for _, t in pairs(Constants.Drives.ItemDrive) do
        local name = t.name
        local count = BaseNet.get_table_length_in_priority(self.network.getOperableObjects(self.network.filter_by_name(name, self.network.ItemDriveTable)))
        if count > 0 then
            local section = GuiApi.add_frame(guiTable, "", ConnectedStructuresTable, "vertical")
            section.style = Constants.Settings.RNS_Gui.frame_1
            section.style.minimal_width = 200
            GuiApi.add_label(guiTable, "", section, game.item_prototypes[name].localised_name, Constants.Settings.RNS_Gui.white, "", false, Constants.Settings.RNS_Gui.label_font)
            GuiApi.add_item_frame(guiTable, "", section, t.powerUsage .. "/t", name, count .. "x", 64, Constants.Settings.RNS_Gui.label_font_2)
        end
    end

    for _, t in pairs(Constants.Drives.FluidDrive) do
        local name = t.name
        local count = BaseNet.get_table_length_in_priority(self.network.getOperableObjects(self.network.filter_by_name(name, self.network.FluidDriveTable)))
        if count > 0 then
            local section = GuiApi.add_frame(guiTable, "", ConnectedStructuresTable, "vertical")
            section.style = Constants.Settings.RNS_Gui.frame_1
            section.style.minimal_width = 200
            GuiApi.add_label(guiTable, "", section, game.item_prototypes[name].localised_name, Constants.Settings.RNS_Gui.white, "", false, Constants.Settings.RNS_Gui.label_font)
            GuiApi.add_item_frame(guiTable, "", section, t.powerUsage .. "/t", name, count .. "x", 64, Constants.Settings.RNS_Gui.label_font_2)
        end
    end

    local itemIOcount = BaseNet.get_table_length_in_priority(self.network.getOperableObjects(self.network.ItemIOTable))
    if itemIOcount > 0 then
        local name = Constants.NetworkCables.itemIO.name
        local section = GuiApi.add_frame(guiTable, "", ConnectedStructuresTable, "vertical")
        section.style = Constants.Settings.RNS_Gui.frame_1
        section.style.minimal_width = 200
        GuiApi.add_label(guiTable, "", section, game.item_prototypes[name].localised_name, Constants.Settings.RNS_Gui.white, "", false, Constants.Settings.RNS_Gui.label_font)
        GuiApi.add_item_frame(guiTable, "", section, _G.IIO3.powerUsage*global.IIOMultiplier .. "/t", name, itemIOcount .. "x", 64, Constants.Settings.RNS_Gui.label_font_2)
    end

    local itemIOV2count = BaseNet.get_table_length_in_priority(self.network.getOperableObjects(self.network.ItemIOV2Table))
    if itemIOV2count > 0 then
        local name = "RNS_NetworkCableIOV2_Item"
        local section = GuiApi.add_frame(guiTable, "", ConnectedStructuresTable, "vertical")
        section.style = Constants.Settings.RNS_Gui.frame_1
        section.style.minimal_width = 200
        GuiApi.add_label(guiTable, "", section, game.item_prototypes[name].localised_name, Constants.Settings.RNS_Gui.white, "", false, Constants.Settings.RNS_Gui.label_font)
        GuiApi.add_item_frame(guiTable, "", section, _G.IIO2.powerUsage*global.IIOMultiplier .. "/t", name, itemIOV2count .. "x", 64, Constants.Settings.RNS_Gui.label_font_2)
    end

    local fluidIOcount = BaseNet.get_table_length_in_priority(self.network.getOperableObjects(self.network.FluidIOTable))
    if fluidIOcount > 0 then
        local name = Constants.NetworkCables.fluidIO.name
        local section = GuiApi.add_frame(guiTable, "", ConnectedStructuresTable, "vertical")
        section.style = Constants.Settings.RNS_Gui.frame_1
        section.style.minimal_width = 200
        GuiApi.add_label(guiTable, "", section, game.item_prototypes[name].localised_name, Constants.Settings.RNS_Gui.white, "", false, Constants.Settings.RNS_Gui.label_font)
        GuiApi.add_item_frame(guiTable, "", section, _G.FIO.powerUsage*global.FIOMultiplier .. "/t", name, fluidIOcount .. "x", 64, Constants.Settings.RNS_Gui.label_font_2)
    end

    local fluidIOV2count = BaseNet.get_table_length_in_priority(self.network.getOperableObjects(self.network.FluidIOV2Table))
    if fluidIOV2count > 0 then
        local name = "RNS_NetworkCableIOV2_Fluid"
        local section = GuiApi.add_frame(guiTable, "", ConnectedStructuresTable, "vertical")
        section.style = Constants.Settings.RNS_Gui.frame_1
        section.style.minimal_width = 200
        GuiApi.add_label(guiTable, "", section, game.item_prototypes[name].localised_name, Constants.Settings.RNS_Gui.white, "", false, Constants.Settings.RNS_Gui.label_font)
        GuiApi.add_item_frame(guiTable, "", section, _G.FIO2.powerUsage*global.FIOMultiplier .. "/t", name, fluidIOV2count .. "x", 64, Constants.Settings.RNS_Gui.label_font_2)
    end

    local externalIOcount = BaseNet.get_table_length_in_priority(self.network.getOperableObjects(self.network.ExternalIOTable))
    if externalIOcount > 0 then
        local name = Constants.NetworkCables.externalIO.name
        local section = GuiApi.add_frame(guiTable, "", ConnectedStructuresTable, "vertical")
        section.style = Constants.Settings.RNS_Gui.frame_1
        section.style.minimal_width = 200
        GuiApi.add_label(guiTable, "", section, game.item_prototypes[name].localised_name, Constants.Settings.RNS_Gui.white, "", false, Constants.Settings.RNS_Gui.label_font)
        GuiApi.add_item_frame(guiTable, "", section, _G.EIO.powerUsage .. "/t", name, externalIOcount .. "x", 64, Constants.Settings.RNS_Gui.label_font_2)
    end

    local interfacecount = BaseNet.get_table_length_in_priority(self.network.getOperableObjects(self.network.NetworkInventoryInterfaceTable))
    if interfacecount > 0 then
        local name = Constants.NetworkInventoryInterface.name
        local section = GuiApi.add_frame(guiTable, "", ConnectedStructuresTable, "vertical")
        section.style = Constants.Settings.RNS_Gui.frame_1
        section.style.minimal_width = 200
        GuiApi.add_label(guiTable, "", section, game.item_prototypes[name].localised_name, Constants.Settings.RNS_Gui.white, "", false, Constants.Settings.RNS_Gui.label_font)
        GuiApi.add_item_frame(guiTable, "", section, _G.NII.powerUsage .. "/t", name, interfacecount .. "x", 64, Constants.Settings.RNS_Gui.label_font_2)
    end

    local wirelessTransmittercount = BaseNet.get_table_length_in_priority(self.network.getOperableObjects(self.network.WirelessTransmitterTable))
    if wirelessTransmittercount > 0 then
        local name = Constants.NetworkCables.wirelessTransmitter.name
        local section = GuiApi.add_frame(guiTable, "", ConnectedStructuresTable, "vertical")
        section.style = Constants.Settings.RNS_Gui.frame_1
        section.style.minimal_width = 200
        GuiApi.add_label(guiTable, "", section, game.item_prototypes[name].localised_name, Constants.Settings.RNS_Gui.white, "", false, Constants.Settings.RNS_Gui.label_font)
        GuiApi.add_item_frame(guiTable, "", section, _G.WT.powerUsage*global.WTRangeMultiplier .. "/t", name, wirelessTransmittercount .. "x", 64, Constants.Settings.RNS_Gui.label_font_2)
    end

    local detectorcount = BaseNet.get_table_length_in_priority(self.network.getOperableObjects(self.network.DetectorTable))
    if detectorcount > 0 then
        local name = Constants.Detector.name
        local section = GuiApi.add_frame(guiTable, "", ConnectedStructuresTable, "vertical")
        section.style = Constants.Settings.RNS_Gui.frame_1
        section.style.minimal_width = 200
        GuiApi.add_label(guiTable, "", section, game.item_prototypes[name].localised_name, Constants.Settings.RNS_Gui.white, "", false, Constants.Settings.RNS_Gui.label_font)
        GuiApi.add_item_frame(guiTable, "", section, _G.DT.powerUsage .. "/t", name, detectorcount .. "x", 64, Constants.Settings.RNS_Gui.label_font_2)
    end

    local transmittercount = BaseNet.get_table_length_in_priority(self.network.getOperableObjects(self.network.TransmitterTable))
    if transmittercount > 0 then
        local name = Constants.NetworkTransReceiver.transmitter.name
        local section = GuiApi.add_frame(guiTable, "", ConnectedStructuresTable, "vertical")
        section.style = Constants.Settings.RNS_Gui.frame_1
        section.style.minimal_width = 200
        GuiApi.add_label(guiTable, "", section, game.item_prototypes[name].localised_name, Constants.Settings.RNS_Gui.white, "", false, Constants.Settings.RNS_Gui.label_font)
        GuiApi.add_item_frame(guiTable, "", section, Constants.NetworkTransReceiver.transmitter.powerUsage .. "/t", name, transmittercount .. "x", 64, Constants.Settings.RNS_Gui.label_font_2)
    end

    local receivercount = BaseNet.get_table_length_in_priority(self.network.getOperableObjects(self.network.ReceiverTable))
    if receivercount > 0 then
        local name = Constants.NetworkTransReceiver.receiver.name
        local section = GuiApi.add_frame(guiTable, "", ConnectedStructuresTable, "vertical")
        section.style = Constants.Settings.RNS_Gui.frame_1
        section.style.minimal_width = 200
        GuiApi.add_label(guiTable, "", section, game.item_prototypes[name].localised_name, Constants.Settings.RNS_Gui.white, "", false, Constants.Settings.RNS_Gui.label_font)
        GuiApi.add_item_frame(guiTable, "", section, "0/t", name, receivercount .. "x", 64, Constants.Settings.RNS_Gui.label_font_2)
    end

end