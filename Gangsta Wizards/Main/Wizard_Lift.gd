extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		for g in range(0,15):
			body.gravity = -9.8
			await get_tree().create_timer(0.3).timeout
