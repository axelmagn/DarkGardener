class_name Hoe extends Equipment

@export var anim_action: String = "hoe"

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

func _do_animated_effect(do_fn):
	assert(_player != null)
	_player.set_is_performing_action(true)
	_player._update_facing_direction()
	_player.set_anim_action(self.anim_action)
	await _player.get_sprite().animation_finished
	do_fn.call()
	_player.set_is_performing_action(false)
