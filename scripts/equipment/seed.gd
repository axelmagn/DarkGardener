class_name Seed extends Equipment

@export var crop_scene: PackedScene

func primary_fire():
	var aim_point = _player.get_aim_global()
	_player.get_terrain().crop_manager.add_crop(crop_scene, aim_point)