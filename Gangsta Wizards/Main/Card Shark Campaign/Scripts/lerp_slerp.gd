extends Node

class_name TransformUtils

static func lerp_slerp_to_target(
		moving_node: Node3D,
		target_node: Node3D,
		move_speed: float,
		rotate_speed: float,
		delta: float
	) -> void:
	
	var from_pos = moving_node.global_transform.origin
	var to_pos = target_node.global_transform.origin
	var new_pos = from_pos.lerp(to_pos, move_speed * delta)
	
	var from_rot = moving_node.global_transform.basis.get_rotation_quaternion()
	var to_rot = target_node.global_transform.basis.get_rotation_quaternion()
	var new_rot = from_rot.slerp(to_rot, rotate_speed * delta)
	
	moving_node.global_transform = Transform3D(Basis(new_rot), new_pos)
