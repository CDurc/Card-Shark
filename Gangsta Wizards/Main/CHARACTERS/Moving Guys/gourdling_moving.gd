extends CharacterBody3D

@export var speed := 8.0
@export var gravity: float

@onready var nav_agent = $NavigationAgent3D
@onready var goal = $"../Gourd Goals/Bush Puncher"


func _ready():
	await get_tree().create_timer(5).timeout
	move_to(goal.global_position)


func _physics_process(delta):
	# Gravity
	if is_on_floor():
		if velocity.y <= 0.0:
			velocity.y = 0.0
	else:
		velocity.y -= gravity * delta

	# Stop when path is done
	if nav_agent.is_navigation_finished():
		velocity = Vector3.ZERO
		move_and_slide()
		return

	# Navigation movement
	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# Rotate to face movement direction (yaw only)
	var flat_dir := Vector3(direction.x, 0.0, direction.z)
	if flat_dir.length() > 0.001:
		look_at(global_position + flat_dir, Vector3.UP)

	move_and_slide()


func move_to(world_position: Vector3):
	nav_agent.target_position = world_position
	
