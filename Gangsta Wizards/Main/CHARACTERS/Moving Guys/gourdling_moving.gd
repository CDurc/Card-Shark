extends CharacterBody3D

@export var speed := 8.0

@onready var nav_agent = $NavigationAgent3D
@onready var goal = $"../Gourd Goals/Bush Puncher"


func _ready():
	#nav_agent.path_desired_distance = 0.2
	#nav_agent.target_desired_distance = 0.5
	await get_tree().create_timer(2).timeout
	move_to(goal.global_position)

func _physics_process(delta):
	if nav_agent.is_navigation_finished():
		velocity = Vector3.ZERO
		return

	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	move_and_slide()


func move_to(world_position: Vector3):
	nav_agent.target_position = world_position
