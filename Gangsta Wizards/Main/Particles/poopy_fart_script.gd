extends Node3D

var lingers = []
var t = 0.0

func _ready() -> void:
	var timer = Timer.new()
	timer.wait_time = 10
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

	# Collect all Linger children (recursive if needed)
	collect_lingers(self)

func collect_lingers(node):
	for child in node.get_children():
		if child.name == "Linger" and child is GPUParticles3D:
			lingers.append(child)
		else:
			collect_lingers(child)
			
func _process(delta):
	t += delta
	if t > 1 and lingers.size() > 0:
		t = 0
		for particle in lingers:
			if particle.amount > 0:
				particle.amount = max(particle.amount - 1, 0)

func _on_timer_timeout() -> void:
	queue_free()
