#close check hurtbox.  Use monitoring to tighten the window
extends Area3D

@export var damage := 60

@export var goblin: Node3D

@onready var main_hurtbox = $"../Mountain King3/Mountain King/Skeleton3D/BoneAttachment3D/Hurtbox"
@onready var damaged_bodies = main_hurtbox.damaged_bodies

func overlap_check():
	var overlapping_bodies = get_overlapping_bodies()
	for body in overlapping_bodies:
		if body != goblin and body.has_method("damage") and body.is_in_group("Player"):
			body.damage(damage)
			damaged_bodies[body] = true

func _on_body_entered(body):
	
	print("body entered")
	
	if not goblin:
		return
		
	if body.has_method("damage") and goblin.attacking and body.is_in_group("Player"):
		if body not in damaged_bodies:
			body.damage(damage)
			damaged_bodies[body] = true
			await get_tree().create_timer(2).timeout
			damaged_bodies.clear()
