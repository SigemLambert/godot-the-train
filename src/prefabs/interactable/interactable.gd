@icon("uid://6hw5ppt8sun7")
class_name Interactable3D
extends StaticBody3D


signal interaction_started()
signal interaction_stopped()


@export var enabled: bool = true

var interaction_active: bool


func _on_interact_started() -> bool: return true
func _on_interact_active(_delta: float): pass
func _on_interact_stopped(): pass


func _process(delta: float):
	if enabled and interaction_active:
		_on_interact_active(delta)


func interact() -> bool:
	if interaction_start():
		interaction_stop()
		return true
	return false


func interaction_start() -> bool:
	if enabled and _on_interact_started():
		interaction_active = true
		interaction_started.emit()
		return true
	return false


func interaction_stop():
	if enabled:
		_on_interact_stopped()
		interaction_active = false
		interaction_stopped.emit()
