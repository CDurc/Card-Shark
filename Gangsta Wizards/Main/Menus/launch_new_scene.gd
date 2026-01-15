extends Area3D

@export_file("*.tscn") var target_scene_path: String

func launch_scene():
	if target_scene_path.is_empty():
		push_warning("No target scene set")
		return

	SceneManager.go_to(SceneManager.SceneID.STORY_MODE)
