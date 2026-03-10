extends Node3D

var MHG = preload("uid://bkfav26se306g")

@onready var player = get_tree().get_first_node_in_group("Player")
@export var put_away = false
@export var weapon_type: int
@export var ammo = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func use_item():
	print("shot")
	throw()

func throw():
	self.visible = false
	Engine.time_scale = 0.1
