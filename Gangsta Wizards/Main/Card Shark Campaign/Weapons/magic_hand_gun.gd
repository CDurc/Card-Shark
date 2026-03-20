#Magic HandGun
extends Node3D

signal shoot_magic_bullets

@onready var gun_cooldown = $GunCooldown
@onready var magic_bullet_cooldown = $MagicBulletCooldown
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var gun_anime = $SharkGun2/AnimationPlayer
@onready var bullet_spawn = $Bullet_spawn
@onready var magic_bullet_spawn = $Bullet_spawn2
@onready var magic_hand = $Phys
@onready var mouse_sensitivity = player.mouse_sensitivity
@onready var magic_bullet_path = preload("uid://3ulswtvxvud8")
@onready var behind_pos = $Behind_pos
@onready var magic_hand_pos = $MagicHand_pos

var shot_count = 0 #Number of shots fired during magic hand ability
var is_frozen = false
var hand_ability
var ability_phase = 0
var can_ability = true
var reloading = false
var magic_cam
var ending_ability = false
var ability_ready = true
@export var bullet_path = preload("uid://c12fc3guvo5gu")

#@onready var ammo = player.ammo
@onready var acting = player.acting
@onready var ammo_counter = player.get_node("HUD/Bottombar/Ammo_icon/Ammo")
@onready var left_container = player.get_node("Head/Camera/SubViewportContainer/SubViewport/CameraItem/LeftContainer")
@onready var camera = player.get_node("Head/Camera")
@onready var raycast = player.get_node("Head/Camera/RayCast")
var magic_raycast
@onready var LA_anime = player.get_node("TheCardShark2/LeftArmController")

@export var dmg: float
@export var clip_ammo: int
@export var cooldown: float #Theres now a GunCooldown thing in editor so this is probs obsolete
@export var reload_time: float
@export var spread: float
@export var burst: int
@export var HS_mult: float
@export var Velocity: float
@export var recoil: float
@export var put_away = false
@export var weapon_type: int
var ammo: int
var hand: = true #True is real hand, false is magic hand
var _returning = false

func _ready() -> void:
	ammo = clip_ammo
	pass


var return_speed := 20.0

func _process(delta: float) -> void:
#	if _returning:
#		var pos_diff = behind_pos.global_position - hand_ability.global_position
#		var rot_diff = behind_pos.global_rotation - hand_ability.global_rotation
#		
#		hand_ability.global_position += pos_diff.normalized() * return_speed * delta
#		hand_ability.global_rotation += rot_diff.normalized() * return_speed * delta
	pass
	
func _input(event):
	if is_frozen and event is InputEventMouseMotion:
		rotate_frozen_hand(event.relative)

func rotate_frozen_hand(mouse_delta: Vector2):
	hand_ability.rotate_y(-mouse_delta.x / mouse_sensitivity)
	hand_ability.rotate_object_local(Vector3.RIGHT, mouse_delta.y / mouse_sensitivity)

func use_item():
	if put_away: return
	if ability_phase == 0:
		#Engine.time_scale = 0.4
		if player.acting == true: return
		if !gun_cooldown.is_stopped(): return
		if player.ammo <= 0 and not player.reloading:
			reload()
			return
		if reloading: return
		
		#gun_anime.play("Fire")
		gun_cooldown.start(cooldown)
		
		for i in range(burst):
			ammo -= 1
			ammo_counter.text = str(ammo)
			shoot_a_bullet()
			camera.rotation.x += recoil
			await get_tree().create_timer(0.07).timeout

		if ammo <= 0:
			await get_tree().create_timer(0.3).timeout
			reload()
		

func use_item_press():
	if ability_phase ==2 and shot_count<3:
		if !magic_bullet_cooldown.is_stopped(): return
		shot_count += 1
		shoot_magic_bullet()

func reload():
	if put_away: return
	if player.acting == true: return
	reloading = true
	#gun_anime.play("Reload")
	await get_tree().create_timer(max(reload_time - 2,0.1)).timeout
	player.LA_anime.play("Reload")
	await get_tree().create_timer(2).timeout
	if not put_away:
		ammo = clip_ammo
		ammo_counter.text = str(ammo)
		await get_tree().process_frame
	reloading = false


func shoot_a_bullet():
	print("shoot a normal bullet")
	var bullet = bullet_path.instantiate()
	bullet.target_group = "Enemies"
	bullet.damage_amount = dmg
	bullet.HS_mult = HS_mult
	
	raycast.target_position.x = randf_range(-spread, spread) * raycast.target_position.z
	raycast.target_position.y = randf_range(-spread, spread) * raycast.target_position.z
	raycast.force_raycast_update()
	
	var dir: Vector3
	if raycast.is_colliding():
		# Shoot towards collision point
		if hand:
			dir = (raycast.get_collision_point() - bullet_spawn.global_transform.origin).normalized()
		else:
			dir = (raycast.get_collision_point() - magic_bullet_spawn.global_transform.origin).normalized()
	else:
		# If nothing hit, shoot forward from camera
		dir = -camera.global_transform.basis.z
		
		#dir.x += randf_range(-spread, spread)
		#dir.y += randf_range(-spread, spread)
		dir = dir.normalized()

	Audio.play_pitch("sounds/blaster_repeater.ogg", 0.65) #Consider adding a pitch RV
	get_tree().root.add_child(bullet)
	#Spawn at correct muzzle
	if hand:
		bullet.global_transform = bullet_spawn.global_transform
	else:
		bullet.global_transform = magic_bullet_spawn.global_transform
	hand = !hand
	bullet.look_at(bullet.global_transform.origin + dir)
	bullet.apply_impulse(dir * Velocity)

func shoot_magic_bullet():
	print("shoot a magic bullet")
	#var magic_bullet = bullet_path.instantiate()
	var magic_bullet = magic_bullet_path.instantiate()
	var magic_ability_bullet_spawn = hand_ability.get_node("Magic_spawn")
	#magic_bullet.target_group = "Enemies"
	#magic_bullet.damage_amount = dmg
	#magic_bullet.HS_mult = HS_mult
	
	#magic_raycast.target_position.x = randf_range(-spread, spread) * magic_raycast.target_position.z
	#magic_raycast.target_position.y = randf_range(-spread, spread) * magic_raycast.target_position.z
	#await get_tree().process_frame
	magic_raycast.force_raycast_update()
	#await get_tree().process_frame
	#await get_tree().process_frame
	
	var dir: Vector3
	if magic_raycast.is_colliding():
		# Shoot towards collision point
		print("Working collider")
		print("Hit: ", magic_raycast.get_collider())
		dir = (magic_raycast.get_collision_point() - magic_ability_bullet_spawn.global_transform.origin).normalized()
	else:
		# If nothing hit, shoot forward from camera
		print("Collision failed, backup used")
		dir = -magic_cam.global_transform.basis.z
		dir = dir.normalized()

	Audio.play_pitch("sounds/blaster_repeater.ogg", 0.65) #Consider adding a pitch RV
	#Spawn at correct muzzle
	get_tree().root.add_child(magic_bullet)
	magic_bullet.global_transform = magic_ability_bullet_spawn.global_transform
	magic_bullet.look_at(magic_bullet.global_transform.origin + dir)
	#await get_tree().create_timer(0.1).timeout
	if shot_count == 1:
		await shoot_magic_bullets
		await get_tree().create_timer(0.005).timeout
		magic_bullet.draw_ray()
		await get_tree().create_timer(0.002).timeout
		magic_bullet.queue_free()
	elif shot_count == 2:
		await shoot_magic_bullets
		await get_tree().create_timer(0.006).timeout
		magic_bullet.draw_ray()
		await get_tree().create_timer(0.002).timeout
		magic_bullet.queue_free()
	elif shot_count == 3:
		await get_tree().create_timer(0.001).timeout
		#if not ending_ability:
		#	ending_ability = true
		#	end_ability()
		await shoot_magic_bullets
		await get_tree().create_timer(0.007).timeout
		magic_bullet.draw_ray()
		print("RAY DRAWN")
		await get_tree().create_timer(0.002).timeout
		magic_bullet.queue_free()
		print("finally free")
		
	#magic_bullet.apply_impulse(dir * Velocity)

func ability():
	if put_away: return
	if can_ability == false: return #This is for a wait period before you can freeze the hand
	if ability_ready == false: return #This is for the cooldown of reusuing the ability
	if ability_phase == 0:
		#duplicate magic hand
		can_ability = false
		ability_phase = 1 #Hand is flying
		print("abillibty")
		hand_ability = magic_hand.duplicate()
		magic_raycast = hand_ability.get_node("Magic_Cam/RayCast")
		get_tree().root.add_child(hand_ability)
		hand_ability.global_transform = magic_hand.global_transform
		magic_hand.visible = false
		hand_ability.freeze = false
		hand_ability.get_node("collider").disabled = false
		
		#Ray trace endpoint
		raycast.target_position.x = randf_range(-spread, spread) * raycast.target_position.z
		raycast.target_position.y = randf_range(-spread, spread) * raycast.target_position.z
		raycast.force_raycast_update()
		
		var dir: Vector3
		if raycast.is_colliding():
			# Shoot towards collision point
			dir = (raycast.get_collision_point() - bullet_spawn.global_transform.origin).normalized()
		else:
			# If nothing hit, shoot forward from camera
			dir = -camera.global_transform.basis.z
			
			dir.x += randf_range(-spread, spread)
			dir.y += randf_range(-spread, spread)
			dir = dir.normalized()
			
		hand_ability.apply_impulse(dir * 20)
	
		await get_tree().create_timer(0.5).timeout
		can_ability = true
	
	elif ability_phase == 1:
		ability_phase = 2 #hand is stationary
		magic_cam = hand_ability.get_node("Magic_Cam")
		player.can_look = false
		player.can_move = false
		hand_ability.freeze = true
		Engine.time_scale = 0.01
		magic_cam.current = true
		is_frozen = true
		await get_tree().create_timer(0.04).timeout
		if not ending_ability:
			ending_ability = true
			end_ability()
		
func end_ability():
	ability_ready = false
	print("ability over")
	ability_phase = 3 #Does nothing atm but prevents other phases
	magic_cam.current = false
	shoot_magic_bullets.emit()
	await get_tree().create_timer(0.008).timeout
	hand_ability.reparent(self)
	player.can_look = true
	player.can_move = true
	Engine.time_scale = 1.0
	is_frozen = false
	#Return the ghost hand
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(hand_ability, "position", magic_hand.position, 1.0)
	tween.tween_property(hand_ability, "rotation", magic_hand.rotation, 1.0)
	await tween.finished
	magic_hand.visible = true
	hand_ability.queue_free()
	await get_tree().create_timer(0.1).timeout
	ability_phase = 0
	await get_tree().create_timer(1.9).timeout
	can_ability = true
	ability_ready = true
	ending_ability = false
	shot_count = 0
