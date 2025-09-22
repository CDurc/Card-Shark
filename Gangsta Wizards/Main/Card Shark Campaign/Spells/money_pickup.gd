extends Area3D

@export var value = 1
@onready var parent = $"../.."
@onready var player = get_tree().get_first_node_in_group("Player")

func _on_body_entered(body: Node3D) -> void:
	if body == player:
		body.money += value
		GameState.money += value
		print(GameState.money)
		parent.queue_free()
