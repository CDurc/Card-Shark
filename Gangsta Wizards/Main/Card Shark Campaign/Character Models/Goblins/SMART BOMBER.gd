#Smart Bomber Script
extends CharacterBody3D

@export var speed:		float = 3.0		# horizontal move speed
@export var gravity:	float = 20.0	# downward acceleration
@export var target_path:	NodePath		# drag your Player node here

@onready var target:		Node3D = get_node(target_path)
@onready var nav_agent:	NavigationAgent3D = $NavigationAgent3D
@onready var healthbar = $Control/Healthbar/Helth
#@onready var initial_healthbar = healthbar.scale.x

#Durc
@export var follow_distance     = 10
@export var attack_distance     = 2 #redundant
@export var follow_speed        = 2.0
@export var gravity_strength    = 20.0
@export var can_move            = true
@export var can_turn            = true
@export var damaging            = false
@export var health: float       = 60
var initial_health = health

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

@onready var player = get_tree().get_nodes_in_group("Player")[0]
var destroyed       := false
var attacking       = false
var fuse_ticking = false
var face_dir: Vector3


@onready var goblin_anime = $goblin_4/AnimationPlayer
@onready var bomb_anime = $Bomb2/AnimationPlayer

var boom_effect = preload("res://Particles/BIGGER BOMB.tscn")


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
			goblin_anime.play("Run")
			
		if (target.global_transform.origin - global_transform.origin).length() < 1.8 and not attacking:
			explode()
			print("TRYING TO ATTACK")
			
		if (target.global_transform.origin - global_transform.origin).length() < 8 and not fuse_ticking:
			fuse()
			print("FUSE IS TICKING")			
			

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
		face_dir = target.global_transform.origin - global_transform.origin
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
		explode()
		destroy()

func explode():
	attacking = true
	print("BOOM BANG BANG")
	boom()
	

func boom():

	#EXPLOSIVE IMPULSE
	print("boom went off")
	var overlapping_bodies = $BombArea.get_overlapping_bodies()
	var boom = boom_effect.instantiate()
	get_tree().root.add_child(boom)
	boom.global_position = $BombArea.global_position
	
	if player in overlapping_bodies:
		print("Player is inside the area!")
		var impulse_dir = face_dir
		impulse_dir = 100*(impulse_dir+Vector3(0,2,0))
		print(impulse_dir)
		player.trigger_ragdoll(impulse_dir)
		
	for body in overlapping_bodies:
		if body.has_method("damage") and body != self and body.health > 0:
			print("DAMAGED OTHER BOY")
			body.call("damage", 60)

	destroy()

func fuse():
	speed = 5
	fuse_ticking = true
	bomb_anime.play("Fuse")
	await get_tree().create_timer(5).timeout
	explode()
	
