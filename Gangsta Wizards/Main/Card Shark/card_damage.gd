extends Area3D

@export var damage: float
var enemy_list = []
#@onready var player = get_tree().get_first_node_in_group("Player")



func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Enemies") and body not in enemy_list:
		enemy_list.append(body)
		body.damage(damage)
