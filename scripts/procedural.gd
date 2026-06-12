extends RefCounted

class_name procedural

const MOORES_NEIGHBORHOOD = [
	TileSet.CELL_NEIGHBOR_TOP_SIDE,
	TileSet.CELL_NEIGHBOR_BOTTOM_SIDE,
	TileSet.CELL_NEIGHBOR_LEFT_SIDE,
	TileSet.CELL_NEIGHBOR_RIGHT_SIDE,
	TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER,
	TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER,
	TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
	TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER
]

const occupied_pos = Vector2i(4, 11) 	# Ground
const clear_pos = Vector2i(6, 11)		# Water

static func randomize_grid(ground_layer: TileMapLayer, density: float):
	var cells = procedural.get_clear_spaces(ground_layer)
	for cell_coords in cells:
		if randf() < density:
			ground_layer.set_cell(cell_coords, 0, occupied_pos)
	procedural._cellular_iteration(ground_layer, cells)
	
static func _cellular_iteration(ground_layer: TileMapLayer, cells: Array[Vector2i]):
	var occupied_cells = [] #living
	var clear_cells = [] #dead
	for cell_coords in cells:
		var clear_count = 0
		var clear = ground_layer.get_cell_atlas_coords(cell_coords) == clear_pos
		var neighbors = []
		for direction in MOORES_NEIGHBORHOOD:
			neighbors.append(ground_layer.get_neighbor_cell(cell_coords, direction))
		for neighbor in neighbors:
			if ground_layer.get_cell_atlas_coords(neighbor) == clear_pos:
				clear_count = clear_count + 1
		var occupied_count = 8 - clear_count
		#cell dies
		if occupied_count != 1 and not clear and occupied_count < 5:
			occupied_cells.append(cell_coords)
		else:
			clear_cells.append(cell_coords)
	
	for occupied in occupied_cells:
		ground_layer.set_cell(occupied, 0, occupied_pos)
	for clear in clear_cells:
		ground_layer.set_cell(clear, 0, clear_pos)
	
# super efficient function, trust <:]
static func fill_holes(ground_layer: TileMapLayer):
	var remaining_clear_spaces = get_clear_spaces(ground_layer)
	if remaining_clear_spaces.size() == 0:
		return
	var current_clear_queue: Array[Vector2i] = []
	var pockets = []
	#at least one pocket left
	while remaining_clear_spaces.size() > 0:
		current_clear_queue.append(remaining_clear_spaces[0])
		pockets.append([remaining_clear_spaces[0]])
		remaining_clear_spaces.erase(remaining_clear_spaces[0])
		#at least one space left to explore in the current pocket
		while current_clear_queue.size() > 0:
			var cur_pos = current_clear_queue.pop_front()
			pockets[pockets.size() - 1].append(cur_pos)
			for orthogonal_neighbor in ground_layer.get_surrounding_cells(cur_pos):
				if orthogonal_neighbor in remaining_clear_spaces:
					remaining_clear_spaces.erase(orthogonal_neighbor)
					current_clear_queue.append(orthogonal_neighbor)
	var main_pocket = pockets[0]
	for pocket in pockets:
		if pocket.size() > main_pocket.size():
			main_pocket = pocket
	for pocket in pockets:
		if pocket == main_pocket:
			continue
		for cell in pocket:
			ground_layer.set_cell(cell, 0, occupied_pos)
	
	
static func get_clear_spaces(ground_layer: TileMapLayer) -> Array[Vector2i]:
	var clear_cells: Array[Vector2i] = []
	for cell_coords in ground_layer.get_used_cells():
		var atlas_coords = ground_layer.get_cell_atlas_coords(cell_coords)
		if atlas_coords == clear_pos:
			clear_cells.append(cell_coords)
	return clear_cells
