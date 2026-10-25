@icon("uid://bepy4wkd816xj")
class_name PlayerInteractor3D
extends RayCast3D


signal hovered(interactable: Interactable3D)
signal unhovered(interactable: Interactable3D)
signal interaction_started(interactable: Interactable3D)
signal interaction_released(interactable: Interactable3D)

@export_group("Controls", "action")
@export var action_interact: String = "ui_accept"

var target: Interactable3D:
	set(value):
		if value == target:
			return
		if target:
			unhovered.emit(target)
		target = value
		if target:
			hovered.emit(target)
var interaction_down: bool


func _physics_process(_delta: float):
	if enabled and not interaction_down:
		target = get_collider() as Interactable3D


func _input(event: InputEvent):
	if not enabled:
		return
	
	if event.is_action_pressed(action_interact):
		if target and not interaction_down:
			interaction_down = true
			target.interaction_start()
			interaction_started.emit(target)
		return
	
	if event.is_action_released(action_interact):
		if target and interaction_down:
			interaction_down = false
			target.interaction_stop()
			interaction_released.emit(target)
		return
