#SMART SHOOT GOBLIN SCRIPT AUBURNMAN
extends CharacterBody3D

@export var speed:		float = 4.0		# horizontal move speed
@export var gravity:	float = 20.0	# downward acceleration
@export var target_path:	NodePath	
@export var dmg: float

@onready var target: Node3D = get_node(target_path) if target_path else null #if no target path, Ready() will find player
@onready var nav_agent:	NavigationAgent3D = $NavigationAgent3D
@onready var healthbar = $Control/Healthbar/Helth
@onready var bullet_path = preload("res://Particles/bullet.tscn")
@onready var bullet_spawn = self.get_node("spawn")
@onready var money_drop = preload("res://Card Shark Campaign/Spells/10d_money_drop.tscn")
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
@onready var initial_speed = speed


#Jumping/Stuck
var last_position: Vector3
var stuck_timer: float = 0.0
var stuck_threshold_time: float = 1
var min_movement_threshold: float = 0.1
var jump_timer = 0.0
@export var jump_force: float = 9
var jumping = false
var was_stuck: bool = false
var target_center



# Knockback state
var knockback_v   := Vector3.ZERO
var knockback_t   := 0.0

var player
var destroyed       := false
var attacking       = false
var bullet_cooldown = 0.5
var wants_to_jump = true

var impatient_timer = 0
var rush = false



#@onready var upper_anime        = $Goblin/ArmAnimation
#@onready var lower_anime          = $Goblin/LegAnimation


func _ready() -> void:
	
	if target == null:
		target = get_tree().get_first_node_in_group("Player")
		
	target_center = target.get_node("CharacterCenter")
	
	print("healthbar",healthbar)
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
			#l_anime.play("Walking") NOTE
			
		if (target.global_transform.origin - global_transform.origin).length() < 35 and not attacking:
			attacking = true
			shoot()

		#if nav_agent.is_navigation_finished():
		#	velocity.x = 0
		#	velocity.z = 0
			
		#CLOSE ENOUGH, TRY TO SHOOT	
		if (target.global_transform.origin - global_transform.origin).length() < 15 and not rush:
			wants_to_jump = false
			velocity.x = 0
			velocity.z = 0
			#GETTING IMPATIENT
			impatient_timer += delta
			if impatient_timer >= 10:
				rush = true
				speed = 1.5*initial_speed
			
		
			
			
		else:
			wants_to_jump = true
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
		if stuck_too_long and is_on_floor() and not was_stuck and jump_timer <= 0.0 and wants_to_jump:
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
	drop_money()

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

var last_direction = Vector3.ZERO  # store direction of the first bullet

func shoot():
	# SLOW THE GOBBY AND ANIME
	speed = speed / 4

	for i in range(3):
		if i == 0:
			# First bullet targets player
			last_direction = shoot_a_bullet(true)
		else:
			# Other bullets follow the same direction
			shoot_a_bullet(false, last_direction)
		
		await get_tree().create_timer(0.1).timeout
		print(i + 1)

	speed = initial_speed
	await get_tree().create_timer(1).timeout
	attacking = false


# Returns the direction if it's the first bullet
func shoot_a_bullet(target_player := true, fixed_direction := Vector3.ZERO) -> Vector3:
	var bullet = bullet_path.instantiate()
	bullet.target_group = "Player"
	bullet.damage_amount = dmg
	Audio.play_pitch("sounds/blaster_repeater.ogg", 0.65)
	get_tree().root.add_child(bullet)
	bullet.global_transform = bullet_spawn.global_transform
	
	var direction = Vector3.ZERO
	if target_player:
		var player_move_dir = target.movement_velocity.normalized()
		var rand_aim = randf_range(0.25,3)
		direction = ((target_center.global_transform.origin - bullet.global_transform.origin) + player_move_dir*rand_aim).normalized()
	else:
		direction = fixed_direction
	
	bullet.look_at(bullet.global_transform.origin + direction, Vector3.UP)
	bullet.apply_impulse(direction * 40.0)

	return direction

func drop_money():
	var money = money_drop.instantiate()
	money.global_position = self.global_position
	get_tree().root.add_child(money)
	
	
