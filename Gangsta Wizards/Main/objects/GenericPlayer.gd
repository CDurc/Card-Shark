#GENERIC PLAYER SCRIPT
extends CharacterBody3D

@export_subgroup("Properties")
@export var movement_speed = 5
@export var jump_strength = 8
@export var health:int = 100

var deck = [
	{"rank": 2, "suit": "Clubs"},
	{"rank": 3, "suit": "Clubs"},
	{"rank": 4, "suit": "Clubs"},
	{"rank": 5, "suit": "Clubs"},
	{"rank": 6, "suit": "Clubs"},
	{"rank": 7, "suit": "Clubs"},
	{"rank": 8, "suit": "Clubs"},
	{"rank": 9, "suit": "Clubs"},
	{"rank": 10, "suit": "Clubs"},
	{"rank": 11, "suit": "Clubs"},
	{"rank": 12, "suit": "Clubs"},
	{"rank": 13, "suit": "Clubs"},
	{"rank": 14, "suit": "Clubs"},
	{"rank": 2, "suit": "Diamonds"},
	{"rank": 3, "suit": "Diamonds"},
	{"rank": 4, "suit": "Diamonds"},
	{"rank": 5, "suit": "Diamonds"},
	{"rank": 6, "suit": "Diamonds"},
	{"rank": 7, "suit": "Diamonds"},
	{"rank": 8, "suit": "Diamonds"},
	{"rank": 9, "suit": "Diamonds"},
	{"rank": 10, "suit": "Diamonds"},
	{"rank": 11, "suit": "Diamonds"},
	{"rank": 12, "suit": "Diamonds"},
	{"rank": 13, "suit": "Diamonds"},
	{"rank": 14, "suit": "Diamonds"},
	{"rank": 2, "suit": "Hearts"},
	{"rank": 3, "suit": "Hearts"},
	{"rank": 4, "suit": "Hearts"},
	{"rank": 5, "suit": "Hearts"},
	{"rank": 6, "suit": "Hearts"},
	{"rank": 7, "suit": "Hearts"},
	{"rank": 8, "suit": "Hearts"},
	{"rank": 9, "suit": "Hearts"},
	{"rank": 10, "suit": "Hearts"},
	{"rank": 11, "suit": "Hearts"},
	{"rank": 12, "suit": "Hearts"},
	{"rank": 13, "suit": "Hearts"},
	{"rank": 14, "suit": "Hearts"},
	{"rank": 2, "suit": "Spades"},
	{"rank": 3, "suit": "Spades"},
	{"rank": 4, "suit": "Spades"},
	{"rank": 5, "suit": "Spades"},
	{"rank": 6, "suit": "Spades"},
	{"rank": 7, "suit": "Spades"},
	{"rank": 8, "suit": "Spades"},
	{"rank": 9, "suit": "Spades"},
	{"rank": 10, "suit": "Spades"},
	{"rank": 11, "suit": "Spades"},
	{"rank": 12, "suit": "Spades"},
	{"rank": 13, "suit": "Spades"},
	{"rank": 14, "suit": "Spades"}
]


var mouse_sensitivity = 700
var gamepad_sensitivity := 0.075

var mouse_captured := true

var movement_velocity: Vector3
var rotation_target: Vector3

var input_mouse: Vector2

var gravity := 0.0

var previously_floored := false

var jump_single := true
var jump_double := true

var left_container_offset = Vector3(-0.38 , -0.3, -1) # weapon location
var right_container_offset = Vector3(.8, -.5, -2.3) # card location
var gun_rotation = Vector3(0,90,0)


signal health_updated

@onready var camera = $Head/Camera
@onready var raycast = $Head/Camera/RayCast
@onready var raycast2 = $Head/Camera/RayCast2 #Used for magic to allow gun and magic at same time
@onready var right_muzzle = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/RightMuzzle
@onready var left_muzzle = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/LeftMuzzle
@onready var right_container = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/RightContainer
@onready var left_container = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/LeftContainer
@onready var right_hand_container = $TheCardSharkv4/SharkBones/Skeleton3D/RightHandContainer
@onready var laser_spawn = right_hand_container.get_node("Card").get_node("Target").get_node("spawn")#For position
@onready var test_spawn = $Laserspawn #For parenting

@onready var card_container = $CardContainer
@onready var sound_footsteps = $SoundFootsteps
@onready var card_cooldown = $CardCooldown
@onready var magic_cooldown = $MagicCooldown #Timer for magic only
@onready var gun_cooldown = $GunCooldown #Timer for magic only
@onready var straight_laser_cooldown = $StraightLaserCooldown #Timer for magic only

@onready var anime = $TheCardSharkv4/AnimationPlayer
@onready var UI_Card1 = $"../HUD/C1/Txt"
@onready var UI_Card2 = $"../HUD/C2/Txt"

@export var crosshair:TextureRect

#Durc
var active_laser
var all_cards
var best_hand #Best Hand Algo will return this
var hand = []
var cards #This is the asset for the physical cards and is not related to the card data
var straight_laser
var gun
var phys_card_path
var phys_card #phys_cards are affected by gravity/ physics
var bofa
var splash
var PokerEvaluator = load("res://Card Shark/GPT Best Hand.gd")
var evaluator_instance = PokerEvaluator.new()
var phys_card_scene = preload("res://Card Shark/Physics Cards.tscn")
var active_laser_path = preload("res://Card Shark/laser.tscn")
var splash_path = preload("res://Particles/laser_splash.tscn")

# Functions
func _ready():
	add_to_group("Player") #So bots can communicate easily with player?
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#Load weapon
	deck.shuffle()
	bofa = two_cards()
	set_cards()
	set_bofa()
	load_viewport()
func _physics_process(delta):
	
	# Handle functions
	handle_controls(delta)
	handle_gravity(delta)
	
	if active_laser:
		laser()
	
	# Movement
	var applied_velocity: Vector3
	movement_velocity = transform.basis * movement_velocity #"Transform.basis" is relative to parent cords
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity
	velocity = applied_velocity
	move_and_slide()
	
	# Rotation
	
	camera.rotation.z = lerp_angle(camera.rotation.z, -input_mouse.x * 25 * delta, delta * 5)	
	camera.rotation.x = lerp_angle(camera.rotation.x, rotation_target.x, delta * 25)
	rotation.y = lerp_angle(rotation.y, rotation_target.y, delta * 25)
	
	#make the container lag for a sway effect
	right_container.position = lerp(right_container.position, right_container_offset - (basis.inverse() * applied_velocity / 30), delta * 10)
	left_container.position = lerp(left_container.position, left_container_offset - (basis.inverse() * applied_velocity / 30), delta * 10)
	#Durc
	right_container.get_child(0).position = right_container.position #The cards
	#left_muzzle.position = left_container.position + left_container_offset + Vector3(-.3,0.4,-3)

	# Movement sound
	sound_footsteps.stream_paused = true
	
	if is_on_floor():
		if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			sound_footsteps.stream_paused = false
			anime.play("Walking")
	
	# Landing after jump or falling
	camera.position.y = lerp(camera.position.y, 0.0, delta * 5)
	
	if is_on_floor() and gravity > 1 and !previously_floored: # Landed
		Audio.play("sounds/land.ogg")
		#camera.position.y = -0.1
		#^ This will make the character model look weird unless compensated for
	
	previously_floored = is_on_floor()
	
	# Falling/respawning
	if position.y < -10:
		get_tree().reload_current_scene()


func load_viewport(): #Also load any real world things that aren't part of the player scene
	
	var card_model_path = load("res://Card Shark/Card.tscn")
	cards = card_model_path.instantiate()
	#irl_cards = card_model_path.instantiate()
	load_set_cards()
	right_container.add_child(cards)
	#right_hand_container.add_child(irl_cards)
	#irl_cards.rotation_degrees = Vector3(90,-90,0)
	#irl_cards.position = Vector3(1,1,-1)
	#card1.rotation_degrees = Vector3()
	
	var gun_model_path = load("res://Card Shark/aceGUN.tscn") #Stolen from destiny lol
	gun = gun_model_path.instantiate()
	left_container.add_child(gun)
	gun.rotation_degrees = gun_rotation
	
	#Set model to only render on layer 2 (the weapon camera)
	
	for child in cards.find_children("*", "MeshInstance3D"):
		child.layers = 2
	for child in gun.find_children("*", "MeshInstance3D"):
		child.layers = 2
		#child.position += Vector3(0,1,0)


func two_cards():	
	var _bofa = deck.slice(0,2)
	deck = deck.slice(2,)
	return (_bofa)
	
func set_bofa():
	UI_Card1.text = str(bofa[0]["rank"])
	UI_Card2.text = str(bofa[1]["rank"])
	
func set_cards():
	hand = deck.slice(0,5)
	deck = deck.slice(5,)
	all_cards = hand.duplicate()
	all_cards.append_array(bofa)
	best_hand = evaluator_instance.get_best_poker_hand(all_cards)
	print(best_hand)
	
func load_set_cards(): #This CANNOT be same fn as set_cards because viewport needs to load after set
	#cards.get_node("C1").get_node("Txt").mesh.text = str(hand[0]["rank"])
	for i in range(len(hand)):
		print(i)
		var card_front = cards.get_node("C%d" % (i+1)).get_node("Front").mesh.material
		var card_type = str(hand[i]["rank"]) + str(hand[i]["suit"].left(1))
		print (card_type)
		var image = load("res://Card Shark/Card Pics/PlayingCard_%s.jpg" % (card_type))
		card_front.albedo_texture = image

func discard():
	if Input.is_action_pressed("Ability1"):
		if !magic_cooldown.is_stopped(): return
		var tween = create_tween()
		var original = right_container_offset
		var down = original + Vector3(0,-0.8,0)
		magic_cooldown.start(3)
		tween.tween_property(self,"right_container_offset",down,0.2)
		tween.tween_callback(Callable(self,"throw_cards"))
		tween.tween_callback(Callable(self,"cards_down")) #Do the loading while cards out of sight
		tween.tween_interval(1)
		tween.tween_property(self,"right_container_offset",original,0.5)
		
		#Throw Cards
		
		print("discard")

func cards_down():
	set_cards()
	load_set_cards()

func throw_cards():
	anime.play("Discard")
	for i in range(len(hand)):
		phys_card = phys_card_scene.instantiate()
		var text_node = phys_card.get_node("Rig").get_node("Txt")
		text_node.mesh = text_node.mesh.duplicate() #Dupe so that they don't share properties (txt)
		text_node.mesh.text = str(hand[i]["rank"])
		$"../Projectiles".add_child(phys_card)
		phys_card.position = card_container.global_position
		var random_vector = Vector3(randf()*1-0.5,randf()*1,0)
		var local_direction = Vector3(0,0,-0.8)+random_vector
		var random_direction = card_container.global_transform.basis * local_direction
		random_direction = random_direction.normalized()
		phys_card.get_node("Rig").linear_velocity = random_direction * 8

func drop_cards():
	
	for i in range(len(hand)):
		
		anime.play("New Card")
		phys_card = phys_card_scene.instantiate()
		var text_node = phys_card.get_node("Rig").get_node("Txt")
		text_node.mesh = text_node.mesh.duplicate() #Dupe so that they don't share properties (txt)
		text_node.mesh.text = str(hand[i]["rank"])
		$"../Projectiles".add_child(phys_card)
		phys_card.position = card_container.global_position
		var random_vector = Vector3(randf()*1-0.5,randf()*1,0)
		var local_direction = Vector3(0,0,-0.8)+random_vector
		var random_direction = card_container.global_transform.basis * local_direction
		random_direction = random_direction.normalized()
		phys_card.get_node("Rig").linear_velocity = random_direction * 8

func straight_laser_spell():
	if Input.is_action_pressed("Right_Click"):
		if !straight_laser_cooldown.is_stopped(): return
		straight_laser_cooldown.start(6) #For 6 seconds, let _physics_process move the cards
		straight_fly_cards(cards)
		straight_fly_cards_real(right_hand_container.get_node("Card"))
		var d = get_tree().create_timer(2.0).timeout #Wait for spin-up
		await d
		print("spawn laser")
		active_laser = active_laser_path.instantiate()
		test_spawn.add_child(active_laser)
		var d2 = get_tree().create_timer(0.1).timeout #Wait laser to get set
		await d2
		active_laser.visible = true
		await straight_laser_cooldown.timeout #Wait for laser animation to end
		active_laser.queue_free()
		active_laser = null

#Cards forming pentagon for straight_laser
var rot_speed = 0.7
var rot_acc = 3
var rot_max_speed = 9.5
func straight_fly_cards(instance): #Viewport version, possibly obselete
	if straight_laser_cooldown.time_left <= 0: return
	var delta = get_process_delta_time()
	#lerp and slerp the cards to pentagon formation
	for i in range(1, 6):
		var from_transform = instance.get_node("C%d" % i).global_transform
		var to_transform   = instance.get_node("Target").get_node("T%d" % i).global_transform
		
		from_transform = Transform3D(
			Basis(
				from_transform.basis.orthonormalized() #SCALE MUST BE 1,1,1
				.get_rotation_quaternion()
				.slerp(
					to_transform.basis.orthonormalized()
					.get_rotation_quaternion(), 4 * delta
				)
			),
			from_transform.origin.lerp(to_transform.origin, 4 * delta)
		)
		
		instance.get_node("C%d" % i).global_transform = from_transform
	#Begin rotating the parent node
	rot_speed = min(rot_speed + rot_acc * delta, rot_max_speed)
	var current_rotation = instance.get_node("Target").global_transform.basis.get_rotation_quaternion()
	var rotation_delta = Quaternion(Vector3(0,0,1), delta)  # Small Y-axis rotation
	var new_rotation = current_rotation.slerp(rotation_delta * current_rotation, rot_speed)

	instance.get_node("Target").global_transform.basis = Basis(new_rotation)

func straight_fly_cards_real(instance):
	if straight_laser_cooldown.time_left <= 0:
		return # Exit if cooldown is over

	var target_node = instance.get_node("Target")
	var current_rotation = target_node.transform.basis.get_rotation_quaternion()  # Declare at the start

	while straight_laser_cooldown.time_left > 0:
		var delta = get_process_delta_time()

		# Lerp + slerp each card in local space (relative to the 'Card' node)
		for i in range(1, 6):
			var card = instance.get_node("C%d" % i)
			var t_node = target_node.get_node("T%d" % i)

			# The card’s current local transform (relative to 'Card')
			var from_transform = card.transform

			# Combine 'Target.transform' and 'T#.transform' to get T# in 'Card' space
			var t_in_card_space = target_node.transform * t_node.transform

			# Position: LERP
			var new_origin = from_transform.origin.lerp(t_in_card_space.origin, 4 * delta)

			# Rotation: SLERP
			var from_quat = from_transform.basis.orthonormalized().get_rotation_quaternion()
			var to_quat   = t_in_card_space.basis.orthonormalized().get_rotation_quaternion()
			var new_quat  = from_quat.slerp(to_quat, 4 * delta)

			card.transform = Transform3D(Basis(new_quat), new_origin)

		# Rotate 'Target'
		rot_speed = min(rot_speed + rot_acc * delta, rot_max_speed)
		current_rotation = target_node.transform.basis.get_rotation_quaternion()  # Update rotation
		var rotation_delta = Quaternion(Vector3(0, 0, 1), delta)  # Rotate around Z-axis
		var new_rotation = current_rotation.slerp(rotation_delta * current_rotation, rot_speed)
		target_node.transform.basis = Basis(new_rotation)

		await get_tree().process_frame  # Yield execution so it doesn't lock up

	# Reset rotation and stop movement
	target_node.transform.basis = Basis(current_rotation)  # Ensure final rotation reset
	rot_speed = 0.7
	rot_acc = 3
	rot_max_speed = 9.5

	# Return cards to original position and rotation while invisible
	for i in range(1, 6):
		var card = instance.get_node("C%d" % i)
		var t_node = instance.get_node("P%d" % i)
		card.transform = t_node.transform

	print("e")
	set_cards()
	load_set_cards()

func laser():
	if active_laser:
		var hit_position
		if raycast.is_colliding():
			hit_position = raycast.get_collision_point()

			# Spawn the splash scene.
			var splash = splash_path.instantiate()
			get_tree().root.add_child(splash)

			# Position the splash at the hit point.
			splash.position = hit_position + (raycast.get_collision_normal() / 10) #/10 to nudge towards the ray a bit
			
			var particles = splash.get_node("GPUParticles3D")
			if particles:
				#Duplicate the entire process_material so it doesn't share with previous splashes.
				if particles.process_material:
					particles.process_material = particles.process_material.duplicate(true)

				particles.emitting = true

				# 4) Delete the splash
				get_tree().create_timer(particles.lifetime).timeout.connect(func():
					if is_instance_valid(splash):
						splash.queue_free()
				)
		else:
			hit_position = raycast.global_transform.origin + raycast.global_transform.basis.z * -100 #Fallback distance

		var start_position = laser_spawn.global_transform.origin
		active_laser.global_transform.origin = start_position
		active_laser.look_at(hit_position)
		var distance = start_position.distance_to(hit_position)
		active_laser.scale.z = distance

		
func shoot():
	if Input.is_action_pressed("Left_Click"):
	
		if !gun_cooldown.is_stopped(): return
		
		#Audio.play("res://sounds/blaster.ogg")
		#shoot_laser()
		Audio.play("sounds/blaster_repeater.ogg")
		
		left_container.position.z += 0.25 # Knockback of weapon visual
		camera.rotation.x += 0.025 # Knockback of camera
		
		# Set muzzle flash position, play animation	
		#left_muzzle.rotation_degrees.z = randf_range(-45, 45)
		#left_muzzle.scale = Vector3(0.5,0.5,0.5) * randf_range(0.40, 0.75)
		#left_muzzle.position = left_container.position + left_container_offset + Vector3(-.3,0.4,-3)
		#left_muzzle.play("default")
		
		#Durc
		gun.get_node("Sketchfab_model").get_node("Ace Of Spades_fbx").get_node("RootNode").get_node("MuzzleFlash").play("default")
		
		
		
		gun_cooldown.start(0.7)
		
		# Shoot the weapon, amount based on shot count
		
		for n in range(10):
		
			raycast.target_position.x = randf_range(-0.5, 0.5)
			raycast.target_position.y = randf_range(-0.5, 0.5)
			
			raycast.force_raycast_update()
			
			if !raycast.is_colliding(): continue
			
			var collider = raycast.get_collider()
			# Hitting an enemy
			
			if collider.has_method("damage"):
				collider.damage(20)
			
			# Creating an impact animation
			
			var impact = preload("res://objects/impact.tscn")
			var impact_instance = impact.instantiate()
			
			impact_instance.play("shot")
			
			get_tree().root.add_child(impact_instance)
			
			impact_instance.position = raycast.get_collision_point() + (raycast.get_collision_normal() / 10)
			impact_instance.look_at(camera.global_transform.origin, Vector3.UP, true) 
# Mouse movement
func _input(event):
	if event is InputEventMouseMotion and mouse_captured:
		
		input_mouse = event.relative / mouse_sensitivity
		
		rotation_target.y -= event.relative.x / mouse_sensitivity
		rotation_target.x -= event.relative.y / mouse_sensitivity

func handle_controls(_delta):
	
	discard()
	shoot()
	straight_laser_spell()
	
	# Mouse capture
	
	if Input.is_action_just_pressed("mouse_capture"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		mouse_captured = true
	
	if Input.is_action_just_pressed("mouse_capture_exit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse_captured = false
		
		input_mouse = Vector2.ZERO
	
	# Movement
	
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	movement_velocity = Vector3(input.x, 0, input.y).normalized() * movement_speed
	
	# Rotation
	
	var rotation_input := Input.get_vector("camera_right", "camera_left", "camera_down", "camera_up")
	
	rotation_target -= Vector3(-rotation_input.y, -rotation_input.x, 0).limit_length(1.0) * gamepad_sensitivity
	rotation_target.x = clamp(rotation_target.x, deg_to_rad(-90), deg_to_rad(90))
	
	# Jumping
	
	if Input.is_action_just_pressed("jump"):
		print("JUMP")
		
		if jump_single or jump_double:
			Audio.play("sounds/jump_a.ogg, sounds/jump_b.ogg, sounds/jump_c.ogg")
		
		if jump_double:
			
			gravity = -jump_strength
			jump_double = false
			
		if(jump_single): action_jump()
		

# Handle gravity

func handle_gravity(delta):
	
	gravity += 20 * delta
	
	if gravity > 0 and is_on_floor():
		
		jump_single = true
		gravity = 0

# Jumping

func action_jump():
	
	anime.play("Jump")
	gravity = -jump_strength
	
	jump_single = false;
	jump_double = true;

func damage(amount):
	
	health -= amount
	health_updated.emit(health) # Update health on HUD
	
	if health < 0:
		get_tree().reload_current_scene() # Reset when out of health
#Fin
