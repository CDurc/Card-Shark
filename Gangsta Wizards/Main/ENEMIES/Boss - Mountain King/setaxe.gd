extends Node3D

@onready var rig = $RigidBody3D
@onready var col1 = $RigidBody3D/CollisionShape3D
@onready var col2 = $RigidBody3D/CollisionShape3D2
@onready var hitbox = $RigidBody3D/Hitbox
@onready var start_transform = transform

var spinning = false

func reset_transform():
	transform = start_transform
	rig.rotation_degrees.z = 0

func monitor(stat:bool):
	hitbox.monitoring = stat
	

func set_axe():
	visible = true
	#rig.freeze = false
	col1.disabled = false
	col2.disabled = false

func unset_axe():
	visible = false
	#rig.freeze = true
	col1.disabled = true
	col2.disabled = true

	
func _process(delta: float) -> void:
	if spinning:
		rig.rotation_degrees.z += 4000*delta
