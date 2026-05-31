extends Node3D

@onready var rig = $RigidBody3D
@onready var col1 = $RigidBody3D/CollisionShape3D
@onready var col2 = $RigidBody3D/CollisionShape3D2


func set_axe():
	visible = true
	rig.freeze = false
	col1.disabled = false
	col2.disabled = false
