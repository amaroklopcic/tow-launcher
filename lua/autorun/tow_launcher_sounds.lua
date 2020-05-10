// Made by Raven; Steam Acc: https://steamcommunity.com/id/amaroklopcic

sound.Add( {
	name = "tow_launcher_missile_fire",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 85,
	pitch = { 95, 130 },
	sound = "weapons/rpg/rocket1.wav"
} )

sound.Add( {
	name = "tow_missile_blast",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 100,
	pitch = { 30, 200 },
	sound = "weapons/rpg/rocketfire1.wav" --weapons/gauss/fire1.wav
} )

sound.Add( {
	name = "tow_reload",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 80,
	pitch = { 95, 130 },
	sound = "tow/tow_reload.wav"
} )

sound.Add( {
	name = "tow_ammo_sound",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 80,
	pitch = { 95, 130 },
	sound = "items/ammo_pickup.wav"
} )