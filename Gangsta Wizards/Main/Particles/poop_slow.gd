extends Area3D

@onready var player:Node3D = get_tree().get_first_node_in_group("Player")
var inside = false


func _ready() -> void:
	await get_tree().create_timer(9).timeout
	queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body == player:
		body.movement_speed = (body.walk_speed)/2
		print("SLOW RN")
		inside = true
		


func _on_body_exited(body: Node3D) -> void:
	if body == player:
		body.movement_speed = body.walk_speed
		print("FAST AGAIN")
		inside = false

func _physics_process(delta: float) -> void:
	if inside:
		player.stamina = -1
		player.sprint_cooldown = 1
		print("STAMINA:   ",player.stamina)
	
