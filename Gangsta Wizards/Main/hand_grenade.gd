extends Node3D

@onready var player = get_tree().get_first_node_in_group("Player")

var hold_time: float = 0.0
var holding: = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if holding:
		hold_time += delta

func hold_item() -> void:
	holding = true
	player.LA_anime.play("Jump")
	
func release_item() -> void:
	holding = false
	print("Item held for ", hold_time, " seconds")
	hold_time = 0.0
