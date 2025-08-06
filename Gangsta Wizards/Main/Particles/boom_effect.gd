extends Node3D

@export var auto_remove_after := 2.0  # Seconds before auto-cleanup

func _ready() -> void:
	# Start particles
	$Smoke.emitting = true
	$Fire.emitting = true


	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = auto_remove_after
	add_child(timer)

	timer.timeout.connect(self._on_timer_timeout)

	timer.start()

func _on_timer_timeout() -> void:
	queue_free()
