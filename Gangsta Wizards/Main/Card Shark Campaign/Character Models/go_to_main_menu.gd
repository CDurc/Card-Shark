extends Button

@export var new_scene: PackedScene
@onready var chip = $Chip


func _on_pressed() -> void:
	if new_scene:
		get_tree().paused = false
		get_tree().change_scene_to_packed(new_scene)

func _on_mouse_entered() -> void: #hovered over
	chip.visible=true



func _on_mouse_exited() -> void:
	chip.visible=false
