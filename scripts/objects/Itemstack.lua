Itemstack = {
    name = nil,
    type = nil,
    --prototype = nil,
    health = nil,
    count = nil,
    durability = nil,
    ammo = nil,
    tags = nil,
    item_number = nil,
    extras = nil,
    modified = false
}

function Itemstack:new(item)
    if item == nil then return nil end
    if item.valid_for_read == false then return nil end
    if item.count <= 0 then return nil end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = Itemstack
    local offset = 0
    t.name = item.name
    t.type = item.type
    --t.prototype = game.item_prototypes[t.name]

    t.health = item.health
    --if t.health < 1.0 then t.modified = true end

    t.count = item.count
    t.ammo = item.type == "ammo" and item.ammo or nil
    t.durability = item.is_tool and item.durability or nil

    t.tags = item.is_item_with_tags and Util.copy(item.tags or {}) or nil
    --if Util.getTableLength_non_nil(t.tags) > 0 then t.modified = true end

    t.item_number = item.item_number

    t.extras = {}
    t.extras.grid = item.grid and item.grid.get_contents() or nil
    --if #t.extras.grid.get_contents() > 0 then t.modified = true end

    t.extras.custom_description = item.is_item_with_tags and item.custom_description or nil
    if t.extras.custom_description ~= nil and t.extras.custom_description == "" then offset = offset + 1 end
    --if t.extras.custom_description ~= nil then t.modified = true end

    t.extras.is_blueprint_setup = item.is_blueprint and item.is_blueprint_setup() or nil
    if t.extras.is_blueprint_setup ~= nil and t.extras.is_blueprint_setup == false then offset = offset + 1 end
    --if t.extras.is_blueprint_setup ~= nil then t.modified = true end

    t.extras.blueprint_entities = item.is_blueprint and Util.copy(item.get_blueprint_entities() or {}) or nil
    --if Util.getTableLength_non_nil(t.extras.blueprint_entities) > 0 then t.modified = true end

    t.extras.blueprint_entity_count = item.is_blueprint and item.get_blueprint_entity_count() or nil
    if t.extras.blueprint_entity_count and t.extras.blueprint_entity_count == 0 then offset = offset + 1 end

    t.extras.blueprint_tiles = item.is_blueprint and Util.copy(item.get_blueprint_tiles() or {}) or nil
    --if Util.getTableLength_non_nil(t.extras.blueprint_tiles) > 0 then t.modified = true end

    t.extras.blueprint_icons = item.is_blueprint and Util.copy(item.blueprint_icons or {}) or nil
    --if Util.getTableLength_non_nil(t.extras.blueprint_icons) > 0 then t.modified = true end

    t.extras.default_icons = (item.is_blueprint and item.get_blueprint_entity_count() ~= 0) and Util.copy(item.default_icons or {}) or nil
    --if Util.getTableLength_non_nil(t.extras.blueprint_icons) > 0 then t.modified = true end
    t.extras.blueprint_snap_to_grid = item.is_blueprint and item.blueprint_snap_to_grid or nil
    t.extras.blueprint_position_relative_to_grid = item.is_blueprint and item.blueprint_position_relative_to_grid or nil
    t.extras.blueprint_absolute_snapping = item.is_blueprint and item.blueprint_absolute_snapping or nil
    t.extras.cost_to_build = item.is_blueprint and item.cost_to_build or nil
    t.extras.active_index = item.is_blueprint_book and item.active_index or nil

    t.extras.label = item.is_item_with_label and item.label or nil
    t.extras.label_color = item.is_item_with_label and item.label_color or nil
    t.extras.allow_manual_label_change = item.is_item_with_label and item.allow_manual_label_change or nil
    if t.extras.allow_manual_label_change ~= nil and t.extras.allow_manual_label_change == false then offset = offset + 1 end

    t.extras.extends_inventory = item.is_item_with_inventory and item.extends_inventory or nil
    if t.extras.extends_inventory ~= nil and t.extras.extends_inventory == game.item_prototypes[item.name].extends_inventory_by_default then offset = offset + 1 end

    t.extras.prioritize_insertion_mode = item.is_item_with_inventory and item.prioritize_insertion_mode or nil
    if t.extras.prioritize_insertion_mode ~= nil and t.extras.prioritize_insertion_mode == game.item_prototypes[item.name].insertion_priority_mode then offset = offset + 1 end

    t.extras.item_inventory = item.is_item_with_inventory and item.get_inventory(defines.inventory.item_main).get_contents() or nil
    if t.extras.item_inventory and t.extras.item_inventory == 0 then offset = offset + 1 end

    t.extras.entity_filters = item.is_deconstruction_item and item.entity_filters or nil
    t.extras.entity_filter_mode = item.is_deconstruction_item and item.entity_filter_mode or nil
    t.extras.tile_filters = item.is_deconstruction_item and item.tile_filters or nil
    t.extras.tile_filter_mode = item.is_deconstruction_item and item.tile_filter_mode or nil
    t.extras.tile_selection_mode = item.is_deconstruction_item and item.tile_selection_mode or nil
    t.extras.trees_and_rocks_only = item.is_deconstruction_item and item.trees_and_rocks_only or nil
    t.extras.entity_filter_count = item.is_deconstruction_item and item.entity_filter_count or nil
    t.extras.tile_filter_count = item.is_deconstruction_item and item.tile_filter_count or nil

    t.extras.construction_filters = item.is_upgrade_item and {} or nil
    if item.is_upgrade_item then
        for i = 1, item.prototype.mapper_count do
            t.extras.construction_filters[i] = {
                from = item.get_mapper(i, "from"),
                to = item.get_mapper(i, "to")
            }
        end
    end

    t.extras.stack_export_string = (item.is_item_with_tags or item.is_blueprint or item.is_blueprint_book or item.is_deconstruction_item or item.is_upgrade_item) and item.export_stack() or nil
    if t.extras.stack_export_string ~= nil then offset = offset + 1 end

    t.extras.connected_entity = (item.type == "spidertron-remote" and item.connected_entity ~= nil) and {
        name = item.connected_entity.name,
        entity_label = item.connected_entity.entity_label,
        color = item.connected_entity.color,
        unit_number = item.connected_entity.unit_number
    } or nil

    t.extras.entity_label = item.is_item_with_entity_data and item.entity_label or nil
    t.extras.entity_color = item.is_item_with_entity_data and item.entity_color or nil

    --doesn't include those with ammo or durability because I can easily store them in code
    --those with different health can't be in drives because they don't stack together with normal ones
    t.modified = (Util.getTableLength_non_nil(t.extras) - offset) > 0 or t.health ~= 1.0 or Util.getTableLength_non_nil(t.tags or {}) > 0
        --or (t.ammo ~= nil and t.ammo ~= game.item_prototypes[t.name].magazine_size)
        --or (t.durability ~= nil and t.durability ~= game.item_prototypes[t.name].durability)
    return t
end

function Itemstack.create_template(name)
    if name == nil or game.item_prototypes[name] == nil then return nil end
    local prototype = game.item_prototypes[name]
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = Itemstack
    t.name = name
    t.type = prototype.type
    t.count = 1
    --t.prototype = prototype
    t.health = 1
    t.ammo = prototype.type == "ammo" and prototype.magazine_size or nil
    t.durability = prototype.durability or nil
    t.modified = false
    t.tags = {}
    t.extras = {}
    return t
end

--Requires item1 and item2 to be instances of class Itemstack
function Itemstack:compare_itemstacks(itemstack, exact, exact_exact)
    if self.name ~= itemstack.name then return false end
    --if self.prototype ~= itemstack.prototype then return false end
    --if self.type ~= itemstack.type then return false end

    if exact then
        if self.health ~= itemstack.health then return false end
        if self.ammo ~= itemstack.ammo then
            if exact_exact then return false end
            if not exact_exact and self.ammo > itemstack.ammo and itemstack.count == 1 then return false end
            if not exact_exact and self.ammo < itemstack.ammo and self.count == 1 then return false end
        end
        if self.durability ~= itemstack.durability then
            if exact_exact then return false end
            if not exact_exact and self.durability > itemstack.durability and itemstack.count == 1 then return false end
            if not exact_exact and self.durability < itemstack.durability and self.count == 1 then return false end
        end
        if self.modified ~= itemstack.modified then return false end
        if Itemstack.compare_tags(self.tags, itemstack.tags) == false then return false end
        if Itemstack.compare_tags(self.extras, itemstack.extras) == false then return false end
        --if self.stack_export_string ~= itemstack.stack_export_string then return false end
    end

    return true
end

function Itemstack.compare_tags(tag1, tag2)
    if tag1 == nil and tag2 == nil then return true end
    if type(tag1) ~= "table" or type(tag2) ~= "table" then return false end
    for k, v in pairs(tag1) do
        local t1 = tag1[k]
        local t2 = tag2[k]
        if type(t1) == "table" and type(t2) == "table" then
            if Itemstack.compare_tags(t1, t2) == false then return false end
        elseif type(t1) ~= type(t2) then
            return false
        elseif t1 ~= t2 then
            return false
        end
    end
    return true
end

function Itemstack:reload(itemstack)
    local mt = {}
    mt.__index = Itemstack
    setmetatable(itemstack, mt)
    return itemstack
end

function Itemstack:split(itemstack_master, amount, exact)
    local split = self:copy()

    if exact then
        if self.ammo ~= nil and self.ammo ~= itemstack_master.ammo and self.ammo ~= game.item_prototypes[self.name].magazine_size then
            if self.count <= 1 then return nil end
            local newAmount = math.min(self.count - 1, amount)
            split.count = newAmount
            self.count = self.count - newAmount
            
            split.ammo = itemstack_master.ammo
            return split
        end
        if self.durability ~= nil and self.durability ~= itemstack_master.durability and self.durability ~= game.item_prototypes[self.name].durability then
            if self.count <= 1 then return nil end
            local newAmount = math.min(self.count - 1, amount)
            split.count = newAmount
            self.count = self.count - newAmount
            
            split.durability = itemstack_master.durability
            return split
        end
    end

    local splitAmount = math.min(self.count, amount)
    split.count = splitAmount
    self.count = self.count - splitAmount
    
    if self.ammo ~= nil then
        --split.ammo = itemstack_master.ammo ~= itemstack_master.prototype.magazine_size and self.ammo or itemstack_master.prototype.magazine_size
        --self.ammo = itemstack_master.ammo ~= itemstack_master.prototype.magazine_size and itemstack_master.prototype.magazine_size or self.ammo
        split.ammo = self.ammo
        self.ammo = game.item_prototypes[self.name].magazine_size
    end
    if self.durability ~= nil then
        --split.durability = itemstack_master.durability ~= itemstack_master.prototype.durability and self.durability or itemstack_master.prototype.durability
        --self.durability = itemstack_master.durability ~= itemstack_master.prototype.durability and itemstack_master.prototype.durability or self.durability
        split.durability = self.durability
        self.durability = game.item_prototypes[self.name].durability
    end

    return split
end

function Itemstack:copy()
    local temp = Util.copy(self)
    local mt = {}
    setmetatable(temp, mt)
    mt.__index = Itemstack
    return temp
end