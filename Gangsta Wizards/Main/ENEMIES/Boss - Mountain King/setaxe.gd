extends Node3D

@onready var rig = $MtKingAxe/RigidBody3D
@onready var col1 = $MtKingAxe/RigidBody3D/CollisionShape3D
@onready var col2 = $MtKingAxe/RigidBody3D/CollisionShape3D2


func set_axe():
	visible = true
	rig.freeze = false
	col1.disabled = false
	col2.disabled = false
