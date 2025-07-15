extends Area3D

@export var damage = 10
@export var force = 8

var player
var collider
@export var damaged_bodies := {} # A dictionary to store each body we've damaged.

func _ready():
	collider = get_node("CollisionShape3D")
	player = get_tree().get_first_node_in_group("Player")
	monitoring = true

func overlap_check():
	var overlapping_bodies = get_overlapping_bodies()
	for body in overlapping_bodies:
		if body != player and body.has_method("damage"):
			if body not in damaged_bodies:
				push(body)
				body.damage(damage)
				damaged_bodies[body] = true
				print("Overlap Ouch")

func _on_body_entered(body):
	
	if body != player and body.has_method("damage"):
		if body not in damaged_bodies:
			push(body)
			body.damage(damage)
			damaged_bodies[body] = true
			print("Entered Ouch")

func expand():
	var tween = get_tree().create_tween()
	tween.tween_property(collider.shape, "radius", 9, 0.6)
	tween.tween_callback(Callable(self, "reset"))
	
func reset():
	collider.shape.radius = 2.2
	damaged_bodies = {}

func push(body: CharacterBody3D) -> void:
	var dir: Vector3 = body.global_position - global_position
	dir.y = 0
	if dir.length_squared() == 0:
		return
	dir = dir.normalized()
	dir.y = 0.15
	body.knockback_v = dir * force
	body.knockback_t = 3
	print(body.knockback_v)
	print("PUSH")
