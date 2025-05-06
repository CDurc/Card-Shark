extends Node3D

@export var auto_remove_after := 2.0  # Seconds before auto-cleanup

func _ready() -> void:
	# Start particles (make sure child node names match!)
	$Smoke.emitting = true
	$Fire.emitting = true

	# Create a Timer to remove this node after auto_remove_after seconds
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = auto_remove_after
	add_child(timer)

	# Connect Godot 4 style: pass a callable
	timer.timeout.connect(self._on_timer_timeout)

	timer.start()

func _on_timer_timeout() -> void:
	queue_free()
