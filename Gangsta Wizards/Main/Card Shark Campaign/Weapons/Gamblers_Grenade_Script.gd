#Gambler's Nade
extends Node3D

@export var put_away = false
@export var weapon_type: int

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var grenade = get_child(1)
@onready var nade_spawn = $GrenadeSpawn
@onready var ammo_counter = player.get_node("HUD/Bottombar/Ammo_icon/Ammo")


var live_nade_scene = preload("res://Card Shark Campaign/Weapons/live_gamblers_grenade.tscn")
var hold_time: float = 0.0
var holding: = false
var ammo: int = 200
var can_throw: = true
var can_release: = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if holding:
		hold_time += delta

func hold_item() -> void:
	print("Attempted to use item")
	if put_away: return
	print("put away was false")
	if ammo >= 1 and can_throw:
		print("THROW ATTEMPT")
		can_throw = false
		grenade = get_child(1)
		holding = true
		#player.LA_anime.play("Grenade Aim")
		grenade.pull_pin()
	
func release_item() -> void:
	if put_away: return
	if can_release and holding:
		can_release = false
		holding = false
		if grenade:  #Check to make sure grenade still exists/ hasnt exploded
			ammo -= 1
			ammo_counter.text = str(ammo)
			#player.LA_anime.play("Grenade Throw")
			print("Item held for ", hold_time, " seconds")
			hold_time = 0.0
			await get_tree().create_timer(0.1).timeout
			if grenade:
				grenade.throw_grenade_g()
				await get_tree().create_timer(0.7).timeout
			
		#Grab new grenade
		player.LA_anime.play("Reload")
		await get_tree().create_timer(1.5).timeout
		var next_nade = live_nade_scene.instantiate()
		if ammo <= 0:
			next_nade.visible = false
		add_child(next_nade)
		next_nade.global_position = nade_spawn.global_position
		await get_tree().create_timer(0.5).timeout
		can_throw = true
		can_release = true

	
