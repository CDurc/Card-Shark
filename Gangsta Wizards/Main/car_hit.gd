extends Area3D

@onready var player = get_tree().get_first_node_in_group("Player")
var initial_speed = 70
var decay = 1
var flying = false
var car_direction
var fly_direction


func _physics_process(delta):
	if flying:
		fly()
		decay -= decay*delta

func _on_body_entered(body):
	if body == player:
		car_direction = -(global_transform.basis.x.normalized())
		fly_direction = (3*car_direction + Vector3.UP).normalized()
		
		player.can_move = false
		flying = true
		
		await get_tree().create_timer(3).timeout
		player.can_move = true
		flying = false
		
func fly():
	player.velocity = fly_direction * initial_speed * decay
	player.move_and_slide()
