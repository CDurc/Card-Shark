#Ambient Talking NPC Generic
extends CharacterBody3D
@export var speed: float = 2.0
@export var gravity: float = 9.8
@export var turn_speed: float = 4.0
@export var stuck_threshold: float = 0.5
@export var stuck_distance_threshold: float = 0.3
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var collider = $CollisionShape3D
@export var NPC_goals: Node3D
@export var anime: AnimationPlayer
@export var ambient_lines: Array[AudioStream] = []
@export var interact_lines: Array[AudioStream] = []
@onready var audio_player = $AudioStreamPlayer3D


### DIALOGUE STUFF ------------------
@onready var player = get_tree().get_first_node_in_group("Player")
var current_node_index: int = 0
### END DIALOGUE STUFF -------------


var current_goal = null
var state: String = "idle"
var jump_force = 4
var is_jumping = false
var talking_timer:float = 0.0

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

	elif state == "turning_to_task" and current_goal != null:
		var target = NPC_goals.get_node(current_goal["path"]).get_child(0)
		var flat_dir = Vector3(target.global_position.x - global_position.x, 0, target.global_position.z - global_position.z)
		if flat_dir.length() > 0.01:
			var current_yaw = rotation.y
			var desired_yaw = atan2(flat_dir.x, flat_dir.z)
			rotation.y = lerp_angle(current_yaw, desired_yaw, turn_speed * delta)

	elif state == "idle":
		#anime.play("Idle")
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

func _process(delta: float) -> void:
	if talking_timer > 0.0:
		talking_timer -= delta

# Called when the crab self-decides to go do something
func consult_goals():
	var goals = NPC_goals.goals  # however you're accessing the goals script
	var available = goals.filter(func(g): return g["open"])
	if available.size() == 0:
		state = "idle"
		print(name + " found no open goals.")
		return
	# Pick one — first available for now, could be random or weighted later
	var chosen = available[randi() % available.size()]
	claim_goal(chosen)

func claim_goal(goal: Dictionary):
	goal["open"] = false
	goal["assignedTo"] = name
	current_goal = goal
	move_to(NPC_goals.get_node(goal["path"]).global_position)
	print(name + " claimed goal " + str(goal["id"]))

func finish_goal():
	if current_goal != null:
		current_goal["assignedTo"] = null
		current_goal["open"] = false
		var old_goal = current_goal
		current_goal = null
		get_tree().create_timer(3.0).timeout.connect(func(): old_goal["open"] = true)
	state = "idle"
	print(name + " finished their goal.")
	await get_tree().create_timer(1.0).timeout
	consult_goals()

var interrupted_goal = null

func interrupt():
	nav_agent.target_position = global_position
	velocity.x = 0
	velocity.z = 0
	state = "idle"

func interrupt_with_new_goal(new_goal):
	interrupted_goal = current_goal
	current_goal = new_goal
	nav_agent.target_position = NPC_goals.get_node(new_goal["path"]).global_position
	state = "walking"

func resume_goal():
	if interrupted_goal != null:
		current_goal = interrupted_goal
		interrupted_goal = null
	if current_goal != null:
		nav_agent.target_position = NPC_goals.get_node(current_goal["path"]).global_position
		state = "walking"
	else:
		finish_goal()

func check_if_stuck(delta: float):
	var distance_moved = global_position.distance_to(last_position)
	if distance_moved < stuck_distance_threshold * delta:
		time_since_moved += delta
		if time_since_moved >= stuck_threshold:
			print("Stuck! Jumping...")
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
	print("jump attempt")
	if is_on_floor():
		print("jumped")
		velocity.y = jump_force
		is_jumping = true


func interac():
	rand_int_line()

func rand_int_line():
	audio_player.stream = interact_lines[randi() % interact_lines.size()]
	audio_player.play()
	print("GARY RAND VOICE LINE INTED")


func rand_ambient_line():
	audio_player.stream = ambient_lines[randi() % ambient_lines.size()]
	audio_player.play()

func _on_ambient_range_body_entered(body: Node3D) -> void:
	if body == player:
		print("player in range")
		var rand_i = randi_range(0,1)
		if rand_i == 1 and talking_timer <= 0:
			talking_timer = 10.0
			print("AMBIENT LINE GO")
			rand_ambient_line()
