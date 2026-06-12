extends Area2D

@onready var timer = $Timer

@onready var death_sound_player: AudioStreamPlayer = $death_sound_player


# killzone collision mask on layer 2
# same as the player layer
func _on_body_entered(_body: Node2D) -> void:
	game_manager.enemy_attack()
	game_manager.player_death()
	timer.start()

func _on_timer_timeout():
	get_tree().reload_current_scene()
