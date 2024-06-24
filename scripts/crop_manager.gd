class_name CropManager extends Node2D

@onready var _terrain: Terrain = get_parent()

## Crops indexed by coordinate
var _crop_coord_idx = {}

enum Result {
	ADDED,
	UNCHANGED
}

## Add a crop instance to the map
func add_crop(crop_scene: PackedScene, crop_position: Vector2) -> Result:
	var crop_coord = _terrain.global_to_map(crop_position)
	if crop_coord in _crop_coord_idx:
		return Result.UNCHANGED
	if not _terrain.is_soil(crop_coord):
		return Result.UNCHANGED
	crop_position = _terrain.map_to_global(crop_coord)
	var crop = crop_scene.instantiate()
	add_child(crop)
	crop.initialize(crop_position)
	_crop_coord_idx[crop_coord] = crop
	return Result.ADDED

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
