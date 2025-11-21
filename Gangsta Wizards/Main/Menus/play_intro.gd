extends Node3D
@onready var cam = $"../../Cam Work/Camera3D"
@onready var anime = $"../../World/Main Menu/AnimationPlayer"
@onready var S1 = $"../../Cam Work/Step1"
@onready var S2 = $"../../Cam Work/Step2"
@onready var S3 = $"../../Cam Work/Step3"
@onready var black_box = $"../../GUI/CanvasLayer/BlackBox"
@onready var arm = $"../../World/Arm"
@onready var armscript = $"../Buttons"

var moving_cam1 = false
var moving_cam2 = false

var step = 1
var fading = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	await get_tree().create_timer(1).timeout
	fading = true
	anime.play("MainMenuAction")
	anime.play("MainMenuAction2")
	await get_tree().create_timer(4.5).timeout
	moving_cam1 = true
	await get_tree().create_timer(3.5).timeout
	moving_cam1 = false
	moving_cam2 = true
	await get_tree().create_timer(1).timeout
	arm.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	fade_in(delta)
	if moving_cam1:
		move_cam(S2,delta,0.2)
	elif moving_cam2:
		move_cam(S3,delta,1)


func move_cam(step,delta,sl):
	var goal = step
	var lerpspeed = 1
	var slerpspeed = sl
	TransformUtils.lerp_slerp_node(cam, goal, lerpspeed, slerpspeed, delta)


func fade_in(delta):
	if step > 0 and fading:
		step -= 0.5*delta
		black_box.color = Color(0,0,0,step)
	elif step <= 0 and fading:
		fading = false
		black_box.queue_free()
