local PlacmentObjectData = {}

PlacmentObjectData.CategoryList = {"Blocks", "Turrets"}

PlacmentObjectData.Blocks = {
    ["Leaves"] = {
        CategorySort = {
            ["Blocks"] = 0001,
        },
        Health = 5,
        Cost = 0,
    },

    ["Dirt"] = {
        CategorySort = {
            ["Blocks"] = 0002,
        },
        Health = 5,
        Cost = 1,
    },

    ["Wood Plank"] = {
        CategorySort = {
            ["Blocks"] = 0003,
        },
        Health = 15,
        Cost = 5,
    },
    ["Stone"] = {
        CategorySort = {
            ["Blocks"] = 0004,
        },
        Health = 45,
        Cost = 15,
    },
    ["Copper"] = {
        CategorySort = {
            ["Blocks"] = 0005,
        },
        Health = 75,
        Cost = 45,
    },
    ["Iron"] = {
        CategorySort = {
            ["Blocks"] = 0006,
        },
        Health = 125,
        Cost = 125,
    },
    ["Gold"] = {
        CategorySort = {
            ["Blocks"] = 0007,
        },
        Health = 175,
        Cost = 750,
    },
    ["Emerald"] = {
        CategorySort = {
            ["Blocks"] = 0008,
        },
        Health = 225,
        Cost = 2500,
    },
    ["Diamond"] = {
        CategorySort = {
            ["Blocks"] = 0009,
        },
        Health = 275,
        Cost = 7500,
    },
    ["Obsidian"] = {
        CategorySort = {
            ["Blocks"] = 0091,
        },
        Health = 325,
        Cost = 27000,
    },
}

PlacmentObjectData.Turrets = {
    ["Basic Turret"] = {
        CategorySort = {
            ["Turrets"] = 0001,
        },
        Damage = 5,
        FireRate = 3, -- seconds
        Health = 25,
        Cost = 500,
    },
}


return PlacmentObjectData