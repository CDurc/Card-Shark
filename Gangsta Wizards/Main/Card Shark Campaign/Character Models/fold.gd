extends Button

@onready var chip = $Chip

func _on_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_mouse_entered() -> void: #hovered over
	chip.visible=true

func _on_mouse_exited() -> void:
	chip.visible=false
