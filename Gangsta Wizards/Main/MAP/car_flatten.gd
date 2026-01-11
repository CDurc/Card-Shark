extends Area3D

@onready var player = get_tree().get_first_node_in_group("Player")
var car_direction



func _on_body_entered(body):
	if body == player:
		#car_direction = -(global_transform.basis.x.normalized())

		#player.trigger_ragdoll(200*(car_direction + Vector3.UP).normalized())
		#var horizontal_force = car_direction * 1000
		#var vertical_force = Vector3.UP * 1000
		
		#var launch_vector = (horizontal_force + vertical_force)
		#print("LAUNCH          ",launch_vector)
		player.call_deferred("flatten")
