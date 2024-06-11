class_name Equipment extends Resource

var _player: Player = null

func set_player(player: Player):
	var old_player = _player
	_player = player
	if _player != old_player:
		_on_player_changed(old_player)

func primary_fire():
	pass

func secondary_fire():
	pass

func activate():
	pass

func deactivate():
	pass

func _process():
	pass

func _on_player_changed(old_player: Player):
	pass