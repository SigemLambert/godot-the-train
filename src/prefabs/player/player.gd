@icon("uid://b4gim56t7ug4b")
class_name Player3D
extends CharacterBody3D


@onready var camera: PlayerCamera3D = %Camera
@onready var movement: PlayerMovementController = %Controller
@onready var collider: CollisionShape3D = %Collider
@onready var interactor: PlayerInteractor3D = %Interactor
