extends Button

@export var button_number: int

@onready var player = $"../../../.."


func _on_pressed() -> void:
	var NPC = player.current_NPC
	NPC.select_option(button_number)
