extends HBoxContainer

var current_index := 0

@export var max_timer = 2.0

@onready var choices := get_children()  # the 5 Control nodes
@onready var t = max_timer

func _ready():
	_update_selection()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			current_index += 1
			self.visible = true
			t = max_timer
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			current_index -= 1
			self.visible = true
			t = max_timer

		# Wrap index around
		current_index = wrapi(current_index, 0, choices.size())
		_update_selection()

func _update_selection():
	print("SCROLLED TO: ", current_index)
	for i in range(choices.size()):
		var LabelBG = choices[i].get_node("LabelBG")
		var ItemBG = choices[i].get_node("ItemBG")
		
		var label_style = LabelBG.get_theme_stylebox("panel").duplicate()
		var item_style = ItemBG.get_theme_stylebox("panel").duplicate()
		
		if i == current_index:
			label_style.set_border_width_all(4.0)
			item_style.set_border_width_all(4.0)
		else:
			label_style.set_border_width_all(0.0)
			item_style.set_border_width_all(0.0)
		
		LabelBG.add_theme_stylebox_override("panel", label_style)
		ItemBG.add_theme_stylebox_override("panel", item_style)

func _process(delta) -> void:
	if visible:
		t -= delta
		if t <= 0:
			visible = false
			t = max_timer
