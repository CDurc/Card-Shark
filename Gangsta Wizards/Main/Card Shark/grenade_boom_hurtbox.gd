#Can also hurt player on purpose

extends Area3D

@export var damage: float
var enemy_list = []
var can_damage: = true
#@onready var player = get_tree().get_first_node_in_group("Player")

func _ready():
	await get_tree().create_timer(3).timeout
	can_damage = false
	


func _on_body_entered(body: Node3D) -> void:
	if (body.is_in_group("Enemies") or body.is_in_group("Player")) and body not in enemy_list and can_damage:
		enemy_list.append(body)
		body.damage(damage)
		await get_tree().create_timer(0.5).timeout
		can_damage = false
