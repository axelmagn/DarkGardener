extends TopDownCharacter

@onready var _sprite = $AnimatedSprite2D
# TODO(axelmagn): decouple this by injecting from outside
@onready var _terrain: Terrain = get_parent().get_node("Terrain")

var _anim_dir = "down"
var _anim_action = "idle"

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

	# Handle interact
	if Input.is_action_just_pressed("interact"):
		_terrain.try_add_grass(global_position)

func _on_started_moving():
	_update_animations()

func _on_stopped_moving():
	_update_animations()

func _on_facing_direction_changed(_old_facing_direction: Direction):
	_update_animations()

func _update_animations():
	match _facing_direction:
		Direction.UP:
			_anim_dir = "up"
		Direction.DOWN:
			_anim_dir = "down"
		Direction.LEFT:
			_anim_dir = "left"
		Direction.RIGHT:
			_anim_dir = "right"
	if _last_move_input.is_zero_approx():
		_anim_action = "idle"
	else:
		_anim_action = "walk"
	_sprite.play("%s_%s" % [_anim_action, _anim_dir])
