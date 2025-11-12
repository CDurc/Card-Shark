extends Node3D
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var rot_node = $".." #This is both the "root" node and the "rotated" node

var moving = false

var open = false
var closed = true

var original_rotation: Vector3
var target_rotation: Vector3
var open_rot: float


func _ready() -> void:
	original_rotation = rot_node.rotation_degrees
	open_rot = rot_node.get("Door_open_angle")
	target_rotation = original_rotation + Vector3(0,open_rot,0)



func _process(delta: float) -> void:
	pass


func interac():
	print("intaxionned")
	if closed and not moving:
		closed = false
		moving = true
		print("opening")
		
		var tween = create_tween()
		tween.tween_property(rot_node, "rotation_degrees", target_rotation, 2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		
		tween.finished.connect(func():
			moving = false
			open = true
		)
	elif open and not moving:
		open = false
		moving = true
		print("closing")
		
		var tween = create_tween()
		tween.tween_property(rot_node, "rotation_degrees", original_rotation, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
		tween.finished.connect(func():
			moving = false
			closed = true
		)
