extends CharacterBody2D
class_name TopDownCharacter

## Maximum speed of the character in (px/s)
@export var max_speed: float = 150.

## Time to accelerate form rest to top speed
@export var accel_time: float = 0.2

## Time to decelerate from top speed to rest
@export var brake_time: float = 0.2

var _move_input: Vector2 = Vector2.ZERO

enum Direction {
  UP = 0,
  DOWN = 1,
  LEFT = 2,
  RIGHT = 3,
}

func _physics_process(delta):
  pass

## Consume and reset move input.
## Used during movement processing.
func _consume_move_input() -> Vector2:
  _clamp_move_input()
  var out = _move_input
  _move_input = Vector2.ZERO
  return out

## Add movement input to the character.
func add_move_input(delta: Vector2):
  _move_input += delta

## Clamp the lenght of _move_imput to be less that 1.
func _clamp_move_input():
  if _move_input.length_squared() > 1.:
    _move_input /= _move_input.length()
  assert(_move_input.length_squared() <= 1.)
