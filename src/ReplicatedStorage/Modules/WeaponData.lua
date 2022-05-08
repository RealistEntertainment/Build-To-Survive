local WeaponData = {}

WeaponData.CategoryList = {"Swords"}

WeaponData.Swords = {
    ["Wooden Sword"] = {
        Damage = 3,
        AttackDelay = 1,
        AttackRange = 6.5,
        CategorySort = {
            Swords = 0001
        },
        Cost = 0
    },
    ["Stone Sword"] = {
        Damage = 4,
        AttackDelay = .85,
        AttackRange = 7,
        CategorySort = {
            Swords = 00011
        },
        Cost = 100
    },
    ["Copper Sword"] = {
        Damage = 5,
        AttackDelay = .85,
        AttackRange = 7,
        CategorySort = {
            Swords = 00012
        },
        Cost = 350
    },
    ["Iron Sword"] = {
        Damage = 10,
        AttackDelay = .85,
        AttackRange = 7,
        CategorySort = {
            Swords = 00013
        },
        Cost = 1250
    },
    ["Gold Sword"] = {
        Damage = 15,
        AttackDelay = .85,
        AttackRange = 7,
        CategorySort = {
            Swords = 00014
        },
        Cost = 3750
    },
    ["Emerald Sword"] = {
        Damage = 25,
        AttackDelay = .85,
        AttackRange = 7,
        CategorySort = {
            Swords = 00015
        },
        Cost = 12750
    },---/ diamond 36750, damage 40
    ["Diamond Sword"] = {
        Damage = 40,
        AttackDelay = .85,
        AttackRange = 7,
        CategorySort = {
            Swords = 00016
        },
        Cost = 36750
    },
    ["Obsidian Sword"] = {
        Damage = 65,
        AttackDelay = .85,
        AttackRange = 7,
        CategorySort = {
            Swords = 00017
        },
        Cost = 97500
    }
}

return WeaponData
