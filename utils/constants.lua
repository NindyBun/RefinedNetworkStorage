local Constants = {}

Constants.Settings = {

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
Constants.NetworkLasers = {
    NLI = {
        name = "RNS_NetworkLaserInjector",
        itemIcon = "__RefinedNetworkStorage__/graphics/NetworkLaserInjectorI.png",
        entityE = "__RefinedNetworkStorage__/graphics/NetworkLaserInjectorE.png",
        entityS = "__RefinedNetworkStorage__/graphics/NetworkLaserInjectorS.png",
        connections = {
                base_level = 1,
                pipe_connections = {{type = "output", position = {0, -1}}},
                production_type = "output",
        },
        craft_time = 1,
        enabled = true,
        ingredients = {},
        stack_size = 25
    },
    NLS = {
        name = "RNS_NetworkLaserStraight",
        itemIcon = "__RefinedNetworkStorage__/graphics/NetworkLaserStraightI.png",
        entityE = "__RefinedNetworkStorage__/graphics/NetworkLaserStraightE.png",
        entityS = "__RefinedNetworkStorage__/graphics/NetworkLaserStraightS.png",
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
        itemIcon = "__RefinedNetworkStorage__/graphics/NetworkLaserTjunI.png",
        entityE = "__RefinedNetworkStorage__/graphics/NetworkLaserTjunE.png",
        entityS = "__RefinedNetworkStorage__/graphics/NetworkLaserTjunS.png",
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
        itemIcon = "__RefinedNetworkStorage__/graphics/NetworkLaserCrossI.png",
        entityE = "__RefinedNetworkStorage__/graphics/NetworkLaserCrossE.png",
        entityS = "__RefinedNetworkStorage__/graphics/NetworkLaserCrossS.png",
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
        itemIcon = "__RefinedNetworkStorage__/graphics/NetworkLaserElbowI.png",
        entityE = "__RefinedNetworkStorage__/graphics/NetworkLaserElbowE.png",
        entityS = "__RefinedNetworkStorage__/graphics/NetworkLaserElbowS.png",
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
Constants.NetworkController = {
    name = "RNS_NetworkController",
    itemIcon = "__RefinedNetworkStorage__/graphics/NetworkControllerI.png",
    entityE = "__RefinedNetworkStorage__/graphics/NetworkControllerE.png",
    entityS = "__RefinedNetworkStorage__/graphics/DriveS.png"
}
Constants.NetworkInventoryBlock = {
    name = "RNS_NetworkInventoryBlock",
    itemIcon = "__RefinedNetworkStorage__/graphics/NetworkInventoryBlockI.png",
    entityE = "__RefinedNetworkStorage__/graphics/NetworkInventoryBlockE.png",
    entityS = "__RefinedNetworkStorage__/graphics/NetworkInventoryBlockS.png"
}
Constants.Drives = {
    ItemDrive1k = {
        name = "RNS_ItemDrive1k",
        itemIcon = "__RefinedNetworkStorage__/graphics/ItemDrive1kI.png",
        entityE = "__RefinedNetworkStorage__/graphics/ItemDrive1kE.png",
        entityS = "__RefinedNetworkStorage__/graphics/DriveS.png",
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
        itemIcon = "__RefinedNetworkStorage__/graphics/ItemDrive4kI.png",
        entityE = "__RefinedNetworkStorage__/graphics/ItemDrive4kE.png",
        entityS = "__RefinedNetworkStorage__/graphics/DriveS.png",
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
        itemIcon = "__RefinedNetworkStorage__/graphics/ItemDrive16kI.png",
        entityE = "__RefinedNetworkStorage__/graphics/ItemDrive16kE.png",
        entityS = "__RefinedNetworkStorage__/graphics/DriveS.png",
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
        itemIcon = "__RefinedNetworkStorage__/graphics/ItemDrive64kI.png",
        entityE = "__RefinedNetworkStorage__/graphics/ItemDrive64kE.png",
        entityS = "__RefinedNetworkStorage__/graphics/DriveS.png",
        max_size = 64000,
        craft_time = 1,
        enabled = true,
        ingredients = {},
        stack_size = 10,
        subgroup = Constants.ItemGroup.Category.ItemDrive_subgroup,
        order = "i-i[4]"
    },
    FluidDrive4k = {
        name = "RNS_FluidDrive1k",
        itemIcon = "__RefinedNetworkStorage__/graphics/FluidDrive4kI.png",
        entityE = "__RefinedNetworkStorage__/graphics/FluidDrive4kE.png",
        entityS = "__RefinedNetworkStorage__/graphics/DriveS.png",
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
        itemIcon = "__RefinedNetworkStorage__/graphics/FluidDrive16kI.png",
        entityE = "__RefinedNetworkStorage__/graphics/FluidDrive16kE.png",
        entityS = "__RefinedNetworkStorage__/graphics/DriveS.png",
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
        itemIcon = "__RefinedNetworkStorage__/graphics/FluidDrive64kI.png",
        entityE = "__RefinedNetworkStorage__/graphics/FluidDrive64kE.png",
        entityS = "__RefinedNetworkStorage__/graphics/DriveS.png",
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
        itemIcon = "__RefinedNetworkStorage__/graphics/FluidDrive256kI.png",
        entityE = "__RefinedNetworkStorage__/graphics/FluidDrive256kE.png",
        entityS = "__RefinedNetworkStorage__/graphics/DriveS.png",
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