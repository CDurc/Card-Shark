
extends Area3D

@export var damage := 60

var goblin
@export var damaged_bodies := {} 

func _ready():
	goblin = get_parent()
	monitoring = true

func overlap_check():
	var overlapping_bodies = get_overlapping_bodies()
	for body in overlapping_bodies:
		if body != goblin and body.has_method("damage"):
			body.damage(damage)
			damaged_bodies[body] = true

func _on_body_entered(body):
	
	if not goblin or not goblin.damaging:
		return

	if not body.is_in_group("Enemies") and body.has_method("damage"):
		if body not in damaged_bodies:
			body.damage(damage)
			damaged_bodies[body] = true
			#flatten(body)
			await get_tree().create_timer(2).timeout
			damaged_bodies.clear()
