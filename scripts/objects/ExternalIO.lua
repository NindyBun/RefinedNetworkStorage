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
    guiFilters = nil,
    filters = nil,
    color = "RED",
    io = "input/output",
    type = "item",
    ioIcon = nil,
    enabler = nil,
    enablerCombinator = nil,
    combinator = nil,
    onlyModified = true,
    whitelistBlacklist = "blacklist",
    priority = 0,
    powerUsage = 160,
    cache = nil,
    storedAmount = 0,
    capacity = 0,
    oldDirection = defines.direction.north,
}

function EIO:new(object)
    if object == nil then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = EIO
    t.thisEntity = object
    t.entID = object.unit_number
    rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[t.color].sprites[5].name, target=t.thisEntity, surface=t.thisEntity.surface, render_layer="lower-object-above-shadow"}
    t:generateModeIcon()
    t.oldDirection = t:getDirection()
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
        oldPosition = nil,
        inventory = {
            input = {
                index = 0,
                max = 0,
                values = {}
            },
            output = {
                index = 0,
                max = 0,
                values = {}
            },
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
        item = {},
        fluid = {}
    }
    t.guiFilters = {
        item = {},
        fluid = {}
    }
    for i=1, 10 do
        t.guiFilters.item[i] = ""
        t.guiFilters.fluid[i] = ""
    end
    t.combinator = object.surface.create_entity{
        name="rns_Combinator",
        position=object.position,
        force="neutral"
    }
    t.combinator.destructible = false
    t.combinator.operable = false
    t.combinator.minable = false
    t.enabler = {
        operator = "<",
        number = 0,
        filter = nil,
        numberOutput = 1
    }
    t.enablerCombinator = object.surface.create_entity{
        name="rns_Combinator_2",
        position=object.position,
        force="neutral"
    }
    t.enablerCombinator.destructible = false
    t.enablerCombinator.operable = false
    t.enablerCombinator.minable = false
    UpdateSys.add_to_entity_table(t)
    t:createArms()
    BaseNet.postArms(t)
    BaseNet.update_network_controller(t.networkController)
    t:init_cache()
    --UpdateSys.addEntity(t)
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
    if self.enablerCombinator ~= nil then self.enablerCombinator.destroy() end
    UpdateSys.remove_from_entity_table(self)
    BaseNet.postArms(self)
    --[[if self.networkController ~= nil then
        self.networkController.network.ExternalIOTable[Constants.Settings.RNS_Max_Priority+1-self.priority][self.entID] = nil
        self.networkController.network.shouldRefresh = true
    end]]
    BaseNet.update_network_controller(self.networkController, self.entID)
end

function EIO:valid()
    return self.thisEntity ~= nil and self.thisEntity.valid == true
end

function EIO:interactable()
    return self.thisEntity ~= nil and self.thisEntity.valid and self.thisEntity.to_be_deconstructed() == false
end

function EIO:target_interactable()
    --self:reset_focused_entity()
    return self:check_focused_entity() and true or (self:check_focused_entity() and true or false)
    --if self.focusedEntity.thisEntity == nil or self.focusedEntity.thisEntity.valid == false then self:flush_cache() end
    --return self.focusedEntity.thisEntity ~= nil and self.focusedEntity.thisEntity.valid and self.focusedEntity.thisEntity.to_be_deconstructed() == false
end

function EIO:clear_cache()
    self.cache = nil
    self.storedAmount = 0
    self.capacity = 0
end

function EIO:flush_cache(type)
    if self.cache == nil then return end
    if self.networkController ~= nil and BaseNet.exists_in_network(self.networkController, self.thisEntity.unit_number) then
        if type == nil then type = self.type end
        if type == "item" then
            self.networkController.network:delta_ItemExternal_Partition(-self.storedAmount, -self.capacity)
            for i = 1, #self.cache do
                local cached = self.cache[i]
                if cached.name ~= "RNS_Empty" then
                    self.networkController.network:decrease_tracked_item_count(cached.name, cached.count)
                    self.networkController.network:remove_item_from_interface_cache(cached)
                end
            end
        else
            self.networkController.network:delta_FluidExternal_Partition(-self.storedAmount, -self.capacity)
            local cached = self.cache[1]
            if cached ~= nil then
                self.networkController.network:decrease_tracked_fluid_amount(cached.name, cached.amount)
                self.networkController.network:remove_fluid_from_interface_cache(cached)
            end
        end
    end
end

function EIO:inject_cache()
    if self.cache == nil or #self.cache <= 0 then return end
    if self.networkController ~= nil and BaseNet.exists_in_network(self.networkController, self.thisEntity.unit_number) then
        if self.type == "item" then
            self.networkController.network:delta_ItemExternal_Partition(self.storedAmount, self.capacity)
            for i = 1, #self.cache do
                local cached = self.cache[i]
                if cached.name ~= "RNS_Empty" then
                    self.networkController.network:increase_tracked_item_count(cached.name, cached.count)
                    self.networkController.network:add_item_from_interface_cache(cached)
                end
            end
        else
            self.networkController.network:delta_FluidExternal_Partition(self.storedAmount, self.capacity)
            local cached = self.cache[1]
            if cached ~= nil then
                self.networkController.network:increase_tracked_fluid_amount(cached.name, cached.amount)
                self.networkController.network:add_fluid_from_interface_cache(cached)
            end
        end
    end
end

function EIO:init_cache()
    if self.cache ~= nil then return false end
    if self.type == "item" and self.focusedEntity.inventory.output.max ~= 0 then
        self.cache = {}
        for i = 1, self.focusedEntity.inventory.output.max do
            local inv = self.focusedEntity.thisEntity.get_inventory(i)
            if BaseNet.inventory_is_sortable(inv) then inv.sort_and_merge() end
            for j = 1, #inv do
                local itemstack = Itemstack:new(inv[j]) or {name = "RNS_Empty", count = 0}
                self.cache[j] = itemstack
                self.storedAmount = self.storedAmount + (itemstack.count <= 0 and 1 or 0)
            end
            self.capacity = self.capacity + #inv
        end
    elseif self.type == "fluid" and self.focusedEntity.fluid_box.index ~= nil and string.match(self.focusedEntity.fluid_box.flow, "output") then
        local fluid = self.focusedEntity.thisEntity.fluidbox[self.focusedEntity.fluid_box.index]
        self.cache = {}
        if fluid ~= nil then
            self.cache[1] = fluid
            self.storedAmount = self.storedAmount + (fluid and fluid.amount or 0)
        end
        self.capacity = self.focusedEntity.thisEntity.fluidbox.get_capacity(self.focusedEntity.fluid_box.index)
    end
    return true
end

function EIO:update(network)
    if self.io == "output" then return end
    --[[if self:check_focused_entity() == nil then
        self:flush_cache()
        self:clear_cache()
        self:reset_focused_entity()
    end]]
    if self.focusedEntity.thisEntity == nil or self.focusedEntity.thisEntity.valid == false then
        self:flush_cache()
        self:clear_cache()
    end
    if self.type == "item" and self.focusedEntity.inventory.output.max == 0 then
        self:flush_cache()
        self:clear_cache()
    elseif self.type == "fluid" and self.focusedEntity.fluid_box.index == nil then
        self:flush_cache()
        self:clear_cache()
    end

    if self:init_cache() then return end

    if self.type == "item" then
        network:delta_ItemExternal_Partition(-self.storedAmount, -self.capacity)
    else
        network:delta_FluidExternal_Partition(-self.storedAmount, -self.capacity)
    end

    self.storedAmount = 0
    self.capacity = 0

    if self.type == "item" and self.focusedEntity.inventory.output.max ~= 0 then
        for i = 1, self.focusedEntity.inventory.output.max do
            local inv = self.focusedEntity.thisEntity.get_inventory(i)
            if BaseNet.inventory_is_sortable(inv) then inv.sort_and_merge() end
            for j = 1, #inv do
                local itemstack = Itemstack:new(inv[j]) or {name = "RNS_Empty", count = 0}
                self.storedAmount = self.storedAmount + (itemstack.count ~= 0 and 1 or 0)
                if j > #self.cache then
                    if itemstack.name ~= "RNS_Empty" then
                        network:increase_tracked_item_count(itemstack.name, itemstack.count)
                        network:add_item_from_interface_cache(itemstack)
                        self.cache[j] = itemstack
                    end
                    goto continue
                end

                local cached = Itemstack:reload(self.cache[j])

                if cached.name == "RNS_Empty" and itemstack.name == cached.name then goto continue end

                if cached.name ~= "RNS_Empty" and itemstack.name == "RNS_Empty" then
                    network:decrease_tracked_item_count(cached.name, cached.count)
                    network:remove_item_from_interface_cache(cached)
                    self.cache[j] = {name = "RNS_Empty", count = 0}
                elseif cached.name == "RNS_Empty" and itemstack.name ~= "RNS_Empty" then
                    network:increase_tracked_item_count(itemstack.name, itemstack.count)
                    network:add_item_from_interface_cache(itemstack)
                    self.cache[j] = itemstack
                elseif cached:compare_itemstacks(itemstack, true, true) == false then
                    network:decrease_tracked_item_count(cached.name, cached.count)
                    network:remove_item_from_interface_cache(cached)
                    network:increase_tracked_item_count(itemstack.name, itemstack.count)
                    network:add_item_from_interface_cache(itemstack)
                    self.cache[j] = itemstack
                elseif cached.count ~= itemstack.count then
                    local delta = itemstack.count - cached.count
                    if delta > 0 then
                        network:increase_tracked_item_count(itemstack.name, delta)
                        network:add_item_from_interface_cache(itemstack)
                        cached.count = cached.count + delta
                    else
                        network:decrease_tracked_item_count(itemstack.name, math.abs(delta))
                        network:remove_item_from_interface_cache(itemstack)
                        cached.count = cached.count - math.abs(delta)
                    end
                    self.cache[j] = itemstack
                end
                ::continue::
            end
            self.capacity = self.capacity + #inv
            
            if #self.cache > #inv then
                for j = #self.cache, #inv, -1 do
                    local cached = self.cache[j]
                    if cached.name ~= "RNS_Empty" then
                        network:decrease_tracked_item_count(cached.name, cached.count)
                        network:remove_item_from_interface_cache(cached)
                    end
                    self.cache[j] = {name="RNS_Empty", count=0}
                end
            end
        end
    elseif self.type == "fluid" and self.focusedEntity.fluid_box.index ~= nil and string.match(self.focusedEntity.fluid_box.flow, "output") then
        local fluid = self.focusedEntity.thisEntity.fluidbox[self.focusedEntity.fluid_box.index]
        self.storedAmount = self.storedAmount + (fluid and fluid.amount or 0)
        local cached = self.cache[1]
        if fluid == nil and cached == nil then
            --do nothing
        elseif fluid == nil and cached ~= nil then
            network:decrease_tracked_fluid_amount(cached.name, cached.amount)
            network:remove_fluid_from_interface_cache(cached)
            self.cache[1] = nil
        elseif fluid ~= nil and cached == nil then
            network:increase_tracked_fluid_amount(fluid.name, fluid.amount)
            network:add_fluid_from_interface_cache(fluid)
            self.cache[1] = fluid
        elseif fluid.name ~= cached.name or fluid.tempurature ~= cached.tempurature then
            network:decrease_tracked_fluid_amount(cached.name, cached.amount)
            network:remove_fluid_from_interface_cache(cached)
            network:increase_tracked_fluid_amount(fluid.name, fluid.amount)
            network:add_fluid_from_interface_cache(fluid)
            self.cache[1] = fluid
        elseif fluid.amount ~= cached.amount then
            local delta = fluid.amount - cached.amount
            if delta > 0 then
                network:increase_tracked_fluid_amount(fluid.name, delta)
                network:add_fluid_from_interface_cache(fluid)
                cached.amount = cached.amount + delta
            else
                network:decrease_tracked_fluid_amount(fluid.name, math.abs(delta))
                network:remove_fluid_from_interface_cache(fluid)
                cached.amount = cached.amount - math.abs(delta)
            end
        end

        self.capacity = self.capacity + self.focusedEntity.thisEntity.fluidbox.get_capacity(self.focusedEntity.fluid_box.index)
    end

    if self.type == "item" then
        network:delta_ItemExternal_Partition(self.storedAmount, self.capacity)
    else
        network:delta_FluidExternal_Partition(self.storedAmount, self.capacity)
    end
end

function EIO:validate()
    if self.cache == nil then return end
    for k, v in pairs(self.cache) do
        if self.type == "fluid" and game.fluid_prototypes[v.name] == nil then
            self.storedAmount = self.storedAmount - v.amount
            self.cache[k] = nil
        elseif self.type == "item" and game.item_prototypes[v.name] == nil then
            self.storedAmount = self.storedAmount - v.count
            self.cache[k] = nil
        end
    end
end

function EIO:copy_settings(obj)
    self.color = obj.color
    self.onlyModified = obj.onlyModified
    self.whitelistBlacklist = obj.whitelistBlacklist
    self.io = obj.io
    self.type = obj.type
    self.enabler = obj.enabler

    self.filters = {
        item = obj.filters.item,
        fluid = obj.filters.fluid
    }

    self.guiFilters ={
        item = {},
        fluid = {}
    }
    for i=1, 10 do
        self.guiFilters.item[i] = obj.guiFilters.item[i]
        self.guiFilters.fluid[i] = obj.guiFilters.fluid[i]
    end
    for i=1, 10 do
        self:set_icons(i, self.guiFilters[self.type][i] ~= "" and self.guiFilters[self.type][i] or nil, self.type)
    end

    self.priority = obj.priority
    self:generateModeIcon()
end

function EIO:set_icons(index, name, type)
    self.combinator.get_or_create_control_behavior().set_signal(index, name ~= nil and {signal={type=type, name=name}, count=1} or nil)
end

function EIO:serialize_settings()
    local tags = {}

    tags["color"] = self.color
    tags["filters"] = self.filters
    tags["guiFilters"] = self.guiFilters
    tags["onlyModified"] = self.onlyModified
    tags["whitelistBlacklist"] = self.whitelistBlacklist
    tags["io"] = self.io
    tags["priority"] = self.priority
    tags["type"] = self.type
    tags["enabler"] = self.enabler

    return tags
end

function EIO:deserialize_settings(tags)
    self.color = tags["color"]
    self.onlyModified = tags["onlyModified"]
    self.whitelistBlacklist = tags["whitelistBlacklist"]
    self.io = tags["io"]
    self.type = tags["type"]
    self.enabler = tags["enabler"]

    self.filters = tags["filters"]
    self.guiFilters = tags["guiFilters"]
    for i=1, 10 do
        self:set_icons(i, self.guiFilters[self.type][i] ~= "" and self.guiFilters[self.type][i] or nil, self.type)
    end

    self.priority = tags["priority"]
    self:generateModeIcon()
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
            orientation=self.io == "input" and (self:getRealDirection()*0.25)+0.25 or ((self:getRealDirection()*0.25)-0.25)%1.00
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
    self.oldDirection = self:getDirection()
    self:flush_cache()
    self:clear_cache()
    self.focusedEntity = {
        thisEntity = nil,
        oldPosition = nil,
        inventory = {
            input = {
                index = 0,
                max = 0,
                values = {}
            },
            output = {
                index = 0,
                max = 0,
                values = {}
            },
        },
        fluid_box = {
            index = nil,
            filter = "",
            target_position = nil,
            pipe_index = nil,
            flow = ""
        }
    }

    local selfP = self.thisEntity.position
    local area = self:getCheckArea()[self:getDirection()]
    local ents = self.thisEntity.surface.find_entities_filtered{area={area.startP, area.endP}}
    local nearest = nil

    for _, ent in pairs(ents) do
        if ent ~= nil and ent.valid == true and ent.to_be_deconstructed() == false and string.match(string.upper(ent.name), "RNS_") == nil and global.entityTable[ent.unit_number] == nil then
            if (nearest == nil or Util.distance(selfP, ent.position) < Util.distance(selfP, nearest.position)) and
            ((self.type == "item" and Constants.Settings.RNS_TypesWithContainer[ent.type] == true) or (self.type == "fluid" and #ent.fluidbox ~= 0)) then
                nearest = ent
            end
        end
    end

    if nearest == nil then return end
    if #nearest.fluidbox ~= 0 then
        for i=1, #nearest.fluidbox do
            for j=1, #nearest.fluidbox.get_pipe_connections(i) do
                local target = nearest.fluidbox.get_pipe_connections(i)[j]
                if Util.positions_match(target.target_position, self.thisEntity.position) then
                    self.focusedEntity.thisEntity = nearest
                    self.focusedEntity.oldPosition = nearest.position
                    self.focusedEntity.fluid_box.index = i
                    self.focusedEntity.fluid_box.pipe_index = j
                    self.focusedEntity.fluid_box.flow =  target.flow_direction
                    self.focusedEntity.fluid_box.target_position = target.target_position
                    self.focusedEntity.fluid_box.filter =  (nearest.fluidbox.get_locked_fluid(i) ~= nil and {nearest.fluidbox.get_locked_fluid(i)} or {""})[1]
                end
            end
        end
    end
    if Constants.Settings.RNS_TypesWithContainer[nearest.type] == true then
        self.focusedEntity.thisEntity = nearest
        self.focusedEntity.oldPosition = nearest.position
        for _, inv_index in pairs(Constants.Settings.RNS_Inventory_Types[nearest.type].input) do
            if nearest.get_inventory(inv_index) ~= nil then
                self.focusedEntity.inventory.input.max = self.focusedEntity.inventory.input.max + 1
                table.insert(self.focusedEntity.inventory.input.values, inv_index)
            end
        end
        for _, inv_index in pairs(Constants.Settings.RNS_Inventory_Types[nearest.type].output) do
            if nearest.get_inventory(inv_index) ~= nil then
                self.focusedEntity.inventory.output.max = self.focusedEntity.inventory.output.max + 1
                table.insert(self.focusedEntity.inventory.output.values, inv_index)
            end
        end
        if self.focusedEntity.inventory.input.max ~= 0 then self.focusedEntity.inventory.input.index = 1 end
        if self.focusedEntity.inventory.output.max ~= 0 then self.focusedEntity.inventory.output.index = 1 end
    end
    self:init_cache()
end

--Makes sure the focused entity is still in front or else try to search for a new one
function EIO:check_focused_entity()
    if self.focusedEntity.thisEntity == nil or self.focusedEntity.thisEntity.valid == false or self.focusedEntity.thisEntity.to_be_deconstructed() then self:reset_focused_entity() return end
    if Util.positions_match(self.focusedEntity.thisEntity.position, self.focusedEntity.oldPosition) == false then self:reset_focused_entity() return end
    if self.oldDirection ~= self:getDirection() then self:reset_focused_entity() return end
    if self.type == "item" then
        if self.focusedEntity.inventory.input.max == nil or self.focusedEntity.inventory.output.max == nil then self:reset_focused_entity() return end
        if self.focusedEntity.inventory.input.max == 0 and self.io == "output" then self:reset_focused_entity() return end
        if self.focusedEntity.inventory.output.max == 0 and self.io == "input" then self:reset_focused_entity() return end
        
        if self.io == "output" then
            for _, i in pairs(self.focusedEntity.inventory.input.values) do
                if self.focusedEntity.thisEntity.get_inventory(i) == nil then self:reset_focused_entity() return end
            end
        end
        if self.io == "input" then
            for _, i in pairs(self.focusedEntity.inventory.input.values) do
                if self.focusedEntity.thisEntity.get_inventory(i) == nil then self:reset_focused_entity() return end
            end
        end
    elseif self.type == "fluid" then
        if self.focusedEntity.fluid_box.target_position == nil then self:reset_focused_entity() return end
        if Util.positions_match(self.thisEntity.position, self.focusedEntity.fluid_box.target_position) == false then self:reset_focused_entity() return end
        if self.focusedEntity.thisEntity.fluidbox.get_pipe_connections(self.focusedEntity.fluid_box.index) == nil then self:reset_focused_entity() return end
        if self.focusedEntity.thisEntity.fluidbox.get_pipe_connections(self.focusedEntity.fluid_box.index)[self.focusedEntity.fluid_box.pipe_index] == nil then self:reset_focused_entity() return end
        if self.focusedEntity.fluid_box.flow ~= self.focusedEntity.thisEntity.fluidbox.get_pipe_connections(self.focusedEntity.fluid_box.index)[self.focusedEntity.fluid_box.pipe_index].flow_direction then self:reset_focused_entity() return end
        if self.focusedEntity.fluid_box.filter ~= (self.focusedEntity.thisEntity.fluidbox.get_locked_fluid(self.focusedEntity.fluid_box.index) or "") then self:reset_focused_entity() return end
    end
    return true
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
    BaseNet.generateArms(self)
    --[[local areas = self:getCheckArea()
    self:resetConnection()
    for _, area in pairs(areas) do
        local ents = self.thisEntity.surface.find_entities_filtered{area={area.startP, area.endP}}
        for _, ent in pairs(ents) do
            if ent ~= nil and ent.valid == true then
                if ent ~= nil and global.entityTable[ent.unit_number] ~= nil and string.match(ent.name, "RNS_") ~= nil then
                    if area.direction ~= self:getDirection() then --Prevent cable connection on the IO port
                        local obj = global.entityTable[ent.unit_number]
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
                        break
                    end
                end
            end
        end
    end]]
end

function EIO:signal_valid()
    if self.enablerCombinator.get_circuit_network(defines.wire_type.red, defines.circuit_connector_id.constant_combinator) ~= nil or self.enablerCombinator.get_circuit_network(defines.wire_type.green, defines.circuit_connector_id.constant_combinator) ~= nil then
        if self.enabler.filter == nil then return false end
        local amount = self.enablerCombinator.get_merged_signal({type=self.enabler.filter.type, name=self.enabler.filter.name}, defines.circuit_connector_id.constant_combinator)
        if Util.OperatorFunctions[self.enabler.operator](amount, self.enabler.number) == false then return false end
    end
    return true
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

function EIO.has_item_room(inv)
    --inv.sort_and_merge()
    --for i=1, #inv do
    --    if inv[i].count <= 0 then return true end
    --end
    if not inv.is_full() then return true end
    if inv.is_empty() then return true end
    return false
end

function EIO.has_item(inv, itemstack_data, getModified)
    local amount = 0
    if inv.is_empty() then return 0 end
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
        if amount > 0 then break end
    end

    return amount
end

function EIO:getTooltips(guiTable, mainFrame, justCreated)
    if justCreated == true then
		guiTable.vars.Gui_Title.caption = {"gui-description.RNS_NetworkCableIO_External_Title"}
        local mainFlow = GuiApi.add_flow(guiTable, "MainFlow", mainFrame, "vertical")

        local topFrame = GuiApi.add_flow(guiTable, "TopFrame", mainFlow, "horizontal")
        local bottomFrame = GuiApi.add_flow(guiTable, "BottomFrame", mainFlow, "horizontal")

        local colorFrame = GuiApi.add_frame(guiTable, "ColorFrame", topFrame, "vertical", true)
		colorFrame.style = Constants.Settings.RNS_Gui.frame_1
		colorFrame.style.vertically_stretchable = true
		colorFrame.style.left_padding = 3
		colorFrame.style.right_padding = 3
		colorFrame.style.right_margin = 3
		colorFrame.style.width = 150

        GuiApi.add_subtitle(guiTable, "", colorFrame, {"gui-description.RNS_Connection_Color"})
        local colorDD = GuiApi.add_dropdown(guiTable, "RNS_NetworkCableIO_External_Color", colorFrame, Constants.Settings.RNS_ColorG, Constants.Settings.RNS_Colors[self.color], false, {"gui-description.RNS_Connection_Color_tooltip"}, {ID=self.thisEntity.unit_number})
        colorDD.style.minimal_width = 100

        local filtersFrame = GuiApi.add_frame(guiTable, "FiltersFrame", topFrame, "vertical", true)
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
            guiTable.vars.filters[self.type][i] = filter
            if self.guiFilters[self.type][i] ~= "" then
                filter.elem_value = self.guiFilters[self.type][i]
            end
        end

        local settingsFrame = GuiApi.add_frame(guiTable, "SettingsFrame", topFrame, "vertical", true)
		settingsFrame.style = Constants.Settings.RNS_Gui.frame_1
		settingsFrame.style.vertically_stretchable = true
		settingsFrame.style.left_padding = 3
		settingsFrame.style.right_padding = 3
		settingsFrame.style.right_margin = 3
		settingsFrame.style.minimal_width = 200

		GuiApi.add_subtitle(guiTable, "", settingsFrame, {"gui-description.RNS_Setting"})

        --Fluid or Item Mode
        local typeFlow = GuiApi.add_flow(guiTable, "", settingsFrame, "horizontal")
        GuiApi.add_label(guiTable, "", typeFlow, {"gui-description.RNS_Type"}, Constants.Settings.RNS_Gui.white)
        local typeDD = GuiApi.add_dropdown(guiTable, "RNS_NetworkCableIO_External_Type", typeFlow, {{"gui-description.RNS_Item"}, {"gui-description.RNS_Fluid"}}, Constants.Settings.RNS_Types[self.type], false, "", {ID=self.thisEntity.unit_number})
        typeDD.style.minimal_width = 100

        --IO Mode
        local modeFlow = GuiApi.add_flow(guiTable, "", settingsFrame, "horizontal")
        GuiApi.add_label(guiTable, "", modeFlow, {"gui-description.RNS_Mode"}, Constants.Settings.RNS_Gui.white)
        local modeDD = GuiApi.add_dropdown(guiTable, "RNS_NetworkCableIO_External_Mode", modeFlow, {{"gui-description.RNS_Input"}, {"gui-description.RNS_Output"}, {"gui-description.RNS_Both"}}, Constants.Settings.RNS_Modes[self.io], false, "", {ID=self.thisEntity.unit_number})
        modeDD.style.minimal_width = 100

        local priorityFlow = GuiApi.add_flow(guiTable, "", settingsFrame, "horizontal")
        GuiApi.add_label(guiTable, "", priorityFlow, {"gui-description.RNS_Priority"}, Constants.Settings.RNS_Gui.white)
        local priorityDD = GuiApi.add_dropdown(guiTable, "RNS_NetworkCableIO_External_Priority", priorityFlow, Constants.Settings.RNS_Priorities, ((#Constants.Settings.RNS_Priorities+1)/2)-self.priority, false, "", {ID=self.thisEntity.unit_number})
        priorityDD.style.minimal_width = 100

        GuiApi.add_line(guiTable, "", settingsFrame, "horizontal")

        -- Whitelist/Blacklist mode
        local state = "left"
        if self.whitelistBlacklist == "blacklist" then state = "right" end
        GuiApi.add_switch(guiTable, "RNS_NetworkCableIO_External_WhitelistBlacklist", settingsFrame, {"gui-description.RNS_Whitelist"}, {"gui-description.RNS_Blacklist"}, "", "", state, false, {ID=self.thisEntity.unit_number})

        if self.type == "item" and string.match(self.io, "input") ~= nil then
            -- Match metadata mode
            GuiApi.add_checkbox(guiTable, "RNS_NetworkCableIO_External_Modified", settingsFrame, {"gui-description.RNS_Modified"}, {"gui-description.RNS_Modified_description"}, self.onlyModified, false, {ID=self.thisEntity.unit_number})
        end

        if self.enablerCombinator.get_circuit_network(defines.wire_type.red) ~= nil or self.enablerCombinator.get_circuit_network(defines.wire_type.green) ~= nil then
            local enableFrame = GuiApi.add_frame(guiTable, "EnableFrame", bottomFrame, "vertical")
            enableFrame.style = Constants.Settings.RNS_Gui.frame_1
            enableFrame.style.vertically_stretchable = true
            enableFrame.style.left_padding = 3
            enableFrame.style.right_padding = 3
            enableFrame.style.right_margin = 3
    
            GuiApi.add_subtitle(guiTable, "ConditionSub", enableFrame, {"gui-description.RNS_EnableDisable_Condition"})
            local cFlow = GuiApi.add_flow(guiTable, "", enableFrame, "horizontal")
            cFlow.style.vertical_align = "center"
            local filter = GuiApi.add_filter(guiTable, "RNS_NetworkCableIO_External_Enabler", cFlow, "", true, "signal", 40, {ID=self.thisEntity.unit_number})
            guiTable.vars.enabler = filter
            if self.enabler.filter ~= nil then
                filter.elem_value = self.enabler.filter
            end
            local opDD = GuiApi.add_dropdown(guiTable, "RNS_NetworkCableIO_External_Operator", cFlow, Constants.Settings.RNS_OperatorN, Constants.Settings.RNS_Operators[self.enabler.operator], false, "", {ID=self.thisEntity.unit_number})
            opDD.style.minimal_width = 50
            --local number = GuiApi.add_filter(guiTable, "RNS_Detector_Number", cFlow, "", true, "signal", 40, {ID=self.thisEntity.unit_number})
            --number.elem_value = {type="virtual", name="constant-number"}
            local number = GuiApi.add_text_field(guiTable, "RNS_NetworkCableIO_External_Number", cFlow, tostring(self.enabler.number), "", false, true, false, false, nil, {ID=self.thisEntity.unit_number})
            number.style.minimal_width = 100
        end
    end

    for i=1, 10 do
        if self.guiFilters[self.type][i] ~= "" then
            guiTable.vars.filters[self.type][i].elem_value = self.guiFilters[self.type][i]
        end
    end
    if self.enabler.filter ~= nil and (self.enablerCombinator.get_circuit_network(defines.wire_type.red) ~= nil or self.enablerCombinator.get_circuit_network(defines.wire_type.green) ~= nil) then
        guiTable.vars.enabler.elem_value = self.enabler.filter
    end
end

function EIO.interaction(event, RNSPlayer)
    local guiTable = RNSPlayer.GUI[Constants.Settings.RNS_Gui.tooltip]

    if string.match(event.element.name, "RNS_NetworkCableIO_External_Number") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local num = math.min(2^32, tonumber(event.element.text ~= "" and event.element.text or "0"))
        io.enabler.number = num
        event.element.text = tostring(num)
        return
    elseif string.match(event.element.name, "RNS_NetworkCableIO_External_Operator") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local operator = Constants.Settings.RNS_OperatorN[event.element.selected_index]
        if operator ~= io.enabler.operator then
            io.enabler.operator = operator
        end
		return
    elseif string.match(event.element.name, "RNS_NetworkCableIO_External_Enabler") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        if event.element.elem_value ~= nil then
            io.enabler.filter = event.element.elem_value
        else
            io.enabler.filter = nil
        end
		return
    elseif string.match(event.element.name, "RNS_NetworkCableIO_External_Filter") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        if event.element.elem_value ~= nil then
            io.guiFilters[event.element.tags.type][event.element.tags.index] = event.element.elem_value
            io.combinator.get_or_create_control_behavior().set_signal(event.element.tags.index, {signal={type=event.element.tags.type, name=event.element.elem_value}, count=1})
        else
            io.guiFilters[event.element.tags.type][event.element.tags.index] = ""
            io.combinator.get_or_create_control_behavior().set_signal(event.element.tags.index, nil)
        end

        io.filters = {
            item = {},
            fluid = {}
        }
        for i = 1, 10 do
            local filter = guiTable.vars.filters[event.element.tags.type][i]
            if filter ~= nil and filter.elem_value ~= nil then
                io.filters[event.element.tags.type][filter.elem_value] = true
            end
        end
		return
    elseif string.match(event.element.name, "RNS_NetworkCableIO_External_Color") then
		local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local color = Constants.Settings.RNS_ColorN[event.element.selected_index]
        if color ~= io.color then
            io.color = color
            rendering.draw_sprite{sprite=Constants.NetworkCables.Cables[io.color].sprites[5].name, target=io.thisEntity, surface=io.thisEntity.surface, render_layer="lower-object-above-shadow"}  
            io:createArms()
            BaseNet.postArms(io)
            BaseNet.update_network_controller(io.networkController)
        end
		return
	elseif string.match(event.element.name, "RNS_NetworkCableIO_External_Mode") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local mode = Constants.Settings.RNS_ModeN[event.element.selected_index]
        if mode ~= io.io then
            io.io = mode
            io:generateModeIcon()
            if mode == "input" then
                io:inject_cache()
            elseif mode == "output" then
                io:flush_cache()
            end
        end
		return
    elseif string.match(event.element.name, "RNS_NetworkCableIO_External_Type") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        local type = Constants.Settings.RNS_TypeN[event.element.selected_index]
        if type ~= io.type then
            io:flush_cache(io.type)
            io:clear_cache()
            io.type = type
            RNSPlayer:push_varTable(id, true)
            for i=1, 10 do
                local filter = io.guiFilters[io.type][i]
                io.combinator.get_or_create_control_behavior().set_signal(i, filter ~= "" and {signal={type=io.type, name=filter}, count=1} or nil)
            end
        end
		return
    elseif string.match(event.element.name, "RNS_NetworkCableIO_External_Priority") then
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
        end
		return
    elseif string.match(event.element.name, "RNS_NetworkCableIO_External_WhitelistBlacklist") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        io.whitelistBlacklist = event.element.switch_state == "left" and "whitelist" or "blacklist"
		return
    elseif string.match(event.element.name, "RNS_NetworkCableIO_External_Modified") then
        local id = event.element.tags.ID
		local io = global.entityTable[id]
		if io == nil then return end
        io.onlyModified = event.element.state
		return
    end
end