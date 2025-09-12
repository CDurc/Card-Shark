extends RigidBody3D

@onready var player = get_tree().get_first_node_in_group("Player")

func _on_body_entered(body):
	if not player:
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		freeze = true  # Stops the RigidBody
