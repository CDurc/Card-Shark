extends Area3D
var enemy_list = []
@onready var enemies = get_tree().current_scene.get_node("Enemies")

func _on_body_entered(body):
	if body.get_parent() == enemies:
		enemy_list.append(body)
		print(enemy_list)


func _on_body_exited(body):
	if body in enemy_list:
		enemy_list.erase(body)
		print(enemy_list)
