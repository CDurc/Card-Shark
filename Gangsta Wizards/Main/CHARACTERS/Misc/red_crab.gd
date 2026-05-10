#Crab goin around
extends CharacterBody3D
@export var speed: float = 2.0
@export var gravity: float = 9.8
@export var turn_speed: float = 4.0
@export var stuck_threshold: float = 0.5
@export var stuck_distance_threshold: float = 0.3
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anime: AnimationPlayer = $CrabModel/AnimationPlayer
@onready var collider = $CollisionShape3D
@export var NPC_goals: Node3D

var current_goal = null
var state: String = "idle"
var jump_force = 4
var is_jumping = false

# Stuck detection
var last_position: Vector3 = Vector3.ZERO
var time_since_moved: float = 0.0

func _ready():
	last_position = global_position
	consult_goals()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if not is_jumping:
			velocity.y = 0
		is_jumping = false

	if state == "walking":
		anime.play("Walking")
		check_if_stuck(delta)
		move_along_path(delta)
		if nav_agent.is_navigation_finished():
			velocity.x = 0
			velocity.z = 0
			move_and_slide()
			if current_goal != null and current_goal["action"] != null:
				state = "turning_to_task"
				call_deferred("_delayed_task_runner", 0.5, current_goal)
			else:
				finish_goal()

	if state == "turning_to_task" and current_goal != null:
		var target = NPC_goals.get_node(current_goal["path"]).get_child(0)
		var flat_dir = Vector3(target.global_position.x - global_position.x, 0, target.global_position.z - global_position.z)
		if flat_dir.length() > 0.01:
			var current_yaw = rotation.y
			var desired_yaw = atan2(flat_dir.x, flat_dir.z)
			rotation.y = lerp_angle(current_yaw, desired_yaw, turn_speed * delta)

	move_and_slide()

# Called when the crab self-decides to go do something
func consult_goals():
	var goals = NPC_goals.goals  # however you're accessing the goals script
	var available = goals.filter(func(g): return g["open"])
	if available.size() == 0:
		state = "idle"
		return
	# Pick one — first available for now, could be random or weighted later
	var chosen = available[randi() % available.size()]
	claim_goal(chosen)

func claim_goal(goal: Dictionary):
	goal["open"] = false
	goal["assignedTo"] = name
	current_goal = goal
	move_to(NPC_goals.get_node(goal["path"]).global_position)

func finish_goal():
	if current_goal != null:
		current_goal["assignedTo"] = null
		current_goal["open"] = false
		var old_goal = current_goal
		current_goal = null
		get_tree().create_timer(3.0).timeout.connect(func(): old_goal["open"] = true)
	state = "idle"
	await get_tree().create_timer(1.0).timeout
	consult_goals()

func check_if_stuck(delta: float):
	var distance_moved = global_position.distance_to(last_position)
	if distance_moved < stuck_distance_threshold * delta:
		time_since_moved += delta
		if time_since_moved >= stuck_threshold:
			jump()
			time_since_moved = 0.0
	else:
		time_since_moved = 0.0
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
	time_since_moved = 0.0

func rotate_toward_direction(direction: Vector3, delta: float):
	var flat_dir = Vector3(direction.x, 0, direction.z)
	if flat_dir.length() < 0.01:
		return
	var current_yaw = rotation.y
	var desired_yaw = atan2(flat_dir.x, flat_dir.z)
	rotation.y = lerp_angle(current_yaw, desired_yaw, turn_speed * delta)

func _delayed_task_runner(delay_time: float, goal) -> void:
	await get_tree().create_timer(delay_time).timeout
	if goal != current_goal:
		return
	state = "performing_task"
	await goal["action"].call(NPC_goals.get_node(goal["path"]), self)
	finish_goal()

func jump():
	if is_on_floor():
		velocity.y = jump_force
		is_jumping = true
