extends RigidBody3D

@export var damage_amount: int = 100

func _ready() -> void:
	# Ensure this object can detect collisions
	contact_monitor = true
	max_contacts_reported = 1

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# Detect collisions
	for i in range(state.get_contact_count()):
		var collider = state.get_contact_collider_object(i) as Node
		if collider and collider.has_method("damage"):
			print("BANG")
			collider.call("damage", damage_amount)
			queue_free()  # Remove the projectile after dealing damage
			break
