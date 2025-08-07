extends Control

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func give_change(chips: float) -> Array: #Input chips as a number (ideally int) to get an ordered array of chips
	var change = round(chips)
	var denominations := {
		"BlackChip100.png": 100.0,
		"GreenChip25.png": 25.0,
		"BlueChip10.png": 10.0,
		"RedChip5.png": 5.0,
		"WhiteChip1.png": 1.0,
	}
	var chip_list := []

	var sorted_keys := denominations.keys()
	sorted_keys.sort_custom(func(a, b): return denominations[a] > denominations[b])

	for name in sorted_keys:
		var value = denominations[name]
		var count = int(change / value)
		for i in count:
			chip_list.append(name)
		change -= count * value
	
	return chip_list

func display_chips(chips: float) -> void: #Input chips as a number to display the chips in the healthbar
	var chip_images = give_change(chips)
	for i in 20:
		var chip_slot = "C" + str(i + 1)
		var chip_slot_node = get_node(chip_slot)
		if i < chip_images.size():
			var texture = load("res://Menus/HealthChips/" + chip_images[i])
			chip_slot_node.texture = texture
			chip_slot_node.visible = true
		else:
			chip_slot_node.texture = null
			chip_slot_node.visible = false
