extends RigidBody3D

@export var damage_amount: int = 10

func _ready() -> void:
	gravity_scale = 0.0

func _on_body_entered(body: Node) -> void:
	print(body)
	if body.has_method("damage"):
		body.damage(damage_amount)
	queue_free()  # delete bullet on hit
