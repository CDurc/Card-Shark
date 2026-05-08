#Gary Goals
extends Node3D

var goals = [
	{"id": 0, "path": "G0", "open": true, "assignedTo": null, "action": loiter},
	{"id": 1, "path": "G1", "open": true, "assignedTo": null, "action": loiter}
]

func loiter(node, body):
	var wait_time = randf_range(5,10)
	await get_tree().create_timer(wait_time).timeout
	print("loiter done")
