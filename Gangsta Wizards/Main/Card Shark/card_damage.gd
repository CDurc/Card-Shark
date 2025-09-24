extends Area3D

@export var damage: float
@onready var Root = $"../.."
#@onready var player = get_tree().get_first_node_in_group("Player")



func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Enemies"):
		body.damage(damage)
		Root.queue_free()
		print("CARD HIT ENEMY")
