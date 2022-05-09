local Mobs = {}

Mobs["Giant Rat"] = {
    DamageType = "Melee", --// not used yet
    AttackRange = 4, --// this is from the center of the model(might make some kinda of calculation to make this automated)
    ObjectDamage = 8, --// damage dealt to objects
    PlayerDamage = 10, --// damage dealt to players
    DeathReward = 25, --// amount of coins rewarded on death
    AttackDelay = 1.2 --// in seconds
}
Mobs["Green Slime"] = {
	DamageType = "Melee", --// not used yet
	AttackRange = 4, --// this is from the center of the model(might make some kinda of calculation to make this automated)
	ObjectDamage = 5, --// damage dealt to objects
	PlayerDamage = 8, --// damage dealt to players
	DeathReward = 10, --// amount of coins rewarded on death
	AttackDelay = 1.1 --// in seconds
}

return Mobs