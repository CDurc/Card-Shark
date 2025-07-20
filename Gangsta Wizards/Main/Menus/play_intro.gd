extends Node3D
@onready var cam = $"../../Cam Work/Camera3D"
@onready var anime = $"../../World/Main Menu/AnimationPlayer"
@onready var S1 = $"../../Cam Work/Step1"
@onready var S2 = $"../../Cam Work/Step2"
@onready var S3 = $"../../Cam Work/Step3"

var moving_cam1 = false
var moving_cam2 = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anime.play("MainMenuAction")
	await get_tree().create_timer(4.5).timeout
	moving_cam1 = true
	await get_tree().create_timer(3.5).timeout
	moving_cam1 = false
	moving_cam2 = true
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if moving_cam1:
		move_cam(S2,delta,0.8)
	elif moving_cam2:
		move_cam(S3,delta,1.5)


func move_cam(step,delta,sl):
	var goal = step
	var lerpspeed = 1
	var slerpspeed = sl
	TransformUtils.lerp_slerp_node(cam, goal, lerpspeed, slerpspeed, delta)
