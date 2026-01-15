extends Node

enum SceneID {
	MAIN_MENU,
	STORY_MODE,
	MOUNTAIN_KING,
	MULTIPLAYER
}

var scenes := {
	SceneID.MAIN_MENU: "res://Menus/MAIN MENU SCENE.tscn",
	SceneID.STORY_MODE: "res://MAP/StoryMode.tscn",
	SceneID.MOUNTAIN_KING: "res://CardSharkGoblinDefense/Mountain King Survival.tscn",
	SceneID.MULTIPLAYER: "res://MULTIPLAYER/THE MULTIPLAYER MAP.tscn",
}

var is_changing := false

func go_to(id: SceneID):
	if is_changing:
		return
	is_changing = true
	get_tree().change_scene_to_file(scenes[id])
