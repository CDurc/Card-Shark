#Magic HandGun
extends Node3D
@onready var gun_cooldown = $GunCooldown
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var gun_anime = $SharkGun2/AnimationPlayer
@onready var bullet_spawn = $Bullet_spawn
@onready var magic_bullet_spawn = $Bullet_spawn2
@onready var magic_hand = $Phys

var hand_ability
var ability_phase = 0
var can_ability = true
var reloading = false
@export var bullet_path = preload("uid://c12fc3guvo5gu")

#@onready var ammo = player.ammo
@onready var acting = player.acting
@onready var ammo_counter = player.get_node("HUD/Bottombar/Ammo_icon/Ammo")
@onready var left_container = player.get_node("Head/Camera/SubViewportContainer/SubViewport/CameraItem/LeftContainer")
@onready var camera = player.get_node("Head/Camera")
@onready var raycast = player.get_node("Head/Camera/RayCast")
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

func _ready() -> void:
	ammo = clip_ammo
	pass


func _process(delta: float) -> void:
	pass


func use_item():
	if put_away: return
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
		dir = (raycast.get_collision_point() - bullet_spawn.global_transform.origin).normalized()
	else:
		# If nothing hit, shoot forward from camera
		dir = -camera.global_transform.basis.z
		
		dir.x += randf_range(-spread, spread)
		dir.y += randf_range(-spread, spread)
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

func ability():
	if put_away: return
	if can_ability == false: return
	if ability_phase == 0:
		#duplicate magic hand
		can_ability = false
		ability_phase = 1
		print("abillibty")
		hand_ability = magic_hand.duplicate()
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
			
		hand_ability.apply_impulse(dir * 12)
	
		await get_tree().create_timer(0.5).timeout
		can_ability = true
	
	elif ability_phase ==1:
		var magic_cam = hand_ability.get_node("Magic_Cam")
		player.can_look = false
		magic_cam.current = true
		hand_ability.freeze = true
		Engine.time_scale = 0.2
