extends CharacterBody2D

const tile_size: Vector2 = Vector2(16,16)
var sprite_node_pos_tween: Tween
var camera_pos_tween: Tween
var move_cooldown: float = 0.0
var timer: float = 0.0
var light_timer: float = 0.0
var enemies: Array[Node2D] = []
var LIGHT_COST: int = 1
var STUN_COST: int = 1

var small_light_size = Vector2(1, 1)
var small_light_color = Color(0.913, 0.502, 0.369)

var big_light_size = Vector2(3, 3)
var big_light_color = Color(0.992, 0.447, 0.035)

@onready var score_label: Label = $Camera2D/score
@onready var point_light_2d: PointLight2D = $Sprite2D/PointLight2D
@onready var light_area: Area2D = $Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	update_light(false)
	display_score()
	game_manager.player_spawn()
	
	# TODO: set camera bounds

func _physics_process(delta: float) -> void:
	# echolocation
	if Input.is_action_just_pressed("ui_accept") and game_manager.get_charge() > 0:
		light_timer = 5.0
		game_manager.subtract_charge(LIGHT_COST)
		
	light_timer -= 0.1
	
	if light_timer >= 0.0:
		update_light(true)
	else:
		update_light(false)
	
	# stun
	if Input.is_key_pressed(KEY_SHIFT) and game_manager.get_charge() > 0:
		game_manager.subtract_charge(LIGHT_COST)
		var targets = light_area.get_overlapping_bodies()
		for target in targets:
			var query = PhysicsRayQueryParameters2D.create(global_position, target.global_position)
			query.exclude = [self.get_rid()]
			if target.has_method("apply_stun"):
				enemies.append(target)
				target.apply_stun(2.0)
		
	
	display_score()
	movement_manager(delta)
	
func movement_manager(delta: float) -> void:
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
	if dir.x > 0.0:
		$Sprite2D.global_rotation = deg_to_rad(0)
	elif dir.x < 0.0:
		$Sprite2D.global_rotation = deg_to_rad(180)
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
	var score = game_manager.get_score()
	var max_score = game_manager.get_coin_count()
	score_label.text = str(score, "/", max_score)
