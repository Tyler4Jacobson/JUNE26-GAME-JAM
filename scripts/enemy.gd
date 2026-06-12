extends CharacterBody2D

@onready var sprite_2d = $Sprite2D

var tile_map: TileMapLayer
var player: CharacterBody2D
var is_moving = false
var astar_grid: AStarGrid2D
const tile_size: Vector2 = Vector2(16,16)
var sprite_node_pos_tween: Tween
var timer = 0.0
var stun_timer: float = 0.0
var stunned_color = Color.BLUE
var clear_color = Color.WHITE


var agro_flag: bool = false
var agro_range: int = 10
var follow_range: int = 20


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	move_manager(delta)

func move_manager(delta: float) -> void:
	if player == null or astar_grid == null or tile_map == null:
		return
	
	if stun_timer > 0:
		stun_timer -= delta
	
	var interval = 0.5
	# If the player moves, update the path
	if is_moving:
		timer += delta
		if timer >= interval:
			is_moving = false
			timer -= interval
		return
		
	if stun_timer <= 0:
		modulate = clear_color
		move()

# Move enemy one step toward player along AStar Path
func move() -> void:
	# global positions into tile_map's local space
	var local_enemy_pos = tile_map.to_local(global_position)
	var local_player_pos = tile_map.to_local(player.global_position)
	
	# grid coordinates
	var start_cell = tile_map.local_to_map(local_enemy_pos)
	var target_cell = tile_map.local_to_map(local_player_pos)
	var path = astar_grid.get_id_path(start_cell, target_cell)
	
	# Stop movement if player is out of range
	# The range is increased when the player gets close
	# Then the enemy is agrovated
	if agro_flag:
		if path.size() > follow_range:
			is_moving = false
			agro_flag = false
			return
	else:
		if path.size() > agro_range:
			is_moving = false
			agro_flag = false
			return
	
	# Take next step along the path
	var original_position = path.pop_front()
	if path.is_empty(): 
		return
	var next_position = path[0]
	
	# stop next to other enemies
	if is_cell_occupied(next_position):
		is_moving = true
		return
	
	global_position = tile_map.map_to_local(next_position)
	sprite_2d.global_position = tile_map.map_to_local(original_position)
	
	# make the enemy sprite slide nicely
	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property(sprite_2d, "global_position", global_position, 0.185)
	
	is_moving = true
	agro_flag = true
	
# Check if a cell holds the player or an enemy
func is_cell_occupied(target_cell: Vector2i) -> bool:
	for sibling in get_parent().get_children():
		# skip cells containing the enemy or player
		if sibling == self or (not sibling.has_method("move")):
			continue
		
		# real-world position into grid coordinates
		var sibling_local = tile_map.to_local(sibling.global_position)
		var sibling_cell = tile_map.local_to_map(sibling_local)
		
		# occupied
		if sibling_cell == target_cell:
			return true
	
	# not occupied
	return false

func apply_stun(duration: float) -> void:
	modulate = stunned_color
	stun_timer = max(stun_timer, duration)
