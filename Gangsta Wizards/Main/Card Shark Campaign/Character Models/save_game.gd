extends Button

@onready var pause_menu = $"../.."
@onready var chip = $Chip

func _on_pressed() -> void:
	print("SAVE GAME")
	#get_tree().paused = false
	#pause_menu.visible = false



func _on_mouse_entered() -> void: #hovered over
	chip.visible=true



func _on_mouse_exited() -> void:
	chip.visible=false
