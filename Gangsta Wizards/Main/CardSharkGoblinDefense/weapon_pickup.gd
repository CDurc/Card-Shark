extends StaticBody3D

@export var gun_type_path = preload("res://Card Shark Campaign/Weapons/shark_rifle.tscn")
var player
var item_container
var can_pickup = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	item_container = player.get_node("TheCardShark2/SharkBones/Skeleton3D/LeftHandContainer/Held_Item")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func interac():
	if player.money >= 3500 and can_pickup:
		can_pickup = false
		player.money - 3500
		print("item pickup")
		item_container.get_child(0).queue_free()
		await get_tree().process_frame
		var new_item = gun_type_path.instantiate()
		new_item.transform = Transform3D()
		item_container.add_child(new_item)
		player.new_item()
