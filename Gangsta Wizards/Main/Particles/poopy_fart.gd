extends Node3D

@export var auto_remove_after := 30  # Seconds before auto-cleanup
@onready var root := get_tree().get_current_scene()
@onready var dummy_cam = root.get_node("Dummy")
@onready var real_cam = root.get_node("Player/Head/Camera")

func _ready() -> void:
	
	# Recursively enable all GPUParticles3D nodes
	activate_particles_recursive(self)

	# Set up auto-remove timer
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = auto_remove_after
	add_child(timer)
	timer.timeout.connect(self._on_timer_timeout)
	timer.start()

func activate_particles_recursive(node: Node) -> void:
	for child in node.get_children():
		if child is GPUParticles3D:
			child.visibility_aabb = AABB(
	   			Vector3(-100, -100, -100),   # corner
				Vector3(200, 200, 200)    # size
				)
			child.emitting = true
		activate_particles_recursive(child)

func _on_timer_timeout() -> void:
	queue_free()
