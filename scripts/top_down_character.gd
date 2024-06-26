extends CharacterBody2D
class_name TopDownCharacter

## Maximum speed of the character in (px/s)
@export var max_speed: float = 150.

## Time to accelerate from rest to top speed
@export var spur_time: float = 0.2

## Time to decelerate from top speed to rest
@export var brake_time: float = 0.2

@export var _active: bool = true

signal started_moving()
signal stopped_moving()
signal facing_direction_changed(old_facing_direction: Direction)

var _move_input: Vector2 = Vector2.ZERO
var _last_move_input: Vector2 = Vector2.ZERO
var _facing_direction: Direction = Direction.DOWN
var _is_performing_action: bool = false

enum Direction {
  UP = 0,
  DOWN = 1,
  LEFT = 2,
  RIGHT = 3,
}

## Add movement input to the character.
func add_move_input(delta: Vector2):
	_move_input += delta

## Set movement input for the character.
func set_move_input(move_input: Vector2):
	_move_input = move_input

func _physics_process(delta: float):
	# capture move transition signals before consuming move input
	# (they are tougher to figure out once movement is consumed)
	var is_moving_before = !velocity.is_zero_approx()

	_handle_move(delta)
	if not _is_performing_action:
		_update_facing_direction()

	var is_moving_after = !velocity.is_zero_approx()

	# emit move transition signals
	if not is_moving_before and is_moving_after:
		started_moving.emit()
	if is_moving_before and not is_moving_after:
		stopped_moving.emit()

func _handle_move(delta: float):
	if !_can_move():
		_consume_move_input()
		return
	var tgt_velocity = _consume_move_input() * max_speed
	var is_braking = velocity.length_squared() < tgt_velocity.length_squared()
	var accel_time = brake_time if is_braking else spur_time
	velocity = lerp(velocity, tgt_velocity, delta / accel_time)
	move_and_slide()

## Consume and reset move input.
## Used during movement processing.
func _consume_move_input() -> Vector2:
	_last_move_input = _move_input.limit_length(1.)
	_move_input = Vector2.ZERO
	return _last_move_input

func _update_facing_direction():
	if _last_move_input.is_zero_approx():
		return
	var old_facing_direction = _facing_direction
	if abs(_last_move_input.angle_to(Vector2.LEFT)) < PI / 4:
		_facing_direction = Direction.LEFT
	elif abs(_last_move_input.angle_to(Vector2.RIGHT)) < PI / 4:
		_facing_direction = Direction.RIGHT
	elif abs(_last_move_input.angle_to(Vector2.UP)) < PI / 4:
		_facing_direction = Direction.UP
	elif abs(_last_move_input.angle_to(Vector2.DOWN)) < PI / 4:
		_facing_direction = Direction.DOWN
		
	if _facing_direction != old_facing_direction:
		facing_direction_changed.emit(old_facing_direction)

func _can_move() -> bool:
	return _active
