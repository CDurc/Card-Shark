extends Node3D

@export var rotation_speed = 2.0
@export var rotation_goal = -110

var target_open_rotation: Quaternion
var target_closed_rotation: Quaternion
var opening = false
var closing = false
var player
var interact
var inside = false
var closed = true
var open = false
var rotation_t = 0.0

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	print ("player found:",player)
	
	var initial_quat: Quaternion = global_transform.basis.get_rotation_quaternion()
	var move_quat = Quaternion(Vector3.UP, deg_to_rad(rotation_goal))
	
	# Set the target rotation
	target_open_rotation = initial_quat * move_quat
	target_closed_rotation = initial_quat

func _process(delta):
	if opening:
		# Get current rotation as a Quaternion
		var current_quat: Quaternion = global_transform.basis.get_rotation_quaternion()
		
		# Slerp from stored start rotation to target_open_rotation using rotation_t
		var new_quat: Quaternion = target_closed_rotation.slerp(target_open_rotation, rotation_t)
		
		# Apply the new rotation
		global_transform.basis = Basis(new_quat)
		
		# Increase rotation_t
		rotation_t += (1.0 - (rotation_t / 1.05)) * 2 * delta #/1.05 ensures it doesn't get TOO slow at the end
		if rotation_t > 1.0:
			rotation_t = 1.0
		
		#Stop door
		if current_quat.dot(target_open_rotation) > 0.9999:
			opening = false
			open = true
			print("Door open")
			rotation_t = 0
			global_transform.basis = Basis(target_open_rotation) #snap to target
			if inside == true:
				interact.visible = true
			
	if closing:
		# Get current rotation as a Quaternion
		var current_quat: Quaternion = global_transform.basis.get_rotation_quaternion()
		
		# Slerp from stored start rotation to target_closed_rotation using rotation_t
		var new_quat: Quaternion = target_open_rotation.slerp(target_closed_rotation, rotation_t)
		
		# Apply the new rotation
		global_transform.basis = Basis(new_quat)
		
		# Increase rotation_t
		rotation_t += (1.0 - (rotation_t / 1.05)) * 2 * delta
		if rotation_t > 1.0: #Prevent overshooting
			rotation_t = 1.0
		
		# Stop door
		if current_quat.dot(target_closed_rotation) > 0.9999:
			closing = false
			closed = true
			print("Door closed")
			rotation_t = 0
			global_transform.basis = Basis(target_closed_rotation) #snap to target
			if inside == true:
				interact.visible = true
			
	if inside and player and player.interact(): #F was pressed
		print("F")
		if closed:
			closed = false
			opening = true
			interact.visible = false
		elif open:
			open = false
			closing = true
			interact.visible = false
		
func interac():
	print("intaxionned")
	if closed:
		closed = false
		opening = true
		#interact.visible = false
		print("opening")
	elif open:
		open = false
		closing = true
		#interact.visible = false
		print("closing")
