extends Node

class_name TransformUtils

static func lerp_slerp_transform( #Lerps and Slerps anything given a target pos
		moving_node: Node3D,
		target_transform: Transform3D,
		move_speed: float,
		rotate_speed: float,
		delta: float
	) -> void:
	
	var from_pos = moving_node.global_transform.origin
	var to_pos = target_transform.origin
	var new_pos = from_pos.lerp(to_pos, move_speed * delta)
	
	var from_rot = moving_node.global_transform.basis.get_rotation_quaternion()
	var to_rot = target_transform.basis.get_rotation_quaternion()
	var new_rot = from_rot.slerp(to_rot, rotate_speed * delta)
	
	moving_node.global_transform = Transform3D(Basis(new_rot), new_pos)

static func lerp_slerp_node( #Lerps and Slerps anything given two nodes
		moving_node: Node3D,
		target_node: Node3D,
		move_speed: float,
		rotate_speed: float,
		delta: float
	) -> void:
		ramped_lerp_slerp_transform(moving_node, target_node.global_transform, move_speed, rotate_speed, delta)


static func ramped_lerp_slerp_transform( #Lerps and slerps, ramped
	moving_node: Node3D,
	target_transform: Transform3D,
	base_speed: float,
	ramp_factor: float,
	delta: float,
	snap_threshold: float = 0.001
) -> void:
	var from_pos = moving_node.global_transform.origin
	var to_pos = target_transform.origin
	var distance = from_pos.distance_to(to_pos)

	# Ramp interpolation factor: increases when farther away
	var interp_amount = min(1.0, base_speed * (1.0 + ramp_factor * distance) * delta)
	var new_pos = from_pos.lerp(to_pos, interp_amount)

	var from_rot = moving_node.global_transform.basis.get_rotation_quaternion()
	var to_rot = target_transform.basis.get_rotation_quaternion()
	var new_rot = from_rot.slerp(to_rot, interp_amount)

	var final_transform = Transform3D(Basis(new_rot), new_pos)

	if distance < snap_threshold and from_rot.angle_to(to_rot) < snap_threshold:
		moving_node.global_transform = target_transform
	else:
		moving_node.global_transform = final_transform


static func new_lerp_slerp_transform(
	moving_node: Node3D,
	target_transform: Transform3D,
	base_move_speed: float,
	move_ramp_factor: float,
	base_rot_speed: float,
	rot_ramp_factor: float,
	delta: float,
	snap_threshold: float = 0.01
) -> void:
	# --- Position ramping ---
	var from_pos = moving_node.global_transform.origin
	var to_pos = target_transform.origin
	var distance = from_pos.distance_to(to_pos)

	var move_interp = base_move_speed * (1.0 + move_ramp_factor * distance) * delta
	move_interp = clamp(move_interp, 0.1, 1.0)  # Prevent slow motion crawl
	var new_pos = from_pos.lerp(to_pos, move_interp)

	# --- Rotation ramping ---
	var from_rot = moving_node.global_transform.basis.get_rotation_quaternion()
	var to_rot = target_transform.basis.get_rotation_quaternion()
	var angle = from_rot.angle_to(to_rot)

	var rot_interp = base_rot_speed * (1.0 + rot_ramp_factor * angle) * delta
	rot_interp = clamp(rot_interp, 0.1, 1.0)  # Prevent ultra slow spin
	var new_rot = from_rot.slerp(to_rot, rot_interp)

	# --- Apply new transform ---
	var new_basis = Basis(new_rot)
	var final_transform = Transform3D(new_basis, new_pos)

	# Snap if very close to prevent jitter / lingering
	if distance < snap_threshold and angle < deg_to_rad(1.0):
		moving_node.global_transform = target_transform
	else:
		moving_node.global_transform = final_transform
