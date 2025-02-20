extends PathFollow3D

func _process(delta):
	if has_meta("speed"):
		progress += get_meta("speed") * delta
