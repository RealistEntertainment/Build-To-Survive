local ServerStorage = game:GetService("ServerStorage")
local Rounds = {}


Rounds.List = {
	"Rat1",
	"RatSwarm",
	"GreenSlime1",
	"Meteor Shower 1"
}

Rounds["Rat1"] = {
    NpcModel = "Giant Rat",
    EventType = "MobSpawning",
    Announcement = "Hide! Three Giant Rats are on the way!",
    RoundTime  = 60,
    Award = 50,
    NpcCount = 3,
}

Rounds["RatSwarm"] = {
    NpcModel = "Giant Rat",
    EventType = "MobSpawning",
    Announcement = "Hide! There are a lot of Giant Rats on the way!",
    RoundTime  = 60,
    Award = 100,
    NpcCount = 8,
}

Rounds["GreenSlime1"] = {
	NpcModel = "Green Slime",
	EventType = "MobSpawning",
	Announcement = "Hide! Three Green Slimes are on the way!",
	RoundTime  = 60,
	Award = 25,
	NpcCount = 3,
}

Rounds["Meteor Shower 1"] = {
    EventType = "MeteorShower",
    Announcement = "Take cover it's raining fiery stones!",
    Award = 50,
    MeteorModel = "Meteor",
    Meteors = 90, --// (round time - 5)/ meteors = time delay between meteors
    MeteorDamage = 25, --// damage dealt to touched objects
    RoundTime  = 60,
}

return Rounds