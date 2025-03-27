extends Node3D

var player
var interact
var inside = false

@onready var anime = $G_model/AnimationPlayer


func _ready():
	player = get_tree().get_first_node_in_group("Player")
	print ("player found:",player)
	anime.play("Idle")

func _process(delta):
	if inside and player and player.interact(): #F was pressed
		enter_dialogue()

func on_body_entered(body):
	if body == player:
		inside = true
		interact = player.get_node("HUD/Interact")
		interact.visible = true
		player.can_interact = true
		
func on_body_exited(body):
	if body == player:
		inside = false
		interact = player.get_node("HUD/Interact")
		interact.visible = false
		player.can_interact = false

func enter_dialogue():
	anime.play("Talking")
	player.can_move = false
