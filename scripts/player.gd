extends CharacterBody2D

const tile_size: Vector2 = Vector2(16,16)
var sprite_node_pos_tween: Tween
var camera_pos_tween: Tween
var timer = 0.0

var small_light_size = Vector2(0.5, 0.5)
var small_light_color = Color(0.913, 0.502, 0.369)

var big_light_size = Vector2(3, 3)
var big_light_color = Color(0.992, 0.447, 0.035)

@onready var point_light_2d: PointLight2D = $Sprite2D/PointLight2D
@onready var score: Label = $Camera2D/score

func _ready() -> void:
	update_light(false)
	display_score()

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_accept"):
		update_light(true)
	elif Input.is_action_just_released("ui_accept"): #Input.is_action_just_released("ui_up") or Input.is_action_just_released("ui_down") or Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right"):
		update_light(false)
	
	movement_manager(delta)
	display_score()
		
func movement_manager(delta: float) -> void:
	var base_interval = 0.1
	var diag_interval = base_interval * sqrt(2)
	var interval = base_interval
	var movement_vector = Vector2.ZERO
	
	timer += delta
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
	$Camera2D.global_position -= dir * tile_size
	
	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()
	if camera_pos_tween:
		camera_pos_tween.kill()
	sprite_node_pos_tween = create_tween()
	camera_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	camera_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property($Sprite2D, "global_position", global_position, 0.185)
	camera_pos_tween.tween_property($Camera2D, "global_position", global_position, 0.25)

func update_light(on: bool) -> void:
	if (on):
		point_light_2d.scale = big_light_size
		point_light_2d.color = big_light_color
	else:
		point_light_2d.scale = small_light_size
		point_light_2d.color = small_light_color
		
func display_score() -> void:
	score.text = str(game_manager.score)
