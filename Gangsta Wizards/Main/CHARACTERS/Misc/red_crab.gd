#Crab goin around
extends CharacterBody3D

@export var speed: float = 8.0
@export var gravity: float = 9.8
@export var turn_speed: float = 4.0
@export var stuck_threshold: float = 0.5  # How long before considering "stuck"
@export var stuck_distance_threshold: float = 0.3  # Minimum movement to not be stuck

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anime: AnimationPlayer = $CrabModel/AnimationPlayer
@onready var collider = $CollisionShape3D

var goal_task_queue: Array = []
var current_goal_task = null
var state: String = "idle"
var jump_force = 4

# Stuck detection variables
var last_position: Vector3 = Vector3.ZERO
var time_since_moved: float = 0.0

func _ready():
	last_position = global_position

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	# Walk toward goal
	if state == "walking":
		anime.play("Walking")
		
		# Stuck detection
		check_if_stuck(delta)
		
		move_along_path(delta)
		if nav_agent.is_navigation_finished():
			velocity.x = 0
			velocity.z = 0
			move_and_slide()
			if current_goal_task != null and current_goal_task["task"] != null:
				state = "turning_to_task"
				call_deferred("_delayed_task_runner", 0.5, current_goal_task)

	# Gradual turning instead of instant
	if state == "turning_to_task" and current_goal_task != null:
		var target = current_goal_task["goal"].get_child(0)
		var flat_dir = Vector3(target.global_position.x - global_position.x, 0, target.global_position.z - global_position.z)
		if flat_dir.length() > 0.01:
			var current_yaw = rotation.y
			var desired_yaw = atan2(flat_dir.x, flat_dir.z)
			rotation.y = lerp_angle(current_yaw, desired_yaw, turn_speed * delta)

	move_and_slide()

func check_if_stuck(delta: float):
	var distance_moved = global_position.distance_to(last_position)
	
	if distance_moved < stuck_distance_threshold * delta:
		time_since_moved += delta
		if time_since_moved >= stuck_threshold:
			print("Stuck! Jumping...")
			jump()
			time_since_moved = 0.0  # Reset timer
	else:
		time_since_moved = 0.0  # Reset if we're moving
	
	last_position = global_position

func move_along_path(delta):
	if nav_agent.is_navigation_finished():
		velocity.x = 0
		velocity.z = 0
		return
	var next_pos: Vector3 = nav_agent.get_next_path_position()
	var direction: Vector3 = (next_pos - global_position).normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	rotate_toward_direction(direction, delta)

func move_to(target_pos: Vector3):
	nav_agent.target_position = target_pos
	state = "walking"
	time_since_moved = 0.0  # Reset stuck timer when starting new movement

func rotate_toward_direction(direction: Vector3, delta: float):
	var flat_dir = Vector3(direction.x, 0, direction.z)
	if flat_dir.length() < 0.01:
		return
	var current_yaw = rotation.y
	var desired_yaw = atan2(flat_dir.x, flat_dir.z)
	rotation.y = lerp_angle(current_yaw, desired_yaw, turn_speed * delta)


func start_next_goal_task():
	if goal_task_queue.size() == 0:
		state = "idle"
		current_goal_task = null
		print("gourdling is out of tasks")
		return
	current_goal_task = goal_task_queue.pop_front()
	#if not underground: #If underground, no need to move
	move_to(current_goal_task["goal"].global_position)

func _delayed_task_runner(delay_time: float, goal_task) -> void:
	await get_tree().create_timer(delay_time).timeout
	if goal_task != current_goal_task:
		return
	state = "performing_task"
	await goal_task["task"].call(goal_task["goal"])



func jump():
	if is_on_floor():
		velocity.y = jump_force
