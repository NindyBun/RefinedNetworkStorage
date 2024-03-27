GuiApi = GuiApi or {}

function GuiApi.create_base_window(type, RNSPlayer, showTitle, showMainFrame, isScrollPane, windowDirection, mainFrameDirection)
    if RNSPlayer == nil then return end
    if RNSPlayer.thisEntity.gui.screen[type] ~= nil and RNSPlayer.thisEntity.gui.screen[type].valid == true then RNSPlayer.thisEntity.gui.screen[type].destroy() end
    if RNSPlayer.thisEntity.gui.screen[type] ~= nil and RNSPlayer.thisEntity.gui.screen[type].valid == false then RNSPlayer.thisEntity.gui.screen[type] = nil end
    local guiTable = {RNSPlayer=RNSPlayer, vars={}}
    guiTable.gui = RNSPlayer.thisEntity.gui.screen.add{type="frame", name=type, direction=windowDirection or "vertical"}
    guiTable.gui.style.padding = 5
    guiTable.gui.style.top_padding = 0
    guiTable.gui.style.margin = 0
    if showTitle == true then GuiApi.create_title(guiTable, true) end
    if showMainFrame == true then
        local mainFrame = nil
        if isScrollPane == false then
            mainFrame = GuiApi.add_frame(guiTable, "MainFrame", guiTable.gui, mainFrameDirection or "vertical", true)
            mainFrame.style = "invisible_frame"
        else
            mainFrame = GuiApi.add_scroll_pane(guiTable, "MainFrame", guiTable.gui, nil, true)
        end
        mainFrame.style.vertically_stretchable = true
    end
    GuiApi.set_size(guiTable.gui, Constants.Settings.RNS_Gui.default_gui_height, Constants.Settings.RNS_Gui.default_gui_width)
    GuiApi.center_window(guiTable.gui)
    return guiTable
end

function GuiApi.create_relative_window(type, relativeGuiType, guiPosition, RNSPlayer, showTitle, showMainFrame, isScrollPane, windowDirection, mainFrameDirection)
    if RNSPlayer == nil then return end
    if RNSPlayer.thisEntity.gui.relative[type] ~= nil and RNSPlayer.thisEntity.gui.relative[type].valid == true then RNSPlayer.thisEntity.gui.relative[type].destroy() end
    if RNSPlayer.thisEntity.gui.relative[type] ~= nil and RNSPlayer.thisEntity.gui.relative[type].valid == false then RNSPlayer.thisEntity.gui.relative[type] = nil end
    local guiTable = {RNSPlayer=RNSPlayer, vars={}}
    guiTable.gui = RNSPlayer.thisEntity.gui.relative.add{type="frame", name=type, direction=windowDirection or "vertical", anchor={gui=relativeGuiType, position=guiPosition}}
    guiTable.gui.style.padding = 5
    guiTable.gui.style.top_padding = 0
    guiTable.gui.style.margin = 0
    if showTitle == true then GuiApi.create_title(guiTable, false) end
    if showMainFrame == true then
        local mainFrame = nil
        if isScrollPane == false then
            mainFrame = GuiApi.add_frame(guiTable, "MainFrame", guiTable.gui, mainFrameDirection or "vertical", true)
            mainFrame.style = "invisible_frame"
        else
            mainFrame = GuiApi.add_scroll_pane(guiTable, "MainFrame", guiTable.gui, nil, true)
        end
        mainFrame.style.vertically_stretchable = true
    end
    GuiApi.set_size(guiTable.gui, Constants.Settings.RNS_Gui.default_gui_height, Constants.Settings.RNS_Gui.default_gui_width)
    --GuiApi.center_window(guiTable.gui)
    return guiTable
end

function GuiApi.set_size(gui, height, width)
    if height ~= nil then gui.style.natural_height = height end
    if width ~= nil then gui.style.natural_width = width end
end

function GuiApi.create_title(guiTable, addDragBar)
    local topBarFlow = GuiApi.add_flow(guiTable, "topBarFlow", guiTable.gui, "horizontal", true)
    topBarFlow.style.vertical_align = "center"
    topBarFlow.style.padding = 0
    topBarFlow.style.margin = 0

    local barTitle = {"gui-description." .. guiTable.gui.name .. "_Title"}
    GuiApi.add_label(guiTable, "Gui_Title", topBarFlow, barTitle, Constants.Settings.RNS_Gui.orange, nil, true, Constants.Settings.RNS_Gui.title_font)

    if addDragBar then
        local dragArea = GuiApi.add_empty_widget(guiTable, "", topBarFlow, guiTable.gui, Constants.Settings.RNS_Gui.drag_area_size)
        dragArea.style.left_margin = 8
        dragArea.style.right_margin = 8
        dragArea.style.minimal_width = 30
    end
end

function GuiApi.add_flow(guiTable, name, gui, direction, save)
    if name ~= nil and name ~= "" and gui[name] ~= nil then gui[name].destroy() end
    local flow = gui.add{type="flow", name=name, direction=direction}
    flow.style.padding = 0
    flow.style.margin = 0
    flow.style.horizontally_stretchable = true
    if guiTable ~= nil and save == true then
        guiTable.vars[name] = flow
    end
    return flow
end

function GuiApi.add_close_button(guiTable)
    local button = GuiApi.add_button(guiTable, guiTable.gui.name .. "_CloseButton", guiTable.vars.topBarFlow, "utility.close_white", "utility.close_black", "utility.close_black", {"gui-description.RNS_CloseButton"}, Constants.Settings.RNS_Gui.close_button_size)
    button.style = "frame_action_button"
end

function GuiApi.center_window(guiTable)
    guiTable.force_auto_center()
end

function GuiApi.add_frame(guiTable, name, gui, direction, save)
    if name ~= nil and name ~= "" and gui[name] ~= nil then gui[name].destroy() end
    local frame = gui.add{type="frame", name=name, direction=direction}
    frame.style.padding = 0
    frame.style.margin = 0
    frame.style.horizontally_stretchable = true
    if guiTable ~= nil and save == true then
        guiTable.vars[name] = frame
    end
    return frame
end

function GuiApi.add_scroll_pane(guiTable, name, gui, size, save, style, scroll_verically)
    if name ~= nil and name ~= "" and gui[name] ~= nil then gui[name].destroy() end
    local scrollPane = gui.add{type="scroll-pane", name=name, horizontal_scroll_policy="never", vertical_scroll_policy=scroll_verically or "always"}
    if style ~= nil then scrollPane.style = style end
    scrollPane.style.padding = 0
    scrollPane.style.margin = 0
    scrollPane.style.maximal_height = size
    scrollPane.style.horizontally_stretchable = true
    if guiTable ~= nil and save == true then
        guiTable.vars[name] = scrollPane
    end
    return scrollPane
end

function GuiApi.add_button(guiTable, name, gui, sprite, hoverSprite, clickedSprite, tooltip, size, save, visible, count, style, tags)
    if visible == false then return end
    if name ~= nil and name ~= "" and gui[name] ~= nil then gui[name].destroy() end
    local button = gui.add{type="sprite-button", name=name, sprite=sprite, hovered_sprite=hoverSprite, clicked_sprite=clickedSprite, resize_to_sprite=false, tooltip=tooltip, number=count, tags=tags}
    if style ~= nil then button.style = style end
    button.style.minimal_width = size
    button.style.maximal_width = size
    button.style.minimal_height = size
    button.style.maximal_height = size
    button.style.padding = 0
    button.style.margin = 0
    if guiTable ~= nil and save == true then
        guiTable.vars[name] = button
    end
    return button
end

function GuiApi.add_simple_button(guiTable, name, gui, text, tooltip, save, tags)
    -- Check if this Element doesn't exist --
    if name ~= nil and name ~= "" and gui[name] ~= nil then gui[name].destroy() end
    local button = gui.add{type="button", name=name, caption=text, tooltip=tooltip, tags=tags}

    if guiTable ~= nil and save == true then
        guiTable.vars[name] = button
    end
    return button
end

function GuiApi.add_label(guiTable, name, gui, text, color, tooltip, save, font, style)
    if name ~= nil and name ~= "" and gui[name] ~= nil then gui[name].destroy() end

    local label = gui.add{type="label", name, caption=text, tooltip=tooltip}
    if style ~= nil then
        label.style = style
    else
        label.style.font = font or Constants.Settings.RNS_Gui.label_font
        label.style.font_color = color or Constants.Settings.RNS_Gui.blue
    end
    if guiTable ~= nil and save == true then
        guiTable.vars[name] = label
    end
    return label
end

function GuiApi.add_empty_widget(guiTable, name, gui, parent, sizeX, sizeY, save)
    if name ~= nil and name ~= "" and gui[name] ~= nil then gui[name].destroy() end
    local widget = gui.add{type="empty-widget", name=name, style="draggable_space"}
    widget.drag_target = parent
    if sizeX ~= nil then widget.style.height = sizeX end
    if sizeY ~= nil then widget.style.width = sizeY end
    widget.style.padding = 0
    widget.style.margin = 0
    widget.style.horizontally_stretchable = true
    if guiTable ~= nil and save == true then
        guiTable.vars[name] = widget
    end
    return widget
end

function GuiApi.add_line(guiTable, name, gui, direction, save)
    if name ~= nil and name ~= "" and gui[name] ~= nil then gui[name].destroy() end
    local line = gui.add{type="line", name=name, direction=direction}
    if guiTable ~= nil and save == true then
        guiTable.vars[name] = line
    end
    return line
end

function GuiApi.add_subtitle(guiTable, name, gui, text, save)
    local flow = GuiApi.add_flow(guiTable, "", gui, "vertical", save)
    flow.style.horizontal_align = "center"
    flow.style.vertically_stretchable = false
    GuiApi.add_line(guiTable, "", flow, "horizontal")
    local label = GuiApi.add_label(guiTable, "", flow, text, nil, nil, false, nil, Constants.Settings.RNS_Gui.yellow_title)
    label.style.left_margin = 10
    label.style.right_margin = 10
    GuiApi.add_line(guiTable, "", flow, "horizontal")
end

function GuiApi.add_table(guiTable, name, gui, column, save)
    if name ~= nil and name ~= "" and gui[name] ~= nil then gui[name].destroy() end
    local tableGui = gui.add{type="table", name=name, column_count=column}
    tableGui.style.padding = 0
    tableGui.style.margin = 0
    tableGui.style.cell_padding = 0
    tableGui.style.horizontal_spacing = 0
    tableGui.style.vertical_spacing = 0
    if guiTable ~= nil and save == true then
        guiTable.vars[name] = tableGui
    end
    return tableGui
end

function GuiApi.add_sprite(guiTable, name, gui, path, tooltip, save)
    if name ~= nil and name ~= "" and gui[name] ~= nil then gui[name].destroy() end
    local sprite = gui.add{type="sprite", name=name, sprite=path, tooltip=tooltip}
    sprite.style.padding = 0
    sprite.style.margin = 0
    if guiTable ~= nil and save == true then
        guiTable.vars[name] = sprite
    end
    return sprite
end

function GuiApi.add_item_frame(guiTable, name, gui, tooltip, item, amount, itemSize, fontStyle, color, save)
    local frame = GuiApi.add_frame(guiTable, name, gui, "horizontal")
    local sprite = GuiApi.add_sprite(guiTable, "", frame, "item/" .. item, tooltip or game.item_prototypes[item].localised_name)
    if itemSize ~= nil then
        sprite.resize_to_sprite = false
        sprite.style.size = itemSize
    end
    local label = GuiApi.add_label(guiTable, "", frame, amount, color)
    label.style.vertical_align = "center"
    label.style.horizontal_align = "center"
    label.style.size = itemSize
    if fontStyle ~= nil then
        label.style.font = fontStyle
    end
    if guiTable ~= nil and save == true then
        guiTable.vars[name] = frame
    end
    return frame
end

function GuiApi.add_progress_bar(guiTable, name, gui, text, tooltip, save, color, value, width, height)
    if name ~= nil and name ~= "" and gui[name] ~= nil then gui[name].destroy() end

    local progressBar = gui.add{type="progressbar", name=name, caption=text, tooltip=tooltip}
    if color ~= nil then progressBar.style.color = color end

    if width ~= nil then progressBar.style.maximal_width = width end
    if height ~= nil then progressBar.style.bar_width = height end
    progressBar.style.horizontally_stretchable = true

    if value ~= nil then progressBar.value = value end

    if guiTable ~= nil and save == true then
        guiTable.vars[name] = progressBar
    end
    return progressBar
end

function GuiApi.add_text_field(guiTable, name, gui, text, tooltip, save, numeric, allowDecimal, allowNegative, isPassword, tags)
    if name ~= nil and name ~= "" and gui[name] ~= nil then gui[name].destroy() end
    local textField = gui.add{type="textfield", name=name, text=text, tooltip=tooltip, numeric=numeric or false, allow_decimal=allowDecimal or false, allow_negative=allowNegative or false, is_password=isPassword or false, tags=tags}
    if guiTable ~= nil and save == true then
        guiTable.vars[name] = textField
    end
    return textField
end

function GuiApi.add_switch(guiTable, name, gui, text1, text2, tooltip1, tooltip2, state, save, tags)
    if gui[name] ~= nil then gui[name].destroy() end
    local switch = gui.add{type="switch", name=name, switch_state=state or "left", left_label_caption=text1, right_label_caption=text2, left_label_tooltip=tooltip1, right_label_tooltip=tooltip2, tags=tags}

    if guiTable ~= nil and save == true then
        guiTable.vars[name] = switch
    end
    return switch
end

function GuiApi.add_filter(guiTable, name, gui, tooltip, save, elemType, size, tags)
    if gui[name] ~= nil then gui[name].destroy() end
    local filter = gui.add{type="choose-elem-button", name=name, tooltip=tooltip, elem_type=elemType, tags=tags}
    filter.style.height = size
    filter.style.width = size
    
    if guiTable ~= nil and save == true then
        guiTable.vars[name] = filter
    end
    return filter
end

function GuiApi.add_checkbox(guiTable, name, gui, text, tooltip, state, save, tags)
    if gui[name] ~= nil then gui[name].destroy() end
    local checkBox = gui.add{type="checkbox", name=name, caption=text, tooltip=tooltip, state=state or false, tags = tags}

    if guiTable ~= nil and save == true then
        guiTable.vars[name] = checkBox
    end
    return checkBox
end

function GuiApi.add_dropdown(guiTable, name, gui, values, selected, save, tooltip, tags)
    if gui[name] ~= nil then gui[name].destroy() end
    local dropDown = gui.add{type="drop-down", name=name, items=values, selected_index=selected, tooltip=tooltip, tags=tags}

    dropDown.style.maximal_width = 200
    if guiTable ~= nil and save == true then
        guiTable.vars[name] = dropDown
    end
    return dropDown
end

function GuiApi.add_slider(guiTable, name, gui, min, max, initial, step, save, tooltip, tags, d_slider, d_values)
    if gui[name] ~= nil then gui[name].destroy() end
    local slider = gui.add{type="slider", name=name, minimum_value=min, maximum_value=max, value=initial, value_step=step, discrete_slider=d_slider, discrete_values=d_values, tooltip=tooltip, tags=tags}

    slider.style.maximal_width = 250
    if guiTable ~= nil and save == true then
        guiTable.vars[name] = slider
    end
    return slider
end