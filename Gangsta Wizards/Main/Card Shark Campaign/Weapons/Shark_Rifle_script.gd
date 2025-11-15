#Use this for any projectile gun
extends Node3D
@onready var gun_cooldown = $GunCooldown
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var gun_anime = $SharkGun2/AnimationPlayer
@onready var bullet_spawn = $Bullet_spawn

var reloading = false
var bullet_path = preload("res://Particles/bullet.tscn")

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
var ammo: int

func _ready() -> void:
	ammo = clip_ammo
	pass


func _process(delta: float) -> void:
	pass


func use_item():
	if player.acting == true: return
	if !gun_cooldown.is_stopped(): return
	if player.ammo <= 0 and not player.reloading:
		reload()
		return
	if reloading: return
	
	#gun_anime.play("Fire")
	gun_cooldown.start(cooldown)
	
	for i in range(3):
		ammo -= 1
		ammo_counter.text = str(ammo)
		shoot_a_bullet()
		await get_tree().create_timer(0.07).timeout

	if ammo <= 0:
		await get_tree().create_timer(0.3).timeout
		reload()


func reload():
	if player.acting == true: return
	reloading = true
	#gun_anime.play("Reload")
	await get_tree().create_timer(0.5).timeout
	player.LA_anime.play("Reload")
	await get_tree().create_timer(reload_time - 0.5).timeout
	ammo = clip_ammo
	ammo_counter.text = str(ammo)
	await get_tree().process_frame
	reloading = false


func shoot_a_bullet():
	var bullet = bullet_path.instantiate()
	bullet.target_group = "Enemies"
	bullet.damage_amount = dmg
	
	raycast.target_position.x = randf_range(-0.5, 0.5)  # optional spread
	raycast.target_position.y = randf_range(-0.5, 0.5)
	raycast.force_raycast_update()
	
	var dir: Vector3
	if raycast.is_colliding():
		# Shoot towards collision point
		dir = (raycast.get_collision_point() - bullet_spawn.global_transform.origin).normalized()
	else:
		# If nothing hit, shoot forward from camera
		dir = -camera.global_transform.basis.z

	Audio.play_pitch("sounds/blaster_repeater.ogg", 0.65) #Consider adding a pitch RV
	get_tree().root.add_child(bullet)
	bullet.global_transform = bullet_spawn.global_transform
	bullet.look_at(bullet.global_transform.origin + dir)
	bullet.apply_impulse(dir * 60.0)
