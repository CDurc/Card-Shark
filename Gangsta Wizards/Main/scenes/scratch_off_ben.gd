extends Node
const IMAGE_COUNT := 10
const SLOT_COUNT := 6

# Adjust this if your folder or filenames differ
const IMAGE_PATH :=  "res://IMAGES/Gambling Images/Slot%s.png"

var slot_nodes: Array[TextureRect] = []
var chosen_indices: Array[int] = []

var result_label: Label

func _ready():
	print("READY CALLED")
	_cache_slots()
	result_label = $ResultLabel
	result_label.text = ""
	await _generate_ticket()
	_check_win_condition()


func _cache_slots():
	slot_nodes.clear()

	for i in range(1, SLOT_COUNT + 1):
		var slot_name = "Slot" + str(i)
		var slot = get_node(slot_name)
		#var slot = get_node("Slot1")
		#var slot = $"Slot{i}"
		print("Looking for Slot", i, " → ", slot)
		if slot == null:
			push_error("Slot" + str(i) + " not found in scene. Check node names and hierarchy.")
		slot_nodes.append(slot)


func _generate_ticket():
	chosen_indices.clear()

	for i in range(slot_nodes.size()):
		var slot = slot_nodes[i]

		if slot == null:
			push_error("Slot " + str(i + 1) + " is null — cannot assign texture.")
			continue

		var index := 1 + randi() % IMAGE_COUNT
		chosen_indices.append(index)

		var path := IMAGE_PATH % index
		var tex := load(path)

		print("Loading:", path, " → ", tex)

		if tex == null:
			push_error("Failed to load texture at: " + path)
			continue

		slot.texture = tex
		await get_tree().create_timer(0.2).timeout



func _check_win_condition():
	print(chosen_indices)
	if chosen_indices.is_empty():
		print("No indices generated.")
		return

	var first := chosen_indices[0]
	var all_match := chosen_indices.all(func(x): return x == first)

	if all_match:
		print("WINNER!")
		result_label.text = "🎉 WINNER! All symbols match!"

	else:
		print("Loser")
		result_label.text = "No match — try again."

		
