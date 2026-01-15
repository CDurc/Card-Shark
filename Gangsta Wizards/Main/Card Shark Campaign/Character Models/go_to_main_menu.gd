extends Button

@onready var chip = $Chip

func _on_pressed() -> void:
	get_tree().paused = false
	SceneManager.go_to(SceneManager.SceneID.MAIN_MENU)

func _on_mouse_entered() -> void: #hovered over
	chip.visible=true

func _on_mouse_exited() -> void:
	chip.visible=false
