extends StaticBody3D
@onready var player = $"../Player"
@onready var HUD = player.get_node("HUD")
@onready var GunMenu = player.get_node("GunMenu")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func interac():
	print("hey kids,")
	#player.can_move = false
	#player.can_look = false
	GameState.current_mode = GameState.GameMode.DIALOGUE
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	HUD.visible = false
	GunMenu.visible = true
