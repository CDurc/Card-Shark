extends RigidBody3D

@export var damage_amount: int = 10
@onready var parent = $"."

var target_group: String #The group that you want to do dmg to

func _ready() -> void:
	gravity_scale = 0.0

func _on_body_entered(body: Node) -> void:
	if not body == parent: #There is always one collision with the parent collider (which might not need to exist tbh)
		if body.has_method("damage") and body.is_in_group(target_group):
			body.damage(damage_amount)
		queue_free()  # delete bullet on hit.  Rn detects hits on all used masks
