extends Area2D

# Coin mask is on the layer that the player occupies
func _on_body_entered(body: Node2D) -> void:
	#increment score counter
	game_manager.add_score()
	# Remove coin from scene
	queue_free()
