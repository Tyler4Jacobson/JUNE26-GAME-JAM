extends CharacterBody2D

const tile_size: Vector2 = Vector2(16,16)
var sprite_node_pos_tween: Tween
var camera_pos_tween: Tween
var move_cooldown: float = 0.0

var small_light_size = Vector2(0.5, 0.5)
var small_light_color = Color(0.913, 0.502, 0.369)

var big_light_size = Vector2(3, 3)
var big_light_color = Color(0.992, 0.447, 0.035)

@onready var score_label: Label = $Camera2D/score
@onready var point_light_2d: PointLight2D = $Sprite2D/PointLight2D
@onready var light_area: Area2D = $Sprite2D/Area2D

func _ready() -> void:
	update_light(false)
	display_score()
	
	# TODO: set camera bounds

func _physics_process(delta: float) -> void:
	
	# echolocation
	if Input.is_action_pressed("ui_accept"):
		update_light(true)
	elif Input.is_action_just_released("ui_accept"): #Input.is_action_just_released("ui_up") or Input.is_action_just_released("ui_down") or Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right"):
		update_light(false)
	
	# stun
	if Input.is_action_just_pressed("duck"):
		var space_state = get_world_2d().direct_space_state
		var targets = light_area.get_overlapping_bodies()
		for target in targets:
			var query = PhysicsRayQueryParameters2D.create(global_position, target.global_position)
			query.exclude = [self.get_rid()]
			var result = space_state.intersect_ray(query)
			if target.has_method("apply_stun"): # and result.collider == target:
				target.apply_stun(2.0)
		
	
	if move_cooldown > 0:
		move_cooldown -= delta
		return
		
	
	
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("ui_left", "ui_right")
	input_dir.y = Input.get_axis("ui_up", "ui_down")
	
	if input_dir == Vector2.ZERO:
		return
	
	display_score()
	movement_manager(delta, input_dir)
	
func movement_manager(delta: float, input_dir: Vector2) -> void:
	var base_interval = 0.1
	var diag_interval = base_interval * sqrt(2)
	var interval_to_use = base_interval
	var movement_vector = Vector2.ZERO
	
	var free_n = !$n.is_colliding()
	var free_s = !$s.is_colliding()
	var free_e = !$e.is_colliding()
	var free_w = !$w.is_colliding()
	
	# diagonal
	if input_dir.x != 0 and input_dir.y != 0:
		var diag_free = false
		interval_to_use = diag_interval
		
		if input_dir == Vector2(-1, -1) and !$nw.is_colliding() and free_n and free_w:
			diag_free = true
		elif input_dir == Vector2(1, -1) and !$ne.is_colliding() and free_n and free_e:
			diag_free = true
		elif input_dir == Vector2(-1, 1) and !$sw.is_colliding() and free_s and free_w:
			diag_free = true
		elif input_dir == Vector2(1, 1) and !$se.is_colliding() and free_s and free_e:
			diag_free = true
			
		if diag_free:
			movement_vector = input_dir
			interval_to_use = diag_interval
		else:
			# if diagonal is blocked
			if input_dir.x < 0 and free_w:
				movement_vector = Vector2(-1, 0)
			elif input_dir.x > 0 and free_e:
				movement_vector = Vector2(1, 0)
			elif input_dir.y < 0 and free_n:
				movement_vector = Vector2(0, -1)
			elif input_dir.y > 0 and free_s:
				movement_vector = Vector2(0, 1)
	
	# orthogonal
	elif input_dir.x < 0 and free_w:
		movement_vector = Vector2(-1, 0)
	elif input_dir.x > 0 and free_e:
		movement_vector = Vector2(1, 0)
	elif input_dir.y < 0 and free_n:
		movement_vector = Vector2(0, -1)
	elif input_dir.y > 0 and free_s:
		movement_vector = Vector2(0, 1)
	
	# move and set cooldown
	if movement_vector != Vector2.ZERO:
		move_cooldown = interval_to_use
		_move(movement_vector)
		
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
	score_label.text = str(game_manager.get_score())
