local Constants = {}
Constants.MOD_ID = "RefinedNetworkStorage"
Constants.Settings = {
    RNS_BlankIcon = "__RefinedNetworkStorage__/graphics/blank.png",
    RNS_FR_Cable = "RNS_FR_NetworkCable",
    RNS_Tag = "RNS_StorageTag",
    RNS_BeltSides = {
        ["Right"] = 2,
        ["Left"] = 1,
    },
    RNS_BaseItemIO_Speed = 15,
    RNS_BaseFluidIO_Speed = 1200/60,
    RNS_TypesWithContainer = {
        ["ammo-turret"] = true,
        ["artillery-turret"] = true,
        ["artillery-wagon"] = true,
        ["assembling-machine"] = true,
        ["boiler"] = true,
        ["burner-generator"] = true,
        ["car"] = true,
        ["cargo-wagon"] = true,
        ["container"] = true,
        ["furnace"] = true,
        ["infinity-container"] = true,
        ["inserter"] = true,
        ["lab"] = true,
        ["linked-container"] = true,
        ["locomotive"] = true,
        ["logistic-container"] = true,
        ["mining-drill"] = true,
        ["reactor"] = true,
        ["roboport"] = true,
        ["rocket-silo"] = true,
        ["spider-vehicle"] = true,
        ["fluid-turret"] = true,
        ["fluid-wagon"] = true,
        ["generator"] = true,
        ["infinity-pipe"] = true,
        ["offshore-pump"] = true,
        ["pipe"] = true,
        ["pipe-to-ground"] = true,
        ["pump"] = true,
        ["storage-tank"] = true,
        ["transport-belt"] = true,
        ["underground-belt"] = true,
        ["splitter"] = true,
        ["loader"] = true,
        ["loader-1x1"] = true
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
Constants.ItemGroup = {
    Category = {
        group = "RefinedNetworkStorage",
        subgroup = "RNS",
        ItemDrive_subgroup = "RNS-ItemDrives",
        FluidDrive_subgroup = "RNS-FluidDrives",
        Laser_subgroup = "RNS-Lasers"
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
        itemIcon = "__RefinedNetworkStorage__/graphics/Networks/NetworkControllerI.png",
        entityE =  "__RefinedNetworkStorage__/graphics/Networks/NetworkControllerE_stable2.png",
        entityS =  "__RefinedNetworkStorage__/graphics/Networks/NetworkControllerE_S2.png"
    },
    slateEntity = {
        name = "RNS_NetworkController",
        itemIcon = "__RefinedNetworkStorage__/graphics/Networks/NetworkControllerI.png",
        entityE =  "__RefinedNetworkStorage__/graphics/blank.png",
        entityS =  "__RefinedNetworkStorage__/graphics/blank.png"
    },
    statesEntity = {
        stable = "RNS_NetworkController_Stable",
        unstable = "RNS_NetworkController_Unstable",
        itemIcon = "__RefinedNetworkStorage__/graphics/blank.png",
        stableE =  "__RefinedNetworkStorage__/graphics/Networks/NetworkControllerE_stable2.png",
        unstableE =  "__RefinedNetworkStorage__/graphics/Networks/NetworkControllerE_unstable2.png",
        shadow =  "__RefinedNetworkStorage__/graphics/Networks/NetworkControllerE_S2.png"
    }
}
    
Constants.NetworkInventoryInterface = {
    name = "RNS_NetworkInventoryInterface",
    itemIcon = "__RefinedNetworkStorage__/graphics/Networks/NetworkInventoryBlockI.png",
    entityE =  "__RefinedNetworkStorage__/graphics/Networks/NetworkInventoryBlockE.png",
    entityS =  "__RefinedNetworkStorage__/graphics/Networks/NetworkInventoryBlockS.png"
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