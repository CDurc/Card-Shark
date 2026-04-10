#Talking NPC Generic
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


### DIALOGUE STUFF ------------------
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var d_control = player.get_node("HUD/Bottombar/Dialogue")
@onready var cursor = player.get_node("HUD/Crosshair")
@onready var interact_UI = player.get_node("HUD/Interact")
@onready var cam = player.get_node("Head/Camera")
@onready var cam_goal = $Cam0
@onready var box0 = d_control.get_node("0")
@onready var box1 = d_control.get_node("1")
@onready var box2 = d_control.get_node("2")
@onready var response_text = d_control.get_node("Text/Label")
@export var dialogue_tree: DialogueTree
var current_node_index: int = 0
var old_cam_rot
var old_cam_pos
var in_dialogue: = false
### END DIALOGUE STUFF -------------


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
	while in_dialogue:  #Stuck until no longer in dialouge
		await get_tree().create_timer(0.5).timeout
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


### DIALOGUE STUFF ---------------------
func interac():
	if not in_dialogue:
		interrupt()
		in_dialogue = true
		current_node_index = 0
		enter_dialogue_mode()

func enter_dialogue_mode():
	print("Entering d")
	player.current_NPC = self
	GameState.current_mode = GameState.GameMode.DIALOGUE
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	cursor.visible = false
	interact_UI.visible = false
	

	old_cam_pos = cam.global_position
	old_cam_rot = cam.global_rotation

	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(cam, "global_position", cam_goal.global_position, 1.0)
	tween.tween_property(cam, "global_rotation", cam_goal.global_rotation, 1.0)

	d_control.visible = true
	display_node(current_node_index)

func display_node(index: int):
	var node: DialogueNode = dialogue_tree.nodes[index]
	#print(node.text)
	response_text.text = node.text
	box0.text = node.options[0] if node.options.size() > 0 else ""
	box1.text = node.options[1] if node.options.size() > 1 else ""
	box2.text = node.options[2] if node.options.size() > 2 else ""

func select_option(option: int):
	var node: DialogueNode = dialogue_tree.nodes[current_node_index]
	if option >= node.options_goto.size():
		return

	var prop = node.options_check_property[option] if node.options_check_property.size() > option else ""
	var method = node.options_call_method[option] if node.options_call_method.size() > option else ""

	if prop != "":
		var player_val = player.get(prop)
		var required = node.options_check_value[option]
		if player_val is bool:
			if player_val != (required == 1):
				current_node_index = node.options_fail_goto[option]
				display_node(current_node_index)
				return
		else:
			if player_val < required:
				current_node_index = node.options_fail_goto[option]
				display_node(current_node_index)
				return

	# Only reached if check passed (or no check)
	if method != "":
		call(method)

	current_node_index = node.options_goto[option]
	display_node(current_node_index)
	
func leave_dialogue():
	print("Leaving d")
	#player.current_NPC = nil
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	d_control.visible = false
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(cam, "global_position", old_cam_pos, 1.0)
	tween.tween_property(cam, "global_rotation", old_cam_rot, 1.0)
	await tween.finished
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	resume_goal()
	cursor.visible = true
	GameState.current_mode = GameState.GameMode.GAMEPLAY
	in_dialogue = false

func give_key():
	player.has_key = true
	print("Key given")

func use_key():
	print("key used")
	player.has_key = false
