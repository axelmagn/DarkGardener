extends TileMap
class_name Terrain

@export var terrain_set: int = 0

@export var grass_layer_name = "00_grass"
var grass_layer = null

@export var grass_terrain_name = "grass"
var grass_terrain = null

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(get_layers_count()):
		var layer_name = get_layer_name(i)
		if layer_name == grass_layer_name:
			grass_layer = i
	for i in range(tile_set.get_terrains_count(terrain_set)):
		var terrain_name = tile_set.get_terrain_name(terrain_set, i)
		if terrain_name == grass_terrain_name:
			grass_terrain = i

	assert(grass_layer != null)
	assert(grass_terrain != null)

func till(global_pos: Vector2):
	var local_pos = to_local(global_pos)
	var coords = local_to_map(local_pos)
	set_cells_terrain_connect(grass_layer, [coords], terrain_set, -1)
