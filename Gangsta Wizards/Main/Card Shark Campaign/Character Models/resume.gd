extends Button

@onready var pause_menu = $"../.."
@onready var chip = $Chip
@onready var crosshair = $"../../../Crosshair"

func _on_pressed() -> void:
	print("RESUME GAMBLING LETS GOOOOOOOOOOOOOO")
	get_tree().paused = false
	pause_menu.visible = false
	crosshair.visible = true



func _on_mouse_entered() -> void: #hovered over
	chip.visible=true



func _on_mouse_exited() -> void:
	chip.visible=false
