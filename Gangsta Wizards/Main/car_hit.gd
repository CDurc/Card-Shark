extends Area3D

@export var weight:float = 1

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var speed = abs(get_parent().get_parent().mps)  #speed scales from 60 to 250, weight scales from 1 to 2


var car_direction

func _ready():
	weight *= 2

func _on_body_entered(body):
	if body == player:
		car_direction = -(global_transform.basis.x.normalized())
		
		var scalar = speed * weight * 4
		#player.trigger_ragdoll(200*(car_direction + Vector3.UP).normalized())
		var horizontal_force = car_direction * scalar
		var vertical_force = Vector3.UP * scalar / 1.75
		print("WEIGHT  ",weight)
		print("SCALAR  ",scalar)
		
		var launch_vector = (horizontal_force + vertical_force)
		print("LAUNCH          ",launch_vector)
		player.call_deferred("trigger_ragdoll", launch_vector)
