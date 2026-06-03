extends CharacterBody2D

const tile_size: Vector2 = Vector2(16,16)
var sprite_node_pos_tween: Tween
var timer = 0.0

func _physics_process(delta: float) -> void:
	var interval = 0.1
	
	timer += delta
	#print(timer, interval)
	# Governer slows down movement
	if timer >= interval:
		if Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_left") and !$nw.is_colliding():
			_move(Vector2(-1, -1))	# move northwest
		elif Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_right") and !$ne.is_colliding():
			_move(Vector2(1, -1))	# move northeast
		elif Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_left") and !$sw.is_colliding():
			_move(Vector2(-1, 1))	# move southwest
		elif Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_right") and !$se.is_colliding():
			_move(Vector2(1, 1))	# move southeast
		elif Input.is_action_pressed("ui_up") and !$n.is_colliding():
			_move(Vector2(0, -1))
		elif Input.is_action_pressed("ui_down") and !$s.is_colliding():
			_move(Vector2(0, 1))
		elif Input.is_action_pressed("ui_left") and !$w.is_colliding():
			_move(Vector2(-1, 0))
		elif Input.is_action_pressed("ui_right") and !$e.is_colliding():
			_move(Vector2(1, 0))
		timer -= interval
		
func _move(dir: Vector2):
	global_position += dir * tile_size
	$Sprite2D.global_position -= dir * tile_size
	
	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property($Sprite2D, "global_position", global_position, 0.185)
	#sprite_node_pos_tween.tween_property($PointLight2D, "global_position", global_position, 0.185)
