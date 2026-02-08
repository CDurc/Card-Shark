extends CharacterBody3D

@export var speed: float = 8.0
@export var gravity: float = 9.8
@export var turn_speed: float = 4.0
@export var stuck_threshold: float = 0.5  # How long before considering "stuck"
@export var stuck_distance_threshold: float = 0.3  # Minimum movement to not be stuck

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var Gen_anime: AnimationPlayer = $G/GenAnime
@onready var Leg_anime: AnimationPlayer = $G/LegAnime
@onready var Arm_anime: AnimationPlayer = $G/ArmAnime
@onready var collider = $CollisionShape3D

var goal_task_queue: Array = []
var current_goal_task = null
var state: String = "idle"
var jump_force = 4

var underground: = true

# Stuck detection variables
var last_position: Vector3 = Vector3.ZERO
var time_since_moved: float = 0.0

func _ready():
	last_position = global_position
	birth()

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	# Walk toward goal
	if state == "walking":
		Leg_anime.play("Sprint Lower")
		Arm_anime.play("Sprint Upper")
		
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

func fight_task(goal_node: Node3D) -> void:
	goal_node.set_meta("Occupied", true)
	var par = goal_node.get_parent()
	var children = par.get_children()
	
	while true:
		var all_occupied = true
		for child in children:
			if not child.get_meta("Occupied", false): #If occupied==false or if occupied doesnt exist
				all_occupied = false
				break
		if all_occupied:
			break
		await get_tree().process_frame
	print("All Children Occupied!")
	
	#self.reparent(goal_node)
	#await get_tree().process_frame
	#var other_gourd: Node
	#for child in children:
	#	if child != goal_node:
	#		other_gourd = child.get_child(1)
	#look_at(other_gourd.global_position)
	#self.global_rotation_degrees.y += 180
	var rand_delay = randf_range(0.1,0.3) #Slight delay to desync the punches
	await get_tree().create_timer(rand_delay).timeout
	#self.reparent($"..")
	punch_task(goal_node)


func punch_task(goal_node: Node3D) -> void:
	var task_time: float = float(current_goal_task["time"])
	var cycles: int = int(floor(task_time / 4.5))
	for i in range(cycles):
		await multi_punch()
	start_next_goal_task()


func multi_punch() -> void: #Multipunch takes 4.5 seconds on average
	var rand_len = randi_range(3,6)
	Gen_anime.speed_scale = 2.0
	Gen_anime.play("Punch")
	await get_tree().create_timer(rand_len).timeout
	Gen_anime.stop()
	await get_tree().create_timer(0.5).timeout


		

func die(goal_node: Node3D) -> void:
	await get_tree().create_timer(0.7).timeout
	Gen_anime.play("Death")

func sit(goal_node: Node3D) -> void:
	var old_ground_pos = global_position
	var old_ground_quat = global_transform.basis.get_rotation_quaternion() * Quaternion(Vector3.UP, PI)
	gravity = 0
	collider.disabled = true
	await get_tree().process_frame
	
	var target_position = goal_node.get_child(1).global_position
	var target_look_at = goal_node.get_child(0).global_position
	var direction = (target_look_at - target_position).normalized()
	var target_rotation_y = atan2(direction.x, direction.z)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", target_position, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_rotation:y", target_rotation_y, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	Gen_anime.play("Sit - Down")
	
	var task_time = current_goal_task["time"]
	var it_len = task_time / 10
	await get_tree().create_timer(1.5).timeout
	Gen_anime.play("Sit - Idle")
	await get_tree().create_timer(1.5).timeout
	for i in range(0,9):
		var anime_delay = randf_range(0.1, it_len)
		var remaining_it_len = it_len - anime_delay
		await get_tree().create_timer(anime_delay).timeout
		Gen_anime.play("Sit - Idle")
		await get_tree().create_timer(remaining_it_len).timeout
	print("Done sitting")
	
	var tween2 = create_tween()
	tween2.set_parallel(true)
	tween2.tween_property(self, "global_position", old_ground_pos, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween2.tween_property(self, "global_transform:basis", Basis(old_ground_quat), 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	Gen_anime.play("Sit - Up")
	await tween2.finished
	gravity = 9.8
	collider.disabled = false
	start_next_goal_task()
	

func some_other_task(goal_node: Node3D) -> void:
	await get_tree().create_timer(2).timeout
	start_next_goal_task()
	
func jump():
	if is_on_floor():
		velocity.y = jump_force
		
func open_door(goal_node: Node3D) -> void:  #Use when ENTERING buildings
	var door = current_goal_task["goal"].get_child(1)
	var target_position = current_goal_task["goal"].get_child(0).global_position
	if door.get_child(0).open == false:
		door.get_child(0).interac()
	await get_tree().create_timer(1).timeout
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_position, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	Leg_anime.play("Sprint Lower")
	Arm_anime.play("Sprint Upper")
	await tween.finished
	start_next_goal_task()
	await get_tree().create_timer(0.5).timeout
	if door.get_child(0).open == true:
		door.get_child(0).interac()
	

func open_door_exit(goal_node: Node3D) -> void:  #Use when EXITING buildings
	var door = current_goal_task["goal"].get_parent().get_child(1)
	var target_position = current_goal_task["goal"].get_parent().get_child(2).global_position
	if door.get_child(0).open == false:
		door.get_child(0).interac()
	await get_tree().create_timer(1).timeout
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_position, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	Leg_anime.play("Sprint Lower")
	Arm_anime.play("Sprint Upper")
	await tween.finished
	start_next_goal_task()
	await get_tree().create_timer(0.5).timeout
	if door.get_child(0).open == true:
		door.get_child(0).interac()
		
func sleep(goal_node: Node3D) -> void:
	var old_ground_pos = global_position
	var old_ground_quat = global_transform.basis.get_rotation_quaternion() * Quaternion(Vector3.UP, PI)
	gravity = 0
	collider.disabled = true
	await get_tree().process_frame
	
	var target_position = goal_node.get_child(1).global_position
	var target_look_at = goal_node.get_child(0).global_position
	var direction = (target_look_at - target_position).normalized()
	var target_rotation_y = atan2(direction.x, direction.z)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", target_position, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_rotation:y", target_rotation_y, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	Gen_anime.play("Lie Down - Down")
	
	var task_time = current_goal_task["time"]
	await get_tree().create_timer(1.5).timeout
	Gen_anime.speed_scale = 1.0
	Gen_anime.play("Lie Down - Idle") #set to loop
	await get_tree().create_timer(task_time).timeout
	print("Done sleeping")
	
	var tween2 = create_tween()
	tween2.set_parallel(true)
	tween2.tween_property(self, "global_position", old_ground_pos, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween2.tween_property(self, "global_transform:basis", Basis(old_ground_quat), 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	Gen_anime.play("Lie Down - Up")
	await tween2.finished
	gravity = 9.8
	collider.disabled = false
	start_next_goal_task()
	
func birth():
	print("birth")
	underground = false
	Gen_anime.play("Birth")
	Gen_anime.seek(0.0, true)  # Seeks to time 0.0, true = don't update immediately
	Gen_anime.pause()
	await get_tree().create_timer(2).timeout
	Gen_anime.play("Birth")
	await get_tree().create_timer(2).timeout
	start_next_goal_task()
