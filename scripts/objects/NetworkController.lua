--NetworkController object
NC = {
    thisEntity = nil,
    entID = nil,
    updateTick = 600,
    lastUpdate = 0,
    stable = false,
    state = nil,
    network = nil,
    connectedObjs = nil,
    nametag = nil,
    powerDraw = 0
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
    t.nametag = {"gui-description.RNS_TransReceiver_ID", t.thisEntity.unit_number, t.thisEntity.surface.name, tostring(serpent.line(t.thisEntity.position))}
    t:setState(Constants.NetworkController.states.unstable)
    t.connectedObjs = {
        [1] = {}, --N
        [2] = {}, --E
        [3] = {}, --S
        [4] = {}, --W
    }
    UpdateSys.add_to_entity_table(t)
    BaseNet.add_networkcontroller_to_global(t)
    t:createArms()
    BaseNet.postArms(t)
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
    --self.network:doRefresh(self)
    if self.state ~= nil then rendering.destroy(self.state) end
    UpdateSys.remove_from_entity_table(self)
    BaseNet.remove_networkcontroller_from_global(self)
    BaseNet.postArms(self)
    UpdateSys.remove(self)
end
--Is valid
function NC:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function NC:interactable()
    return self.thisEntity ~= nil and self.thisEntity.valid and self.thisEntity.to_be_deconstructed() == false
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
    if game.tick % self.updateTick == 0 or self.network.shouldRefresh == true then --Refreshes connections every 10 seconds
        self.network:doRefresh(self)
        self.powerDraw = self.network:getTotalObjects()
        --1.8MW buffer but 15KW energy at 900KMW- input
        --1.8MW buffer but 30KW energy at 1.8MW- input
        --1.8MW buffer but 1.8MW energy at 1.8MW+ input
        --Can check if energy*60 >= buffer then NC is stable
        --1 Joule converts to 60 Watts? How strange
        self.thisEntity.power_usage = self.powerDraw --Takes Joules as a param
        self.thisEntity.electric_buffer_size = math.max(self.powerDraw*300, 300) --Takes Joules as a param
    
    end

    if self.thisEntity.energy >= self.powerDraw and self.thisEntity.energy ~= 0 then
        self:setActive(true)
    else
        self:setActive(false)
    end

    if not self.stable then return end

    if game.tick % Constants.Settings.RNS_ExternalStorage_Tick == 0 then self:updateExternalStorage() end
    if game.tick % Constants.Settings.RNS_Detector_Tick == 0 then self:updateDetectors() end

    if game.tick % Constants.Settings.RNS_ItemIO_Tick == 0 then self:updateItemIO() end --Base is every 4 ticks to match yellow belt speed at 15/s
    --local tickItemBeltIO = game.tick % (120/Constants.Settings.RNS_ItemIO_Tick) --speed based on 1 side of a belt. Done every 8 ticks
    --if tickItemBeltIO >= 0.0 and tickItemBeltIO < 1.0 then self:updateItemIO(true) end

    if game.tick % Constants.Settings.RNS_FluidIO_Tick == 0 then self:updateFluidIO() end --Base is every 5 ticks to match offshore pump speed at 1200/s

    if game.tick % Constants.Settings.RNS_WirelessTransmitter_Tick == 0 then self:find_players_with_wirelessTransmitter() end --Updates every 30 ticks
end

function NC:DataConvert_ItemToEntity(tag)
    if tag.nametag then
        self.nametag = tag.nametag
    end
end

function NC:DataConvert_EntityToItem(tag)
    local tags = {}
    local description = {"", tag.prototype.localised_description}

    tags.nametag = self.nametag
    Util.add_list_into_table(description, {{"item-description.RNS_TransReceiverNameTag"}, self.nametag})

    tag.set_tag(Constants.Settings.RNS_Tag, tags)
    tag.custom_description = description
end

function NC:updateDetectors()
    for _, detector in pairs(self.network.DetectorTable[1]["enable/disable"]) do
        if detector.thisEntity ~= nil and detector.thisEntity.valid == true and detector.thisEntity.to_be_deconstructed() == false then
            detector:update_signal()
        end
    end
    for _, detector in pairs(self.network.DetectorTable[1]["connect/disconnect"]) do
        if detector.thisEntity ~= nil and detector.thisEntity.valid == true and detector.thisEntity.to_be_deconstructed() == false then
            detector:update_signal()
        end
    end
end

function NC:updateExternalStorage()
    local validExternals = self.network:filter_externalIO_by_valid_signal()
    for i = 1, Constants.Settings.RNS_Max_Priority*2+1 do
        local priorityExternals = validExternals[i]
        for _, type in pairs(priorityExternals) do
            for _, external in pairs(type) do
                external:update(self.network)
            end
        end
    end
end

function NC:find_players_with_wirelessTransmitter()
    local processed_players = {}
    for _, transmitter in pairs(self.network.WirelessTransmitterTable[1]) do
        if transmitter.thisEntity ~= nil and transmitter.thisEntity.valid and transmitter.thisEntity.to_be_deconstructed() == false then
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

end

function NC:find_wirelessgrid_with_wirelessTransmitter(id)
    for _, transmitter in pairs(self.network.WirelessTransmitterTable[1]) do
        if transmitter.thisEntity ~= nil and transmitter.thisEntity.valid and transmitter.thisEntity.to_be_deconstructed() == false then
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
                        if inter ~= nil and inter.thisEntity ~= nil and inter.thisEntity.valid == true and inter.connected and inter.connected == self.entID then return true end
                    end
                end
            else
                local inter = global.entityTable[id]
                if inter ~= nil and inter.thisEntity ~= nil and inter.thisEntity.valid == true and inter.connected and inter.connected == self.entID then return true end
            end
        end
    end
    return false
end

function NC:import_items()
    for p, priority in pairs(self.network.ItemIOTable) do
        for i, v in pairs(priority.input) do
            local item = global.entityTable[v]
            if item ~= nil and item.io == "output" then
                table.remove(priority.input, i)
                goto next
            end
            if item ~= nil then
                item:IO()
                if settings.global[Constants.Settings.RNS_RoundRobin].value == true and item.processed == true then
                    table.remove(priority.input, i)
                    table.insert(priority.input, v)
                    item.processed = false
                end
            end
            ::next::
        end
    end
    --[[local import = {}
    local import_length = 0
    local import_processed = 0
    for p, priority in pairs(self.network.ItemIOTable) do
        if settings.global[Constants.Settings.RNS_RoundRobin].value == true then
            import[p] = {}
            for _, item in pairs(priority.input) do
                if item.processed == false then
                    table.insert(import[p], 1, item)
                else
                    table.insert(import[p], item)
                end
                --table.insert(import[p], (item.processed == false and {1} or {Util.getTableLength(import[p])})[1], item)
            end
        else
            import[p] = priority.input
        end
        
        for _, item in pairs(import[p]) do
            if item:interactable() then
                --local old = item.processed
                item:IO()

                if item.focusedEntity.inventory.input.values ~= nil then
                    import_length = import_length + 1
                    if item.processed == true then import_processed = import_processed + 1 end
                    --import_length = import_length + 1
                    --if item.processed == true then import_processed = import_processed + 1 end
                end
                if self.network:is_full() then return end
                --if old == true and item.processed == true then item.processed = false end
            end
        end
        if import_processed >= import_length and settings.global[Constants.Settings.RNS_RoundRobin].value == true then
            for _, item in pairs(import[p]) do
                item.processed = false
            end
        end
    end]]
end

function NC:export_items()
    for p, priority in pairs(self.network.ItemIOTable) do
        for i, v in pairs(priority.output) do
            local item = global.entityTable[v]
            if item ~= nil and item.io == "input" then
                table.remove(priority.output, i)
                goto next
            end
            if item ~= nil then
                item:IO()
                if settings.global[Constants.Settings.RNS_RoundRobin].value == true and item.processed == true then
                    table.remove(priority.output, i)
                    table.insert(priority.output, v)
                    item.processed = false
                end
            end
            ::next::
        end
    end
    --[[local export = {}
    local export_length = 0
    local export_processed = 0
    for p, priority in pairs(self.network.ItemIOTable) do
        if settings.global[Constants.Settings.RNS_RoundRobin].value == true then
            export[p] = {}
            for _, item in pairs(priority.output) do
                if item.processed == false then
                    table.insert(export[p], 1, item)
                else
                    table.insert(export[p], item)
                end
                --table.insert(export[p], (item.processed == false and {1} or {Util.getTableLength(export[p])})[1], item)
            end
        else
            export[p] = priority.output
        end

        for _, item in pairs(export[p]) do
            if item:interactable() then
                --local old = item.processed
                item:IO()
                if item.focusedEntity.inventory.output.values ~= nil then
                    --export_length = export_length + 1
                    --if item.processed == true then export_processed = export_processed + 1 end
                    export_length = export_length + 1
                    if item.processed == true then export_processed = export_processed + 1 end
                end
                if self.network:is_empty() then return end
                --if old == true and item.processed == true then item.processed = false end
            end
        end
        if export_processed >= export_length and settings.global[Constants.Settings.RNS_RoundRobin].value == true then
            for _, item in pairs(export[p]) do
                item.processed = false
            end
        end
    end]]
end

function NC:updateItemIO()
    if self.network:is_full() == false then
        self:import_items()
    end
    if self.network:is_empty() == false then
        self:export_items()
    end
end

function NC:import_fluids()
    for p, priority in pairs(self.network.FluidIOTable) do
        for i, v in pairs(priority.input) do
            local fluid = global.entityTable[v]
            if fluid ~= nil and fluid.io == "output" then
                table.remove(priority.input, i)
                goto next
            end
            if fluid ~= nil then
                fluid:IO()
                if settings.global[Constants.Settings.RNS_RoundRobin].value == true and fluid.processed == true then
                    table.remove(priority.input, i)
                    table.insert(priority.input, v)
                    fluid.processed = false
                end
            end
            ::next::
        end
    end
    --[[local import = {}
    local import_length = 0
    local import_processed = 0
    for p, priority in pairs(self.network.FluidIOTable) do
        if settings.global[Constants.Settings.RNS_RoundRobin].value == true then
            import[p] = {}
            for _, fluid in pairs(priority.input) do
                if fluid.processed == false then
                    table.insert(import[p], 1, fluid)
                elseif fluid.processed == true then
                    table.insert(import[p], fluid)
                end
                --table.insert(import[p], (fluid.processed == false and {1} or {Util.getTableLength(import[p])})[1], fluid)
            end
        else
            import[p] = priority.input
        end

        for _, fluid in pairs(import[p]) do
            if fluid:interactable() then
                --local old = fluid.processed
                fluid:IO()
                if fluid.focusedEntity.fluid_box.index ~= nil then
                    import_length = import_length + 1
                    if fluid.processed == true then import_processed = import_processed + 1 end
                    --import_length = import_length + 1
                    --if fluid.processed == true then import_processed = import_processed + 1 end
                end
                --if old == true and fluid.processed == true then fluid.processed = false end
            end
            if self.network:is_full() then return end
        end
        if import_processed >= import_length and settings.global[Constants.Settings.RNS_RoundRobin].value == true then
            for _, item in pairs(import[p]) do
                item.processed = false
            end
        end
    end]]
end

function NC:export_fluids()
    for p, priority in pairs(self.network.FluidIOTable) do
        for i, v in pairs(priority.output) do
            local fluid = global.entityTable[v]
            if fluid ~= nil and fluid.io == "input" then
                table.remove(priority.ouput, i)
                goto next
            end
            if fluid ~= nil then
                fluid:IO()
                if settings.global[Constants.Settings.RNS_RoundRobin].value == true and fluid.processed == true then
                    table.remove(priority.output, i)
                    table.insert(priority.output, v)
                    fluid.processed = false
                end
            end
            ::next::
        end
    end
    --[[local export = {}
    local export_length = 0
    local export_processed = 0
    for p, priority in pairs(self.network.FluidIOTable) do
        if settings.global[Constants.Settings.RNS_RoundRobin].value == true then
            export[p] = {}
            for _, fluid in pairs(priority.output) do
                if fluid.processed == false then
                    table.insert(export[p], 1, fluid)
                elseif fluid.processed == true then
                    table.insert(export[p], fluid)
                end
            end
        else
            export[p] = priority.output
        end 
        for _, fluid in pairs(export[p]) do
            if fluid:interactable() then
                fluid:IO()
                if fluid.focusedEntity.fluid_box.index ~= nil then
                    export_length = export_length + 1
                    if fluid.processed == true then export_processed = export_processed + 1 end
                    --export_length = export_length + 1
                    --if fluid.processed == true then export_processed = export_processed + 1 end
                end
                if self.network:is_empty() then return end
            end
        end
        if export_processed >= export_length and settings.global[Constants.Settings.RNS_RoundRobin].value == true then
            for _, item in pairs(export[p]) do
                item.processed = false
            end
        end
    end]]
end

function NC:updateFluidIO()
    if self.network:is_full() == false then
        self:import_fluids()
    end
    if self.network:is_empty() == false then
        self:export_fluids()
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
            if ent ~= nil and ent.valid == true and ent.to_be_deconstructed() == false and string.match(ent.name, "RNS_") ~= nil then
                if global.entityTable[ent.unit_number] ~= nil then
                    local obj = global.entityTable[ent.unit_number]
                    if (string.match(obj.thisEntity.name, "RNS_NetworkCableIO") ~= nil and obj:getConnectionDirection() == area.direction) or (string.match(obj.thisEntity.name, "RNS_NetworkCableRamp") ~= nil and obj:getConnectionDirection() == area.direction) or obj.thisEntity.name == Constants.WirelessGrid.name then
                        --Do nothing
                    else
                        if BaseNet.exists_in_network(obj.networkController, obj.entID) and obj.networkController.entID ~= self.entID then
                            --game.print(BaseNet.exists_in_network(obj.networkController, obj.entID))
                            self.thisEntity.order_deconstruction("player")
                        else
                            table.insert(self.connectedObjs[area.direction], obj)
                            obj.networkController = self
                        end
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
        local mainFlowV = GuiApi.add_flow(guiTable, "MainFlowV", mainFrame, "vertical")

        GuiApi.add_subtitle(guiTable, "", mainFlowV, {"gui-description.RNS_NameTag"})
        local infoFlow = GuiApi.add_flow(guiTable, "", mainFlowV, "vertical")
        infoFlow.style.horizontal_align = "center"

        local nameFlow = GuiApi.add_flow(guiTable, "nameFlow", infoFlow, "horizontal", true)
        nameFlow.style.vertical_align = "center"

        self:make_name_label(guiTable, nameFlow)
        
        GuiApi.add_line(guiTable, "", infoFlow, "horizontal")

        local mainFlowH = GuiApi.add_flow(guiTable, "MainFlowH", mainFlowV, "horizontal")

        local infoFrame = GuiApi.add_frame(guiTable, "InformationFrame", mainFlowH, "vertical", true)
		infoFrame.style = Constants.Settings.RNS_Gui.frame_1
		infoFrame.style.vertically_stretchable = true
		infoFrame.style.minimal_width = 200
		infoFrame.style.left_margin = 3
		infoFrame.style.left_padding = 3
		infoFrame.style.right_padding = 3

        GuiApi.add_subtitle(guiTable, "", infoFrame, {"gui-description.RNS_Information"})

        GuiApi.add_label(guiTable, "EnergyUsage", infoFrame, {"gui-description.RNS_NetworkController_EnergyUsage", Util.toRNumber(self.thisEntity.power_usage)}, Constants.Settings.RNS_Gui.orange, nil, true)
        GuiApi.add_label(guiTable, "EnergyBuffer", infoFrame, {"gui-description.RNS_NetworkController_EnergyBuffer", Util.toRNumber(self.thisEntity.electric_buffer_size)}, Constants.Settings.RNS_Gui.orange, nil, true)
        GuiApi.add_progress_bar(guiTable, "EnergyBar", infoFrame, "", Util.toRNumber(self.thisEntity.energy) .. "/" .. Util.toRNumber(self.thisEntity.electric_buffer_size), true, nil, self.thisEntity.energy/self.thisEntity.electric_buffer_size, 200, 25)
        GuiApi.add_line(guiTable, "", infoFrame, "horizontal")

        GuiApi.add_label(guiTable, "", infoFrame, {"gui-description.RNS_NetworkController_ID", self.thisEntity.unit_number}, Constants.Settings.RNS_Gui.white)
        GuiApi.add_label(guiTable, "", infoFrame, {"gui-description.RNS_NetworkController_Surface", self.thisEntity.surface.name}, Constants.Settings.RNS_Gui.white)
        GuiApi.add_label(guiTable, "", infoFrame, {"gui-description.RNS_NetworkController_Pos", tostring(serpent.line(self.thisEntity.position))}, Constants.Settings.RNS_Gui.white)

        --local connectedStructuresFrame = GuiApi.add_frame(guiTable, "", mainFrame, "vertical")
		--connectedStructuresFrame.style = Constants.Settings.RNS_Gui.frame_1
		--connectedStructuresFrame.style.vertically_stretchable = true
		--connectedStructuresFrame.style.minimal_width = 350
		--connectedStructuresFrame.style.left_margin = 3
		--connectedStructuresFrame.style.left_padding = 3
		--connectedStructuresFrame.style.right_padding = 3

        local connectedStructuresFlow = GuiApi.add_flow(guiTable, "", mainFlowH, "vertical")

        GuiApi.add_subtitle(guiTable, "", connectedStructuresFlow, {"gui-description.RNS_NetworkController_Connections"})

        local connectedStructuresSP = GuiApi.add_scroll_pane(guiTable, "", connectedStructuresFlow, nil, false)
		connectedStructuresSP.style.vertically_stretchable = true
		connectedStructuresSP.style.bottom_margin = 3
        connectedStructuresSP.style.minimal_width = 450

        GuiApi.add_table(guiTable, "ConnectedStructuresTable", connectedStructuresSP, 2, true)
    end

    local energyUsage = guiTable.vars.EnergyUsage
    local energyBuffer = guiTable.vars.EnergyBuffer
    local energyBar = guiTable.vars.EnergyBar

    energyUsage.caption = {"gui-description.RNS_NetworkController_EnergyUsage", Util.toRNumber(self.thisEntity.power_usage)}
    energyBuffer.caption = {"gui-description.RNS_NetworkController_EnergyBuffer", Util.toRNumber(self.thisEntity.electric_buffer_size)}
    energyBar.tooltip = Util.toRNumber(self.thisEntity.energy) .. "/" .. Util.toRNumber(self.thisEntity.electric_buffer_size)
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
            GuiApi.add_item_frame(guiTable, "", section, t.powerUsage .. " J/t", name, count .. "x", 64, Constants.Settings.RNS_Gui.label_font_2)
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
            GuiApi.add_item_frame(guiTable, "", section, t.powerUsage .. " J/t", name, count .. "x", 64, Constants.Settings.RNS_Gui.label_font_2)
        end
    end

    local itemIOcount = BaseNet.get_table_length_in_priority(self.network.getOperableObjects(self.network.ItemIOTable, "io"), true)
    if itemIOcount > 0 then
        local name = Constants.NetworkCables.itemIO.name
        local section = GuiApi.add_frame(guiTable, "", ConnectedStructuresTable, "vertical")
        section.style = Constants.Settings.RNS_Gui.frame_1
        section.style.minimal_width = 200
        GuiApi.add_label(guiTable, "", section, game.item_prototypes[name].localised_name, Constants.Settings.RNS_Gui.white, "", false, Constants.Settings.RNS_Gui.label_font)
        GuiApi.add_item_frame(guiTable, "", section, _G.IIO3.powerUsage*global.IIOMultiplier .. " J/t", name, itemIOcount .. "x", 64, Constants.Settings.RNS_Gui.label_font_2)
    end

    --[[local itemIOV2count = BaseNet.get_table_length_in_priority(self.network.getOperableObjects(self.network.ItemIOV2Table))
    if itemIOV2count > 0 then
        local name = "RNS_NetworkCableIOV2_Item"
        local section = GuiApi.add_frame(guiTable, "", ConnectedStructuresTable, "vertical")
        section.style = Constants.Settings.RNS_Gui.frame_1
        section.style.minimal_width = 200
        GuiApi.add_label(guiTable, "", section, game.item_prototypes[name].localised_name, Constants.Settings.RNS_Gui.white, "", false, Constants.Settings.RNS_Gui.label_font)
        GuiApi.add_item_frame(guiTable, "", section, _G.IIO2.powerUsage*global.IIOMultiplier .. "/t", name, itemIOV2count .. "x", 64, Constants.Settings.RNS_Gui.label_font_2)
    end]]

    local fluidIOcount = BaseNet.get_table_length_in_priority(self.network.getOperableObjects(self.network.FluidIOTable, "io"), true)
    if fluidIOcount > 0 then
        local name = Constants.NetworkCables.fluidIO.name
        local section = GuiApi.add_frame(guiTable, "", ConnectedStructuresTable, "vertical")
        section.style = Constants.Settings.RNS_Gui.frame_1
        section.style.minimal_width = 200
        GuiApi.add_label(guiTable, "", section, game.item_prototypes[name].localised_name, Constants.Settings.RNS_Gui.white, "", false, Constants.Settings.RNS_Gui.label_font)
        GuiApi.add_item_frame(guiTable, "", section, _G.FIO.powerUsage*global.FIOMultiplier .. " J/t", name, fluidIOcount .. "x", 64, Constants.Settings.RNS_Gui.label_font_2)
    end

    --[[local fluidIOV2count = BaseNet.get_table_length_in_priority(self.network.getOperableObjects(self.network.FluidIOV2Table))
    if fluidIOV2count > 0 then
        local name = "RNS_NetworkCableIOV2_Fluid"
        local section = GuiApi.add_frame(guiTable, "", ConnectedStructuresTable, "vertical")
        section.style = Constants.Settings.RNS_Gui.frame_1
        section.style.minimal_width = 200
        GuiApi.add_label(guiTable, "", section, game.item_prototypes[name].localised_name, Constants.Settings.RNS_Gui.white, "", false, Constants.Settings.RNS_Gui.label_font)
        GuiApi.add_item_frame(guiTable, "", section, _G.FIO2.powerUsage*global.FIOMultiplier .. "/t", name, fluidIOV2count .. "x", 64, Constants.Settings.RNS_Gui.label_font_2)
    end]]

    local externalIOcount = BaseNet.get_table_length_in_priority(self.network.getOperableObjects(self.network.ExternalIOTable, "eo"), true)
    if externalIOcount > 0 then
        local name = Constants.NetworkCables.externalIO.name
        local section = GuiApi.add_frame(guiTable, "", ConnectedStructuresTable, "vertical")
        section.style = Constants.Settings.RNS_Gui.frame_1
        section.style.minimal_width = 200
        GuiApi.add_label(guiTable, "", section, game.item_prototypes[name].localised_name, Constants.Settings.RNS_Gui.white, "", false, Constants.Settings.RNS_Gui.label_font)
        GuiApi.add_item_frame(guiTable, "", section, _G.EIO.powerUsage .. " J/t", name, externalIOcount .. "x", 64, Constants.Settings.RNS_Gui.label_font_2)
    end

    local interfacecount = BaseNet.get_table_length_in_priority(self.network.getOperableObjects(self.network.NetworkInventoryInterfaceTable))
    if interfacecount > 0 then
        local name = Constants.NetworkInventoryInterface.name
        local section = GuiApi.add_frame(guiTable, "", ConnectedStructuresTable, "vertical")
        section.style = Constants.Settings.RNS_Gui.frame_1
        section.style.minimal_width = 200
        GuiApi.add_label(guiTable, "", section, game.item_prototypes[name].localised_name, Constants.Settings.RNS_Gui.white, "", false, Constants.Settings.RNS_Gui.label_font)
        GuiApi.add_item_frame(guiTable, "", section, _G.NII.powerUsage .. " J/t", name, interfacecount .. "x", 64, Constants.Settings.RNS_Gui.label_font_2)
    end

    local wirelessTransmittercount = BaseNet.get_table_length_in_priority(self.network.getOperableObjects(self.network.WirelessTransmitterTable))
    if wirelessTransmittercount > 0 then
        local name = Constants.NetworkCables.wirelessTransmitter.name
        local section = GuiApi.add_frame(guiTable, "", ConnectedStructuresTable, "vertical")
        section.style = Constants.Settings.RNS_Gui.frame_1
        section.style.minimal_width = 200
        GuiApi.add_label(guiTable, "", section, game.item_prototypes[name].localised_name, Constants.Settings.RNS_Gui.white, "", false, Constants.Settings.RNS_Gui.label_font)
        GuiApi.add_item_frame(guiTable, "", section, _G.WT.powerUsage*global.WTRangeMultiplier .. " J/t", name, wirelessTransmittercount .. "x", 64, Constants.Settings.RNS_Gui.label_font_2)
    end

    local detectorcount = BaseNet.get_table_length_in_priority(self.network.getOperableObjects(self.network.DetectorTable, "dt"))
    if detectorcount > 0 then
        local name = Constants.Detector.name
        local section = GuiApi.add_frame(guiTable, "", ConnectedStructuresTable, "vertical")
        section.style = Constants.Settings.RNS_Gui.frame_1
        section.style.minimal_width = 200
        GuiApi.add_label(guiTable, "", section, game.item_prototypes[name].localised_name, Constants.Settings.RNS_Gui.white, "", false, Constants.Settings.RNS_Gui.label_font)
        GuiApi.add_item_frame(guiTable, "", section, _G.DT.powerUsage .. " J/t", name, detectorcount .. "x", 64, Constants.Settings.RNS_Gui.label_font_2)
    end

    local transmittercount = BaseNet.get_table_length_in_priority(self.network.getOperableObjects(self.network.TransmitterTable))
    if transmittercount > 0 then
        local name = Constants.NetworkTransReceiver.transmitter.name
        local section = GuiApi.add_frame(guiTable, "", ConnectedStructuresTable, "vertical")
        section.style = Constants.Settings.RNS_Gui.frame_1
        section.style.minimal_width = 200
        GuiApi.add_label(guiTable, "", section, game.item_prototypes[name].localised_name, Constants.Settings.RNS_Gui.white, "", false, Constants.Settings.RNS_Gui.label_font)
        GuiApi.add_item_frame(guiTable, "", section, _G.TR.powerUsage .. " J/t", name, transmittercount .. "x", 64, Constants.Settings.RNS_Gui.label_font_2)
    end

    local receivercount = BaseNet.get_table_length_in_priority(self.network.getOperableObjects(self.network.ReceiverTable))
    if receivercount > 0 then
        local name = Constants.NetworkTransReceiver.receiver.name
        local section = GuiApi.add_frame(guiTable, "", ConnectedStructuresTable, "vertical")
        section.style = Constants.Settings.RNS_Gui.frame_1
        section.style.minimal_width = 200
        GuiApi.add_label(guiTable, "", section, game.item_prototypes[name].localised_name, Constants.Settings.RNS_Gui.white, "", false, Constants.Settings.RNS_Gui.label_font)
        GuiApi.add_item_frame(guiTable, "", section, "0 J/t", name, receivercount .. "x", 64, Constants.Settings.RNS_Gui.label_font_2)
    end

end

function NC:make_name_label(guiTable, nameFlow)
    nameFlow.clear()
    local nameLabel = GuiApi.add_label(guiTable, "RNS_NC_Name_Label", nameFlow, self.nametag, Constants.Settings.RNS_Gui.white)
    nameLabel.style.horizontally_squashable = true

    local nameButton = GuiApi.add_button(guiTable, "RNS_NC_Name_Button", nameFlow, "utility/rename_icon_normal", nil, nil, "", 30, false, true, nil, "mini_button_aligned_to_text_vertically_when_centered", {ID=self.entID})
    nameButton.mouse_button_filter = {"left"}
end

function NC:make_name_change(guiTable, nameFlow)
    nameFlow.clear()
    local text = self.nametag[1] == "gui-description.RNS_TransReceiver_ID" and --[[("ID: "..self.nametag[2].."Surface: "..self.nametag[3].."Pos: "..self.nametag[4])]]"" or self.nametag[2]
    local nameText = GuiApi.add_text_field(guiTable, "RNS_NC_Name_Text", nameFlow, text, "", true, false, false, false, false, {ID = self.entID})
    nameText.clear_and_focus_on_right_click = true
    nameText.style.horizontally_stretchable = true
    nameText.style.maximal_width = 0
    nameText.select_all()
    nameText.focus()

    local elementButton = GuiApi.add_element_button(guiTable, "RNS_NC_Element_Button", nameFlow, "", false, "signal", {type="virtual", name=Constants.Icons.select_icon_white}, 30, {ID = self.entID})
    --elementButton.style = Constants.Settings.RNS_Gui.button_1
    --elementButton.style.height = 30
    --elementButton.style.width = 30
    local checkMark = GuiApi.add_button(guiTable, "RNS_NC_Checkmark", nameFlow, Constants.Icons.check_mark.name, Constants.Icons.check_mark.name, Constants.Icons.check_mark.name, {"gui-description.RNS_Confirm"}, 30, false, true, nil, nil, {ID=self.thisEntity.unit_number})
    checkMark.mouse_button_filter = {"left"}
    --checkMark.style = Constants.Settings.RNS_Gui.button_1
    --checkMark.style.height = 30
    --checkMark.style.width = 30
end

function NC.interaction(event, RNSPlayer)
    local guiTable = RNSPlayer.GUI[Constants.Settings.RNS_Gui.tooltip]
    if string.match(event.element.name, "RNS_NC_Name_Button") then
		local obj = global.entityTable[event.element.tags.ID]
		if obj == nil then return end
            obj:make_name_change(guiTable, guiTable.vars["nameFlow"])
		return
	elseif string.match(event.element.name, "RNS_NC_Element_Button") and event.name ~= defines.events.on_gui_click then
		local obj = global.entityTable[event.element.tags.ID]
		if obj == nil then return end
            guiTable.vars["RNS_NC_Name_Text"].text = guiTable.vars["RNS_NC_Name_Text"].text .. Util.signal_to_rich_text(event.element.elem_value)
            guiTable.vars["RNS_NC_Name_Text"].focus()
            event.element.elem_value = {
                type = "virtual",
                name = Constants.Icons.select_icon_white
              }
		return
	elseif string.match(event.element.name, "RNS_NC_Checkmark") then
		local obj = global.entityTable[event.element.tags.ID]
		if obj == nil then return end
        if guiTable.vars["RNS_NC_Name_Text"].text == "" then
            obj.nametag = {"gui-description.RNS_TransReceiver_ID", obj.thisEntity.unit_number, obj.thisEntity.surface.name, tostring(serpent.line(obj.thisEntity.position))}
        else
            obj.nametag = {"gui-description.RNS_TransReceiver_Name", guiTable.vars["RNS_NC_Name_Text"].text, obj.thisEntity.unit_number}
        end
        obj:make_name_label(guiTable, guiTable.vars["nameFlow"])
		return
	end
end