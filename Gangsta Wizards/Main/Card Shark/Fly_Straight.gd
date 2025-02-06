extends Node


# Called when the node enters the scene tree for the first time.
func straight_fly_cards_real(delta, instance):
	if straight_laser_cooldown.time_left <= 0:
		return

	# Lerp + slerp each card toward its "T#"
	for i in range(1, 6):
		var card = instance.get_node("C%d" % i)
		var target = instance.get_node("Target").get_node("T%d" % i)

		# Local transforms (relative to "Card")
		var from_transform = card.transform
		var to_transform   = target.transform

		# Lerp position
		var new_origin = from_transform.origin.lerp(to_transform.origin, 4 * delta)

		# Slerp rotation
		var from_quat = from_transform.basis.orthonormalized().get_rotation_quaternion()
		var to_quat   = to_transform.basis.orthonormalized().get_rotation_quaternion()
		var new_quat  = from_quat.slerp(to_quat, 4 * delta)

		card.transform = Transform3D(Basis(new_quat), new_origin)

	# Rotate the "Target" node itself in local space using your original spin logic
	rot_speed = min(rot_speed + rot_acc * delta, rot_max_speed)
	var target_node = instance.get_node("Target")

	# Get the local rotation quaternion
	var current_rotation = target_node.transform.basis.get_rotation_quaternion()
	# Rotate around Z-axis by "delta"
	var rotation_delta = Quaternion(Vector3(0, 0, 1), delta)
	# Slerp for that smooth ramp-up effect
	var new_rotation = current_rotation.slerp(rotation_delta * current_rotation, rot_speed)

	target_node.transform.basis = Basis(new_rotation)
