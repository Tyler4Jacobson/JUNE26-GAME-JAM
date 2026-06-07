extends Node2D

@onready var ground_layer: TileMapLayer = $ground_layer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#
	#
	#Note this is hide() right now. This was so I could see the grid. Probably change back to show() ?
	#
	#
	$ScanCover.hide()
	initialize_grid(randi_range(6, 10), randi_range(4, 8))
	procedural.randomize_grid(ground_layer, randf_range(0.4, 0.6))
	procedural.fill_holes(ground_layer)
	# random levels. Placing things besides the maze is beyond the scope of me _/(<^>)\_
	#place player
	#place enemies
	#place collectibles???
	#use vvvvvvv to have options on where to place all of the above
	#procedural.get_clear_spaces(ground_layer)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	#if Input.is_action_pressed("ui_accept") and $ScanCover.visible == true:
		#$PointLight2D.enabled = true
	#elif Input.is_action_just_released("ui_accept") and $ScanCover.visible == false: #Input.is_action_just_released("ui_up") or Input.is_action_just_released("ui_down") or Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right"):
		#$PointLight2D.enabled = false
		
func initialize_grid(size_x: int, size_y: int):
	for x in range(size_x*-1, size_x):
		for y in range(size_y*-1, size_y):
			var tile_pos = Vector2i(x, y)
			var atlas_pos = Vector2i(1, 1) #all blank, edges later
			ground_layer.set_cell(tile_pos, 0, atlas_pos)
	set_grid_boundary(size_x, size_y)
	
func set_grid_boundary(size_x: int, size_y: int):
	for x in range(size_x*-1, size_x):
		# set bottom layer
		var tile_pos = Vector2i(x, size_y-1)
		var atlas_pos = Vector2i(1, 4)
		if x == size_x*-1:
			atlas_pos = Vector2i(15, 4)
		elif x == size_x-1:
			atlas_pos = Vector2i(16, 4)
		ground_layer.set_cell(tile_pos, 0, atlas_pos)
		# set top layer
		tile_pos = Vector2i(x, size_y*-1)
		if x == size_x*-1 or x == size_x-1:
			atlas_pos.y = atlas_pos.y - 1
		ground_layer.set_cell(tile_pos, 0, atlas_pos)
	
	# don't double do corners
	for y in range(size_y*-1 + 1, size_y-1):
		# set left layer
		var tile_pos = Vector2i(size_x*-1, y)
		var atlas_pos = Vector2i(4, 1)
		ground_layer.set_cell(tile_pos, 0, atlas_pos)
		# set right layer
		tile_pos.x = tile_pos.x * -1 - 1
		ground_layer.set_cell(tile_pos, 0, atlas_pos)
