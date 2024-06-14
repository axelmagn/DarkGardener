class_name Hoe extends Equipment

func primary_fire():
	var aim_point = _player.get_aim_global()
	var remove_grass = func():
		_player.get_terrain().remove_grass(aim_point)
	_do_animated_effect(remove_grass)

func secondary_fire():
	var aim_point = _player.get_aim_global()
	var add_grass = func():
		_player.get_terrain().try_add_grass(aim_point)
	_do_animated_effect(add_grass)
