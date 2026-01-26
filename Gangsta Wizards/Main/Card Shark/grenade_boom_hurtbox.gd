#Can also hurt player on purpose

extends Area3D

@export var damage: float
@export var explosion_time = 0.5
var enemy_list = []
var can_damage: = true
var can_damage_player: = true #Can be changed in code on instantiation
var time: float = 0.0
#@onready var player = get_tree().get_first_node_in_group("Player")

func _ready():
	await get_tree().create_timer(3).timeout
	can_damage = false

func _process(delta):
	time += delta


func _on_body_entered(body: Node3D) -> void:
	if time < explosion_time:
		if body.is_in_group("Enemies") and body not in enemy_list and can_damage:
			enemy_list.append(body)
			body.damage(damage)
			await get_tree().create_timer(0.5).timeout
			can_damage = false
		elif body.is_in_group("Player") and can_damage_player and body not in enemy_list:
			enemy_list.append(body)
			body.damage(damage/2)
			await get_tree().create_timer(0.5).timeout
			can_damage = false
			print("DAMAGED PLAYER", damage/2)
