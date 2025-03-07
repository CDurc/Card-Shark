extends Area3D

@export var damage := 20

var goblin
var damaged_bodies := {} # A dictionary to store each body we've damaged.

func _ready():
	goblin = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
	monitoring = true

func _on_body_entered(body):
	print("Body entered on physics frame:", Engine.get_physics_frames(), "Body:", body)
	
	# If there's no goblin or it's not attacking, don't do anything.
	if not goblin or not goblin.attacking:
		return

	# Make sure the entering body isn't the goblin itself and can be damaged.
	if body != goblin and body.has_method("damage"):
		# Check if we've already damaged this body.
		if body not in damaged_bodies:
			# Damage the body, then add it to the dictionary so we don't damage it again.
			body.damage(damage)
			damaged_bodies[body] = true
			print("Damaged body:", body.name)
			monitoring = false
			print(monitoring)

#debug
func _on_body_exited(body):
	print("Exited on frame:", Engine.get_physics_frames(), "Body:", body)
