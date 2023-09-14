Constants = {}
Constants.MOD_ID = "RefinedNetworkStorage"
Constants.Settings = {
    RNS_PlayerPort_Consumption = 100,
    RNS_WirelessTransmitter_Tick = 30,
    RNS_Default_WirelessGrid_Distance = 32*3,
    RNS_Default_Gui_Distance = 11.5,
    RNS_Max_Priority = 5,
    RNS_Priorities = {},
    RNS_ColorG = {
        [1] = {"gui-description.RNS_RED"},
        [2] = {"gui-description.RNS_WHITE"},
        [3] = {"gui-description.RNS_PURPLE"},
        [4] = {"gui-description.RNS_PINK"},
        [5] = {"gui-description.RNS_ORANGE"},
        [6] = {"gui-description.RNS_LIGHTGREEN"},
        [7] = {"gui-description.RNS_LIGHTBLUE"},
        [8] = {"gui-description.RNS_GREY"},
        [9] = {"gui-description.RNS_GREEN"},
        [10] ={"gui-description.RNS_BROWN"},
    },
    RNS_ColorN = {
        [1] = "RED",
        [2] = "WHITE",
        [3] = "PURPLE",
        [4] = "PINK",
        [5] = "ORANGE",
        [6] = "LIGHTGREEN",
        [7] = "LIGHTBLUE",
        [8] = "GREY",
        [9] = "GREEN",
        [10] = "BROWN",
    },
    RNS_Colors = {
        ["RED"] = 1,
        ["WHITE"] = 2,
        ["PURPLE"] = 3,
        ["PINK"] = 4,
        ["ORANGE"] = 5,
        ["LIGHTGREEN"] = 6,
        ["LIGHTBLUE"] = 7,
        ["GREY"] = 8,
        ["GREEN"] = 9,
        ["BROWN"] = 10,
    },
    RNS_RoundRobin = "RNS_RoundRobin",
    RNS_BlankIcon = "__RefinedNetworkStorage__/graphics/blank.png",
    RNS_FR_Cable = "RNS_FR_NetworkCable",
    RNS_Tag = "RNS_DataTag",
    RNS_BeltSides = {
        ["Right"] = 2,
        ["Left"] = 1,
    },
    RNS_Gui_Tick = 55,
    RNS_ItemIO_Tick = 4,
    RNS_BaseItemIO_TransferCapacity = 1,
    RNS_FluidIO_Tick = 5,
    RNS_BaseFluidIO_TransferCapacity = 100,
    RNS_TypesWithContainer = {
        ["ammo-turret"] = true,
        ["artillery-turret"] = true,
        ["artillery-wagon"] = true,
        ["assembling-machine"] = true,
        ["boiler"] = true,
        ["burner-generator"] = true,
        --["car"] = true,
        ["cargo-wagon"] = true,
        ["container"] = true,
        ["furnace"] = true,
        ["infinity-container"] = true,
        --["inserter"] = true,
        ["lab"] = true,
        ["linked-container"] = true,
        ["locomotive"] = true,
        ["logistic-container"] = true,
        --["mining-drill"] = true,
        ["reactor"] = true,
        ["roboport"] = true,
        ["rocket-silo"] = true,
        --["spider-vehicle"] = true,
        --["fluid-turret"] = true,
        --["fluid-wagon"] = true,
        ["generator"] = true,
        --["infinity-pipe"] = true,
        --["offshore-pump"] = true,
        --["pipe"] = true,
        --["pipe-to-ground"] = true,
        --["pump"] = true,
        --["storage-tank"] = true,
        --["transport-belt"] = true,
        --["underground-belt"] = true,
        --["splitter"] = true,
        --["loader"] = true,
        --["loader-1x1"] = true,
    },
    RNS_TypesWithID = {
        ["armor"] = true,
        ["spidertron-remote"] = true,
        ["selection-tool"] = true,
        ["copy-paste-tool"] = true,
        ["upgrade-item"] = true,
        ["deconstruction-item"] = true,
        ["blueprint"] = true,
        ["blueprint-book"] = true,
        ["item-with-entity-data"] = true,
        ["item-with-inventory"] = true,
        ["item-with-tags"] = true,
    },
    RNS_Inventory_Types = {
        ["rocket-silo"] = {
            [1] = {
                slot = defines.inventory.rocket_silo_rocket,
                io = "input"
            },
            [2] = {
                slot = defines.inventory.rocket_silo_result,
                io = "output"
            },
            [3] = {
                slot = defines.inventory.rocket_silo_input,
                io = "input"
            },
            [4] = {
                slot = defines.inventory.rocket_silo_output,
                io = "output"
            }
        },
        ["mining-drill"] = {
            [1] = {
                slot = defines.inventory.fuel,
                io = "input"
            },
            [2] = {
                slot = defines.inventory.burnt_result,
                io = "output"
            },
            [3] = {
                slot = defines.inventory.chest,
                io = "output"
            }
        },
        ["reactor"] = {
            [1] = {
                slot = defines.inventory.fuel,
                io = "input"
            },
            [2] = {
                slot = defines.inventory.burnt_result,
                io = "output"
            },
        },
        ["locomotive"] = {
            [1] = {
                slot = defines.inventory.fuel,
                io = "input"
            },
            [2] = {
                slot = defines.inventory.burnt_result,
                io = "output"
            },
        },
        ["lab"] = {
            [1] = {
                slot = defines.inventory.lab_input,
                io = "input"
            }
        },
        ["cargo-wagon"] = {
            [1] = {
                slot = defines.inventory.cargo_wagon,
                io = "input/output"
            }
        },
        ["burner-generator"] = {
            [1] = {
                slot = defines.inventory.fuel,
                io = "input"
            },
            [2] = {
                slot = defines.inventory.burnt_result,
                io = "output"
            },
        },
        ["boiler"] = {
            [1] = {
                slot = defines.inventory.fuel,
                io = "input"
            },
            [2] = {
                slot = defines.inventory.burnt_result,
                io = "output"
            },
        },
        ["artillery-wagon"] = {
            [1] = {
                slot = defines.inventory.artillery_wagon_ammo,
                io = "input/output"
            }
        },
        ["artillery-turret"] = {
            [1] = {
                slot = defines.inventory.artillery_turret_ammo,
                io = "input/output"
            }
        },
        ["ammo-turret"] = {
            [1] = {
                slot = defines.inventory.turret_ammo,
                io = "input/output"
            }
        },
        ["roboport"] = {
            [1] = {
                slot = defines.inventory.roboport_robot,
                io = "input/output"
            },
            [2] = {
                slot = defines.inventory.roboport_material,
                io = "input/output"
            }
        },
        ["rocket-silo-rocket"] = {
            [1] = {
                slot = defines.inventory.rocket,
                io = "input/output"
            }
        },
        ["logistic-container"] = {
            [1] = {
                slot = defines.inventory.chest,
                io = "input/output"
            }
        },
        ["linked-container"] = {
            [1] = {
                slot = defines.inventory.chest,
                io = "input/output"
            }
        },
        ["container"] = {
            [1] = {
                slot = defines.inventory.chest,
                io = "input/output"
            }
        },
        ["infinity-container"] = {
            [1] = {
                slot = defines.inventory.chest,
                io = "input/output"
            }
        },
        ["furnace"] = {
            [1] = {
                slot = defines.inventory.fuel,
                io = "input"
            },
            [2] = {
                slot = defines.inventory.burnt_result,
                io = "output"
            },
            [3] = {
                slot = defines.inventory.furnace_source,
                io = "input"
            },
            [4] = {
                slot = defines.inventory.furnace_result,
                io = "output"
            },
        },
        ["assembling-machine"] = {
            [1] = {
                slot = defines.inventory.fuel,
                io = "input"
            },
            [2] = {
                slot = defines.inventory.burnt_result,
                io = "output"
            },
            [3] = {
                slot = defines.inventory.assembling_machine_input,
                io = "input"
            },
            [4] = {
                slot = defines.inventory.assembling_machine_output,
                io = "output"
            },
        }
    },
    RNS_Gui = {
        drag_area_size = 25,
        close_button_size = 20,
        default_gui_width = 10,
        default_gui_height = 10,
        tooltip = "tooltip_gui",
        orange = {255, 131, 0},
        blue = {108, 114, 229},
        white = {255, 255, 255},
        yellow_title = "yellow_label",
        frame_1 = "Frame_1",
        button_1 = "Button_1",
        button_2 = "Button_2",
        title_font = "TitleFont",
        label_font = "LabelFont",
        label_font_2 = "LabelFont2",
        scroll_pane = "Scroll_Pane"
    }
}
local j = 1
for i = Constants.Settings.RNS_Max_Priority, -Constants.Settings.RNS_Max_Priority, -1 do
    Constants.Settings.RNS_Priorities[j] = i
    j = j + 1
end
Constants.ItemGroup = {
    Category = {
        group = "RefinedNetworkStorage",
        subgroup = "RNS",
        ItemDrive_subgroup = "RNS-ItemDrives",
        FluidDrive_subgroup = "RNS-FluidDrives",
        Laser_subgroup = "RNS-Lasers",
        Cable_subgroup = "RNS-ColoredCables"
    }
}
Constants.Icons = {
    item = 'utility.indication_arrow',
    fluid = 'utility.fluid_indication_arrow',
    storage = {
        name = "RNS_storage_indication_arrow",
        sprite = "__RefinedNetworkStorage__/graphics/Cables/IO/storage-indication-arrow.png"
    },
    storage_bothways = {
        name = "RNS_storage_indication_arrow_bothways",
        sprite = "__RefinedNetworkStorage__/graphics/Cables/IO/storage-indication-arrow-both-ways.png"
    },
    check_mark = {
        name = "RNS_check_mark_icon",
        sprite = "__RefinedNetworkStorage__/graphics/check-mark.png"
    },
    x_mark = {
        name = "RNS_x_mark_icon",
        sprite = "__RefinedNetworkStorage__/graphics/x-mark.png"
    },
}
Constants.PlayerPort = {
    name = "RNS_PlayerPort",
    icon = "__RefinedNetworkStorage__/graphics/personalPlayerPort.png",
}
Constants.NetworkCables = {
    itemIO = {
        itemEntity = {
            name = "RNS_NetworkCableIOItem_Item",
            itemIcon = "__RefinedNetworkStorage__/graphics/Cables/IO/ItemIO.png",
            entityE =  "__RefinedNetworkStorage__/graphics/Cables/IO/ItemIOSheet.png",
            entityS =  "__RefinedNetworkStorage__/graphics/Cables/IO/IOSheet_S.png"
        },
        slateEntity = {
            name = "RNS_NetworkCableIOItem",
            itemIcon = "__RefinedNetworkStorage__/graphics/Cables/IO/ItemIO.png",
            entityE =  "__RefinedNetworkStorage__/graphics/Cables/IO/ItemIOSheet_E.png",
            entityS =  "__RefinedNetworkStorage__/graphics/Cables/IO/IOSheet_S.png"
        }
    },
    fluidIO = {
        itemEntity = {
            name = "RNS_NetworkCableIOFluid_Item",
            itemIcon = "__RefinedNetworkStorage__/graphics/Cables/IO/FluidIO.png",
            entityE =  "__RefinedNetworkStorage__/graphics/Cables/IO/FluidIOSheet.png",
            entityS =  "__RefinedNetworkStorage__/graphics/Cables/IO/IOSheet_S.png"
        },
        slateEntity = {
            name = "RNS_NetworkCableIOFluid",
            itemIcon = "__RefinedNetworkStorage__/graphics/Cables/IO/FluidIO.png",
            entityE =  "__RefinedNetworkStorage__/graphics/Cables/IO/FluidIOSheet_E.png",
            entityS =  "__RefinedNetworkStorage__/graphics/Cables/IO/IOSheet_S.png"
        }
    },
    externalIO = {
        itemEntity = {
            name = "RNS_NetworkCableIOExternal_Item",
            itemIcon = "__RefinedNetworkStorage__/graphics/Cables/IO/ExternalIO.png",
            entityE =  "__RefinedNetworkStorage__/graphics/Cables/IO/ExternalIOSheet.png",
            entityS =  "__RefinedNetworkStorage__/graphics/Cables/IO/IOSheet_S.png"
        },
        slateEntity = {
            name = "RNS_NetworkCableIOExternal",
            itemIcon = "__RefinedNetworkStorage__/graphics/Cables/IO/ExternalIO.png",
            entityE =  "__RefinedNetworkStorage__/graphics/Cables/IO/ExternalIOSheet_E.png",
            entityS =  "__RefinedNetworkStorage__/graphics/Cables/IO/IOSheet_S.png"
        }
    },
    wirelessTransmitter = {
        itemEntity = {
            name = "RNS_WirelessTransmitter_Item",
            itemIcon = "__RefinedNetworkStorage__/graphics/Networks/Wireless/wirelessTransmitterI.png",
            entityE =  "__RefinedNetworkStorage__/graphics/Networks/Wireless/wirelessTransmitter.png",
            entityS =  "__RefinedNetworkStorage__/graphics/Networks/Wireless/wirelessTransmitterS.png"
        },
        slateEntity = {
            name = "RNS_WirelessTransmitter",
            itemIcon = "__RefinedNetworkStorage__/graphics/Networks/Wireless/wirelessTransmitterI.png",
            entityE =  "__RefinedNetworkStorage__/graphics/Networks/Wireless/wirelessTransmitterE.png",
            entityS =  "__RefinedNetworkStorage__/graphics/Networks/Wireless/wirelessTransmitterS.png"
        }
    },
    Cable = {
        item = {
            name = "RNS_NetworkCable_I",
            itemIcon = "__RefinedNetworkStorage__/graphics/Cables/NetworkCable.png",
            entityE =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCable.png",
            entityS =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCable_S.png",
        },
        entity = {
            name = "RNS_NetworkCable",
            itemIcon = "__RefinedNetworkStorage__/graphics/Cables/NetworkCableBlank.png",
            entityE =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableBlank.png",
            entityS =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableBlank_S.png",
        }
    },
    Sprites = {
        [1] = {
            name = "RNS_NetworkCableNorth",
            sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableN.png",
            sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableN_S.png",
        },
        [2] = {
            name = "RNS_NetworkCableEast",
            sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableE.png",
            sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableE_S.png",
        },
        [4] = {
            name = "RNS_NetworkCableSouth",
            sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableS.png",
            sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableS_S.png",
        },
        [3] = {
            name = "RNS_NetworkCableWest",
            sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableW.png",
            sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableW_S.png",
        }
    },
    Cables = {
        RED = {
            cable = {
                item = {
                    name = "RNS_NetworkCable_I_RED",
                    itemIcon = "__RefinedNetworkStorage__/graphics/Cables/Red/NetworkCableRed.png",
                    entityE =  "__RefinedNetworkStorage__/graphics/Cables/Red/NetworkCableRed.png",
                    entityS =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCable_S.png",
                },
                entity = {
                    name = "RNS_NetworkCable_RED",
                    itemIcon = "__RefinedNetworkStorage__/graphics/Cables/NetworkCableBlank.png",
                    entityE =  "__RefinedNetworkStorage__/graphics/Cables/Red/NetworkCableRedPlate.png",
                    entityS =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableBlank_S.png",
                }
            },
            sprites = {
                [1] = {
                    name = "RNS_NetworkCableNorth_RED",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Red/NetworkCableRedN.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableN_S.png",
                },
                [2] = {
                    name = "RNS_NetworkCableEast_RED",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Red/NetworkCableRedE.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableE_S.png",
                },
                [4] = {
                    name = "RNS_NetworkCableSouth_RED",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Red/NetworkCableRedS.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableS_S.png",
                },
                [3] = {
                    name = "RNS_NetworkCableWest_RED",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Red/NetworkCableRedW.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableW_S.png",
                },
                [5] = {
                    name = "RNS_NetworkCableDot_RED",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Red/NetworkCableRedDot.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableDot_S.png",
                }
            }
        },
        WHITE = {
            cable = {
                item = {
                    name = "RNS_NetworkCable_I_WHITE",
                    itemIcon = "__RefinedNetworkStorage__/graphics/Cables/White/NetworkCableWhite.png",
                    entityE =  "__RefinedNetworkStorage__/graphics/Cables/White/NetworkCableWhite.png",
                    entityS =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCable_S.png",
                },
                entity = {
                    name = "RNS_NetworkCable_WHITE",
                    itemIcon = "__RefinedNetworkStorage__/graphics/Cables/NetworkCableBlank.png",
                    entityE =  "__RefinedNetworkStorage__/graphics/Cables/White/NetworkCableWhitePlate.png",
                    entityS =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableBlank_S.png",
                }
            },
            sprites = {
                [1] = {
                    name = "RNS_NetworkCableNorth_WHITE",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/White/NetworkCableWhiteN.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableN_S.png",
                },
                [2] = {
                    name = "RNS_NetworkCableEast_WHITE",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/White/NetworkCableWhiteE.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableE_S.png",
                },
                [4] = {
                    name = "RNS_NetworkCableSouth_WHITE",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/White/NetworkCableWhiteS.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableS_S.png",
                },
                [3] = {
                    name = "RNS_NetworkCableWest_WHITE",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/White/NetworkCableWhiteW.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableW_S.png",
                },
                [5] = {
                    name = "RNS_NetworkCableDot_WHITE",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/White/NetworkCableWhiteDot.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableDot_S.png",
                }
            }
        },
        PURPLE = {
            cable = {
                item = {
                    name = "RNS_NetworkCable_I_PURPLE",
                    itemIcon = "__RefinedNetworkStorage__/graphics/Cables/Purple/NetworkCablePurple.png",
                    entityE =  "__RefinedNetworkStorage__/graphics/Cables/Purple/NetworkCablePurple.png",
                    entityS =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCable_S.png",
                },
                entity = {
                    name = "RNS_NetworkCable_PURPLE",
                    itemIcon = "__RefinedNetworkStorage__/graphics/Cables/NetworkCableBlank.png",
                    entityE =  "__RefinedNetworkStorage__/graphics/Cables/Purple/NetworkCablePurplePlate.png",
                    entityS =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableBlank_S.png",
                }
            },
            sprites = {
                [1] = {
                    name = "RNS_NetworkCableNorth_PURPLE",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Purple/NetworkCablePurpleN.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableN_S.png",
                },
                [2] = {
                    name = "RNS_NetworkCableEast_PURPLE",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Purple/NetworkCablePurpleE.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableE_S.png",
                },
                [4] = {
                    name = "RNS_NetworkCableSouth_PURPLE",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Purple/NetworkCablePurpleS.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableS_S.png",
                },
                [3] = {
                    name = "RNS_NetworkCableWest_PURPLE",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Purple/NetworkCablePurpleW.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableW_S.png",
                },
                [5] = {
                    name = "RNS_NetworkCableDot_PURPLE",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Purple/NetworkCablePurpleDot.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableDot_S.png",
                }
            }
        },
        PINK = {
            cable = {
                item = {
                    name = "RNS_NetworkCable_I_PINK",
                    itemIcon = "__RefinedNetworkStorage__/graphics/Cables/Pink/NetworkCablePink.png",
                    entityE =  "__RefinedNetworkStorage__/graphics/Cables/Pink/NetworkCablePink.png",
                    entityS =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCable_S.png",
                },
                entity = {
                    name = "RNS_NetworkCable_PINK",
                    itemIcon = "__RefinedNetworkStorage__/graphics/Cables/NetworkCableBlank.png",
                    entityE =  "__RefinedNetworkStorage__/graphics/Cables/Pink/NetworkCablePinkPlate.png",
                    entityS =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableBlank_S.png",
                }
            },
            sprites = {
                [1] = {
                    name = "RNS_NetworkCableNorth_PINK",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Pink/NetworkCablePinkN.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableN_S.png",
                },
                [2] = {
                    name = "RNS_NetworkCableEast_PINK",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Pink/NetworkCablePinkE.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableE_S.png",
                },
                [4] = {
                    name = "RNS_NetworkCableSouth_PINK",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Pink/NetworkCablePinkS.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableS_S.png",
                },
                [3] = {
                    name = "RNS_NetworkCableWest_PINK",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Pink/NetworkCablePinkW.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableW_S.png",
                },
                [5] = {
                    name = "RNS_NetworkCableDot_PINK",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Pink/NetworkCablePinkDot.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableDot_S.png",
                }
            }
        },
        ORANGE = {
            cable = {
                item = {
                    name = "RNS_NetworkCable_I_ORANGE",
                    itemIcon = "__RefinedNetworkStorage__/graphics/Cables/Orange/NetworkCableOrange.png",
                    entityE =  "__RefinedNetworkStorage__/graphics/Cables/Orange/NetworkCableOrange.png",
                    entityS =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCable_S.png",
                },
                entity = {
                    name = "RNS_NetworkCable_ORANGE",
                    itemIcon = "__RefinedNetworkStorage__/graphics/Cables/NetworkCableBlank.png",
                    entityE =  "__RefinedNetworkStorage__/graphics/Cables/Orange/NetworkCableOrangePlate.png",
                    entityS =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableBlank_S.png",
                }
            },
            sprites = {
                [1] = {
                    name = "RNS_NetworkCableNorth_ORANGE",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Orange/NetworkCableOrangeN.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableN_S.png",
                },
                [2] = {
                    name = "RNS_NetworkCableEast_ORANGE",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Orange/NetworkCableOrangeE.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableE_S.png",
                },
                [4] = {
                    name = "RNS_NetworkCableSouth_ORANGE",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Orange/NetworkCableOrangeS.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableS_S.png",
                },
                [3] = {
                    name = "RNS_NetworkCableWest_ORANGE",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Orange/NetworkCableOrangeW.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableW_S.png",
                },
                [5] = {
                    name = "RNS_NetworkCableDot_ORANGE",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Orange/NetworkCableOrangeDot.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableDot_S.png",
                }
            }
        },
        LIGHTGREEN = {
            cable = {
                item = {
                    name = "RNS_NetworkCable_I_LIGHTGREEN",
                    itemIcon = "__RefinedNetworkStorage__/graphics/Cables/LightGreen/NetworkCableLightGreen.png",
                    entityE =  "__RefinedNetworkStorage__/graphics/Cables/LightGreen/NetworkCableLightGreen.png",
                    entityS =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCable_S.png",
                },
                entity = {
                    name = "RNS_NetworkCable_LIGHTGREEN",
                    itemIcon = "__RefinedNetworkStorage__/graphics/Cables/NetworkCableBlank.png",
                    entityE =  "__RefinedNetworkStorage__/graphics/Cables/LightGreen/NetworkCableLightGreenPlate.png",
                    entityS =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableBlank_S.png",
                }
            },
            sprites = {
                [1] = {
                    name = "RNS_NetworkCableNorth_LIGHTGREEN",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/LightGreen/NetworkCableLightGreenN.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableN_S.png",
                },
                [2] = {
                    name = "RNS_NetworkCableEast_LIGHTGREEN",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/LightGreen/NetworkCableLightGreenE.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableE_S.png",
                },
                [4] = {
                    name = "RNS_NetworkCableSouth_LIGHTGREEN",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/LightGreen/NetworkCableLightGreenS.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableS_S.png",
                },
                [3] = {
                    name = "RNS_NetworkCableWest_LIGHTGREEN",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/LightGreen/NetworkCableLightGreenW.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableW_S.png",
                },
                [5] = {
                    name = "RNS_NetworkCableDot_LIGHTGREEN",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/LightGreen/NetworkCableLightGreenDot.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableDot_S.png",
                }
            }
        },
        LIGHTBLUE = {
            cable = {
                item = {
                    name = "RNS_NetworkCable_I_LIGHTBLUE",
                    itemIcon = "__RefinedNetworkStorage__/graphics/Cables/LightBlue/NetworkCableLightBlue.png",
                    entityE =  "__RefinedNetworkStorage__/graphics/Cables/LightBlue/NetworkCableLightBlue.png",
                    entityS =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCable_S.png",
                },
                entity = {
                    name = "RNS_NetworkCable_LIGHTBLUE",
                    itemIcon = "__RefinedNetworkStorage__/graphics/Cables/NetworkCableBlank.png",
                    entityE =  "__RefinedNetworkStorage__/graphics/Cables/LightBlue/NetworkCableLightBluePlate.png",
                    entityS =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableBlank_S.png",
                }
            },
            sprites = {
                [1] = {
                    name = "RNS_NetworkCableNorth_LIGHTBLUE",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/LightBlue/NetworkCableLightBlueN.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableN_S.png",
                },
                [2] = {
                    name = "RNS_NetworkCableEast_LIGHTBLUE",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/LightBlue/NetworkCableLightBlueE.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableE_S.png",
                },
                [4] = {
                    name = "RNS_NetworkCableSouth_LIGHTBLUE",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/LightBlue/NetworkCableLightBlueS.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableS_S.png",
                },
                [3] = {
                    name = "RNS_NetworkCableWest_LIGHTBLUE",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/LightBlue/NetworkCableLightBlueW.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableW_S.png",
                },
                [5] = {
                    name = "RNS_NetworkCableDot_LIGHTBLUE",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/LightBlue/NetworkCableLightBlueDot.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableDot_S.png",
                }
            }
        },
        GREY = {
            cable = {
                item = {
                    name = "RNS_NetworkCable_I_GREY",
                    itemIcon = "__RefinedNetworkStorage__/graphics/Cables/Grey/NetworkCableGrey.png",
                    entityE =  "__RefinedNetworkStorage__/graphics/Cables/Grey/NetworkCableGrey.png",
                    entityS =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCable_S.png",
                },
                entity = {
                    name = "RNS_NetworkCable_GREY",
                    itemIcon = "__RefinedNetworkStorage__/graphics/Cables/NetworkCableBlank.png",
                    entityE =  "__RefinedNetworkStorage__/graphics/Cables/Grey/NetworkCableGreyPlate.png",
                    entityS =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableBlank_S.png",
                }
            },
            sprites = {
                [1] = {
                    name = "RNS_NetworkCableNorth_GREY",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Grey/NetworkCableGreyN.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableN_S.png",
                },
                [2] = {
                    name = "RNS_NetworkCableEast_GREY",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Grey/NetworkCableGreyE.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableE_S.png",
                },
                [4] = {
                    name = "RNS_NetworkCableSouth_GREY",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Grey/NetworkCableGreyS.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableS_S.png",
                },
                [3] = {
                    name = "RNS_NetworkCableWest_GREY",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Grey/NetworkCableGreyW.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableW_S.png",
                },
                [5] = {
                    name = "RNS_NetworkCableDot_GREY",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Grey/NetworkCableGreyDot.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableDot_S.png",
                }
            }
        },
        GREEN = {
            cable = {
                item = {
                    name = "RNS_NetworkCable_I_GREEN",
                    itemIcon = "__RefinedNetworkStorage__/graphics/Cables/Green/NetworkCableGreen.png",
                    entityE =  "__RefinedNetworkStorage__/graphics/Cables/Green/NetworkCableGreen.png",
                    entityS =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCable_S.png",
                },
                entity = {
                    name = "RNS_NetworkCable_GREEN",
                    itemIcon = "__RefinedNetworkStorage__/graphics/Cables/NetworkCableBlank.png",
                    entityE =  "__RefinedNetworkStorage__/graphics/Cables/Green/NetworkCableGreenPlate.png",
                    entityS =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableBlank_S.png",
                }
            },
            sprites = {
                [1] = {
                    name = "RNS_NetworkCableNorth_GREEN",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Green/NetworkCableGreenN.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableN_S.png",
                },
                [2] = {
                    name = "RNS_NetworkCableEast_GREEN",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Green/NetworkCableGreenE.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableE_S.png",
                },
                [4] = {
                    name = "RNS_NetworkCableSouth_GREEN",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Green/NetworkCableGreenS.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableS_S.png",
                },
                [3] = {
                    name = "RNS_NetworkCableWest_GREEN",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Green/NetworkCableGreenW.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableW_S.png",
                },
                [5] = {
                    name = "RNS_NetworkCableDot_GREEN",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Green/NetworkCableGreenDot.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableDot_S.png",
                }
            }
        },
        BROWN = {
            cable = {
                item = {
                    name = "RNS_NetworkCable_I_BROWN",
                    itemIcon = "__RefinedNetworkStorage__/graphics/Cables/Brown/NetworkCableBrown.png",
                    entityE =  "__RefinedNetworkStorage__/graphics/Cables/Brown/NetworkCableBrown.png",
                    entityS =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCable_S.png",
                },
                entity = {
                    name = "RNS_NetworkCable_BROWN",
                    itemIcon = "__RefinedNetworkStorage__/graphics/Cables/NetworkCableBlank.png",
                    entityE =  "__RefinedNetworkStorage__/graphics/Cables/Brown/NetworkCableBrownPlate.png",
                    entityS =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableBlank_S.png",
                }
            },
            sprites = {
                [1] = {
                    name = "RNS_NetworkCableNorth_BROWN",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Brown/NetworkCableBrownN.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableN_S.png",
                },
                [2] = {
                    name = "RNS_NetworkCableEast_BROWN",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Brown/NetworkCableBrownE.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableE_S.png",
                },
                [4] = {
                    name = "RNS_NetworkCableSouth_BROWN",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Brown/NetworkCableBrownS.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableS_S.png",
                },
                [3] = {
                    name = "RNS_NetworkCableWest_BROWN",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Brown/NetworkCableBrownW.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableW_S.png",
                },
                [5] = {
                    name = "RNS_NetworkCableDot_BROWN",
                    sprite_E =  "__RefinedNetworkStorage__/graphics/Cables/Brown/NetworkCableBrownDot.png",
                    sprite_S =  "__RefinedNetworkStorage__/graphics/Cables/NetworkCableDot_S.png",
                }
            }
        },
    }
}
Constants.Beams = {
    ConnectedBeam = {
        name = "RNS_ConnectedBeam",
        entityE = "__RefinedNetworkStorage__/graphics/Beams/ConnectedBeam.png",
        entityL = "__RefinedNetworkStorage__/graphics/Beams/ConnectedBeamLight.png"
    },
    IddleBeam = {
        name = "RNS_IddleBeam",
        entityE = "__RefinedNetworkStorage__/graphics/Beams/IddleBeam.png",
        entityL = "__RefinedNetworkStorage__/graphics/Beams/IddleBeamLight.png"
    },
}
Constants.NetworkController = {
    itemEntity = {
        name = "RNS_NetworkController_Item",
        itemIcon = "__RefinedNetworkStorage__/graphics/Networks/NetworkController/NetworkControllerI.png",
        entityE =  "__RefinedNetworkStorage__/graphics/Networks/NetworkController/NetworkControllerE_stable2.png",
        entityS =  "__RefinedNetworkStorage__/graphics/Networks/NetworkController/NetworkControllerE_S2.png"
    },
    slateEntity = {
        name = "RNS_NetworkController",
        itemIcon = "__RefinedNetworkStorage__/graphics/Networks/NetworkController/NetworkControllerI.png",
        entityE =  "__RefinedNetworkStorage__/graphics/Networks/NetworkController/NetworkControllerPlateE.png",
        entityS =  "__RefinedNetworkStorage__/graphics/blank.png"
    },
    statesEntity = {
        stable = "RNS_NetworkController_Stable",
        unstable = "RNS_NetworkController_Unstable",
        itemIcon = "__RefinedNetworkStorage__/graphics/blank.png",
        stableE =  "__RefinedNetworkStorage__/graphics/Networks/NetworkController/NetworkControllerE_stable2.png",
        unstableE =  "__RefinedNetworkStorage__/graphics/Networks/NetworkController/NetworkControllerE_unstable2.png",
        shadow =  "__RefinedNetworkStorage__/graphics/Networks/NetworkController/NetworkControllerE_S2.png"
    }
}
    
Constants.NetworkInventoryInterface = {
    name = "RNS_NetworkInventoryInterface",
    itemIcon = "__RefinedNetworkStorage__/graphics/Networks/NetworkInterface/NetworkInventoryBlockI.png",
    entityE =  "__RefinedNetworkStorage__/graphics/Networks/NetworkInterface/NetworkInventoryBlockE.png",
    entityS =  "__RefinedNetworkStorage__/graphics/Networks/NetworkInterface/NetworkInventoryBlockS.png"
}
Constants.WirelessGrid = {
    name = "RNS_PortableWirelessGrid",
    itemIcon = "__RefinedNetworkStorage__/graphics/Networks/Wireless/WirelessGridI.png",
    entityE =  "__RefinedNetworkStorage__/graphics/Networks/Wireless/WirelessGridE.png",
    entityS =  "__RefinedNetworkStorage__/graphics/Networks/Wireless/WirelessGridS.png",
    craft_time = 1,
    enabled = true,
    ingredients = {},
}
Constants.Drives = {
    ItemDrive = {
        ItemDrive1k = {
            name = "RNS_ItemDrive1k",
            itemIcon = "__RefinedNetworkStorage__/graphics/Drives/ItemDrive1kI.png",
            entityE =  "__RefinedNetworkStorage__/graphics/Drives/ItemDrive1kE.png",
            entityS =  "__RefinedNetworkStorage__/graphics/Drives/DriveS.png",
            max_size = 1000,
            craft_time = 1,
            enabled = true,
            ingredients = {},
            stack_size = 10,
            subgroup = Constants.ItemGroup.Category.ItemDrive_subgroup,
            order = "i-i[1]"
        },
        ItemDrive4k = {
            name = "RNS_ItemDrive4k",
            itemIcon = "__RefinedNetworkStorage__/graphics/Drives/ItemDrive4kI.png",
            entityE =  "__RefinedNetworkStorage__/graphics/Drives/ItemDrive4kE.png",
            entityS =  "__RefinedNetworkStorage__/graphics/Drives/DriveS.png",
            max_size = 4000,
            craft_time = 1,
            enabled = true,
            ingredients = {},
            stack_size = 10,
            subgroup = Constants.ItemGroup.Category.ItemDrive_subgroup,
            order = "i-i[2]"
        },
        ItemDrive16k = {
            name = "RNS_ItemDrive16k",
            itemIcon = "__RefinedNetworkStorage__/graphics/Drives/ItemDrive16kI.png",
            entityE =  "__RefinedNetworkStorage__/graphics/Drives/ItemDrive16kE.png",
            entityS =  "__RefinedNetworkStorage__/graphics/Drives/DriveS.png",
            max_size = 16000,
            craft_time = 1,
            enabled = true,
            ingredients = {},
            stack_size = 10,
            subgroup = Constants.ItemGroup.Category.ItemDrive_subgroup,
            order = "i-i[3]"
        },
        ItemDrive64k = {
            name = "RNS_ItemDrive64k",
            itemIcon = "__RefinedNetworkStorage__/graphics/Drives/ItemDrive64kI.png",
            entityE =  "__RefinedNetworkStorage__/graphics/Drives/ItemDrive64kE.png",
            entityS =  "__RefinedNetworkStorage__/graphics/Drives/DriveS.png",
            max_size = 64000,
            craft_time = 1,
            enabled = true,
            ingredients = {},
            stack_size = 10,
            subgroup = Constants.ItemGroup.Category.ItemDrive_subgroup,
            order = "i-i[4]"
        }
    },
    FluidDrive = {
        FluidDrive4k = {
            name = "RNS_FluidDrive4k",
            itemIcon = "__RefinedNetworkStorage__/graphics/Drives/FluidDrive4kI.png",
            entityE =  "__RefinedNetworkStorage__/graphics/Drives/FluidDrive4kE.png",
            entityS =  "__RefinedNetworkStorage__/graphics/Drives/DriveS.png",
            max_size = 4000,
            craft_time = 1,
            enabled = true,
            ingredients = {},
            stack_size = 10,
            subgroup = Constants.ItemGroup.Category.FluidDrive_subgroup,
            order = "f-f[1]"
        },
        FluidDrive16k = {
            name = "RNS_FluidDrive16k",
            itemIcon = "__RefinedNetworkStorage__/graphics/Drives/FluidDrive16kI.png",
            entityE =  "__RefinedNetworkStorage__/graphics/Drives/FluidDrive16kE.png",
            entityS =  "__RefinedNetworkStorage__/graphics/Drives/DriveS.png",
            max_size = 16000,
            craft_time = 1,
            enabled = true,
            ingredients = {},
            stack_size = 10,
            subgroup = Constants.ItemGroup.Category.FluidDrive_subgroup,
            order = "f-f[2]"
        },
        FluidDrive64k = {
            name = "RNS_FluidDrive64k",
            itemIcon = "__RefinedNetworkStorage__/graphics/Drives/FluidDrive64kI.png",
            entityE =  "__RefinedNetworkStorage__/graphics/Drives/FluidDrive64kE.png",
            entityS =  "__RefinedNetworkStorage__/graphics/Drives/DriveS.png",
            max_size = 64000,
            craft_time = 1,
            enabled = true,
            ingredients = {},
            stack_size = 10,
            subgroup = Constants.ItemGroup.Category.FluidDrive_subgroup,
            order = "f-f[3]"
        },
        FluidDrive256k = {
            name = "RNS_FluidDrive256k",
            itemIcon = "__RefinedNetworkStorage__/graphics/Drives/FluidDrive256kI.png",
            entityE =  "__RefinedNetworkStorage__/graphics/Drives/FluidDrive256kE.png",
            entityS =  "__RefinedNetworkStorage__/graphics/Drives/DriveS.png",
            max_size = 256000,
            craft_time = 1,
            enabled = true,
            ingredients = {},
            stack_size = 10,
            subgroup = Constants.ItemGroup.Category.FluidDrive_subgroup,
            order = "f-f[4]"
        }
    }
}

return Constants