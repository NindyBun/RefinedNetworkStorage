--[[
    The External Storage Bus
    When mode is "input," allow the network to see the contents of the entity; and pull stuff from.
    When mode is "output," do not allow the network to see the contents of the entity; but push stuff to.
    When mode is "input/output," allow the network to see the contents of the entity; and pull/push stuff from/to.
]]
EIO = {
    thisEntity = nil,
    entID = nil,
    networkController = nil,
    arms = nil,
    connectedObjs = nil,
    focusedEntity = nil,
    cardinals = nil,
    filters = nil,
    io = "input/output",
    type = "item",
    ioIcon = nil,
    combinator = nil,
    metadataMode = false,
    whitelist = true,
    priority = 0
}

function EIO:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = EIO
    t.thisEntity = object
    t.entID = object.unit_number
    rendering.draw_sprite{sprite="NetworkCableDot", target=t.thisEntity, surface=t.thisEntity.surface, render_layer="lower-object-above-shadow"}
    t:generateModeIcon()
    --Don't really need to initialize the arrays but it makes it easier to see what's supposed to be there
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
    t.focusedEntity = {
        thisEntity = nil,
        inventory = {
            index = 1,
            values = nil
        },
        fluid_box = {
            index = nil,
            filter = "",
            target_position = nil,
            flow = ""
        }
    }
    --10 filters
    t.filters = {
        item = {
            index = 1,
            values = {}
        },
        fluid = {
            index = 1,
            values = {}
        }
    }
    for i=1, 10 do
        t.filters.item.values[i] = ""
        t.filters.fluid.values[i] = ""
    end
    t.combinator = object.surface.create_entity{
        name="rns-combinator",
        position=object.position,
        force="neutral"
    }
    t.combinator.destructible = false
    t.combinator.operable = false
    t.combinator.minable = false
    UpdateSys.addEntity(t)
    return t
end

function EIO:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = EIO
    setmetatable(object, mt)
end

function EIO:remove()
    if self.combinator ~= nil then self.combinator.destroy() end
    UpdateSys.remove(self)
    if self.networkController ~= nil then
        self.networkController.network.ExternalIOTable[self.entID] = nil
        self.networkController.network.shouldRefresh = true
    end
end

function EIO:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function EIO:update()
    if valid(self) == false then
        self:remove()
        return
    end
    if valid(self.networkController) == false then
        self.networkController = nil
    end
    if self.focusedEntity.thisEntity ~= nil and self.focusedEntity.thisEntity.valid == false then
        self:reset_focused_entity()
    end
    if self.thisEntity.to_be_deconstructed() == true then return end
    self:createArms()
end

function EIO:toggleHoverIcon(hovering)
    if self.ioIcon == nil then return end
    if hovering and rendering.get_only_in_alt_mode(self.ioIcon) then
        rendering.set_only_in_alt_mode(self.ioIcon, false)
    elseif not hovering and not rendering.get_only_in_alt_mode(self.ioIcon) then
        rendering.set_only_in_alt_mode(self.ioIcon, true)
    end
end

function EIO:generateModeIcon()
    if self.ioIcon ~= nil then rendering.destroy(self.ioIcon) end
    local offset = {0, 0}
    if self:getRealDirection() == 1 then
        offset = {0,-0.5}
    elseif self:getRealDirection() == 2 then
        offset = {0.5, 0}
    elseif self:getRealDirection() == 3 then
        offset = {0,0.5}
    elseif self:getRealDirection() == 4 then
        offset = {-0.5,0}
    end
    if self.io ~= "input/output" then
        self.ioIcon = rendering.draw_sprite{
            sprite=Constants.Icons.storage.name, 
            target=self.thisEntity, 
            target_offset=offset,
            surface=self.thisEntity.surface,
            only_in_alt_mode=true,
            orientation=self.io == "input" and (self:getRealDirection()*0.25)-0.25 or ((self:getRealDirection()*0.25)+0.25)%1.00
        }
    else
        self.ioIcon = rendering.draw_sprite{
            sprite=Constants.Icons.storage_bothways.name, 
            target=self.thisEntity, 
            target_offset=offset,
            surface=self.thisEntity.surface,
            only_in_alt_mode=true,
            orientation=(self:getRealDirection()*0.25)-0.25
        }
    end
    
end

function EIO:resetConnection()
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

function EIO:reset_focused_entity()
    self.focusedEntity = {
        thisEntity = nil,
        inventory = {
            index = 1,
            values = nil
        },
        fluid_box = {
            index = nil,
            filter = "",
            target_position = nil,
            flow = ""
        }
    }
end

function EIO:getCheckArea()
    local x = self.thisEntity.position.x
    local y = self.thisEntity.position.y
    return {
        [1] = {direction = 1, startP = {x-0.5, y-1.5}, endP = {x+0.5, y-0.5}}, --North
        [2] = {direction = 2, startP = {x+0.5, y-0.5}, endP = {x+1.5, y+0.5}}, --East
        [4] = {direction = 4, startP = {x-0.5, y+0.5}, endP = {x+0.5, y+1.5}}, --South
        [3] = {direction = 3, startP = {x-1.5, y-0.5}, endP = {x-0.5, y+0.5}}, --West
    }
end

function EIO:createArms()
    local areas = self:getCheckArea()
    self:resetConnection()
    for _, area in pairs(areas) do
        local enti = 0
        local ents = self.thisEntity.surface.find_entities_filtered{area={area.startP, area.endP}}
        for _, ent in pairs(ents) do
            if ent ~= nil and ent.valid == true then
                if ent ~= nil and global.entityTable[ent.unit_number] ~= nil and string.match(ent.name, "RNS_") ~= nil and ent.operable then
                    if area.direction ~= self:getDirection() then --Prevent cable connection on the IO port
                        local obj = global.entityTable[ent.unit_number]
                        if (string.match(obj.thisEntity.name, "RNS_NetworkCableIO") ~= nil and obj:getConnectionDirection() == area.direction) or obj.thisEntity.name == Constants.NetworkCables.wirelessTransmitter.slateEntity.name then
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
                            elseif obj.thisEntity.name == Constants.NetworkController.slateEntity.name then
                                obj.network.shouldRefresh = true
                            end
                        end
                        break
                    end
                elseif ent ~= nil and self:getDirection() == area.direction then --Get entity with inventory
                    if self.focusedEntity.thisEntity == nil or (self.focusedEntity.thisEntity ~= nil and self.focusedEntity.thisEntity.valid == false) then
                        if Constants.Settings.RNS_TypesWithContainer[ent.type] == true then
                            self:reset_focused_entity()
                            self.focusedEntity.thisEntity = ent
                            self.focusedEntity.inventory.values = Constants.Settings.RNS_Inventory_Types[ent.type]
                            if #ent.fluidbox ~= 0 then
                                for i=1, #ent.fluidbox do
                                    for j=1, #ent.fluidbox.get_pipe_connections(i) do
                                        local target = ent.fluidbox.get_pipe_connections(i)[j]
                                        if target.target_position.x == self.thisEntity.position.x and target.target_position.y == self.thisEntity.position.y then
                                            self.focusedEntity.fluid_box.index = i
                                            self.focusedEntity.fluid_box.flow =  target.flow_direction
                                            self.focusedEntity.fluid_box.target_position = target.target_position
                                            self.focusedEntity.fluid_box.filter =  (ent.fluidbox.get_locked_fluid(i) ~= nil and {ent.fluidbox.get_locked_fluid(i)} or {""})[1]
                                        end
                                    end
                                end
                            end
                            break
                        end
                        if #ent.fluidbox ~= 0 then
                            self:reset_focused_entity()
                            self.focusedEntity.thisEntity = ent
                            for i=1, #ent.fluidbox do
                                for j=1, #ent.fluidbox.get_pipe_connections(i) do
                                    local target = ent.fluidbox.get_pipe_connections(i)[j]
                                    if target.target_position.x == self.thisEntity.position.x and target.target_position.y == self.thisEntity.position.y then
                                        self.focusedEntity.fluid_box.index = i
                                        self.focusedEntity.fluid_box.flow =  target.flow_direction
                                        self.focusedEntity.fluid_box.target_position = target.target_position
                                        self.focusedEntity.fluid_box.filter =  (ent.fluidbox.get_locked_fluid(i) ~= nil and {ent.fluidbox.get_locked_fluid(i)} or {""})[1]
                                    end
                                end
                            end
                            if Constants.Settings.RNS_TypesWithContainer[ent.type] == true then
                                self.focusedEntity.inventory.values = Constants.Settings.RNS_Inventory_Types[ent.type]
                            end
                            break
                        end
                    end
                end
            end
        end
        if self:getDirection() ~= area.direction then
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

function EIO:getDirection()
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

function EIO:getConnectionDirection()
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

function EIO:getRealDirection()
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

local modeListN = {
    [1] = "input",
    [2] = "output",
    [3] = "input/output"
}

local typeListN = {
    [1] = "item",
    [2] = "fluid"
}

local modeList = {
    ["input"] = 1,
    ["output"] = 2,
    ["input/output"] = 3
}

local typeList = {
    ["item"] = 1,
    ["fluid"] = 2
}

function EIO.has_item_room(inv)
    inv.sort_and_merge()
    for i=1, #inv do
        if inv[i].count <= 0 then return true end
    end
    if not inv.is_full() then return true end
    if inv.is_empty() then return true end
    return false
end

function EIO:matches_filters(type, filter)
    for _, name in pairs(self.filters[type].values) do
        if name == filter then return true end
    end
    return false
end

function EIO.has_item(inv, itemstack_data, getModified)
    local amount = 0
    inv.sort_and_merge()
    for i = 1, #inv do
        local itemstack = inv[i]
        if itemstack.count <= 0 then break end
        local itemstackC = Util.itemstack_convert(itemstack)
        if Util.itemstack_matches(itemstack_data, itemstackC, getModified) then
            if game.item_prototypes[itemstack_data.cont.name] == game.item_prototypes[itemstackC.cont.name] then
                if itemstack_data.cont.ammo and itemstackC.cont.ammo and itemstack_data.cont.ammo < game.item_prototypes[itemstackC.cont.name].magazine_size then
                    amount = amount + 1
                    goto continue
                end
                if itemstack_data.cont.durability and itemstackC.cont.durability and itemstack_data.cont.durability < game.item_prototypes[itemstackC.cont.name].durability then
                    amount = amount + 1
                    goto continue
                end
            end
            amount = amount + itemstackC.cont.count
        elseif game.item_prototypes[itemstack_data.cont.name] == game.item_prototypes[itemstackC.cont.name] then
            if itemstack_data.cont.ammo and itemstackC.cont.ammo and itemstack_data.cont.ammo > itemstackC.cont.ammo and itemstackC.cont.count > 1 then
                amount = amount + itemstack.count - 1
            end
            if itemstack_data.cont.durability and itemstackC.cont.durability and itemstack_data.cont.durability > itemstackC.cont.durability and itemstackC.cont.count > 1 then
                amount = amount + itemstack.count - 1
            end
        end
        ::continue::
    end

    return amount
end

function EIO:getTooltips(guiTable, mainFrame, justCreated)
    if justCreated == true then
		guiTable.vars.Gui_Title.caption = {"gui-description.RNS_NetworkCableIO_External"}

        local filtersFrame = GuiApi.add_frame(guiTable, "FiltersFrame", mainFrame, "vertical", true)
		filtersFrame.style = Constants.Settings.RNS_Gui.frame_1
		filtersFrame.style.vertically_stretchable = true
		filtersFrame.style.left_padding = 3
		filtersFrame.style.right_padding = 3
		filtersFrame.style.right_margin = 3
		filtersFrame.style.width = 100

        GuiApi.add_subtitle(guiTable, "", filtersFrame, {"gui-description.RNS_Filter"})

        local filterTable = GuiApi.add_table(guiTable, "", filtersFrame, 2, false)
        guiTable.vars.filters = {}
        guiTable.vars.filters[self.type] = {}
        for i=1, 10 do
            local filter = GuiApi.add_filter(guiTable, "RNS_NetworkCableIO_External_Filter_"..i, filterTable, "", true, self.type, 40, {ID=self.thisEntity.unit_number, type=self.type, index=i})
            guiTable.vars.filters[self.type][i] = {}
            guiTable.vars.filters[self.type][i].filter = filter
            if self.filters[self.type].values[i] ~= "" then
                filter.elem_value = self.filters[self.type].values[i]
            end
        end

        local settingsFrame = GuiApi.add_frame(guiTable, "SettingsFrame", mainFrame, "vertical", true)
		settingsFrame.style = Constants.Settings.RNS_Gui.frame_1
		settingsFrame.style.vertically_stretchable = true
		settingsFrame.style.left_padding = 3
		settingsFrame.style.right_padding = 3
		settingsFrame.style.right_margin = 3
		settingsFrame.style.minimal_width = 200

		GuiApi.add_subtitle(guiTable, "", settingsFrame, {"gui-description.RNS_Setting"})

        --Fluid or Item Mode
        local typeFlow = GuiApi.add_flow(guiTable, "", settingsFrame, "horizontal", false)
        GuiApi.add_label(guiTable, "", typeFlow, {"gui-description.RNS_Type"}, Constants.Settings.RNS_Gui.white)
        local typeDD = GuiApi.add_dropdown(guiTable, "RNS_NetworkCableIO_External_Type", typeFlow, {{"gui-description.RNS_Item"}, {"gui-description.RNS_Fluid"}}, typeList[self.type], false, "", {ID=self.thisEntity.unit_number})
        typeDD.style.minimal_width = 100

        --IO Mode
        local modeFlow = GuiApi.add_flow(guiTable, "", settingsFrame, "horizontal", false)
        GuiApi.add_label(guiTable, "", modeFlow, {"gui-description.RNS_Mode"}, Constants.Settings.RNS_Gui.white)
        local modeDD = GuiApi.add_dropdown(guiTable, "RNS_NetworkCableIO_External_Mode", modeFlow, {{"gui-description.RNS_Input"}, {"gui-description.RNS_Output"}, {"gui-description.RNS_Both"}}, modeList[self.io], false, "", {ID=self.thisEntity.unit_number})
        modeDD.style.minimal_width = 100

        local priorityFlow = GuiApi.add_flow(guiTable, "", settingsFrame, "horizontal", false)
        GuiApi.add_label(guiTable, "", priorityFlow, {"gui-description.RNS_Priority"}, Constants.Settings.RNS_Gui.white)
        local priorityDD = GuiApi.add_dropdown(guiTable, "RNS_NetworkCableIO_External_Priority", priorityFlow, Constants.Settings.RNS_Priorities, ((#Constants.Settings.RNS_Priorities+1)/2)-self.priority, false, "", {ID=self.thisEntity.unit_number})
        priorityDD.style.minimal_width = 100

        GuiApi.add_line(guiTable, "", settingsFrame, "horizontal")

        -- Whitelist/Blacklist mode
        local state = "left"
        if self.whitelist == false then state = "right" end
        GuiApi.add_switch(guiTable, "RNS_NetworkCableIO_External_Whitelist", settingsFrame, {"gui-description.RNS_Whitelist"}, {"gui-description.RNS_Blacklist"}, "", "", state, false, {ID=self.thisEntity.unit_number})

        if self.type == "item" then
            -- Match metadata mode
            GuiApi.add_checkbox(guiTable, "RNS_NetworkCableIO_External_Metadata", settingsFrame, {"gui-description.RNS_Metadata"}, {"gui-description.RNS_Metadata_description"}, self.metadataMode, false, {ID=self.thisEntity.unit_number})
        end
    end

    for i=1, 10 do
        if self.filters[self.type].values[i] ~= "" then
            guiTable.vars.filters[self.type][i].elem_value = self.filters[self.type].values[i]
        end
    end
end

function EIO.interaction(event, RNSPlayer)
    if string.match(event.element.name, "RNS_NetworkCableIO_External_Filter") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        if event.element.elem_value ~= nil then
            io.filters[event.element.tags.type].values[event.element.tags.index] = event.element.elem_value
            io.combinator.get_or_create_control_behavior().set_signal(event.element.tags.index, {signal={type=event.element.tags.type, name=event.element.elem_value}, count=1})
        else
            io.filters[event.element.tags.type].values[event.element.tags.index] = ""
            io.combinator.get_or_create_control_behavior().set_signal(event.element.tags.index, nil)
        end
		return
    end

    if string.match(event.element.name, "RNS_NetworkCableIO_External_Mode") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local mode = modeListN[event.element.selected_index]
        if mode ~= io.io then
            io.io = mode
            io.processed = false
            io:generateModeIcon()
        end
		return
    end

    if string.match(event.element.name, "RNS_NetworkCableIO_External_Type") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local type = typeListN[event.element.selected_index]
        if type ~= io.type then
            io.type = type
            RNSPlayer:push_varTable(id, true)
            io.processed = false
        end
		return
    end

    if string.match(event.element.name, "RNS_NetworkCableIO_External_Priority") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local priority = Constants.Settings.RNS_Priorities[event.element.selected_index]
        if priority ~= io.priority then
            local oldP = 1+Constants.Settings.RNS_Max_Priority-io.priority
            io.priority = priority
            if io.networkController ~= nil and io.networkController.valid == true then
                io.networkController.network.ExternalIOTable[oldP][io.entID] = nil
                io.networkController.network.ExternalIOTable[1+Constants.Settings.RNS_Max_Priority-priority][io.entID] = io
            end
            io.processed = false
        end
		return
    end

    if string.match(event.element.name, "RNS_NetworkCableIO_External_Whitelist") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        io.whitelist = event.element.switch_state == "left" and true or false
		return
    end

    if string.match(event.element.name, "RNS_NetworkCableIO_External_Metadata") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        io.metadataMode = event.element.state
		return
    end
end