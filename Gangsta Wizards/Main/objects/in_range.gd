extends Area3D

var enemy_list = []

func _on_body_entered(body):
	if body.is_in_group("Enemies"):
		enemy_list.append(body)
		print(enemy_list)

func _on_body_exited(body):
	if body.is_in_group("Enemies") and body in enemy_list:
		enemy_list.erase(body)
		print(enemy_list)
