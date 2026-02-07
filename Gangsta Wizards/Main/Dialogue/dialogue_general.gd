extends StaticBody3D

@onready var player = $"../../Player2"
@onready var d_control = player.get_node("HUD/Bottombar/Dialogue")

@export var dialogue_options: Resource

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
	GameState.current_mode = GameState.GameMode.DIALOGUE
