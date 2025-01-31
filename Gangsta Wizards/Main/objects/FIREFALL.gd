extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


var firegrav = 1  # Constant gravity strength
var fire_velocity = Vector3.ZERO  # Fireball's movement velocity
	
func fireball_gravity(deltaX):
	# Apply gravity to the vertical velocity
	fire_velocity.y -= firegrav * deltaX
	
	# Update the position based on velocity
	global_transform.origin += fire_velocity * deltaX
