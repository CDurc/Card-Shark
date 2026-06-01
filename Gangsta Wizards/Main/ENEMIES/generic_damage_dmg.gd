#generic dmg area
#This script ALWAYS does dmg. Turn monitoring off to disable that
extends Area3D

@export var damage := 60


@export var damaged_bodies := {}

func overlap_check():
	var overlapping_bodies = get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.has_method("damage") and body.is_in_group("Player"):
			body.damage(damage)
			damaged_bodies[body] = true

func _on_body_entered(body):
	
	print("body entered")
		
	if body.has_method("damage") and body.is_in_group("Player"):
		if body not in damaged_bodies:
			body.damage(damage)
			damaged_bodies[body] = true
			await get_tree().create_timer(2).timeout
			damaged_bodies.clear()
