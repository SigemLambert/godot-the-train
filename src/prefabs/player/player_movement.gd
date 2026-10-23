@icon("uid://mhfmwvqocaq6")
class_name PlayerMovementController
extends Node


@export var body: CharacterBody3D
@export_group("Speed", "speed")
@export var speed_walk: float = 5.0
@export var speed_sprint: float = 7.5
@export var speed_jump_velocity: float = 5.0
 
@export_group("Physics")
@export_subgroup("Acceleration")
@export var acceleration: float = 10.0
@export var air_acceleration: float = 2.0
@export_subgroup("Friction")
@export var friction: float = 8.0
@export var air_friction: float = 0.5
 
@export_group("Controls", "action")
@export var action_jump: String = "ui_accept"
@export var action_sprint: String = ""
@export_subgroup("Move", "action_move")
@export var action_move_forward: String = "ui_up"
@export var action_move_backward: String = "ui_down"
@export var action_move_left: String = "ui_left"
@export var action_move_right: String = "ui_right"

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
	if action_jump and Input.is_action_just_pressed(action_jump):
		body.velocity.y = speed_jump_velocity
 
 
func handle_movement(delta: float, grounded: bool):
	var input_dir: Vector2 = get_input_direction()
	
	if input_dir == Vector2.ZERO:
		apply_friction(delta)
		return
	
	var direction: Vector3 = get_movement_direction(input_dir)
	var target_speed: float = get_target_speed()
	var accel: float = acceleration if grounded else air_acceleration
	
	cancel_perpendicular_velocity(direction)
	accelerate(direction, target_speed, accel, delta)
 
 
func get_input_direction() -> Vector2:
	var forward: float = (
		(Input.get_action_strength(action_move_forward) if action_move_forward else 0.0) -
		(Input.get_action_strength(action_move_backward) if action_move_backward else 0.0)
		)
	var right: float = (
		(Input.get_action_strength(action_move_right) if action_move_right else 0.0) -
		(Input.get_action_strength(action_move_left) if action_move_left else 0.0)
		)
	return Vector2(right, forward)
 
 
func get_movement_direction(input_dir: Vector2) -> Vector3:
	var forward: Vector3 = -body.basis.z
	var right: Vector3 = body.basis.x
	return (forward * input_dir.y + right * input_dir.x).normalized()


func cancel_perpendicular_velocity(direction: Vector3):
	var current_horiz: Vector3 = Vector3(body.velocity.x, 0, body.velocity.z)
	var parallel: float = current_horiz.dot(direction)
	var parallel_vel: Vector3 = direction * parallel
	var perpendicular: Vector3 = current_horiz - parallel_vel
	
	body.velocity.x -= perpendicular.x
	body.velocity.z -= perpendicular.z

 
func get_target_speed() -> float:
	if action_sprint and Input.is_action_pressed(action_sprint):
		return speed_sprint
	return speed_walk
 
 
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
 
