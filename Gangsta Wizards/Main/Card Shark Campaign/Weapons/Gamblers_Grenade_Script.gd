#Gambler's Nade
extends Node3D

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var grenade = get_child(1)
@onready var nade_spawn = $GrenadeSpawn

var live_nade_scene = preload("res://Card Shark Campaign/Weapons/live_gamblers_grenade.tscn")
var hold_time: float = 0.0
var holding: = false
var grenades: int = 200
var can_throw: = true
var can_release: = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if holding:
		hold_time += delta

func hold_item() -> void:
	if grenades >= 1 and can_throw:
		print("THROW ATTEMPT")
		can_throw = false
		grenade = get_child(1)
		holding = true
		#player.LA_anime.play("Grenade Aim")
		grenade.pull_pin()
	
func release_item() -> void:
	if can_release and holding:
		can_release = false
		holding = false
		if grenade:  #Check to make sure grenade still exists/ hasnt exploded
			grenades -= 1
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
		if grenades <= 0:
			next_nade.visible = false
		add_child(next_nade)
		next_nade.global_position = nade_spawn.global_position
		await get_tree().create_timer(0.5).timeout
		can_throw = true
		can_release = true

	
