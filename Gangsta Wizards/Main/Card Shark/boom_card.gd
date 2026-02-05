extends RigidBody3D

#@export var damage_amount: int = 25
var has_exploded: bool = false  # To prevent multiple triggers
var boom_scene = preload("res://Particles/medium_boom.tscn")

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 1

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if has_exploded:
		return  # Prevent multiple explosions

	for i in range(state.get_contact_count()):
		var collider = state.get_contact_collider_object(i) as Node
		if collider:
			# Optional: only damage if method exists
			#if collider.has_method("damage"):
				#collider.call("damage", damage_amount)

			# Explosion effects
			var boom = boom_scene.instantiate()
			boom.get_node("Boombox").can_damage_player = false
			boom.global_transform = self.global_transform
			get_tree().root.add_child(boom)
			#boom.get_node("Fire").emitting = true
			#boom.get_node("Smoke").emitting = true
			print("BOOM card")

			has_exploded = true
			queue_free()  # Remove the projectile
			break
