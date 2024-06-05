extends TopDownCharacter

@onready var _sprite: AnimatedSprite2D = $CharacterSprite
@onready var _crosshair: Sprite2D = $Crosshair
# TODO(axelmagn): decouple this via injection
@onready var _terrain: Terrain = get_parent().get_node("Terrain")

var _anim_dir: String = "down"
var _anim_action: String = "idle"
var _is_performing_action: bool = false

func _ready():
	started_moving.connect(_on_started_moving)
	stopped_moving.connect(_on_stopped_moving)
	facing_direction_changed.connect(_on_facing_direction_changed)

func _process(_delta: float):
	# Update move input
	var horiz_dir = Input.get_axis("move_left", "move_right")
	var vert_dir = Input.get_axis("move_down", "move_up")
	var move_dir = horiz_dir * Vector2.RIGHT + vert_dir * Vector2.UP
	set_move_input(move_dir)

	_update_crosshair()

func _unhandled_input(event: InputEvent):
	# Handle interact
	if event.is_action_pressed("interact"):
		# _terrain.try_add_grass(global_position)
		_use_hoe()

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
	_is_performing_action = true
	await _sprite.animation_finished
	_terrain.try_toggle_grass(_get_aim())
	_is_performing_action = false
	_update_move_animations()

func _update_move_animations():
	_update_anim_dir()
	_update_anim_move_action()
	_sprite.play(_active_anim())

func _update_anim_dir():
	match _facing_direction:
		Direction.UP:
			_anim_dir = "up"
		Direction.DOWN:
			_anim_dir = "down"
		Direction.LEFT:
			_anim_dir = "left"
		Direction.RIGHT:
			_anim_dir = "right"

func _update_anim_move_action():
	if _last_move_input.is_zero_approx():
		_anim_action = "idle"
	else:
		_anim_action = "walk"

func _get_aim() -> Vector2:
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
	_crosshair.global_position = _terrain.nearest_tile_center(_get_aim())

func _active_anim() -> String:
	return "%s_%s" % [_anim_action, _anim_dir]
