#Tree Version
extends StaticBody3D
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var d_control = player.get_node("HUD/Bottombar/Dialogue")
@onready var cursor = player.get_node("HUD/Crosshair")
@onready var interact_UI = player.get_node("HUD/Interact")
@onready var cam = player.get_node("Head/Camera")
@onready var cam_goal = $"../Cam0"
@onready var box0 = d_control.get_node("0")
@onready var box1 = d_control.get_node("1")
@onready var box2 = d_control.get_node("2")
@onready var response_text = d_control.get_node("Text/Label")
@export var dialogue_tree: DialogueTree
var current_node_index: int = 0
var old_cam_rot
var old_cam_pos
var in_dialogue: = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func interac():
	if not in_dialogue:
		in_dialogue = true
		current_node_index = 0
		enter_dialogue_mode()

func enter_dialogue_mode():
	print("Entering d")
	player.current_NPC = self
	GameState.current_mode = GameState.GameMode.DIALOGUE
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	cursor.visible = false
	interact_UI.visible = false
	

	old_cam_pos = cam.global_position
	old_cam_rot = cam.global_rotation

	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(cam, "global_position", cam_goal.global_position, 1.0)
	tween.tween_property(cam, "global_rotation", cam_goal.global_rotation, 1.0)

	d_control.visible = true
	display_node(current_node_index)

func display_node(index: int):
	var node: DialogueNode = dialogue_tree.nodes[index]
	#print(node.text)
	response_text.text = node.text
	box0.text = node.options[0] if node.options.size() > 0 else ""
	box1.text = node.options[1] if node.options.size() > 1 else ""
	box2.text = node.options[2] if node.options.size() > 2 else ""

func select_option(option: int):
	var node: DialogueNode = dialogue_tree.nodes[current_node_index]
	if option >= node.options_goto.size():
		return

	var prop = node.options_check_property[option] if node.options_check_property.size() > option else ""
	var method = node.options_call_method[option] if node.options_call_method.size() > option else ""

	if prop != "":
		var player_val = player.get(prop)
		var required = node.options_check_value[option]
		if player_val is bool:
			if player_val != (required == 1):
				current_node_index = node.options_fail_goto[option]
				display_node(current_node_index)
				return
		else:
			if player_val < required:
				current_node_index = node.options_fail_goto[option]
				display_node(current_node_index)
				return

	# Only reached if check passed (or no check)
	if method != "":
		call(method)

	current_node_index = node.options_goto[option]
	display_node(current_node_index)
	
func leave_dialogue():
	print("Leaving d")
	#player.current_NPC = nil
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	d_control.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(cam, "global_position", old_cam_pos, 1.0)
	tween.tween_property(cam, "global_rotation", old_cam_rot, 1.0)
	await tween.finished
	cursor.visible = true
	GameState.current_mode = GameState.GameMode.GAMEPLAY
	in_dialogue = false

func give_key():
	player.has_key = true
	print("Key given")

func use_key():
	print("key used")
	player.has_key = false
