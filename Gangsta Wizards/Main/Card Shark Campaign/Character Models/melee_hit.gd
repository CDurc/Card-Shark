extends Area3D

@export var damage := 50

@onready var player = $".."

@export var damaged_bodies := {} 


func overlap_check():
	var overlapping_bodies = get_overlapping_bodies()
	for body in overlapping_bodies:
		if body != player and body.has_method("damage"):
			body.damage(damage)
			damaged_bodies[body] = true

func _on_body_entered(body):

	if body != player and body.has_method("damage"):
		if body not in damaged_bodies:
			body.damage(damage)
			damaged_bodies[body] = true
