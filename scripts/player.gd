class_name Player extends TopDownCharacter

const Hoe = preload ("res://scripts/equipment/hoe.gd")

signal animation_changed()
signal aim_dir_changed(old_aim_dir: Vector2)
signal active_equipment_changed(old_active_equipment_idx: int)

@export var equipment: Array[Equipment] = []
@export var equipment_idx: int = 0
@export var aim_dir_clamp: Vector2 = Vector2(16, 16)

@onready var _sprite: AnimatedSprite2D = $CharacterSprite
@onready var _crosshair: Sprite2D = $Crosshair
# TODO(axelmagn): decouple this via injection
@onready var _terrain: Terrain = get_parent().get_node("Terrain")

var _anim_dir: String = "down"
var _anim_action: String = "idle"
var _aim_dir: Vector2 = Vector2.ZERO

func get_sprite() -> AnimatedSprite2D:
	return _sprite

func get_terrain() -> Terrain:
	return _terrain

func get_aim_dir() -> Vector2:
	return _aim_dir

func get_active_equipment() -> Equipment:
	return get_equipment(equipment_idx)

func get_equipment(idx: int) -> Equipment:
	if idx < 0 or idx > equipment.size():
		return null
	return equipment[equipment_idx]

func set_anim_action(anim_action: String):
	if anim_action != _anim_action:
		_anim_action = anim_action
		animation_changed.emit()

func set_is_performing_action(is_performing_action: bool):
	_is_performing_action = is_performing_action
	if not _is_performing_action:
		_update_move_animations()

func set_active_equipment(idx: int):
	var old_active_equipment = equipment_idx
	equipment_idx = idx
	if equipment_idx != old_active_equipment:
		active_equipment_changed.emit(old_active_equipment)

func primary_fire():
	if equipment_idx >= 0 and equipment_idx < equipment.size():
		equipment[equipment_idx].primary_fire()

func secondary_fire():
	if equipment_idx >= 0 and equipment_idx < equipment.size():
		equipment[equipment_idx].secondary_fire()

func _ready():
	animation_changed.connect(_on_animation_changed)
	facing_direction_changed.connect(_on_facing_direction_changed)
	started_moving.connect(_on_started_moving)
	stopped_moving.connect(_on_stopped_moving)
	active_equipment_changed.connect(_on_active_equipment_changed)

	if equipment.size() > 0:
		for t in equipment:
			t.set_player(self)
		equipment[equipment_idx].activate()

func _process(_delta: float):
	# Update move input
	var horiz_dir = Input.get_axis("move_left", "move_right")
	var vert_dir = Input.get_axis("move_down", "move_up")
	var move_dir = horiz_dir * Vector2.RIGHT + vert_dir * Vector2.UP
	set_move_input(move_dir)

	if not _is_performing_action:
		_update_crosshair()

func _unhandled_input(event: InputEvent):
	# Handle interact
	if event.is_action_pressed("primary_fire"):
		primary_fire()
	elif event.is_action_pressed("secondary_fire"):
		secondary_fire()
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)

func _handle_mouse_motion(event: InputEventMouseMotion):
	var mouse_pos = event.position
	var center_pos = get_viewport().get_visible_rect().size / 2
	var old_aim_dir = _aim_dir
	_aim_dir = (mouse_pos - center_pos).clamp( - 1 * aim_dir_clamp, aim_dir_clamp)
	if not _aim_dir.is_equal_approx(old_aim_dir):
		aim_dir_changed.emit(old_aim_dir)

func _on_started_moving():
	_update_move_animations()

func _on_stopped_moving():
	_update_move_animations()

func _on_facing_direction_changed(_old_facing_direction: Direction):
	_update_move_animations()

func _can_move() -> bool:
	return _active and not _is_performing_action

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

func get_aim_global() -> Vector2:
	return global_position + _aim_dir

func _update_crosshair():
	_crosshair.global_position = _terrain.nearest_tile_center(get_aim_global())

func _active_anim() -> String:
	return "%s_%s" % [_anim_action, _anim_dir]

func _on_animation_changed():
	_sprite.play(_active_anim())

func _on_active_equipment_changed(old_active_equipment_idx: int):
	var old_equipment = get_equipment(old_active_equipment_idx)
	if old_equipment != null:
		old_equipment.deactivate()
	var new_equipment = get_active_equipment()
	if new_equipment != null:
		new_equipment.activate()

func _update_facing_direction():
	var facing_vec = _last_move_input
	if _is_performing_action:
		facing_vec = _aim_dir
	elif _last_move_input.is_zero_approx():
		return
	if facing_vec.is_zero_approx():
		return
	var old_facing_direction = _facing_direction
	if abs(facing_vec.angle_to(Vector2.LEFT)) < PI / 4:
		_facing_direction = Direction.LEFT
	elif abs(facing_vec.angle_to(Vector2.RIGHT)) < PI / 4:
		_facing_direction = Direction.RIGHT
	elif abs(facing_vec.angle_to(Vector2.UP)) < PI / 4:
		_facing_direction = Direction.UP
	elif abs(facing_vec.angle_to(Vector2.DOWN)) < PI / 4:
		_facing_direction = Direction.DOWN
	print("facing_vec:", facing_vec, ",", _is_performing_action, ",", _facing_direction)
		
	if _facing_direction != old_facing_direction:
		facing_direction_changed.emit(old_facing_direction)
