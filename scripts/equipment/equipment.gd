class_name Equipment extends Resource

## Coordinate of the icon within the items spritesheet
@export var icon_coord: Vector2i = Vector2i.ZERO

var _player: Player = null

func set_player(player: Player):
	_player = player

func primary_fire():
	pass

func secondary_fire():
	pass

func _do_animated_effect(do_fn, anim_action):
	assert(_player != null)
	_player.set_is_performing_action(true)
	_player._update_facing_direction()
	_player.set_anim_action(anim_action)
	await _player.get_sprite().animation_finished
	do_fn.call()
	_player.set_is_performing_action(false)