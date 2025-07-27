extends Node3D

@export var new_scene: PackedScene

func _ready():
	await get_tree().create_timer(11.5).timeout
	get_tree().change_scene_to_packed(new_scene)
