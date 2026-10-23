@icon("uid://mhfmwvqocaq6")
class_name PlayerMovementController
extends Node


@export var body: CharacterBody3D
@export_group("Speed")
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 7.5
@export var jump_velocity: float = 5.0
 
@export_group("Physics")
@export_subgroup("Acceleration")
@export var acceleration: float = 10.0
@export var air_acceleration: float = 2.0
@export_subgroup("Friction")
@export var friction: float = 8.0
@export var air_friction: float = 0.5
 
@export_group("Controls")
@export var move_forward_action: String = "ui_up"
@export var move_backward_action: String = "ui_down"
@export var move_left_action: String = "ui_left"
@export var move_right_action: String = "ui_right"
@export var jump_action: String = "ui_accept"
@export var sprint_action: String = ""
 
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_friction: float
 
 
func _ready():
	if not body:
		body = get_parent() as CharacterBody3D
	assert(body, "Player body is not specified or found.")
 
 
func _physics_process(delta: float):
	if not body:
		return
	
	var grounded: bool = body.is_on_floor()
	current_friction = friction if grounded else air_friction
	
	apply_gravity(delta)
	handle_jump(grounded)
	handle_movement(delta, grounded)
	
	body.move_and_slide()
 
 
func apply_gravity(delta: float):
	if not body.is_on_floor():
		body.velocity.y -= gravity * delta
 
 
func handle_jump(grounded: bool):
	if not grounded:
		return
	if jump_action and Input.is_action_just_pressed(jump_action):
		body.velocity.y = jump_velocity
 
 
func handle_movement(delta: float, grounded: bool):
	var input_dir: Vector2 = get_input_direction()
	
	if input_dir == Vector2.ZERO:
		apply_friction(delta)
		return
	
	var direction: Vector3 = get_movement_direction(input_dir)
	var target_speed: float = get_target_speed()
	var accel: float = acceleration if grounded else air_acceleration
	
	accelerate(direction, target_speed, accel, delta)
 
 
func get_input_direction() -> Vector2:
	var forward: float = Input.get_action_strength(move_forward_action) - Input.get_action_strength(move_backward_action)
	var right: float = Input.get_action_strength(move_right_action) - Input.get_action_strength(move_left_action)
	return Vector2(right, forward)
 
 
func get_movement_direction(input_dir: Vector2) -> Vector3:
	var forward: Vector3 = -body.basis.z
	var right: Vector3 = body.basis.x
	return (forward * input_dir.y + right * input_dir.x).normalized()

 
func get_target_speed() -> float:
	if sprint_action and Input.is_action_pressed(sprint_action):
		return sprint_speed
	
	return walk_speed
 
 
func accelerate(direction: Vector3, target_speed: float, accel: float, delta: float):
	var current_horiz: Vector3 = Vector3(body.velocity.x, 0, body.velocity.z)
	var target_vel: Vector3 = direction * target_speed
	var diff: Vector3 = target_vel - current_horiz
	
	if diff.length() > accel * delta:
		diff = diff.normalized() * accel * delta
	
	body.velocity.x += diff.x
	body.velocity.z += diff.z
 
 
func apply_friction(delta: float):
	var current_horiz: Vector3 = Vector3(body.velocity.x, 0, body.velocity.z)
	
	if current_horiz.length() < current_friction * delta:
		body.velocity.x = 0
		body.velocity.z = 0
	else:
		var drop: float = current_friction * delta
		body.velocity.x -= current_horiz.normalized().x * drop
		body.velocity.z -= current_horiz.normalized().z * drop
 
