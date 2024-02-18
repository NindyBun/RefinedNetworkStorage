Itemstack = {
    name = nil,
    type = nil,
    prototype = nil,
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
    if item == nil then return end
    if item.valid_for_read == false then return end
    if item.count <= 0 then return end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = Itemstack
    t.name = item.name
    t.type = item.type
    t.prototype = item.prototype

    t.health = item.health
    --if t.health < 1.0 then t.modified = true end

    t.count = item.count
    t.ammo = item.type == "ammo" and item.ammo or nil
    t.durability = item.is_tool and item.durability or nil

    t.tags = item.is_item_with_tags and table.deepcopy(item.tags or {}) or nil
    --if Util.getTableLength_non_nil(t.tags) > 0 then t.modified = true end

    t.item_number = item.item_number

    t.extras = {}
    t.extras.grid = item.grid
    --if #t.extras.grid.get_contents() > 0 then t.modified = true end

    t.extras.custom_description = item.is_item_with_tags and table.deepcopy(item.custom_description) or nil
    --if t.extras.custom_description ~= nil then t.modified = true end

    t.extras.is_blueprint_setup = item.is_blueprint and item.is_blueprint_setup() or nil
    --if t.extras.is_blueprint_setup ~= nil then t.modified = true end

    t.extras.blueprint_entities = item.is_blueprint and table.deepcopy(item.get_blueprint_entities()) or nil
    --if Util.getTableLength_non_nil(t.extras.blueprint_entities) > 0 then t.modified = true end

    t.extras.blueprint_entity_count = item.is_blueprint and item.get_blueprint_entity_count() or nil
    --if t.extras.blueprint_entity_count > 0 then t.modified = true end

    t.extras.blueprint_tiles = item.is_blueprint and table.deepcopy(item.get_blueprint_tiles()) or nil
    --if Util.getTableLength_non_nil(t.extras.blueprint_tiles) > 0 then t.modified = true end

    t.extras.blueprint_icons = (item.is_blueprint or item.is_blueprint_book) and table.deepcopy(item.blueprint_icons) or nil
    --if Util.getTableLength_non_nil(t.extras.blueprint_icons) > 0 then t.modified = true end

    t.extras.default_icons = (item.is_blueprint or item.is_blueprint_book) and table.deepcopy(item.default_icons) or nil
    --if Util.getTableLength_non_nil(t.extras.blueprint_icons) > 0 then t.modified = true end

    t.extras.blueprint_snap_to_grid = (item.is_blueprint or item.is_blueprint_book) and item.blueprint_snap_to_grid or nil
    t.extras.blueprint_position_relative_to_grid = (item.is_blueprint or item.is_blueprint_book) and item.blueprint_position_relative_to_grid or nil
    t.extras.blueprint_absolute_snapping = (item.is_blueprint or item.is_blueprint_book) and item.blueprint_absolute_snapping or nil
    t.extras.cost_to_build = (item.is_blueprint or item.is_blueprint_book) and item.cost_to_build or nil
    t.extras.active_index = item.is_blueprint_book and item.active_index or nil

    t.extras.label = item.is_item_with_label and item.label or nil
    t.extras.label_color = item.is_item_with_label and item.label_color or nil
    t.extras.allow_manual_label_change = item.is_item_with_label and item.allow_manual_label_change or nil

    t.extras.extends_inventory = item.is_item_with_inventory and item.extends_inventory or nil
    t.extras.prioritize_insertion_mode = item.is_item_with_inventory and item.prioritize_insertion_mode or nil
    t.extras.item_inventory = item.is_item_with_inventory and item.get_inventory(defines.inventory.item_main).get_contents() or nil

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

    t.extras.connected_entity = (item.type == "spidertron-remote" and item.connected_entity ~= nil) and {
        name = item.connected_entity.name,
        entity_label = item.connected_entity.entity_label,
        color = item.connected_entity.color,
        unit_number = item.connected_entity.unit_number
    } or nil

    t.extras.entity_label = item.is_item_with_entity_data and item.entity_label or nil
    t.extras.entity_color = item.is_item_with_entity_data and item.entity_color or nil

    --doesn't include those with ammo or durability because I can easily store them in code
    t.modified = Util.getTableLength_non_nil(t.extras) > 0 or t.health ~= 1.0 or Util.getTableLength_non_nil(t.tags or {}) > 0
    return t
end

--Requires item1 and item2 to be instances of class Itemstack
function Itemstack:compare_itemstacks(itemstack, exact)
    if self.name ~= itemstack.name then return false end
    if self.prototype ~= itemstack.prototype then return false end
    if self.type ~= itemstack.type then return false end

    if exact then
        if self.health ~= itemstack.health then return false end
        if self.ammo ~= itemstack.ammo then
            if self.ammo > itemstack.ammo and itemstack.count == 1 then return false end
            if self.ammo < itemstack.ammo and self.count == 1 then return false end
        end
        if self.durability ~= itemstack.durability then
            if self.durability > itemstack.durability and itemstack.count == 1 then return false end
            if self.durability < itemstack.durability and self.count == 1 then return false end
        end

        if self.modified ~= itemstack.modified and self.modified == true then return false end
        if Itemstack.compare_tags(self.tags, itemstack.tags) == false then return false end
        if Itemstack.compare_tags(self.extras, itemstack.extras) == false then return false end
    end

    return true
end

function Itemstack.compare_tags(tag1, tag2)
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

function Itemstack:split(itemstack_master, amount, simulate)
    local split = self:copy()
    local splitAmount = math.min(self.count, amount)

    split.count = splitAmount

    if not simulate then
        self.count = self.count - splitAmount
        if self.ammo ~= nil then
            split.ammo = itemstack_master.ammo ~= itemstack_master.prototype.magazine_size and self.ammo or itemstack_master.prototype.magazine_size
            self.ammo = itemstack_master.ammo ~= itemstack_master.prototype.magazine_size and itemstack_master.prototype.magazine_size or self.ammo
        end
        if self.durability ~= nil then
            split.durability = itemstack_master.durability ~= itemstack_master.prototype.durability and self.durability or itemstack_master.prototype.durability
            self.durability = itemstack_master.durability ~= itemstack_master.prototype.durability and itemstack_master.prototype.durability or self.durability
        end
    end

    return split
end

function Itemstack:copy()
    return Util.copy(self)
end