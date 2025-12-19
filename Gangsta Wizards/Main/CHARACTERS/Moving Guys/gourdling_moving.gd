extends CharacterBody3D

@export var speed: float = 8.0
@export var gravity: float = 9.8
@export var turn_speed: float = 3.0
@export var punch_delay: float = 2.0  # seconds to wait after starting turn

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var Gen_anime: AnimationPlayer = $Gourdling2/GenAnime

var goal_task_queue: Array = []
var current_goal_task = null
var state: String = "idle"

func _ready():
	# Each goal-task is a single unit
	goal_task_queue.append({"goal": $"../Gourd Goals/Bush Puncher", "task": Callable(self, "punch_task")})
	goal_task_queue.append({"goal": $"../Gourd Goals/AnotherGoal", "task": Callable(self, "some_other_task")})
	start_next_goal_task()

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	# Walk toward goal
	if state == "walking":
		move_along_path(delta)
		if nav_agent.is_navigation_finished():
			velocity.x = 0
			velocity.z = 0
			move_and_slide()
			if current_goal_task != null and current_goal_task["task"] != null:
				state = "turning_to_task"
				start_task_after_delay(punch_delay)

	# Gradual turning toward task target while in turning_to_task
	if state == "turning_to_task" and current_goal_task != null:
		var target = current_goal_task["goal"].get_child(0)
		var flat_dir = Vector3(target.global_position.x - global_position.x, 0, target.global_position.z - global_position.z)
		if flat_dir.length() > 0.01:
			var current_yaw = rotation.y
			var desired_yaw = atan2(flat_dir.x, flat_dir.z)
			rotation.y = lerp_angle(current_yaw, desired_yaw, turn_speed * delta)

	move_and_slide()

# -----------------------
# Movement helpers
# -----------------------
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

func rotate_toward_direction(direction: Vector3, delta: float):
	var flat_dir = Vector3(direction.x, 0, direction.z)
	if flat_dir.length() < 0.01:
		return
	var current_yaw = rotation.y
	var desired_yaw = atan2(flat_dir.x, flat_dir.z)
	rotation.y = lerp_angle(current_yaw, desired_yaw, turn_speed * delta)

# -----------------------
# Task flow
# -----------------------
func start_next_goal_task():
	if goal_task_queue.size() == 0:
		state = "idle"
		current_goal_task = null
		return
	current_goal_task = goal_task_queue.pop_front()
	move_to(current_goal_task["goal"].global_position)

func start_task_after_delay(delay_time: float) -> void:
	if current_goal_task == null or current_goal_task["task"] == null:
		return
	call_deferred("_delayed_task_runner", delay_time, current_goal_task)

func _delayed_task_runner(delay_time: float, goal_task) -> void:
	await get_tree().create_timer(delay_time).timeout
	if goal_task != current_goal_task:
		return
	state = "performing_task"
	await goal_task["task"].call(goal_task["goal"])

# -----------------------
# Example task: punch
# -----------------------
func punch_task(goal_node: Node3D) -> void:
	var target = goal_node.get_child(0)
	# Continue facing target (gradual turn already done)
	
	# First punch
	Gen_anime.play("Punch")
	await get_tree().create_timer(3).timeout
	
	# Second punch
	Gen_anime.play("Punch")
	await get_tree().create_timer(1).timeout
	
	# After task, move to next goal-task
	start_next_goal_task()

# Example placeholder for another task
func some_other_task(goal_node: Node3D) -> void:
	await get_tree().create_timer(2).timeout
	start_next_goal_task()
