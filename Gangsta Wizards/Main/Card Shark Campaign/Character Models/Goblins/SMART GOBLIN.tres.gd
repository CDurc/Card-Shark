#SMART GOBLIN SCRIPT
extends CharacterBody3D

@export var speed:		float = 4.0		# horizontal move speed
@export var gravity:	float = 20.0	# downward acceleration
@export var target_path:	NodePath		# drag your Player node here

@onready var target:		Node3D = get_node(target_path)
@onready var nav_agent:	NavigationAgent3D = $NavigationAgent3D
@onready var healthbar = $Control/Healthbar/Helth
#@onready var initial_healthbar = healthbar.scale.x

#Durc
@export var follow_distance     = 10
@export var attack_distance     = 2
@export var follow_speed        = 2.0
@export var gravity_strength    = 20.0
@export var can_move            = true
@export var can_turn            = true
@export var damaging            = false
@export var health :int

@onready var initial_health = health #This HAS to be onready to recieve the export vars

#Jumping/Stuck
var last_position: Vector3
var stuck_timer: float = 0.0
var stuck_threshold_time: float = 1.0
var min_movement_threshold: float = 0.1
var jump_timer = 0.0
@export var jump_force: float = 9
var jumping = false
var was_stuck: bool = false


# Knockback state
var knockback_v   := Vector3.ZERO
var knockback_t   := 0.0

var player
var destroyed       := false
var attacking       = false


@onready var pipe           = $Goblin.get_node("Goblin Bones/Skeleton3D/HandContainer/Metal Pipe/Pipe")
@onready var current_color  = pipe.get_active_material(0).albedo_color
@onready var area3D         = $Goblin.get_node("Goblin Bones/Skeleton3D/HandContainer/Metal Pipe/Area3D")
@onready var damaged_bodies = area3D.damaged_bodies
@onready var monitor        = area3D.monitoring
@onready var a_anime          = $Goblin/ArmAnimation
@onready var l_anime          = $Goblin/LegAnimation


func _ready() -> void:
	if target == null:
		target = get_tree().get_first_node_in_group("Player")
	
	if target:
		nav_agent.target_position = target.global_transform.origin
	last_position = global_position


func _physics_process(delta: float) -> void:
	if not target:
		return
	
		# knockback has priority
	if knockback_t > 0.0:
		velocity = knockback_v
		move_and_slide()
		knockback_t -= delta
	elif can_move:
		

		if (target.global_transform.origin - nav_agent.target_position).length() > 0.15:
			nav_agent.target_position = target.global_transform.origin #Move towards player
			l_anime.play("Walking")
			
		if (target.global_transform.origin - global_transform.origin).length() < 1.25 and not attacking:
			attack()

		if nav_agent.is_navigation_finished():
			velocity.x = 0
			velocity.z = 0
		else:
			var next_point: Vector3 = nav_agent.get_next_path_position()
			var dir: Vector3 = next_point - global_transform.origin
			dir.y = 0
			dir = dir.normalized()

			if dir.length() > 0.01 and not jumping and can_move:
				look_at(global_transform.origin + dir, Vector3.UP)

			velocity.x = dir.x * speed
			velocity.z = dir.z * speed

		# ---- ALWAYS FACE THE PLAYER ----
		var face_dir: Vector3 = target.global_transform.origin - global_transform.origin
		face_dir.y = 0
		if face_dir.length() > 0.01 and not jumping and can_move:
			look_at(global_transform.origin + face_dir.normalized(), Vector3.UP)
		# --------------------------------

		# Gravity
		if is_on_floor():
			if velocity.y <= 0.0:
				velocity.y = 0
		else:
			velocity.y -= gravity * delta

		# Stuck detection
		var movement_distance = global_position.distance_to(last_position)
		last_position = global_position

		var actively_moving := not nav_agent.is_navigation_finished()
		var moving_enough   = movement_distance > min_movement_threshold * speed * delta

		if actively_moving and not moving_enough:
			stuck_timer += delta
		else:
			stuck_timer = 0.0
			was_stuck = false	# reset on movement or when idle at destination

		var stuck_too_long = stuck_timer >= stuck_threshold_time

		# Only jump once per genuine stuck event
		if stuck_too_long and is_on_floor() and not was_stuck and jump_timer <= 0.0:
			jump()
			jump_timer = 1.0
			was_stuck = true

		if jump_timer > 0.0:
			jump_timer -= delta

		move_and_slide()

func jump():
	#jumping = true
	velocity.y = jump_force
	#velocity.x = 10*(jump_force)
	#await get_tree().create_timer(0.5).timeout
	#jumping = false


func destroy():
	Audio.play("sounds/enemy_destroy.ogg")
	destroyed = true
	queue_free()

func damage(amount):
	health -= amount
	var health_ratio = float(health)/float(initial_health)
	var R_color = (1 - health_ratio)  #Should just got to 208 tbh
	var G_color = health_ratio
	healthbar.color = Color(R_color,G_color,0)
	healthbar.scale.x = health_ratio
	print(health_ratio)
	
	if health <= 0 and not destroyed:
		destroy()

func attack():
	attacking = true
	a_anime.stop()
	a_anime.play("Attack")
	await get_tree().create_timer(0.9).timeout

	damaging = true
	monitor = true
	area3D.overlap_check()
	await get_tree().create_timer(0.8).timeout

	damaging = false
	monitor = false
	await get_tree().create_timer(1.5).timeout
	damaged_bodies.clear()
	attacking = false
