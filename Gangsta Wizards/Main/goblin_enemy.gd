extends CharacterBody3D

@export var follow_distance = 4
@export var follow_speed = 2.0
@export var gravity_strength = 20.0

var player

func _ready():
	# Find the first node in group "Player"
	player = get_tree().get_first_node_in_group("Player")
	print("Found player:", player)

func _physics_process(delta):
	if not player:
		return

	# -- 1) Apply gravity to velocity.y
	velocity.y -= gravity_strength * delta

	# If on the floor, reset vertical velocity to avoid sinking
	if is_on_floor():
		velocity.y = 0

	# -- 2) Check distance to player, handle horizontal follow
	var my_pos = global_transform.origin
	var player_pos = player.global_transform.origin
	var dist_to_player = my_pos.distance_to(player_pos)

	if dist_to_player < follow_distance:
		# Normalize direction toward player
		var direction = (player_pos - my_pos).normalized()
		# Update only x and z; keep y for gravity
		velocity.x = direction.x * follow_speed
		velocity.z = direction.z * follow_speed
	else:
		velocity.x = 0
		velocity.z = 0

	# -- 3) Move and slide (Godot 4 automatically uses 'velocity')
	# This returns a bool: true if on floor after moving, false otherwise.
	var on_floor_after = move_and_slide()
	# Optional: do something if we landed on the floor
	# if on_floor_after:
	#     print("Enemy on floor now!")
