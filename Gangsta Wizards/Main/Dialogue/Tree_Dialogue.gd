#Tree Version
extends StaticBody3D

@onready var player = $"../../Player2"
@onready var d_control = player.get_node("HUD/Bottombar/Dialogue")
@onready var cursor = player.get_node("HUD/Crosshair")
@onready var cam = player.get_node("Head/Camera")
@onready var cam_goal = $"../Cam0"

@onready var box0 = d_control.get_node("0")
@onready var box1 = d_control.get_node("1")
@onready var box2 = d_control.get_node("2")

@onready var current_options = dialogue_options.options_0
@onready var current_options_goto = dialogue_options.options_0_goto

@export var dialogue_options: DialogueTree

var old_cam_rot
var old_cam_pos

var in_dialogue: = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func interac():
	if not in_dialogue:
		in_dialogue = true
		enter_dialogue_mode()

func enter_dialogue_mode():
	print("Entering d")
	player.current_NPC = self
	GameState.current_mode = GameState.GameMode.DIALOGUE
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	cursor.visible = false

	#----------Move cam-----------------------------------------------------
	
	old_cam_pos = cam.global_position
	old_cam_rot = cam.global_rotation
	
	var new_cam_pos = cam_goal.global_position
	var new_cam_rot = cam_goal.global_rotation
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(cam, "global_position", new_cam_pos, 1.0)
	tween.tween_property(cam, "global_rotation", new_cam_rot, 1.0)
	
	#---------Set dialogue choices------------------------------------------
	d_control.visible = true
	box0.text = current_options[0]
	box1.text = current_options[1]
	box2.text = current_options[2]
	

func select_option(option):
	var new_options_int = current_options_goto[option]  #Convert button number into goto number
	current_options = dialogue_options.get("options_" + str(new_options_int))
	current_options_goto = dialogue_options.get("options_" + str(new_options_int) + "_goto")
	
	box0.text = current_options[0]
	box1.text = current_options[1]
	box2.text = current_options[2]
