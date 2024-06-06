class_name Player extends TopDownCharacter

const Hoe = preload ("res://scripts/tools/hoe.gd")

signal animation_changed

@export var tools: Array[Tool] = []
@export var active_tool_idx: int = 0

@onready var _sprite: AnimatedSprite2D = $CharacterSprite
@onready var _crosshair: Sprite2D = $Crosshair
# TODO(axelmagn): decouple this via injection
@onready var _terrain: Terrain = get_parent().get_node("Terrain")

var _anim_dir: String = "down"
var _anim_action: String = "idle"
var _is_performing_action: bool = false

func get_sprite() -> AnimatedSprite2D:
	return _sprite

func get_terrain() -> Terrain:
	return _terrain

func set_anim_action(anim_action: String):
	if anim_action != _anim_action:
		_anim_action = anim_action
		animation_changed.emit()

func set_is_performing_action(is_performing_action: bool):
	_is_performing_action = is_performing_action
	if not _is_performing_action:
		_update_move_animations()

func primary_fire():
	if active_tool_idx >= 0 and active_tool_idx < tools.size():
		tools[active_tool_idx].primary_fire()

func secondary_fire():
	if active_tool_idx >= 0 and active_tool_idx < tools.size():
		tools[active_tool_idx].secondary_fire()

func _ready():
	animation_changed.connect(_on_animation_changed)
	facing_direction_changed.connect(_on_facing_direction_changed)
	started_moving.connect(_on_started_moving)
	stopped_moving.connect(_on_stopped_moving)

	for t in tools:
		t.set_player(self)

func _process(_delta: float):
	# Update move input
	var horiz_dir = Input.get_axis("move_left", "move_right")
	var vert_dir = Input.get_axis("move_down", "move_up")
	var move_dir = horiz_dir * Vector2.RIGHT + vert_dir * Vector2.UP
	set_move_input(move_dir)

	_update_crosshair()

func _unhandled_input(event: InputEvent):
	# Handle interact
	if event.is_action_pressed("primary_fire"):
		primary_fire()
	if event.is_action_pressed("secondary_fire"):
		secondary_fire()

func _on_started_moving():
	_update_move_animations()

func _on_stopped_moving():
	_update_move_animations()

func _on_facing_direction_changed(_old_facing_direction: Direction):
	_update_move_animations()

func _can_move() -> bool:
	return _active and not _is_performing_action

# TODO(axelmagn): tool command pattern
func _use_hoe():
	_update_anim_dir()
	_anim_action = "hoe"
	_sprite.play(_active_anim())
	set_is_performing_action(true)
	await _sprite.animation_finished
	_terrain.try_toggle_grass(get_aim())
	set_is_performing_action(false)

func _update_move_animations():
	var changed: bool = false
	changed = changed or _update_anim_dir()
	changed = changed or _update_anim_move_action()
	if changed:
		_sprite.play(_active_anim())

## Update _anim_dir, returning true if this resulted in a change
func _update_anim_dir() -> bool:
	var old_anim_dir = _anim_dir
	match _facing_direction:
		Direction.UP:
			_anim_dir = "up"
		Direction.DOWN:
			_anim_dir = "down"
		Direction.LEFT:
			_anim_dir = "left"
		Direction.RIGHT:
			_anim_dir = "right"
	return _anim_dir != old_anim_dir

func _update_anim_move_action():
	var old_anim_action = _anim_action
	if _last_move_input.is_zero_approx():
		_anim_action = "idle"
	else:
		_anim_action = "walk"
	return _anim_action != old_anim_action

func get_aim() -> Vector2:
	var aim_pos = global_position
	match _facing_direction:
		Direction.UP:
			aim_pos += Vector2(0, -16)
		Direction.DOWN:
			aim_pos += Vector2(0, 16)
		Direction.LEFT:
			aim_pos += Vector2( - 16, 0)
		Direction.RIGHT:
			aim_pos += Vector2(16, 0)
	return aim_pos

func _update_crosshair():
	_crosshair.global_position = _terrain.nearest_tile_center(get_aim())

func _active_anim() -> String:
	return "%s_%s" % [_anim_action, _anim_dir]

func _on_animation_changed():
	_sprite.play(_active_anim())
