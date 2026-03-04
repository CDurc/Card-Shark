extends Area3D

@onready var loading = $"../../../GUI/CanvasLayer/LoadingScreen"

@export_file("*.tscn") var target_scene_path: String

func launch_scene():
	if target_scene_path.is_empty():
		push_warning("No target scene set")
		return

	loading.visible = true
	await get_tree().process_frame
	await get_tree().process_frame
	SceneManager.go_to(SceneManager.SceneID.STORY_MODE)
