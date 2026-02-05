extends HBoxContainer

var current_index := 0
var current_weapon_i:= 0

@export var max_timer = 2.0

@onready var choices := get_children()  # the 5 Control nodes
@onready var t = max_timer
@onready var LA_anime = $"../../../TheCardShark2/LeftArmController"
@onready var player = $"../../.."
@onready var ammo_counter = $"../../Bottombar/Ammo_icon/Ammo"

func _ready():
	_update_selection()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			current_index += 1
			self.visible = true
			t = max_timer
			current_index = wrapi(current_index, 0, choices.size())
			_update_selection()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			current_index -= 1
			self.visible = true
			t = max_timer
			current_index = wrapi(current_index, 0, choices.size())
			_update_selection()

func _update_selection():
	for i in range(choices.size()):
		var LabelBG = choices[i].get_node("LabelBG")
		var ItemBG = choices[i].get_node("ItemBG")
		
		var label_style = LabelBG.get_theme_stylebox("panel").duplicate()
		var item_style = ItemBG.get_theme_stylebox("panel").duplicate()
		
		if i == current_index:
			label_style.set_border_width_all(4.0)
			item_style.set_border_width_all(4.0)
			ItemBG.visible = true
		else:
			label_style.set_border_width_all(0.0)
			item_style.set_border_width_all(0.0)
			ItemBG.visible = false
		
		LabelBG.add_theme_stylebox_override("panel", label_style)
		ItemBG.add_theme_stylebox_override("panel", item_style)

func _process(delta) -> void:
	if visible:
		t -= delta
		if t <= 0:
			visible = false
			t = max_timer
			if current_index != current_weapon_i:
				current_weapon_i = current_index
				change_weapon(current_index)

func change_weapon(i):
	var left_hand = $"../../../TheCardShark2/SharkBones/Skeleton3D/LeftHandContainer"
	var held_item_holder = left_hand.get_child(0)
	var current_weapon = held_item_holder.get_child(0)
	var new_weapon = left_hand.get_child(i+1).get_child(0)
	var new_container = left_hand.get_child(current_weapon.weapon_type + 1)
	print("THIS IS WHAT i+1 WAS",   i+1)
	
	current_weapon.put_away = true
	print("weapon swap")
	LA_anime.play("Reload")
	await get_tree().create_timer(0.7).timeout
	current_weapon.reparent(new_container)
	new_weapon.reparent(held_item_holder)
	await get_tree().create_timer(1.2).timeout
	player.item = new_weapon
	new_weapon.put_away = false
	ammo_counter.text = str(new_weapon.ammo)
