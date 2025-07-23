extends Area3D

@export var new_scene: PackedScene

func launch_scene():
	if new_scene:
		get_tree().change_scene_to_packed(new_scene)
	else:
		print("No new scene avalible")
