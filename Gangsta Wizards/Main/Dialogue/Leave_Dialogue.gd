#Leave
extends Button

@onready var player = $"../../../.."


func _on_pressed() -> void:
	var NPC = player.current_NPC
	NPC.leave_dialogue()
