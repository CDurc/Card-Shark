extends StaticBody3D
#SLIDING DOOR SCRIPT

@onready var area = $"../Area3D"

var open = false
var closed = true

@onready var closed_pos: Vector3
@onready var open_pos: Vector3
@onready var target_pos: Vector3
@onready var marker = $"../open_pos"

var player_inside = false
var timer = 0.0

func _ready():
	closed_pos = global_position
	open_pos = marker.global_position
	target_pos = closed_pos


func _physics_process(delta: float) -> void:
	# Smoothly move toward target position
	global_position = global_position.move_toward(target_pos, 1.4 * delta)
	
	# Handle delayed closing
	if not player_inside:
		if timer <2.0:
			timer += delta
		if timer >= 2.0:
			target_pos = closed_pos
	else:
		timer = 0.0

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player_inside = true
		target_pos = open_pos
		print("Player entered the door area")

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player_inside = false
		timer = 0.0
		print("Player left the door area")
