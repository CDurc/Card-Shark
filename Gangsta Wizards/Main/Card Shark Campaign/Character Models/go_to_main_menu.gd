extends Button

@export var new_scene: PackedScene

func _on_pressed() -> void:
	if new_scene:
		get_tree().paused = false
		get_tree().change_scene_to_packed(new_scene)
