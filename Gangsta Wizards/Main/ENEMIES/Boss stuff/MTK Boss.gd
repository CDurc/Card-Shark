#MTK  k
extends CharacterBody3D

@export var avg_speed: float		# horizontal move speed
@export var gravity:	float = 20.0	# downward acceleration
@export var target_path:	NodePath		# drag your Player node here

@onready var target: Node3D = get_node(target_path) if target_path else null #if no target path, Ready() will find player
@onready var nav_agent:	NavigationAgent3D = $NavigationAgent3D
@onready var healthbar = $Control/Healthbar/Helth
@onready var healthbar_control = $Control
@onready var healthbar_timer = $Control/Hbar_Expire
@onready var money_drop = preload("res://Card Shark Campaign/Spells/1d_money_drop.tscn")
@onready var speed = avg_speed
@onready var axe_spawn = $AxeSpawn
@onready var voice = $Voice
@onready var axe = $"Mountain King3/Mountain King/Skeleton3D/Axe" #The one hes holding
@onready var setaxe = $setaxe #The one he places
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
var destroyed: = false
var attacking: = false
var no_look: = false
var cooling:   = false #Period where he cant call an attack function
var talking:   = false
var YMCA_dir

@export var voice_lines: Array[AudioStream] = []
@export var voice_uhh: Array[AudioStream] = []

var state = "attacking"
#attacking : Runs at player and swings
#YMCA : 
#busy : disable movement and attacking


#@onready var damaged_bodies = area3D.damaged_bodies
@onready var upper_anime          = $"Mountain King3/Upper"
@onready var lower_anime          = $"Mountain King3/Lower"


func _ready() -> void:
	
	if target == null:
		target = get_tree().get_first_node_in_group("Player")
	
	if target:
		nav_agent.target_position = target.global_transform.origin
	last_position = global_position

	await get_tree().create_timer(25).timeout
	
	YMCA()

func _physics_process(delta: float) -> void:
	if not target:
		return
	
		# knockback has priority
	if knockback_t > 0.0:
		velocity = knockback_v
		move_and_slide()
		knockback_t -= delta
	elif can_move and state == "attacking":
		

		if (target.global_transform.origin - nav_agent.target_position).length() > 3:
			nav_agent.target_position = target.global_transform.origin #Move towards player
			lower_anime.play("Walking Lower")
			if not attacking:
				upper_anime.play("Walking Upper")
			
		if (target.global_transform.origin - global_transform.origin).length() < 5 and not cooling:
			rand_attack()

		if nav_agent.is_navigation_finished():
			velocity.x = 0
			velocity.z = 0
		else:
			var next_point: Vector3 = nav_agent.get_next_path_position()
			var dir: Vector3 = next_point - global_transform.origin
			dir.y = 0
			dir = dir.normalized()

			if dir.length() > 0.01 and not jumping and can_move and not no_look:
				look_at(global_transform.origin + dir, Vector3.UP)

			velocity.x = dir.x * speed
			velocity.z = dir.z * speed

		# ---- ALWAYS FACE THE PLAYER ----
		var face_dir: Vector3 = target.global_transform.origin - global_transform.origin
		face_dir.y = 0
		if face_dir.length() > 0.01 and not jumping and can_move and not no_look:
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

	elif can_move and state == "YMCA":
		velocity.x = YMCA_dir.x * 20.0
		velocity.z = YMCA_dir.z * 20.0
		if is_on_floor():
			if velocity.y <= 0.0:
				velocity.y = 0
		else:
			velocity.y -= gravity * delta
			
		move_and_slide()

func jump():
	#jumping = true
	velocity.y = jump_force
	#velocity.x = 10*(jump_force)
	#await get_tree().create_timer(0.5).timeout
	#jumping = false

var ordered_YMCA_animes = ["Stone Freeze Pose Y", "Y-M", "M-C", "C-A"]
func YMCA():
	print("YMCA GO")
	state = "busy"
	
	upper_anime.play("Plant Axe")
	await get_tree().create_timer(1.29).timeout
	axe.visible = false
	setaxe.reparent(get_tree().root)
	setaxe.set_axe()
	
	for i in range(0,4):
		upper_anime.play(ordered_YMCA_animes[i])
		await upper_anime.animation_finished
		YMCA_dir = target.global_position - global_position
		YMCA_dir.y = 0
		YMCA_dir = YMCA_dir.normalized()
		state = "YMCA"
		await get_tree().create_timer(1).timeout
		state = "busy"
	fetch_axe()
	await get_tree().create_timer(0.6).timeout
	state = "attacking"
	upper_anime.play("Idle")
	talking = true
	voice.volume_db = 5
	voice.stream = voice_lines[randi() % voice_lines.size()]
	voice.play()
	await get_tree().create_timer(3.2).timeout
	talking = false

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
	if healthbar_control.can_appear:
		healthbar_control.visible = true
		healthbar_timer.start()
	
	if health <= 0 and not destroyed:
		destroy()

func _on_healthbar_timer_timeout():
	healthbar_control.visible = false

func rand_attack():
	var rand = randi_range(0,1)
	if rand == 0:
		side_attack()
	else:
		over_attack()

func side_attack():
	attacking = true
	cooling = true #Cant call any attack function
	upper_anime.play("Swing - Side")
	await get_tree().create_timer(0.5).timeout
	if not talking:
		voice.volume_db = -2
		voice.stream = voice_uhh[randi() % voice_uhh.size()]
		voice.play()
	print("MTK ATTACK SWING")
	await get_tree().create_timer(0.25).timeout
	$Close_Hurtbox.monitoring = true
	await get_tree().create_timer(0.55).timeout
	$Close_Hurtbox.monitoring = false
	print("attack dmg over")
	attacking = false
	await get_tree().create_timer(0.8).timeout
	cooling = false

func over_attack():
	upper_anime.speed_scale *= 1.5
	attacking = true
	no_look = true
	cooling = true #Cant call any attack function
	upper_anime.play("Swing - Top")
	await get_tree().create_timer(0.5).timeout
	if not talking:
		voice.volume_db = -2
		voice.stream = voice_uhh[randi() % voice_uhh.size()]
		voice.play()
	print("MTK ATTACK SWING")
	await get_tree().create_timer(0.15).timeout #correctly time the too close hurtbox
	$Close_Hurtbox.monitoring = true
	await get_tree().create_timer(0.3).timeout
	$Close_Hurtbox.monitoring = false
	print("attack dmg over")
	attacking = false
	upper_anime.speed_scale = 1.0
	face_player_smooth()
	await get_tree().create_timer(0.15).timeout
	no_look = false
	await get_tree().create_timer(0.5).timeout
	cooling = false
	
func fetch_axe(): #Recalls the set axe
	setaxe.monitor(true)
	setaxe.look_at(self.position)
	setaxe.rotation_degrees.y = 90
	setaxe.reparent(self)
	setaxe.spinning = true
	upper_anime.play("Throw Axe")
	upper_anime.seek(2.5, true) #Start from 1.18 in
	var tween = create_tween()
	tween.tween_property(setaxe, "position", axe_spawn.position, 0.5)
	await tween.finished
	setaxe.monitor(false)
	setaxe.unset_axe()
	axe.visible = true

func face_player_smooth():
	var face_dir = target.global_transform.origin - global_transform.origin
	face_dir.y = 0
	if face_dir.length() < 0.01:
		return
	var target_quat = Basis.looking_at(face_dir.normalized(), Vector3.UP).get_rotation_quaternion()
	var tween = create_tween()
	tween.tween_property(self, "quaternion", target_quat, 0.15)
