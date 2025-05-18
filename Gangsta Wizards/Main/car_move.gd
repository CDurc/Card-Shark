extends PathFollow3D
@export var mps = 250

func _process(delta):
	progress += mps * delta
