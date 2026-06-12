extends Node

class_name game_manager

static var score: int = 0
static var coin_count: int = 100
static var charge: int = 0
static var MAX_CHARGE: int = 3

# Sound
static var volume: float = 0.1		# Ranges from 0.0 to 1.0
static var is_muted: bool = false
# sound players
static var death_sp: AudioStreamPlayer
static var enemy_attack_sp: AudioStreamPlayer
static var pickup_sp: AudioStreamPlayer
static var spawn_sp: AudioStreamPlayer
static var ambient_sp: AudioStreamPlayer

enum soundID { 
	DEATH, 
	ENEMY_ATTACK, 
	PICKUP, 
	SPAWN,
	AMBIENT,
}

func _ready() -> void:
	# initialize score
	score = 0
	
	# initialize sound players
	death_sp = $death_sp
	enemy_attack_sp = $enemy_attack_sp
	pickup_sp = $pickup_sp
	spawn_sp = $spawn_sp
	ambient_sp = $ambient_sp
	
	# set master volume
	AudioServer.set_bus_volume_linear(
		AudioServer.get_bus_index("Master"), 
		volume
	)

func _process(_delta: float) -> void:
	var sound_player = get_sound_player(soundID.AMBIENT)
	if not sound_player.playing:
		play_sound(sound_player)

static func player_death() -> void:
	var sound_player = get_sound_player(soundID.DEATH)
	if not sound_player.playing:
		play_sound(sound_player)
	
static func enemy_attack() -> void:
	var sound_player = get_sound_player(soundID.ENEMY_ATTACK)
	play_sound(sound_player)
	
static func pickup() -> void:
	add_score()
	var sound_player = get_sound_player(soundID.PICKUP)
	play_sound(sound_player)
	
static func player_spawn() -> void:
	var sound_player = get_sound_player(soundID.SPAWN)
	play_sound(sound_player)

static func get_sound_player(id: int) -> AudioStreamPlayer:
	match id:
		soundID.DEATH:
			return death_sp
		soundID.ENEMY_ATTACK:
			return enemy_attack_sp
		soundID.PICKUP:
			return pickup_sp
		soundID.SPAWN:
			return spawn_sp
		soundID.AMBIENT:
			return ambient_sp
		_:
			printerr("Wrong sound player ID given")
			return null

static func play_sound(sound_player: AudioStreamPlayer):
	if is_muted:
		return
	sound_player.play()

static func add_score() -> void:
	score += 1
	if charge <= MAX_CHARGE:
		add_charge()

static func get_score() -> int:
	return score

static func add_charge() -> void:
	charge += 1
	if charge > MAX_CHARGE:
		charge = MAX_CHARGE

static func subtract_charge(count: int) -> void:
	charge -= count
	if charge < 0:
		charge = 0
	
static func get_charge() -> int:
	return charge

static func get_coin_count() -> int:
	return coin_count
