local PlacmentObjectData = {}

PlacmentObjectData.CategoryList = {"Blocks", "Turrets", "Barricades"}

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
        Health = 8,
        Cost = 1,
    },

    ["Wood Plank"] = {
        CategorySort = {
            ["Blocks"] = 0003,
        },
        Health = 15,
        Cost = 2,
    },
    ["Stone"] = {
        CategorySort = {
            ["Blocks"] = 0004,
        },
        Health = 45,
        Cost = 5,
    },
    ["Copper"] = {
        CategorySort = {
            ["Blocks"] = 0005,
        },
        Health = 75,
        Cost = 10,
    },
    ["Iron"] = {
        CategorySort = {
            ["Blocks"] = 0006,
        },
        Health = 125,
        Cost = 20,
    },
    ["Gold"] = {
        CategorySort = {
            ["Blocks"] = 0007,
        },
        Health = 175,
        Cost = 40,
    },
    ["Emerald"] = {
        CategorySort = {
            ["Blocks"] = 0008,
        },
        Health = 225,
        Cost = 75,
    },
    ["Diamond"] = {
        CategorySort = {
            ["Blocks"] = 0009,
        },
        Health = 300,
        Cost = 100,
    },
    ["Obsidian"] = {
        CategorySort = {
            ["Blocks"] = 0091,
        },
        Health = 500,
        Cost = 250,
    },
}

PlacmentObjectData.Turrets = {
    ["Basic Turret"] = {
        CategorySort = {
            ["Turrets"] = 0001,
        },
        Damage = 3,
        FireRate = 1, -- seconds
        Health = 25,
        Cost = 150,
    },
}

PlacmentObjectData.Barricades = {
    ["Wooden Barricade"] = {
        CategorySort = {
            ["Barricades"] = 0001,
        },
        Health = 125,
        Cost = 25,
    },
    ["Metal Barricade"] = {
        CategorySort = {
            ["Barricades"] = 00011,
        },

        Health = 250,
        Cost = 75,
    },
}


return PlacmentObjectData