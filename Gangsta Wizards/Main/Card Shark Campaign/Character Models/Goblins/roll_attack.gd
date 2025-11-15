extends Area3D

@export var damage := 60

var goblin
var can_shrink = true

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
	
	
	if not goblin:
		return
		
	if body != goblin and body.is_in_group("Roller") and can_shrink:  #If touching another roller
		shrink()

	if not body.is_in_group("Enemies") and body.has_method("damage") and goblin.damaging:
		can_shrink = false
		grow()
		if body not in damaged_bodies:
			body.damage(damage)
			damaged_bodies[body] = true
			#flatten(body)
			await get_tree().create_timer(2).timeout
			damaged_bodies.clear()
			can_shrink = true

func shrink():
	await get_tree().create_timer(randf()/2) #Wait rand(0,0.5) so that guys dont shrink at the exact same time
	can_shrink = false
	var tween = create_tween()
	tween.tween_property(goblin, "scale", Vector3(0.3,0.3,0.3), 1.0)
	await get_tree().create_timer(2.5).timeout
	grow()

func grow():
	var tween2 = create_tween()
	tween2.tween_property(goblin, "scale", Vector3(1,1,1), 1.0)
	await get_tree().create_timer(4).timeout
	can_shrink = true
