local sprite1 = {}
sprite1.type = "sprite"
sprite1.name = Constants.Icons.check_mark.name
sprite1.layers = {
    {
        filename = Constants.Icons.check_mark.sprite,
        priority = "high",
        size = 32,
        scale = 1
    }
}
data:extend{sprite1}

local sprite2 = {}
sprite2.type = "sprite"
sprite2.name = Constants.Icons.x_mark.name
sprite2.layers = {
    {
        filename = Constants.Icons.x_mark.sprite,
        priority = "high",
        size = 32,
        scale = 1
    }
}
data:extend{sprite2}