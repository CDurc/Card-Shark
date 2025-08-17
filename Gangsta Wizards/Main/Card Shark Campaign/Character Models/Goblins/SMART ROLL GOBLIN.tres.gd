#ROLL MAN
extends CharacterBody3D

@export var initial_speed:		float = 4.0		# horizontal move speed
@export var attacking_speed:		float = 4.0
@export var gravity:	float = 20.0	# downward acceleration
@export var target_path:	NodePath		# drag your Player node here

@onready var target:		Node3D = get_node(target_path)
@onready var nav_agent:	NavigationAgent3D = $Feet/NavigationAgent3D
@onready var healthbar = $Control/Healthbar/Helth
#@onready var initial_healthbar = healthbar.scale.x

#Durc
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
var wants_to_jump = true
var was_stuck: bool = false


# Knockback state
var knockback_v   := Vector3.ZERO
var knockback_t   := 0.0

var player
var destroyed       := false
var attacking       = true
var next_point


@onready var area3D         = $Attackbox
@onready var damaged_bodies = area3D.damaged_bodies
@onready var monitor        = area3D.monitoring
@onready var anime          = $goblin/AnimationPlayer
@onready var mesh = $goblin

var phase1 = true #Get closer to player
var phase2 = false #Get behind player and stare, 3x
var phase3 = false #Roll quickly towards player
var phase4 = false #Pick a spot just ahead of the player and roll straight to it, not updating this point
var spying = false
var spycount = 0
var maxspycount = randi_range(1, 5)
var too_close = true #True when "too close" needs to function.  Turn off when retreating or attacking
var overshoot_dir: Vector3
var speed


func _ready() -> void:
	speed = initial_speed
	print("MAXSPYCOUNTIS:   ",maxspycount)
	if target:
		nav_agent.target_position = target.global_transform.origin + target.global_transform.basis.z * 10
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
		if phase1: #Get 15 units away, updating target constantly

			if (target.global_transform.origin - nav_agent.target_position).length() > 0.15:
				nav_agent.target_position = target.global_transform.origin #Move towards player
				# anime.play("Walking") Add manual rotation anime

			if nav_agent.is_navigation_finished() or (target.global_transform.origin - global_transform.origin).length() < 15: #initial closing distance
				velocity.x = 0
				velocity.z = 0
				phase1=false
				phase2=true
				next_point = target.global_transform.origin + target.global_transform.basis.z * 15 #Get next point ONLY ONCE
			else:
				var next_point: Vector3 = nav_agent.get_next_path_position()
				var dir: Vector3 = next_point - global_transform.origin
				dir.y = 0
				dir = dir.normalized()

				if dir.length() > 0.01 and not jumping and can_move:
					look_at(global_transform.origin + dir, Vector3.UP)

				velocity.x = dir.x * speed
				velocity.z = dir.z * speed
				roll(delta)

		elif phase2: #Get behind player, don't constant update
			if (next_point - nav_agent.target_position).length() > 0.15:
				nav_agent.target_position = next_point #move towards next point
				# anime.play("Walking") Add manual rotation anime

			if nav_agent.is_navigation_finished():
				velocity.x = 0
				velocity.z = 0
				if not spying:
					#----------------spy------------------
					wants_to_jump = false
					spying = true
					mesh.rotation_degrees.z = 0
					#attacking = false
					#damaging = false
					await get_tree().create_timer(4).timeout
					next_point = target.global_transform.origin + target.global_transform.basis.z * 15 #get next point
					wants_to_jump = true
					spying = false
					spycount += 1
					print("PHASE 2 INCREASED THE SPYCOUNT")
					if spycount >= maxspycount:
						phase2 = false
						phase3 = true
			else:
				var next_point: Vector3 = nav_agent.get_next_path_position()
				var dir: Vector3 = next_point - global_transform.origin
				dir.y = 0
				dir = dir.normalized()

				if dir.length() > 0.01 and not jumping and can_move:
					look_at(global_transform.origin + dir, Vector3.UP)

				velocity.x = dir.x * speed
				velocity.z = dir.z * speed
				roll(delta)

		elif phase3: #Get VERY CLOSE before overshooting

			if (target.global_transform.origin - nav_agent.target_position).length() > 0.15:
				nav_agent.target_position = target.global_transform.origin #Move towards player
				# anime.play("Walking") Add manual rotation anime

			if nav_agent.is_navigation_finished() or (target.global_transform.origin - global_transform.origin).length() < 10: #initial closing distance
				phase3=false
				phase4=true
				#GO ATTACK (called once)
				damaging = true
				attacking = true
				var player_move_dir = target.movement_velocity.normalized() #get direction player is moving to aim ahead
				next_point = target.global_transform.origin + player_move_dir * 3 #Aim ahead of player and GO
				overshoot_dir = next_point - global_transform.origin
				overshoot_dir.y = 0
				overshoot_dir = overshoot_dir.normalized()
				look_at(global_transform.origin + overshoot_dir, Vector3.UP)
				speed = speed*2
				print("ATTACK")
				
				await get_tree().create_timer(2).timeout
				#ATTACK OVER
				damaging = false
				attacking = false
				too_close = true
				speed = initial_speed
				spycount = 0
				maxspycount = randi_range(1, 5)
				phase1 = true
				phase2 = false
				phase4  =false
				phase3 = false

			else:
				var next_point: Vector3 = nav_agent.get_next_path_position()
				var dir: Vector3 = next_point - global_transform.origin
				dir.y = 0
				dir = dir.normalized()

				if dir.length() > 0.01 and not jumping and can_move:
					look_at(global_transform.origin + dir, Vector3.UP)

				velocity.x = dir.x * speed
				velocity.z = dir.z * speed
				roll(delta)

		elif phase4: #GO IN (needs to be triggered by phase3.  If you want to attack, turn phase3 on.
				velocity.x = overshoot_dir.x * speed
				velocity.z = overshoot_dir.z * speed
				roll(delta)
		
		#IF PLAYER GETS TOO CLOSE AT ANY TIMR, FIGHT OR FLIHGT
		if (target.global_transform.origin - global_transform.origin).length() < 6: 
			if too_close == true:
				too_close = false
				print("TARGET GOT TOO CLOSE")
				if spycount >= maxspycount: #patience has run out, ATTACK
					print("OUT OF PATIENCE,ATTACK")
					phase1 = false
					phase2 = false
					phase3 = true
				else: #still too shy, RUN AWAY
					print("RETREAT")
					speed = speed * 2
					phase1 = false
					var dir = (global_transform.origin - target.global_transform.origin).normalized()
					next_point = target.global_transform.origin + dir*15
					phase2 = true
					await get_tree().create_timer(2).timeout
					speed = initial_speed
					too_close = true
		
		# Gravity
		if is_on_floor():
			if velocity.y <= 0.0:
				velocity.y = 0
		else:
			velocity.y -= gravity * delta
			
		if spying:
					# ---- ALWAYS FACE THE PLAYER ----
			var face_dir: Vector3 = target.global_transform.origin - global_transform.origin
			face_dir.y = 0
			if face_dir.length() > 0.01 and not jumping and can_move:
				look_at(global_transform.origin + face_dir.normalized(), Vector3.UP)
			# --------------------------------

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
		if stuck_too_long and wants_to_jump and is_on_floor() and not was_stuck and jump_timer <= 0.0:
			jump()
			jump_timer = 1.0
			was_stuck = true

		if jump_timer > 0.0:
			jump_timer -= delta

		move_and_slide()
	

func roll(delta):
	mesh.rotation_degrees.z -= 75*speed*delta

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


	if too_close == true:
		too_close = false
		print("TARGET shot")
		if spycount >= maxspycount: #patience has run out, ATTACK
			print("OUT OF PATIENCE,ATTACK")
			phase1 = false
			phase2 = false
			phase3 = true
		else: #still too shy, RUN AWAY
			print("RETREAT")
			speed = speed * 2
			phase1 = false
			var dir = (global_transform.origin - target.global_transform.origin).normalized()
			next_point = target.global_transform.origin + dir*15
			phase2 = true
			await get_tree().create_timer(2).timeout
			speed = initial_speed
			too_close = true

	
	if health <= 0 and not destroyed:
		destroy()
