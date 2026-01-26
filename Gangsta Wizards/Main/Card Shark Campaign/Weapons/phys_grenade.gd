extends RigidBody3D

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var collision = $CollisionShape3D
@onready var tool = $".."
@onready var nade_spawn = $"../GrenadeSpawn"

@export var damage: float = 55
@export var timer: float = 5.0

var pin_pulled: = false
var has_exploded: bool = false  # To prevent multiple triggers
var boom_scene = preload("res://Particles/medium_grenade.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if pin_pulled:
		if timer > 0:
			timer -= delta
		else:
			pin_pulled = false
			boom()

func pull_pin():
	pin_pulled = true

func throw_grenade_g():
	self.reparent(get_tree().root)
	self.freeze = false
	var cam_forward = -player.camera.global_transform.basis.z
	cam_forward.y *= 1.3  #Exaggerate
	cam_forward = cam_forward.normalized()

	linear_velocity = cam_forward * 12
	print("THROWN")
	collision.disabled = false



func boom():
	print("BOOOOOOOOOM")
	var boom = boom_scene.instantiate()
	boom.global_transform = self.global_transform
	get_tree().root.add_child(boom)
	has_exploded = true
	queue_free()
