extends RigidBody3D

@export var damage_amount: int = 10
@onready var parent = $"."
var HS_mult: float = 1.0

var hit = false

var target_group: String #The group that you want to do dmg to

func _ready() -> void:
	gravity_scale = 0.0

func _on_body_entered(body: Node) -> void:
	print("BULLET HIT OBJECT")
	#if not body == parent: #There is always one collision with the parent collider (which might not need to exist tbh)
	#	if body.has_method("damage") and body.is_in_group(target_group):
	#		body.damage(damage_amount)
	if not body.has_method("damage"): #Only delete if hit object CANT take damage.  If it can, let area hande deletion
		queue_free()  # delete bullet on hit.  Rn detects hits on all used masks

func _on_area_entered(area: Area3D) -> void:
	if hit: #Make sure signal doesnt trigger twice
		return
	hit = true
	print("HIT HIT HIT")
	if area.get_parent().is_in_group(target_group) or area.get_parent().is_in_group("Non-enemy-hit"): #CHANGED
	
		if area.is_in_group("Headshot"):
			area.get_parent().damage(damage_amount * HS_mult)
			print("HEADSHOT")
			queue_free()
		elif area.is_in_group("Bodyshot"):
			area.get_parent().damage(damage_amount)
			print("BODYSHOT")
			queue_free()
			
	elif area.is_in_group("Non-enemy-hit"):
		area.damage(damage_amount)
		print("HIT A NON-ENEMY HITTABLE THING IDK")
		queue_free()
	else:
		queue_free()
