class_name PlayerCamera3D
extends Camera3D


@export var body: CharacterBody3D
@export var enabled: bool = true

@export_group("Sensitivity", "mouse")
@export var mouse_sensitivity: float = 1.0
@export var mouse_sensitivity_multiplier: float = 0.001

@export_group("Rotation Limits", "limit")
@export var limit_x_up: float = 90.0
@export var limit_x_down: float = -90.0


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if not body:
		body = get_parent() as CharacterBody3D


func _input(event: InputEvent):
	if enabled and event is InputEventMouseMotion:
		handle_mouse_look(event)


func handle_mouse_look(event: InputEventMouseMotion):
	var yaw: float = -event.relative.x * mouse_sensitivity * mouse_sensitivity_multiplier
	var pitch: float = -event.relative.y * mouse_sensitivity * mouse_sensitivity_multiplier
	
	if body:
		body.rotate_y(yaw)
	rotate_x(pitch)
	
	rotation_degrees.x = clamp(rotation_degrees.x, limit_x_down, limit_x_up)
