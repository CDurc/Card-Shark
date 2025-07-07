extends Node3D

var player
var interact
var talking = false
var ending_dialogue = false
var menu
var options
var current_option
var selected_index = 0
var dialogue
var dialogue_path = load("res://Card Shark Campaign/Dialogues/gary_dialogue_1.tscn")

@onready var anime = $G_model/AnimationPlayer

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	interact = player.get_node("HUD/Interact")
	#dialogue = get_node("Gary_dialogue_1")
	print ("player found:",player)
	#anime.play("Idle") FIX LATER NO ANIME
	
func _process(delta):
#	if inside and player and player.interact() and GameState.current_mode == GameState.GameMode.GAMEPLAY: #F was pressed
#		enter_dialogue()
	if talking:
		move_cam(delta)
	if ending_dialogue:
		return_cam(delta)

func interac():
	if GameState.current_mode == GameState.GameMode.GAMEPLAY:
		enter_dialogue()
		print("INTERAXXXXIONED")

func enter_dialogue():
	print("ENTEREDED DIOLUGUEUE")
	dialogue = dialogue_path.instantiate()
	anime.play("Talking")
	interact.visible = false
	#player.can_move = false This is still used for basking_shark, might become obselete not sure
	#player.can_look = false THIS MIGHT BE OBSELETE
	GameState.current_mode = GameState.GameMode.DIALOGUE
	var DE = player.get_node("DialogueElements")
	DE.add_child(dialogue)
	menu = player.get_node("DialogueElements/Gary_dialogue_1/Menu")
	options = menu.get_children()
	current_option = options[0]
	DE.visible = true
	talking = true
	print(current_option)
	
func move_cam(delta):
	var cam = player.get_node("Head/Camera")
	var goal = player.get_node("3rd_person_point")
	var lerpspeed = 1
	var slerpspeed = 1
	TransformUtils.lerp_slerp_node(cam, goal, lerpspeed, slerpspeed, delta)

func return_cam(delta):
	var cam = player.get_node("Head/Camera")
	var goal = player.get_node("Head/Camera_origin")
	var lerpspeed = 1.25
	var slerpspeed = 1.25
	TransformUtils.lerp_slerp_node(cam, goal, lerpspeed, slerpspeed, delta)

func _unhandled_input(event):
	if talking:
		if event.is_action_pressed("move_back"):
			selected_index = (selected_index + 1) % options.size()
			current_option = options[selected_index]
			print(current_option)
			update_highlight()
		if event.is_action_pressed("move_forward"):
			selected_index = (selected_index - 1 + options.size()) % options.size()
			current_option = options[selected_index]
			print(current_option)
			update_highlight()
		if event.is_action_pressed("Left_Click"):
			select()

func update_highlight():
	for i in range(options.size()):
		if i == selected_index:
			options[i].color = Color.ORANGE_RED
		else:
			options[i].color = Color.BLACK

func select(): #Dialogue terminating slection
		talking = false
		ending_dialogue = true
		player.get_node("DialogueElements").visible = false
		await get_tree().create_timer(2).timeout
		GameState.current_mode = GameState.GameMode.GAMEPLAY #Return control to the player a bit before the cam arrives for cool effect
		await get_tree().create_timer(4).timeout
		ending_dialogue = false
