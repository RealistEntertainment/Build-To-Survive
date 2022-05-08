local ServerStorage = game:GetService("ServerStorage")
local Rounds = {}

Rounds.List = {
    "rat 1"
}

Rounds["rat 1"] = {
    NpcModel = "Giant Rat",
    EventType = "MobSpawning",
    Announcement = "Hide 1 Giant Rat inbound!",
    RoundTime  = 60,
    Award = 20,
    NpcCount = 1,
}

Rounds["rat 2"] = {
    NpcModel = "Giant Rat",
    EventType = "MobSpawning",
    Announcement = "Hide 2 Giant Rats inbound!",
    RoundTime  = 60,
    Award = 20,
    NpcCount = 2,
}

Rounds["rat 3"] = {
    NpcModel = "Giant Rat",
    EventType = "MobSpawning",
    Announcement = "Hide 3 Giant Rats inbound!",
    RoundTime  = 60,
    Award = 20,
    NpcCount = 3,
}

Rounds["Meteor Shower 1"] = {
    EventType = "MeteorShower",
    Announcement = "Take cover it's raining fiery stones!",
    Award = 20,
    MeteorModel = "Meteor",
    Meteors = 90, --// (round time - 5)/ meteors = time delay between meteors
    MeteorDamage = 5, --// damage dealt to touched objects
    RoundTime  = 60,
}

return Rounds