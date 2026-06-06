extends CharacterBody2D

const tile_size: Vector2 = Vector2(16,16)
var sprite_node_pos_tween: Tween
var timer = 0.0
@onready var point_light_2d: PointLight2D = $Sprite2D/PointLight2D

func _physics_process(delta: float) -> void:
	
	if Input.is_action_pressed("ui_accept"):
		point_light_2d.enabled = true
	elif Input.is_action_just_released("ui_accept"): #Input.is_action_just_released("ui_up") or Input.is_action_just_released("ui_down") or Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right"):
		point_light_2d.enabled = false
	
	var base_interval = 0.1
	var diag_interval = base_interval * sqrt(2)
	var interval = base_interval
	var movement_vector = Vector2.ZERO
	
	timer += delta
	#print(timer, interval)
	# Governer slows down movement
	if timer >= base_interval:
		if Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_left") and !$nw.is_colliding():
			movement_vector = Vector2(-1, -1) # move northwest
			interval = diag_interval
		elif Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_right") and !$ne.is_colliding():
			movement_vector = Vector2(1, -1) # move northeast
			interval = diag_interval
		elif Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_left") and !$sw.is_colliding():
			movement_vector = Vector2(-1, 1) # move southwest
			interval = diag_interval
		elif Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_right") and !$se.is_colliding():
			movement_vector = Vector2(1, 1) # move southeast
			interval = diag_interval
		elif Input.is_action_pressed("ui_up") and !$n.is_colliding():
			movement_vector = Vector2(0, -1)
		elif Input.is_action_pressed("ui_down") and !$s.is_colliding():
			movement_vector = Vector2(0, 1)
		elif Input.is_action_pressed("ui_left") and !$w.is_colliding():
			movement_vector = Vector2(-1, 0)
		elif Input.is_action_pressed("ui_right") and !$e.is_colliding():
			movement_vector = Vector2(1, 0)
				
		if movement_vector != Vector2.ZERO:
			if timer >= interval:
				timer -= interval
				_move(movement_vector)
		else:
			timer = base_interval
			
func _move(dir: Vector2):
	global_position += dir * tile_size
	$Sprite2D.global_position -= dir * tile_size
	
	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property($Sprite2D, "global_position", global_position, 0.185)
	#sprite_node_pos_tween.tween_property($PointLight2D, "global_position", global_position, 0.185)
