if mods["space-exploration"] then
    for _, color in pairs(Constants.NetworkCables.Cables) do
        data.raw["container"][color.cable.name].se_allow_in_space = true
        data.raw["assembling-machine"][color.underground.name].se_allow_in_space = true
    end

    data.raw["container"][Constants.Detector.name].se_allow_in_space = true

    for _, drive in pairs(Constants.Drives.ItemDrive) do
        data.raw["container"][drive.name].se_allow_in_space = true
    end
    
    for _, drive in pairs(Constants.Drives.FluidDrive) do
        data.raw["container"][drive.name].se_allow_in_space = true
    end

    data.raw["assembling-machine"][Constants.NetworkCables.externalIO.name].se_allow_in_space = true
    data.raw["assembling-machine"][Constants.NetworkCables.itemIO.name].se_allow_in_space = true
    data.raw["assembling-machine"][Constants.NetworkCables.fluidIO.name].se_allow_in_space = true
    
    data.raw["electric-energy-interface"][Constants.NetworkController.main.name].se_allow_in_space = true
    data.raw["container"][Constants.NetworkInventoryInterface.name].se_allow_in_space = true
    data.raw["container"][Constants.WirelessGrid.name].se_allow_in_space = true
    data.raw["container"][Constants.NetworkCables.wirelessTransmitter.name].se_allow_in_space = true

    for _, tr in pairs(Constants.NetworkTransReceiver) do
        data.raw["container"][tr.name].se_allow_in_space = true
    end

    data.raw["constant-combinator"]['rns_Combinator'].se_allow_in_space = true
    data.raw["constant-combinator"]['rns_Combinator_1'].se_allow_in_space = true
    data.raw["constant-combinator"]['rns_Combinator_2'].se_allow_in_space = true
end