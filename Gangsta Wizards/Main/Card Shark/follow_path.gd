extends PathFollow3D
@export var start_speed = 5.0
@export var max_speed: = 12.0
@export var ramp_time = 6.5

@onready var par = $".."
@onready var particles = $"Basking Shark".get_node("Particles")

var current_speed = start_speed
var elapsed_time = 0.0

func _process(delta):
	if current_speed < max_speed:
		elapsed_time += delta
		if elapsed_time > 1.5:
			current_speed = lerp(start_speed, max_speed, elapsed_time / ramp_time)
			particles.emitting = true
	
	progress += current_speed * delta
	if progress_ratio >= 0.99:
		par.queue_free()
