extends Button

@onready var pause_menu = $"../.."

func _on_pressed() -> void:
	print("RESUME GAMBLING LETS GOOOOOOOOOOOOOO")
	get_tree().paused = false
	pause_menu.visible = false
