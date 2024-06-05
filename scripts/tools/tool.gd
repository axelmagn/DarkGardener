class_name Tool extends Resource

const Player = preload ("res://scripts/player.gd")

var _owner: Player = null

func _init(owner: Player):
  self._owner = owner

func primary_fire():
  pass

func secondary_fire():
  pass