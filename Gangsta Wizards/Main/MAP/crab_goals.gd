extends Node3D

var goals = [
	{"id": 0, "path": "G0", "open": true, "assignedTo": null, "action": rand_jump_loiter},
	{"id": 1, "path": "G1", "open": true, "assignedTo": null, "action": rand_jump_loiter},
	{"id": 2, "path": "G2", "open": true, "assignedTo": null, "action": rand_jump_loiter},
	{"id": 3, "path": "G3", "open": true, "assignedTo": null, "action": rand_jump_loiter},
	{"id": 4, "path": "G4", "open": true, "assignedTo": null, "action": rand_jump_loiter},
	{"id": 5, "path": "G5", "open": true, "assignedTo": null, "action": rand_jump_loiter},
	{"id": 6, "path": "G6", "open": true, "assignedTo": null, "action": rand_jump_loiter},
	{"id": 7, "path": "G7", "open": true, "assignedTo": null, "action": rand_jump_loiter},
]

func loiter(node, body):
	var wait_time = randf_range(5,10)
	await get_tree().create_timer(wait_time).timeout

func jump_loiter(node, body):
	var jumps = randf_range(3,6)
	for jump in range(jumps):
		body.jump()
		await get_tree().create_timer(2.0).timeout

func rand_jump_loiter(node, body):
	var id = randi_range(1,2)
	if id == 1:
		await loiter(node, body)
	else:
		await jump_loiter(node, body)
