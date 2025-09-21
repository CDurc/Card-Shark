extends Area3D

@onready var player = get_tree().get_first_node_in_group("Player")
var initial_speed = 60 
var decay = 35 #Inital y component of launch, decays to simulate gravity
var flying = false
var car_direction
var fly_direction


func _physics_process(delta):
	if flying:
		fly()
		decay -= delta*25

func _on_body_entered(body):
	if body == player:
		car_direction = -(global_transform.basis.x.normalized())
		#fly_direction = (3*car_direction + Vector3.UP).normalized()
		
		#player.can_move = false
		#flying = true
		player.trigger_ragdoll(20*(5*car_direction + Vector3.UP).normalized())
		
		#await get_tree().create_timer(3).timeout
		#player.can_move = true
		#flying = false
		#decay = 35
		
func fly():
	player.velocity = (car_direction * initial_speed) + (Vector3.UP * decay)
	player.move_and_slide()
