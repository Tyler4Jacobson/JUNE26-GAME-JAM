extends Area2D

@onready var timer = $Timer

# killzone collision mask on layer 2
# same as the player layer
func _on_body_entered(body: Node2D) -> void:
	timer.start()

func _on_timer_timeout():
	get_tree().reload_current_scene()
