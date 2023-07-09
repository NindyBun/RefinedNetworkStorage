local Constants = {}

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
    item = "__data__/core/graphics/arrows/indication-arrow.png",
    fluid = "__data__/core/graphics/arrows/fluid-indication-arrow.png"
}
Constants.NetworkCables = {
    itemIO = {
        itemEntity = {
            name = "RNS_NetworkCableIOItem_Item",
            itemIcon = "__RefinedNetworkStorage__/graphics/Cables/ItemIO.png",
            entityE =  "__RefinedNetworkStorage__/graphics/Cables/IO/ItemIOSheet.png",
            entityS =  "__RefinedNetworkStorage__/graphics/Cables/IO/IOSheet_S.png"
        },
        slateEntity = {
            name = "RNS_NetworkCableIOItem",
            itemIcon = "__RefinedNetworkStorage__/graphics/Cables/ItemIO.png",
            entityE =  "__RefinedNetworkStorage__/graphics/Cables/IO/ItemIOSheet_E.png",
            entityS =  "__RefinedNetworkStorage__/graphics/Cables/IO/IOSheet_S.png"
        }
    },
    fluidIO = {
        itemEntity = {
            name = "RNS_NetworkCableIOFluid_Item",
            itemIcon = "__RefinedNetworkStorage__/graphics/Cables/FluidIO.png",
            entityE =  "__RefinedNetworkStorage__/graphics/Cables/IO/FluidIOSheet.png",
            entityS =  "__RefinedNetworkStorage__/graphics/Cables/IO/IOSheet_S.png"
        },
        slateEntity = {
            name = "RNS_NetworkCableIOFluid",
            itemIcon = "__RefinedNetworkStorage__/graphics/Cables/FluidIO.png",
            entityE =  "__RefinedNetworkStorage__/graphics/Cables/IO/FluidIOSheet_E.png",
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
Constants.NetworkLasers = {
    NLI = {
        name = "RNS_NetworkLaserInjector",
        itemIcon = "__RefinedNetworkStorage__/graphics/Lasers/NetworkLaserInjectorI.png",
        entityE =  "__RefinedNetworkStorage__/graphics/Lasers/NetworkLaserInjectorE.png",
        entityS =  "__RefinedNetworkStorage__/graphics/Lasers/NetworkLaserInjectorS.png",
        connections = {
                base_level = 1,
                pipe_connections = {
                    {type = "input", position = {0, 1}},
                    {type = "output", position = {0, -1}}
                },
                production_type = "output",
        },
        craft_time = 1,
        enabled = true,
        ingredients = {},
        stack_size = 25
    },
    NLS = {
        name = "RNS_NetworkLaserStraight",
        itemIcon = "__RefinedNetworkStorage__/graphics/Lasers/NetworkLaserStraightI.png",
        entityE =  "__RefinedNetworkStorage__/graphics/Lasers/NetworkLaserStraightE.png",
        entityS =  "__RefinedNetworkStorage__/graphics/Lasers/NetworkLaserStraightS.png",
        connections = {
                base_level = 1,
                pipe_connections = {
                    {type = "input-output", position = {0, -1}},
                    {type = "input-output", position = {0, 1}}
                },
                production_type = "output",
        },
        craft_time = 1,
        enabled = true,
        ingredients = {},
        stack_size = 25
    },
    NLT = {
        name = "RNS_NetworkLaserTjun",
        itemIcon = "__RefinedNetworkStorage__/graphics/Lasers/NetworkLaserTjunI.png",
        entityE =  "__RefinedNetworkStorage__/graphics/Lasers/NetworkLaserTjunE.png",
        entityS =  "__RefinedNetworkStorage__/graphics/Lasers/NetworkLaserTjunS.png",
        connections = {
                base_level = 1,
                pipe_connections = {
                    {type = "input-output", position = {0, -1}},
                    {type = "input-output", position = {1, 0}},
                    {type = "input-output", position = {-1, 0}}
                },
                production_type = "output",
        },
        craft_time = 1,
        enabled = true,
        ingredients = {},
        stack_size = 25
    },
    NLC = {
        name = "RNS_NetworkLaserCross",
        itemIcon = "__RefinedNetworkStorage__/graphics/Lasers/NetworkLaserCrossI.png",
        entityE =  "__RefinedNetworkStorage__/graphics/Lasers/NetworkLaserCrossE.png",
        entityS =  "__RefinedNetworkStorage__/graphics/Lasers/NetworkLaserCrossS.png",
        connections = {
                base_level = 1,
                pipe_connections = {
                    {type = "input-output", position = {0, -1}},
                    {type = "input-output", position = {0, 1}},
                    {type = "input-output", position = {1, 0}},
                    {type = "input-output", position = {-1, 0}}
                },
                production_type = "output",
        },
        craft_time = 1,
        enabled = true,
        ingredients = {},
        stack_size = 25
    },
    NLE = {
        name = "RNS_NetworkLaserElbow",
        itemIcon = "__RefinedNetworkStorage__/graphics/Lasers/NetworkLaserElbowI.png",
        entityE =  "__RefinedNetworkStorage__/graphics/Lasers/NetworkLaserElbowE.png",
        entityS =  "__RefinedNetworkStorage__/graphics/Lasers/NetworkLaserElbowS.png",
        connections = {
                base_level = 1,
                pipe_connections = {
                    {type = "input-output", position = {0, -1}},
                    {type = "input-output", position = {1, 0}},
                },
                production_type = "output",
        },
        craft_time = 1,
        enabled = true,
        ingredients = {},
        stack_size = 25
    },
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
    },
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

return Constants