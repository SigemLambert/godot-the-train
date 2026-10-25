@icon("uid://daq3vkwhfecle")
class_name RotaryDial3D
extends Interactable3D


signal output_value_changed(new_value: float)

@export_group("Rotation", "rotation")
@export var rotation_node: Node3D
@export var rotation_axis: Vector3 = Vector3.RIGHT
@export var rotation_sensitivity: float = 1.0
@export_subgroup("Limits", "rotation_angle")
@export var rotation_angle_min: float = -180.0
@export var rotation_angle_max: float = 180.0

@export_group("Output", "output")
@export var output_mode: OutputMode = OutputMode.RAW_ANGLE
@export var output_normalized_range: Vector2 = Vector2(0.0, 1.0)
@export var output_snapping: float = 0.1

enum OutputMode { RAW_ANGLE, NORMALIZED, WRAPPED }

var output: float:
	set(value):
		set_output_value(value)
	get():
		return get_output_value()
var _rotation: float
var _last_input_mouse_motion_event: InputEventMouseMotion


func _input(event: InputEvent):
	if enabled and interaction_active:
		_last_input_mouse_motion_event = event if event is InputEventMouseMotion else null


func _on_interact_active(_delta: float):
	if interaction_active and _last_input_mouse_motion_event:
		add_rotation(_last_input_mouse_motion_event.relative.x * rotation_sensitivity)
		_last_input_mouse_motion_event = null


func _on_rotation_changed():
	if rotation_node:
		rotation_node.rotation_degrees = rotation_axis * _rotation
	output_value_changed.emit(output)


func add_rotation(delta: float):
	_rotation = clamp(_rotation + delta, rotation_angle_min, rotation_angle_max)
	_on_rotation_changed()


func set_output_value(value: float):
	match output_mode:
		OutputMode.WRAPPED:
			_rotation = clamp(value, rotation_angle_min, rotation_angle_max)
		OutputMode.NORMALIZED:
			var denom: float = output_normalized_range.y - output_normalized_range.x
			var normalized: float = 0.0 if is_zero_approx(denom) else (value - output_normalized_range.x) / denom
			var range_size: float = rotation_angle_max - rotation_angle_min
			_rotation = clamp(rotation_angle_min + normalized * range_size, rotation_angle_min, rotation_angle_max)
		OutputMode.RAW_ANGLE, _:
			_rotation = clamp(value, rotation_angle_min, rotation_angle_max)
	_on_rotation_changed()


func get_output_value() -> float:
	var value := _rotation
	
	match output_mode:
		OutputMode.WRAPPED:
			value = wrapf(_rotation, -180.0, 180.0)
		OutputMode.NORMALIZED:
			var range_size: float = rotation_angle_max - rotation_angle_min
			var normalized: float = (_rotation - rotation_angle_min) / range_size
			value = lerp(output_normalized_range.x, output_normalized_range.y, normalized)
	
	return snappedf(value, output_snapping)
