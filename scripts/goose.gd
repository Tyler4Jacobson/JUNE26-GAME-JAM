extends Area2D

# Goose mask is on the layer that the player occupies
func _on_body_entered(_body: Node2D) -> void:
	# increment score counter
	game_manager.pickup()
	# Remove goose from scene
	queue_free()
