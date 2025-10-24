extends Area3D
@onready var player = $".."
var damage = 30

func attack():
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body != player and body.has_method("damage"):
			body.damage(damage)
