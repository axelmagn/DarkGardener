extends TopDownCharacter

@onready var _sprite = $AnimatedSprite2D

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

func _on_started_moving():
	_update_animations()

func _on_stopped_moving():
	_update_animations()

func _on_facing_direction_changed(_old_facing_direction: Direction):
	_update_animations()

func _update_animations():
	var dir = null
	match _facing_direction:
		Direction.UP:
			dir = "up"
		Direction.DOWN:
			dir = "down"
		Direction.LEFT:
			dir = "left"
		Direction.RIGHT:
			dir = "right"
	var action = null
	if _last_move_input.is_zero_approx():
		action = "idle"
	else:
		action = "walk"
	_sprite.play("%s_%s" % [action, dir])
