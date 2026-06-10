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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#print(tile_map.get_children())
	var interval = 0.5
	
	# check if stunned
	if stun_timer > 0:
		stun_timer -= delta
	
	# If the player moves, update the path
	# TODO: This feels really cheap and messy
	if is_moving:
		timer += delta
		if timer >= interval:
			is_moving = false
			timer -= interval
		return
	
	if stun_timer <= 0:
		move()

# Check if a cell holds the player or an enemy
func is_cell_occupied(target_cell: Vector2i) -> bool:
	for sibling in get_parent().get_children():
		if sibling == self:	# or sibling == player
			continue
		
		if not sibling.has_method("move"):
			continue
		
		# real-world position into grid coordinates
		var sibling_local = tile_map.to_local(sibling.global_position)
		var sibling_cell = tile_map.local_to_map(sibling_local)
		
		# occupied
		if sibling_cell == target_cell:
			return true
	
	# not occupied
	return false

# Move enemy one step toward player along AStar Path
func move() -> void:
	if player == null or astar_grid == null or tile_map == null:
		return
	
	# global positions into tile_map's local space
	var local_enemy_pos = tile_map.to_local(global_position)
	var local_player_pos = tile_map.to_local(player.global_position)
	
	# grid coordinates
	var start_cell = tile_map.local_to_map(local_enemy_pos)
	var target_cell = tile_map.local_to_map(local_player_pos)
	
	var path = astar_grid.get_id_path(start_cell, target_cell)
	
	# Stop movement if player is out of range
	# TODO: Maybe a smaller 'agro' range, but then a greater range that it will continue to follow for
	if path.size() > 10:
		is_moving = false
		return
	
	# Take next step along the path
	var original_position = path.pop_front()
	
	if path.is_empty():
		#print("can't find path")
		return
		
	var next_position = path[0]
	
	# stop next to other enemies
	if is_cell_occupied(next_position):
		is_moving = true
		return
	
	# stop next to player
	#if next_position == target_cell:
		#is_moving = true
		#return
	
	global_position = tile_map.map_to_local(next_position)
	sprite_2d.global_position = tile_map.map_to_local(original_position)
	
	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property(sprite_2d, "global_position", global_position, 0.185)
	
	#print("original_position = ", original_position)
	#print("next_position = ", path[0])
	
	is_moving = true
	
func apply_stun(duration: float) -> void:
	stun_timer = max(stun_timer, duration)
