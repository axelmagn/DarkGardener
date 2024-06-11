extends TileMap
class_name Terrain

@export var terrain_set: int = 0

@export var ground_layer_name = "00_ground"
@export var grass_layer_name = "00_grass"

@export var grass_terrain_name = "grass"

@onready var grass_layer = _get_layer_idx(grass_layer_name)
@onready var ground_layer = _get_layer_idx(ground_layer_name)

@onready var grass_terrain = _get_terrain_idx(grass_terrain_name)

func remove_grass(global_pos: Vector2):
	var coords = global_to_map(global_pos)
	set_cells_terrain_connect(grass_layer, [coords], terrain_set, -1)

func try_add_grass(global_pos: Vector2):
	var coords = global_to_map(global_pos)
	# there must be ground beneath the grass
	var ground_data = get_cell_tile_data(ground_layer, coords)
	if ground_data == null:
		return
	set_cells_terrain_connect(grass_layer, [coords], terrain_set, grass_terrain)

func try_toggle_grass(global_pos: Vector2):
	var coords = global_to_map(global_pos)
	var ground_data = get_cell_tile_data(ground_layer, coords)
	# there must be ground beneath the grass
	if ground_data == null:
		return
	var grass_data = get_cell_tile_data(grass_layer, coords)
	if grass_data == null:
		set_cells_terrain_connect(grass_layer, [coords], terrain_set, grass_terrain)
	else:
		set_cells_terrain_connect(grass_layer, [coords], terrain_set, -1)

func global_to_map(global_pos: Vector2) -> Vector2i:
	return local_to_map(to_local(global_pos))

func map_to_global(coord: Vector2i) -> Vector2:
	return to_global(map_to_local(coord))

func nearest_tile_center(global_pos: Vector2) -> Vector2:
	return map_to_global(global_to_map(global_pos))

func aimed_tile_center(global_pos: Vector2, aim_dir: Vector2) -> Vector2:

	if aim_dir.is_zero_approx():
		return nearest_tile_center(global_pos)

	var offsets = [
		Vector2i( - 1, -1), Vector2i( - 1, 0), Vector2i( - 1, 1),
		Vector2i(0, -1), Vector2i(0, 1),
		Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1),
		]
	var max_dot = 0
	var best_offset = Vector2i.ZERO
	var aim_norm = aim_dir.normalized()
	for offset in offsets:
		var dot = Vector2(offset).normalized().dot(aim_norm)
		if dot > max_dot:
			max_dot = dot
			best_offset = offset
	var center_coord = global_to_map(global_pos)

	return map_to_global(center_coord + best_offset)

func _get_layer_idx(layer_name: String) -> int:
	for i in range(get_layers_count()):
		if layer_name == get_layer_name(i):
			return i
	return (-1)

func _get_terrain_idx(terrain_name: String) -> int:
	for i in range(tile_set.get_terrains_count(terrain_set)):
		if terrain_name == tile_set.get_terrain_name(terrain_set, i):
			return i
	return (-1)
