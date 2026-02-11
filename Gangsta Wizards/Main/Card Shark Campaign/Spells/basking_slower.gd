extends Area3D

func _on_body_entered(body):
	if body.is_in_group("Enemies") and "speed" in body:
		body.speed /= 2
		print("bro got slowed")

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Enemies") and "speed" in body:
		body.speed *= 2
		print("return lil bro")

func _on_parent_deleting():
	for body in get_overlapping_bodies():
		if body.is_in_group("Enemies") and "speed" in body:
			body.speed *= 2
			print("parent deleted, restoring speed")
