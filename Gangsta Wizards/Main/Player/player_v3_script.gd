#PLAYER v3 SCRIPT
extends CharacterBody3D

@export_subgroup("Properties")
@export var walk_speed = 5
@export var sprint_speed = 10
@export var jump_strength = 8
@export var health:int = 100
@export var can_move = true
@export var stamina:float = 6
@export var reload_time:float = 3.25

var initial_deck = [
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

var deck = initial_deck
var movement_speed = walk_speed

var mouse_sensitivity = 700
var gamepad_sensitivity := 0.075

var mouse_captured := true

var movement_velocity: Vector3 #What the player is trying to do from a global perspective, also considering movement speed
var rotation_target: Vector3
var local_velocity: Vector3 #What the player is trying to do relative to their perspective

var input_mouse: Vector2

var gravity := 0.0
var replenishing_stamina = false
var sprint_cooldown:float = 0


var previously_floored := false

var jump_single := true
var jump_double := true
var acting = false #Enable this for any action that should block all other actions
var moving_cam = false

var left_container_offset = Vector3(-0.38 , -0.3, -1) # weapon location
var right_container_offset = Vector3(.8, -.5, -2.3) # card location
var gun_rotation = Vector3(0,90,0)


signal health_updated

@onready var camera = $Head/Camera
@onready var camera_origin = $Head/Camera_origin
@onready var raycast = $Head/Camera/RayCast
@onready var raycast2 = $Head/Camera/RayCast2 #Used for magic to allow gun and magic at same time
@onready var raycast_int = $Head/Camera/RayCast_Int
@onready var right_muzzle = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/RightMuzzle
@onready var left_muzzle = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/LeftMuzzle
@onready var right_container = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/RightContainer
@onready var left_container = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/LeftContainer
@onready var right_hand_container = $TheCardShark2/SharkBones/Skeleton3D/RightHandContainer
@onready var laser_spawn = right_hand_container.get_node("Card/Target/spawn")
@onready var test_spawn = $Laserspawn #For parenting
@onready var cards_in_hand = right_hand_container.get_node("Card")
#@onready var skel = $RAGDOLL/SharkBones/Skeleton3D
#@onready var hip = $"RAGDOLL/SharkBones/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone Hips"
@onready var ragcam = $ragcam
@onready var followhip = $FollowHip

@onready var card_container = $CardContainer
@onready var basking_spawn = $Baskingspawn
@onready var sound_footsteps = $SoundFootsteps
@onready var sound_ahh = $SoundAhh
@onready var card_cooldown = $CardCooldown
@onready var magic_cooldown = $MagicCooldown #Timer for magic only
@onready var straight_laser_cooldown = $StraightLaserCooldown
@onready var basking_house_cooldown = $BaskingHouseCooldown

@onready var LA_anime = $TheCardShark2/LeftArmController
@onready var RA_anime = $TheCardShark2/RightArmController
@onready var Leg_anime = $TheCardShark2/LegController
@onready var Gen_anime = $TheCardShark2/GenericController
@onready var UI_Card1 = $HUD/C1/Txt
@onready var UI_Card2 = $HUD/C2/Txt
@onready var HUD = $HUD
@onready var ranges = $Ranges
@onready var chipbar = $HUD/Chipbar
@onready var ammo_counter = $HUD/Bottombar/Ammo_icon/Ammo
@onready var pause_menu = $HUD/PauseMenu

@onready var flat_cam_goal = $Head/Flatcam_point
@onready var Player_glb = $TheCardShark2

@onready var lowcast = $Autostepper/Lowcast
@onready var highcast = $Autostepper/Highcast
@onready var headcast = $Autostepper/Headcast
@onready var melee_hitbox = $Melee_Hit
@onready var cam2 = $"Head/2nd_cam"
@onready var cursor = $HUD/Crosshair
@onready var player_collider = $Collider

@onready var item_container = $TheCardShark2/SharkBones/Skeleton3D/LeftHandContainer/Held_Item

#@onready var melee_camgoal = $melee_camgoal



#@onready var music := $AudioStreamPlayer
#@onready music.stream = preload("res://Card Shark Campaign/Special Effects/wet-fart-1.mp3")


@export var crosshair:TextureRect

#Durc
var item: Node3D #Assigned to the singular child of item_container
var vulnerable = true
var melee_camgoal = Node3D
var money = 0
var reloading = false
var ammo = 16
var is_disabled = false #Use this for ragdoll
var generic_disable = false #Use this for everything else
var can_double_jump = false
var sprinting = false
var fourkind_lifting = false
var fourkind_slamming = false
var fourkind_uping = false
var can_look = true #Can turn the camera at all with inputs
var basking_shark
var active_laser
var all_cards
var best_hand #Best Hand Algo will return this
var hand = []
var cards #This is the asset for the viewport cards which are linked to the physical cards in hand
var straight_laser
var gun
var phys_card_path
var phys_card #phys_cards are affected by gravity/ physics
var bofa
var splash
var local_pos
var hip
var PokerEvaluator = load("res://Card Shark/GPT Best Hand.gd")
var evaluator_instance = PokerEvaluator.new()
var phys_card_scene = preload("res://Card Shark/Physics Cards.tscn")
var seek_card_scene = preload("res://Card Shark/Seeking Physics Cards.tscn")
var boom_card_scene = preload("res://Card Shark/Boom Physics Cards.tscn")
var active_laser_path = preload("res://Card Shark/laser.tscn")
var splash_path = preload("res://Particles/laser_splash.tscn")
var poopy_path = preload("res://Particles/new_poopy_fart.tscn")
var flush_path = preload("res://Particles/flush_effect.tscn")
var basking_shark_path = preload("res://Card Shark/basking_path.tscn")
var fourkind_slam_scene = preload("res://Particles/fourkind_slam_effect.tscn")
var ragdoll_glb = preload("res://Card Shark Campaign/CS_RAGDOLL.tscn")


#For fourkind in range enemies
var fourkind_enemies: Array = []
var fourkind_goals: Array = []
var fourkind_ups: Array = []
var fourkind_return_goals: Array = []

# Functions
func _ready():
	if item_container.get_child_count() > 0: 
		item = item_container.get_child(0)
	chipbar.call("display_chips", health)
	Gen_anime.play("Idle")
	add_to_group("Player") #Justin case
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#Load weapon
	deck.shuffle()
	bofa = two_cards()
	set_cards()
	set_bofa()
	load_bofa()
	load_viewport()
func _physics_process(delta):
	
	if sprint_cooldown > 0:
		sprint_cooldown -= delta
		replenishing_stamina = false
	elif not sprinting:
		replenishing_stamina = true
	
	if replenishing_stamina and stamina <6:
		stamina += delta
	
	if is_disabled: #Currently only use this for ragdoll pls
		#followhip.position = hip.position
		ragcam.global_position = hip.global_position - local_pos
		ragcam.look_at(hip.position)
		return
	
	if generic_disable:
		TransformUtils.lerp_slerp_node(camera, flat_cam_goal, 4, 0.2, delta)
		return
	
	if moving_cam:
		move_cam(delta)
	
	# Handle functions
	handle_gravity(delta)
	if GameState.current_mode != GameState.GameMode.GAMEPLAY:
		return
	handle_controls(delta)
	if active_laser:
		laser(delta)
	
	# Movement
	var applied_velocity: Vector3
	var local_input = movement_velocity # <- this is before basis transform so relative to player cords
	movement_velocity = transform.basis * movement_velocity #"Transform.basis" is relative to parent cords
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity
	velocity = applied_velocity
	if can_move:
		move_and_slide()
		if lowcast.is_colliding() and not highcast.is_colliding() and not headcast.is_colliding() and get_floor_normal().y > 0.9 and local_velocity.z < 0:
			#global_position.y = lerp(global_position.y, global_position.y + 0.5, delta * 30)
			global_position.y += 0.32
				

	
	# Rotation
	if can_look:
		camera.rotation.z = lerp_angle(camera.rotation.z, -input_mouse.x * 25 * delta, delta * 5)	
		camera.rotation.x = lerp_angle(camera.rotation.x, rotation_target.x, delta * 25)
		camera_origin.rotation.z = lerp_angle(camera_origin.rotation.z, -input_mouse.x * 25 * delta, delta * 5)	
		camera_origin.rotation.x = lerp_angle(camera_origin.rotation.x, rotation_target.x, delta * 25)
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
			if sprinting:
				Leg_anime.play("Sprint")
			else:
				Leg_anime.play("Walking")
	
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
		
	get_interact()


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
	
	#var gun_model_path = load("res://Card Shark/aceGUN.tscn") #Stolen from destiny lol
	#gun = gun_model_path.instantiate()
	#left_container.add_child(gun)
	#gun.rotation_degrees = gun_rotation
	
	#Set model to only render on layer 2 (the weapon camera)
	
	for child in cards.find_children("*", "MeshInstance3D"):
		child.layers = 2
	#for child in gun.find_children("*", "MeshInstance3D"):
	#	child.layers = 2
		#child.position += Vector3(0,1,0)


func two_cards():	
	var _bofa = deck.slice(0,2)
	deck = deck.slice(2,)
	return (_bofa)
	
func set_bofa():
	UI_Card1.text = str(bofa[0]["rank"])
	UI_Card2.text = str(bofa[1]["rank"])
	
func load_bofa(): #This CANNOT be same fn as set_cards because viewport needs to load after set
	#cards.get_node("C1").get_node("Txt").mesh.text = str(hand[0]["rank"])
	for i in range(len(bofa)):
	#	var card_front = cards.get_node("C%d" % (i+1)).get_node("Front").mesh.material
		var card_front = HUD.get_node("C%d" % (i+1)).get_node("Inner/TextureRect")
		var card_type = str(bofa[i]["rank"]) + str(bofa[i]["suit"].left(1))
		var image = load("res://Card Shark/Card Pics/PlayingCard_%s.jpg" % (card_type))
		card_front.texture = image
	
var cards_drawn
func set_cards():
	cards_drawn = min(len(deck),5)
	print("Cards drawn:",cards_drawn)
	hand = []
	hand = deck.slice(0,cards_drawn)
	deck = deck.slice(cards_drawn,)
	all_cards = hand.duplicate()
	all_cards.append_array(bofa)
	best_hand = evaluator_instance.get_best_poker_hand(all_cards)
	print(best_hand)
	print("Size of hand",range(len(hand)))
	print("Size of cards_drawn",cards_drawn)
	
func load_set_cards(): #This CANNOT be same fn as set_cards because viewport needs to load after set
	#cards.get_node("C1").get_node("Txt").mesh.text = str(hand[0]["rank"])
	for i in range(len(hand)):
		var card_front = cards.get_node("C%d" % (i+1)).get_node("Front").mesh.material
		var card_type = str(hand[i]["rank"]) + str(hand[i]["suit"].left(1))
		var image = load("res://Card Shark/Card Pics/PlayingCard_%s.jpg" % (card_type))
		card_front.albedo_texture = image
	if len(hand) < 5: #Make some cards invisible of hand is too smol
		for i in range(0,5):
			if i >= len(hand):
				print("Invis card:",(i+1))
				cards_in_hand.get_node("C%d" % (i+1)).visible = false
	if len(hand) < 1:
		await magic_cooldown.timeout
		shuffle_deck()
		print("auto shuffled")

func discard():
	if Input.is_action_pressed("Ability1"):
		if !magic_cooldown.is_stopped(): return
		if len(hand) > 0:
			magic_cooldown.start(3)
			RA_anime.play("Discard")
			combine_cards() #Merge cards to prepare to throw
			await get_tree().create_timer(0.2).timeout
			right_hand_container.visible = false
			throw_cards() #Instantiates physics cards
			await get_tree().create_timer(1).timeout #This is to allow time for the lerp+slerp to complete before resetting position
			for i in range(1, 6): #return cards to original position while invisible
				var card = right_hand_container.get_node("Card").get_node("C%d" % i)
				var t_node = right_hand_container.get_node("Card").get_node("P%d" % i)
				card.transform = t_node.transform
			set_cards() #Pick cards from deck
			load_set_cards() #Load the textures
			await get_tree().create_timer(0.2).timeout #Ensure it goes visible again after everything is ready
			right_hand_container.visible = true
		else:
			print("auto shuffle")
			shuffle_deck()

func shuffle_deck():
	if !magic_cooldown.is_stopped(): return
	magic_cooldown.start(16)
	
	var t = 0 #Controls rate of card changes while spinning
	var change_delay = 0 #Controls delay until cards begin changing
	var changed_card = 1 #The card that will get changed when shuffling
	var rot_speed = 0.2
	var rot_acc = 7
	var rot_max_speed = 40
	var current_rotation = 0
	var shuffle_node = cards_in_hand.get_node("Shuffles")
	
	combine_cards()
	await get_tree().create_timer(0.5).timeout
	RA_anime.play("Discard")
	
	
	var C1 = HUD.get_node("C1")
	var C2 = HUD.get_node("C2")

	var tween = create_tween()
	tween.tween_property(C1, "position", Vector2(C1.position.x + 250, C1.position.y), 0.7)
	await get_tree().create_timer(0.32).timeout
	var tween2 = create_tween()
	tween2.tween_property(C2, "position", Vector2(C2.position.x + 250, C2.position.y), 0.7)
	
	
	await get_tree().create_timer(1.5).timeout
	for i in range (0,5):
		cards_in_hand.get_node("C%d" % (i+1)).visible = false
	cards_in_hand.get_node("Shuffles").visible = true
	await get_tree().create_timer(0.65).timeout
	deck = initial_deck
	deck.shuffle()
		
	var shuffle_cooldown = get_tree().create_timer(10)
	while shuffle_cooldown.time_left > 0:
		var delta = get_process_delta_time()
		# Rotate 'Target'
		rot_speed = min(rot_speed + rot_acc * delta, rot_max_speed)
		current_rotation = shuffle_node.transform.basis.get_rotation_quaternion()  # Update rotation
		var rotation_delta = Quaternion(Vector3(0, 0, 1), delta)  # Rotate around Z-axis
		var new_rotation = current_rotation.slerp(rotation_delta * current_rotation, rot_speed)
		shuffle_node.transform.basis = Basis(new_rotation)
		await get_tree().process_frame  # Yield execution so it doesn't lock up
		
		#pinn
		
		t += delta
		change_delay += delta
		if t >= 0.25 and changed_card<=13 and change_delay>=6.5:
			t = 0.0
			print("Card Changed",changed_card)
			var mesh_instance = cards_in_hand.get_node("Shuffles/C%d/Front" % changed_card)
			
			# Duplicate the mesh so each card is unique
			var mesh_copy = mesh_instance.mesh.duplicate()
			mesh_instance.mesh = mesh_copy
			
			# Get the material from surface 0
			var original_material = mesh_copy.surface_get_material(0)
			if original_material:
				# Deep-duplicate so sub-resources aren’t shared
				var new_material = original_material.duplicate(true)
				new_material.resource_local_to_scene = true
				
				# Determine which texture to use for this card
				var card_type = str(deck[changed_card-1]["rank"]) + str(deck[changed_card-1]["suit"].left(1))
				var card_texture = load("res://Card Shark/Card Pics/PlayingCard_%s.jpg" % card_type)
				
				new_material.albedo_texture = card_texture
				# Assign the new material to surface 0
				mesh_copy.surface_set_material(0, new_material)

				changed_card += 1
	
	print("While loop expired")
	bofa = two_cards()
	load_bofa()
	var tween_r = create_tween()
	tween_r.tween_property(C1, "position", Vector2(C1.position.x - 250, C1.position.y), 0.7)
	#await get_tree().create_timer(0.32).timeout
	var tween_r2 = create_tween()
	tween_r2.tween_property(C2, "position", Vector2(C2.position.x - 250, C2.position.y), 0.7)
	
	await get_tree().create_timer(0.75).timeout
	RA_anime.play("Discard")
	await get_tree().create_timer(1).timeout
	for i in range (0,5): #Make hand visible and cards in correct places
		var card = cards_in_hand.get_node("C%d" % (i+1))
		var t_node = cards_in_hand.get_node("P%d" % (i+1))
		card.visible = true
		card.transform = t_node.transform
	cards_in_hand.get_node("Shuffles").visible = false
	set_cards() #Pick cards from deck
	load_set_cards() #Load the textures

	# Reset rotation and stop movement
	shuffle_node.transform.basis = Basis(current_rotation)  # Ensure final rotation reset
	rot_speed = 0.7
	rot_acc = 3
	rot_max_speed = 9.5

@onready var flat_path = preload("res://Card Shark Campaign/Character Models/FlatShark.glb")
func flatten():
	#Disable characters body
	generic_disable = true
	self.visible = false
	can_move = false
	LA_anime.stop()
	RA_anime.stop()
	Leg_anime.stop()
	Gen_anime.stop()
	$Collider.disabled = true
	#Place flat CS at feet
	var flat_shark = flat_path.instantiate()
	flat_shark.rotation_degrees = Vector3(0,rotation_degrees.y+270,90)
	flat_shark.position = self.position
	get_tree().root.add_child(flat_shark)
	#Move cam quickly?

	

func trigger_ragdoll(impulse: Vector3):
	
	var ragdoll = ragdoll_glb.instantiate()
	ragdoll.global_position = self.global_position
	#ragdoll.global_rotation = self.global_rotation + Vector3(0,90,0)
	
	Player_glb.visible = false
	ragdoll.visible = true
	
	can_move = false
	is_disabled = true
	LA_anime.stop()
	RA_anime.stop()
	Leg_anime.stop()
	Gen_anime.stop()
	
	var skel = ragdoll.get_node("SharkBones/Skeleton3D")
	hip = ragdoll.get_node("SharkBones/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone Hips")
	var phys = skel.get_node("PhysicalBoneSimulator3D")
	
	
	skel.set_animate_physical_bones(false)
	phys.physical_bones_start_simulation()
	phys.active = true
	$Collider.disabled = true
	get_tree().root.add_child(ragdoll)
	
	


	
	#followhip.position = hip.position #Properly position parent node
	#var dir = impulse.normalized()
	#var cam_pos = (hip.position + dir) * 2 #position cam 5 meters back towards the impulse
	#ragcam.global_transform.origin = cam_pos
	#ragcam.look_at(hip.position)
	
	if impulse != Vector3(0,0,0):
		local_pos = impulse.normalized()
		local_pos = Vector3(local_pos.x,-0.3*local_pos.y,local_pos.z).normalized() * 3.5
		ragcam.global_position = hip.global_position - local_pos
		print("LOCAL POS",local_pos)
		ragcam.look_at(hip.position)
		
		hip.apply_central_impulse(impulse)
		
		ragcam.make_current()
	
	else:
		var back_pos = 2*transform.basis.z
		local_pos = -(Vector3(0,1.5,0) + back_pos)
		ragcam.global_position = hip.global_position - local_pos
		print("LOCAL POS",local_pos)
		ragcam.look_at(hip.position)
		
		hip.apply_central_impulse(impulse)
		
		ragcam.make_current()
		
	#Get back up	
	#get_tree().paused = !get_tree().paused #flip the boolean
	await wait_and_get_up(ragdoll)





func reload_spell():
	if Input.is_action_just_pressed("reload"):
		reload()

func pause_game():
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused #flip the boolean
		pause_menu.visible = get_tree().paused #match menu UI to pause state

	#SHORTCUT SPELL 2 SPELL2

func test_2_spell():
	if Input.is_action_just_pressed("Test_2"):
		#flatten()
		#trigger_ragdoll(Vector3(randi_range(-100,100),200,randi_range(-100,100)))
		#trigger_ragdoll(Vector3(0,0,0))
		#straight_laser_spell()
		flush_spell()

func test_1_spell():
	if Input.is_action_just_pressed("Test_1"):
		#flatten()
		#basking_house_spell()
		melee()
			
func throw_cards():
	for i in range(len(hand)):
		var phys_card = phys_card_scene.instantiate()

		var mesh_instance = phys_card.get_node("Rig/C2/Front")
		
		# Duplicate the mesh so each card is unique
		var mesh_copy = mesh_instance.mesh.duplicate()
		mesh_instance.mesh = mesh_copy

		# Get the material from surface 0
		var original_material = mesh_copy.surface_get_material(0)
		if original_material:
			# Deep-duplicate so sub-resources aren’t shared
			var new_material = original_material.duplicate(true)
			new_material.resource_local_to_scene = true
			
			# Determine which texture to use for this card
			var card_type = str(hand[i]["rank"]) + str(hand[i]["suit"].left(1))
			var card_texture = load("res://Card Shark/Card Pics/PlayingCard_%s.jpg" % card_type)
			
			new_material.albedo_texture = card_texture
			
			# Assign the new material to surface 0
			mesh_copy.surface_set_material(0, new_material)
		
		#var text_node = phys_card.get_node("Rig").get_node("Txt")
		#text_node.mesh = text_node.mesh.duplicate() #Dupe so that they don't share properties (txt)
		#text_node.mesh.text = str(hand[i]["rank"])
		$"../Projectiles".add_child(phys_card)
		phys_card.position = card_container.get_node("spawn").global_position
		#Vert test
		var vert_x = camera.rotation.x
		print("VERT X",vert_x)
		var random_vector = Vector3(randf()*1-0.5,randf()*1,0) # y var was randf()*1
		var local_direction = Vector3(0,vert_x,-0.8)+random_vector #was -0.8
		var random_direction = card_container.get_node("spawn").global_transform.basis * local_direction
		random_direction = random_direction.normalized()
		phys_card.get_node("Rig").linear_velocity = random_direction * 8

func pattern_throw_cards():
	for i in range(len(hand)):
		var phys_card = phys_card_scene.instantiate()

		var mesh_instance = phys_card.get_node("Rig/C2/Front")
		
		# Duplicate the mesh so each card is unique
		var mesh_copy = mesh_instance.mesh.duplicate()
		mesh_instance.mesh = mesh_copy

		# Get the material from surface 0
		var original_material = mesh_copy.surface_get_material(0)
		if original_material:
			# Deep-duplicate so sub-resources aren’t shared
			var new_material = original_material.duplicate(true)
			new_material.resource_local_to_scene = true
			
			# Determine which texture to use for this card
			var card_type = str(hand[i]["rank"]) + str(hand[i]["suit"].left(1))
			var card_texture = load("res://Card Shark/Card Pics/PlayingCard_%s.jpg" % card_type)
			
			new_material.albedo_texture = card_texture
			
			# Assign the new material to surface 0
			mesh_copy.surface_set_material(0, new_material)
		
		$"../Projectiles".add_child(phys_card)
		phys_card.position = card_container.get_node("spawn").global_position
		var x = .5*i
		var moving_vector = Vector3(x,0,0)
		var vert_x = camera.rotation.x
		print(x)
		var local_direction = Vector3(-1,0.7,-4)+moving_vector
		var random_direction = card_container.get_node("spawn").global_transform.basis * local_direction
		random_direction = random_direction.normalized()
		random_direction.y = random_direction.y*vert_x*7
		phys_card.get_node("Rig").linear_velocity = random_direction * 20 #was 15
		await get_tree().create_timer(0.05).timeout

func straightline_throw_cards():
	for i in range(len(hand)):
		var phys_card = boom_card_scene.instantiate()

		var mesh_instance = phys_card.get_node("Rig/C2/Front")
		
		# Duplicate the mesh so each card is unique
		var mesh_copy = mesh_instance.mesh.duplicate()
		mesh_instance.mesh = mesh_copy

		# Get the material from surface 0
		var original_material = mesh_copy.surface_get_material(0)
		if original_material:
			# Deep-duplicate so sub-resources aren’t shared
			var new_material = original_material.duplicate(true)
			new_material.resource_local_to_scene = true
			
			# Determine which texture to use for this card
			var card_type = str(hand[i]["rank"]) + str(hand[i]["suit"].left(1))
			var card_texture = load("res://Card Shark/Card Pics/PlayingCard_%s.jpg" % card_type)
			
			new_material.albedo_texture = card_texture
			
			# Assign the new material to surface 0
			mesh_copy.surface_set_material(0, new_material)
		
		$"../Projectiles".add_child(phys_card)
		phys_card.position = card_container.get_node("spawn").global_position
		var vert_x = camera.rotation.x
		var local_direction = Vector3(0,0.7,-4)
		var random_direction = card_container.get_node("spawn").global_transform.basis * local_direction
		random_direction = random_direction.normalized()
		random_direction.y = random_direction.y*vert_x*7
		phys_card.get_node("Rig").linear_velocity = random_direction * 20
		await get_tree().create_timer(0.05).timeout

func seek_throw_cards():
	for i in range(len(hand)):
		var seek_card = seek_card_scene.instantiate()
		seek_card.enemy_list = ranges.get_node("Spell Range").enemy_list

		var mesh_instance = seek_card.get_node("Rig/C2/Front")
		
		# Duplicate the mesh so each card is unique
		var mesh_copy = mesh_instance.mesh.duplicate()
		mesh_instance.mesh = mesh_copy

		# Get the material from surface 0
		var original_material = mesh_copy.surface_get_material(0)
		if original_material:
			# Deep-duplicate so sub-resources aren’t shared
			var new_material = original_material.duplicate(true)
			new_material.resource_local_to_scene = true
			
			# Determine which texture to use for this card
			var card_type = str(hand[i]["rank"]) + str(hand[i]["suit"].left(1))
			var card_texture = load("res://Card Shark/Card Pics/PlayingCard_%s.jpg" % card_type)
			
			new_material.albedo_texture = card_texture
			
			# Assign the new material to surface 0
			mesh_copy.surface_set_material(0, new_material)
		
		#var text_node = phys_card.get_node("Rig").get_node("Txt")
		#text_node.mesh = text_node.mesh.duplicate() #Dupe so that they don't share properties (txt)
		#text_node.mesh.text = str(hand[i]["rank"])
		$"../Projectiles".add_child(seek_card)
		seek_card.position = card_container.get_node("spawn").global_position
		var random_vector = Vector3(randf()*1-0.5,randf()*1,0)
		var local_direction = Vector3(0,0.5,-0.8)+random_vector
		var random_direction = card_container.get_node("spawn").global_transform.basis * local_direction
		random_direction = random_direction.normalized()
		seek_card.get_node("Rig").linear_velocity = random_direction * 8

func basking_house_spell():
	#if Input.is_action_pressed("Ability2"):
	#cum
	if !basking_house_cooldown.is_stopped(): return
	if !magic_cooldown.is_stopped(): return
	magic_cooldown.start(5)
	print ("F")
	var flying = true
	basking_house_cooldown.start(5)
	basking_shark = basking_shark_path.instantiate()
	basking_shark.global_transform = basking_spawn.global_transform
	get_tree().root.add_child(basking_shark)
	move_shark(basking_shark)
	await get_tree().create_timer(1).timeout #wait to open mouth
	var shark_anime = basking_shark.get_node("PathFollow3D").get_node("Basking Shark").get_node("AnimationPlayer")
	shark_anime.play("Expand")
	shark_anime.speed_scale = 0.7
	# Increase suckbox as mouth opens
	var tween = get_tree().create_tween()
	var sucktween = get_tree().create_tween()

	var sucking_visual = basking_shark.get_node("PathFollow3D/Basking Shark/Sucker/Sucking visual")
	var visual_mesh = sucking_visual.mesh
	var sucking_real = basking_shark.get_node("PathFollow3D/Basking Shark/Sucker/Suckbox")
	var real_mesh = sucking_real.shape

	# Duplicate the mesh and shape so they’re unique instances
	sucking_visual.mesh = visual_mesh.duplicate()
	sucking_real.shape = real_mesh.duplicate()

	# Get references to the duplicates
	var mesh = sucking_visual.mesh
	var shape = sucking_real.shape

	# Animate height
	tween.tween_property(mesh, "height", 2, 0.75)
	sucktween.tween_property(shape, "height", 2, 0.75)
	#await get_tree().create_timer(1.5).timeout
	print("WOP")
	# Animate radius (mesh uses top/bottom, shape uses radius)
	tween.tween_property(mesh, "top_radius", 3, 0.75)
	tween.tween_property(mesh, "bottom_radius", 3, 0.75)
	#sucktween.tween_property(shape, "radius", 3, 0.75)



	
	right_hand_container.visible = false
	set_cards()
	load_set_cards() #Load the textures
	await get_tree().create_timer(0.5).timeout #Ensure it goes visible again after everything is ready
	right_hand_container.visible = true
		
func fourkind_spell():
	if !magic_cooldown.is_stopped(): return
	print("Magic 1 start")
	magic_cooldown.start(4)
	#anime.play("Taunt")
	await get_tree().create_timer(1).timeout
	#Some sort of anime here
	var enemy_list = ranges.get_node("Spell Range").enemy_list
	# Clean up from previous cast
	fourkind_enemies.clear()
	fourkind_goals.clear()
	fourkind_ups.clear()
	fourkind_return_goals.clear()
	for enemy in enemy_list:
		var original_transform = enemy.global_transform
		var original_origin = original_transform.origin
		var up_origin = original_transform.origin + Vector3.UP * 4
		var new_origin = original_transform.origin + Vector3.UP * 3 #Set goal height
		var new_z_rot := Basis(Vector3.RIGHT, deg_to_rad(180)) #Set goal rot
		var enemy_goal := Transform3D(new_z_rot, new_origin)
		var enemy_up_goal := Transform3D(new_z_rot, up_origin)
		var enemy_return_goal := Transform3D(new_z_rot, original_origin) #Return goal is the slam down ending pos
		var effect_goal :=  Transform3D(Basis(), original_origin + Vector3.DOWN * 0.5)
		print(enemy)
		fourkind_enemies.append(enemy) #Add enemy to active list of fourkinding enemies
		fourkind_goals.append(enemy_goal)
		fourkind_ups.append(enemy_up_goal)
		fourkind_return_goals.append(enemy_return_goal)
		enemy.can_move = false
		spawn_slam_effect(enemy,effect_goal)
		if enemy.can_turn: enemy.can_turn = false
	fourkind_lifting = true
	await get_tree().create_timer(1.5).timeout
	fourkind_lifting = false
	fourkind_uping = true
	await get_tree().create_timer(0.5).timeout
	fourkind_uping = false
	fourkind_slamming = true
	await get_tree().create_timer(0.3).timeout
	fourkind_slamming = false
	
	right_hand_container.visible = false
	set_cards()
	load_set_cards() #Load the textures
	await get_tree().create_timer(0.5).timeout #Ensure it goes visible again after everything is ready
	right_hand_container.visible = true

func spawn_slam_effect(enemy,spawn):
	await get_tree().create_timer(2.2).timeout
	if is_instance_valid(enemy): #Check if lil' homie died first, if so remove from all future lists
		var slam_effect = fourkind_slam_scene.instantiate()
		slam_effect.global_transform = spawn
		get_tree().root.add_child(slam_effect)
		if enemy.has_method("damage"):
			enemy.call("damage", 100)
		await get_tree().create_timer(0.3).timeout
		if is_instance_valid(enemy): #Make sure lil homie is alive
			enemy.can_move = true
			if "can_turn" in enemy: enemy.can_turn = true
	

func move_fourkind_enemies(delta):  #Run in process
	var i := 0
	while i < fourkind_enemies.size(): #Only runs when something is in the fourkind_enemies list
		var enemy = fourkind_enemies[i]
		var goal = fourkind_goals[i]
		#var return_goal = fourkind_return_goals[i]
		if not is_instance_valid(enemy): #Check if lil' homie died first, if so remove from all future lists
			fourkind_enemies.remove_at(i)
			fourkind_goals.remove_at(i)
			fourkind_ups.remove_at(i)
			fourkind_return_goals.remove_at(i)
		else:
			TransformUtils.new_lerp_slerp_transform(0.02,enemy, goal, 0.02, 0.1, 0.5, 3, delta)
		i += 1

func up_fourkind_enemies(delta):
	var i := 0
	while i < fourkind_enemies.size(): #Only runs when something is in the fourkind_enemies list
		var enemy = fourkind_enemies[i]
		var up = fourkind_ups[i]
		#var return_goal = fourkind_return_goals[i]
		if not is_instance_valid(enemy): #Check if lil' homie died first, if so remove from all future lists
			fourkind_enemies.remove_at(i)
			fourkind_goals.remove_at(i)
			fourkind_ups.remove_at(i)
			fourkind_return_goals.remove_at(i)
		else:
			TransformUtils.new_lerp_slerp_transform(0.02,enemy, up, 0.02, 0.1, 0.5, 3, delta)
		i += 1	
	

func slam_fourkind_enemies(delta):
	var i := 0
	while i < fourkind_enemies.size(): #Only runs when something is in the fourkind_enemies list
		var enemy = fourkind_enemies[i]
		var return_goal = fourkind_return_goals[i]
		if not is_instance_valid(enemy): #Check if lil' homie died first, if so remove from all future lists
			fourkind_enemies.remove_at(i)
			fourkind_goals.remove_at(i)
			fourkind_ups.remove_at(i)
			fourkind_return_goals.remove_at(i)
		else:
			TransformUtils.new_lerp_slerp_transform(0.1,enemy, return_goal, 0.02, 20, 0.5, 3, delta)
		i += 1
			

func poopy_fart():
	if !magic_cooldown.is_stopped(): return
	magic_cooldown.start(5.5)
	print("PLAY THE POOP")
	Audio.play("Card Shark Campaign/Special Effects/wet-fart-1.mp3")
	#movement_speed = 0.1
	var poop = poopy_path.instantiate()
	var point = get_node("CharacterCenter")
	poop.global_position = point.global_position + 0.3*Vector3.UP
	get_tree().current_scene.add_child(poop)
	#var tween := create_tween()
	#tween.tween_property(self, "movement_speed", 5, 5.0)
	
	toggle_healthbar(false)
	right_hand_container.visible = false
	set_cards()
	load_set_cards() #Load the textures
	await get_tree().create_timer(5.2).timeout #Ensure it goes visible again after everything is ready
	right_hand_container.visible = true
	toggle_healthbar(true)
	
	
func flush_spell():
	if !magic_cooldown.is_stopped(): return
	magic_cooldown.start(5.5)
	print("FLUSH ACTIVATED")
	#Audio.play("Card Shark Campaign/Special Effects/wet-fart-1.mp3")
	var flush = flush_path.instantiate()
	var point = get_node("CharacterCenter")
	var wave = flush.get_node("Wave")
	var white = flush.get_node("White")
	var pushbox = flush.get_node("Pushbox")
	flush.global_position = point.global_position
	get_tree().current_scene.add_child(flush)
	for i in range (0,5):
		print(i)
		flush.global_position = point.global_position
		wave.emitting = true
		white.emitting = true
		flush.global_position = point.global_position
		pushbox.monitoring = true
		pushbox.overlap_check()
		pushbox.expand()
		await get_tree().create_timer(0.5).timeout
		pushbox.monitoring = false
		pushbox.reset()
		await get_tree().create_timer(1).timeout
	
	right_hand_container.visible = false
	set_cards()
	load_set_cards() #Load the textures
	await get_tree().create_timer(0.5).timeout #Ensure it goes visible again after everything is ready
	right_hand_container.visible = true

func move_shark(shark):
	var path_follow = shark.get_node("PathFollow3D")
	path_follow.progress = 0  # Reset position
	path_follow.set_meta("speed", 5)  #pass speed to path3D

	# Enable per-frame movement
	path_follow.set_process(true)

func seeking_card_spell():
#	if Input.is_action_pressed("Test_1"):
	if !magic_cooldown.is_stopped(): return
	magic_cooldown.start(4)
	#Play some sort of spell cast anime
	RA_anime.play("Spell Loop")
	await get_tree().create_timer(1).timeout
	RA_anime.play("Discard")
	combine_cards() #Merge cards to prepare to throw
	await get_tree().create_timer(0.2).timeout
	right_hand_container.visible = false
	seek_throw_cards() #Instantiates physics cards
	await get_tree().create_timer(1).timeout #This is to allow time for the lerp+slerp to complete before resetting position
	for i in range(1, 6): #return cards to original position while invisible
		print("attempt",i)
		var card = right_hand_container.get_node("Card").get_node("C%d" % i)
		var t_node = right_hand_container.get_node("Card").get_node("P%d" % i)
		card.transform = t_node.transform
	set_cards() #Pick cards from deck
	load_set_cards() #Load the textures
	await get_tree().create_timer(0.2).timeout #Ensure it goes visible again after everything is ready
	right_hand_container.visible = true
	
func pattern_card_spell():
#	if Input.is_action_pressed("Test_2"):
	if !magic_cooldown.is_stopped(): return
	magic_cooldown.start(4)
	#Play some sort of spell cast anime
	#anime.play("Taunt")
	#await get_tree().create_timer(1).timeout
	RA_anime.play("Discard")
	combine_cards() #Merge cards to prepare to throw
	await get_tree().create_timer(0.2).timeout
	right_hand_container.visible = false
	pattern_throw_cards() #Instantiates physics cards
	await get_tree().create_timer(1).timeout #This is to allow time for the lerp+slerp to complete before resetting position
	for i in range(1, 6): #return cards to original position while invisible
		print("attempt",i)
		var card = right_hand_container.get_node("Card").get_node("C%d" % i)
		var t_node = right_hand_container.get_node("Card").get_node("P%d" % i)
		card.transform = t_node.transform
	set_cards() #Pick cards from deck
	load_set_cards() #Load the textures
	await get_tree().create_timer(0.2).timeout #Ensure it goes visible again after everything is ready
	right_hand_container.visible = true
	
func straightline_card_spell():
	#if Input.is_action_pressed("Test_3"):
	if !magic_cooldown.is_stopped(): return
	magic_cooldown.start(4)
	#Play some sort of spell cast anime
	#anime.play("Taunt")
	#await get_tree().create_timer(1).timeout
	RA_anime.play("Discard")
	combine_cards() #Merge cards to prepare to throw
	await get_tree().create_timer(0.2).timeout
	right_hand_container.visible = false
	straightline_throw_cards() #Instantiates physics cards
	await get_tree().create_timer(1).timeout #This is to allow time for the lerp+slerp to complete before resetting position
	for i in range(1, 6): #return cards to original position while invisible
		print("attempt",i)
		var card = right_hand_container.get_node("Card").get_node("C%d" % i)
		var t_node = right_hand_container.get_node("Card").get_node("P%d" % i)
		card.transform = t_node.transform
	set_cards() #Pick cards from deck
	load_set_cards() #Load the textures
	await get_tree().create_timer(0.2).timeout #Ensure it goes visible again after everything is ready
	right_hand_container.visible = true

func straight_laser_spell():
	#if Input.is_action_pressed("Right_Click"):
	if !magic_cooldown.is_stopped(): return
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

func cast_spell():
	if Input.is_action_pressed("Right_Click") and not acting:
		if len(hand) > 0:
			if best_hand == "One Pair":
				pattern_card_spell()
			elif best_hand == "Two Pair":
				seeking_card_spell()
			elif best_hand == "Three of a Kind":
				straightline_card_spell()
			elif best_hand == "Straight":
				straight_laser_spell()
			elif best_hand == "Flush":
				flush_spell()
			elif best_hand == "Full House":
				basking_house_spell()
			elif best_hand == "Four of a Kind":
				fourkind_spell()
			elif best_hand == "Straight Flush":
				print("No Straight Flush YEET")
			elif best_hand == "Royal Flush":
				print("OILY FUCKING TITS BRO WTF NO WAY")
			elif best_hand == "High Card":
				print("Poopy fart (:")
				poopy_fart()
			else:
				print("YOU AINT GOT SHIT BOI but frfr wtf do you have cause idk")
		else:
			shuffle_deck()
			print("shuffle")

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

	set_cards()
	load_set_cards()

func laser(delta):
	if active_laser:
		var hit_position
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			if collider:
				if collider.has_method("damage"):
					collider.damage(100*delta)
				elif collider.get_parent().has_method("damage"):
					collider.get_parent().damage(100*delta)
			
			hit_position = raycast.get_collision_point()

			# Spawn the splash scene.
			var splash = splash_path.instantiate()
			#if tree still exists?
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

var combining = false
var combine_t = 0.0  # Progress variable for lerp/slerp

func combine_cards():
	
	if combining:
		return  # Prevent duplicate calls

	combining = true
	combine_t = 0.0  # Reset animation progress

func _process(delta): 
	
	if is_disabled or generic_disable:
		return
	
	if fourkind_lifting:
		move_fourkind_enemies(delta)
	elif fourkind_uping:
		up_fourkind_enemies(delta)
	elif fourkind_slamming:
		slam_fourkind_enemies(delta)
	
	if not combining:
		return

	combine_t += 1.0 * delta  # Increase over time (adjust speed as needed)
	if combine_t > 1:#prevent overshooting
		combine_t = 1.0 
		combining = false  # Stop animating

	var target_node = right_hand_container.get_node("Card").get_node("C3")
	var target_pos = target_node.transform.origin
	var target_quat = target_node.transform.basis.get_rotation_quaternion()

	for i in range(1, 6):
		if i == 3:
			continue

		var card = right_hand_container.get_node("Card").get_node("C%d" % i)

		# Current position
		var from_pos = card.transform.origin

		# Lerp X and Y using combine_t
		var new_pos = Vector3(
			lerp(from_pos.x, target_pos.x, combine_t),
			lerp(from_pos.y, target_pos.y, combine_t),
			from_pos.z # Keep Z unchanged
		)

		# Slerp Rotation
		var from_quat = card.transform.basis.orthonormalized().get_rotation_quaternion()
		var new_quat = from_quat.slerp(target_quat, combine_t)

		# Apply new transform
		card.transform = Transform3D(Basis(new_quat), new_pos)

func sprint(delta):
	#Start sprinting
	if Input.is_action_pressed("Sprint") and stamina > 0 and not acting:
		if not sprinting:
			sprinting = true
			movement_speed = sprint_speed
			replenishing_stamina = false
		stamina = max(stamina - delta, 0)

	#Stop sprinting
	if Input.is_action_just_released("Sprint") or stamina <= 0:
		if sprinting:
			sprinting = false
			movement_speed = walk_speed
			await get_tree().process_frame
			Leg_anime.play("Idle")
			print("STOP")
			sprint_cooldown = 1
			print("STAMINA =   ",stamina)


func reload():
	if Input.is_action_pressed("reload"):
		if item and item.has_method("reload"):
			item.reload()
			print("reload")

func shoot():
	if Input.is_action_pressed("Left_Click"):
		if item and item.has_method("use_item"):
			item.use_item()
			print("shooit")

# Mouse movement
func _input(event):
	if event is InputEventMouseMotion and mouse_captured:
		
		input_mouse = event.relative / mouse_sensitivity
		
		rotation_target.y -= event.relative.x / mouse_sensitivity
		rotation_target.x -= event.relative.y / mouse_sensitivity

func handle_controls(_delta): #Also handles sprint now
	
	sprint(_delta)
	#seeking_card_spell()
	if sprinting:
		pass
		#stamina -= _delta
	else:
		discard()
		shoot()
		#straight_laser_spell()
		#basking_house_spell()
		#pattern_card_spell()
		#straightline_card_spell()
		cast_spell()
		test_2_spell()
		test_1_spell()
		reload_spell()
		pause_game()
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
	
	local_velocity = Vector3(input.x, 0, input.y).normalized()
	
	movement_velocity =  local_velocity * movement_speed
	if get_floor_normal().y < 0.9:
		movement_velocity *= 1.4
	
	
	# Rotation
	
	var rotation_input := Input.get_vector("camera_right", "camera_left", "camera_down", "camera_up")
	
	rotation_target -= Vector3(-rotation_input.y, -rotation_input.x, 0).limit_length(1.0) * gamepad_sensitivity
	rotation_target.x = clamp(rotation_target.x, deg_to_rad(-90), deg_to_rad(90))
	
	# Jumping
	
	if Input.is_action_just_pressed("jump"):
		
		if jump_single or (jump_double and can_double_jump):
			Audio.play("sounds/jump_a.ogg, sounds/jump_b.ogg, sounds/jump_c.ogg")
		
		if jump_double and can_double_jump:
			
			gravity = -jump_strength
			jump_double = false
			
		if(jump_single) and is_on_floor(): action_jump()
		
# Handle gravity

func handle_gravity(delta):
	
	gravity += 20 * delta
	
	if gravity > 0 and is_on_floor():
		
		jump_single = true
		gravity = 0

# Jumping

func action_jump():
	
	#anime.play("Jump") FIX JUMP ANIME HERE
	gravity = -jump_strength
	
	jump_single = false;
	jump_double = true;

var melee_scene = preload("res://Card Shark Campaign/CS_MELEE.tscn")

func melee():
	#melee_camgoal = $melee_camgoal
	#ar lerpspeed = 4
	#var slerpspeed = 3
	if not acting:
		player_collider.disabled = true
		vulnerable = false
		cursor.visible = false
		self.visible = false
		can_move = false
		can_look = false
		var center = get_node("CharacterCenter")
		var melee_bullet = melee_scene.instantiate()
		var melee_hitbox = melee_bullet.get_node("Melee_Hit")
		melee_camgoal = melee_bullet.get_node("cam_goal") #FOLLOW THE CAM GOAL NODE
		get_tree().root.add_child(melee_bullet)
		melee_bullet.global_transform = center.global_transform
		#melee_bullet.global_position = self.global_position
		acting = true
		melee_bullet.get_node("GenericController").play("Melee Attack")
		melee_bullet.rotate_y(deg_to_rad(90))
		var forward_dir = melee_bullet.global_transform.basis.x
		await get_tree().process_frame
		moving_cam = true
		#MOVE THE CAM
		#cam2.make_current()
		await get_tree().create_timer(0.2).timeout
		melee_bullet.apply_central_impulse(10*forward_dir)
		melee_hitbox.monitoring = true
		melee_hitbox.overlap_check()
		print("MELEE DMG")
		#melee_hitbox.attack()
		await get_tree().create_timer(1.1).timeout
		self.velocity = Vector3.ZERO
		self.global_position = melee_bullet.global_position
		melee_bullet.queue_free()
		player_collider.disabled = false
		cursor.visible = true
		vulnerable = true
		camera.global_transform = camera_origin.global_transform
		self.visible = true
		can_move = true
		can_look = true
		moving_cam = false
		acting = false
		#camera.make_current()
		#cam2.global_position = camera.global_position

func move_cam(delta):
	TransformUtils.lerp_slerp_node(camera, melee_camgoal, 2, 2, delta)
	print("MOVING THE CAM")


func damage(amount):
	if vulnerable:
		health -= amount
		health_updated.emit(health) # Update health on HUD, possibly obselete
		chipbar.call("display_chips",health)
		#Audio.play("sounds/ahhhhhhhhh.ogg")
		if amount <= 45:
			var rand_sound = randi_range(1,6)
			Audio.play("SOUND EFFECTS & VOICE LINES/CS_Damage_%d.wav" % rand_sound)
		elif amount > 45:
			Audio.play("SOUND EFFECTS & VOICE LINES/CS_Damage_7.wav")
	else:
		print("player is invulnerable, cant be dmged")

	
	
	if health < 0:
		trigger_ragdoll(Vector3(0,0,0))
		$HUD/BUST.visible = true
		$HUD/Crosshair.visible = false
		
		#get_tree().reload_current_scene() # Reset when out of health
		

func toggle_healthbar(vis: bool):
	for bar in get_tree().get_nodes_in_group("Healthbars"):
		bar.can_appear = vis
		if vis == false:
			bar.visible = vis

@onready var int_prompt = get_node("HUD/Interact")
func get_interact():
	if raycast_int.is_colliding():
		var collider = raycast_int.get_collider()
		if collider and collider.has_method("interac"):
			print("intable")
			int_prompt.visible = true
			if Input.is_action_pressed("Interact"):
				collider.interac()
			else: return
		else:
			int_prompt.visible = false
	else:
		int_prompt.visible = false
#Fin

func get_up(ragdoll):
	
	var skel = ragdoll.get_node("SharkBones/Skeleton3D")
	var hip = ragdoll.get_node("SharkBones/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone Hips")
	
	ragdoll.queue_free()
	Player_glb.visible = true
	self.global_position = hip.global_position + Vector3.UP
	can_move = true
	is_disabled = false
	#LA_anime.start()
	#RA_anime.stop()
	#Leg_anime.stop()
	#Gen_anime.stop()
	#skel.set_animate_physical_bones(false)
	#skel.get_node("PhysicalBoneSimulator3D").physical_bone_s
	skel.get_node("PhysicalBoneSimulator3D").active = false
	$Collider.disabled = false
	camera.make_current()
	
	#await get_tree().create_timer(1).timeout


func wait_and_get_up(ragdoll):
	var hip = ragdoll.get_node("SharkBones/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone Hips")
	if hip == null:
		print("Error: Hip bone not found!")
		return
	
	var min_wait = 2.0
	var max_wait = 7.0
	var elapsed = 0.0
	var delta = 0.1  # check interval
	var speed_threshold = 0.5  # velocity magnitude considered "slow enough"

	while elapsed < max_wait:
		await get_tree().create_timer(delta).timeout
		elapsed += delta
		
		# Only allow get_up if minimum time passed AND hip is slow enough
		if elapsed >= min_wait and hip.linear_velocity.length() <= speed_threshold:
			break
	
	await get_tree().create_timer(0.5).timeout
	if health > 0:
		get_up(ragdoll)

func new_item():
	item = item_container.get_child(0)
