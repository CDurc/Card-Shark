#Use this for any hitscan weapon
extends Node3D
@onready var gun_cooldown = $GunCooldown
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var gun_anime = $SharkGun2/AnimationPlayer

var reloading = false
var reload_time = 2

@onready var ammo = player.ammo
@onready var acting = player.acting
@onready var ammo_counter = player.get_node("HUD/Bottombar/Ammo_icon/Ammo")
@onready var left_container = player.get_node("Head/Camera/SubViewportContainer/SubViewport/CameraItem/LeftContainer")
@onready var camera = player.get_node("Head/Camera")
@onready  var raycast = player.get_node("Head/Camera/RayCast")
@onready var LA_anime = player.get_node("TheCardShark2/LeftArmController")

@export var dmg: float
@export var clip_ammo: int
@export var cooldown: float
@export var HS_Mult: float
@export var spread: float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func use_item():
	if player.acting == true: return
	if !gun_cooldown.is_stopped(): return
	if player.ammo <= 0 and not player.reloading:
		reload()
		return
	if reloading: return
	
	ammo -= 1
	Audio.play("sounds/blaster_repeater.ogg")
	gun_anime.play("Fire")
	ammo_counter.text = str(ammo)
	
	
	# Set muzzle flash position, play animation	
	#left_muzzle.rotation_degrees.z = randf_range(-45, 45)
	#left_muzzle.scale = Vector3(0.5,0.5,0.5) * randf_range(0.40, 0.75)
	#left_muzzle.position = left_container.position + left_container_offset + Vector3(-.3,0.4,-3)
	#left_muzzle.play("default")
	
	#Durc
#	gun.get_node("Sketchfab_model").get_node("Ace Of Spades_fbx").get_node("RootNode").get_node("MuzzleFlash").play("default")
	
	
	
	gun_cooldown.start(cooldown)
	
	# Shoot the weapon, amount based on shot count
	
	for n in range(1):
	
		raycast.target_position.x = randf_range(-spread, spread) * raycast.target_position.z
		raycast.target_position.y = randf_range(-spread, spread) * raycast.target_position.z
		
		raycast.force_raycast_update()
		
		if !raycast.is_colliding(): continue
		
		var collider = raycast.get_collider()
		# Hitting an enemy
		
		if collider.has_method("damage"): #Should become obsolete
			collider.damage(dmg)
		elif collider.get_parent().has_method("damage"):
			if collider.is_in_group("Headshot"):
				collider.get_parent().damage(dmg * HS_Mult)
			elif collider.is_in_group("Bodyshot"):
				collider.get_parent().damage(dmg)
		
		# Creating an impact animation
		
		var impact = preload("res://objects/impact.tscn")
		var impact_instance = impact.instantiate()
		
		impact_instance.play("shot")
		
		get_tree().root.add_child(impact_instance)
		
		impact_instance.position = raycast.get_collision_point() + (raycast.get_collision_normal() / 10)
		impact_instance.look_at(camera.global_transform.origin, Vector3.UP, true) 
		
		left_container.position.z += 0.25 # Knockback of weapon visual
		camera.rotation.x += 0.025 # Knockback of camera
			
	if ammo == 0:
		await get_tree().create_timer(0.3).timeout
		reload()


func reload():
	if player.acting == true: return
	reloading = true
	gun_anime.play("Reload")
	await get_tree().create_timer(0.5).timeout
	LA_anime.play("Reload")
	await get_tree().create_timer(reload_time - 0.5).timeout
	ammo = clip_ammo
	ammo_counter.text = str(ammo)
	await get_tree().process_frame
	reloading = false
