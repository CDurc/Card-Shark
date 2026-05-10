#Gary Goals
extends Node3D

var goals = [
	{"id": 0, "path": "G0", "open": true, "assignedTo": null, "action": loiter},
	{"id": 1, "path": "G1", "open": true, "assignedTo": null, "action": loiter},
	{"id": 2, "path": "G2", "open": true, "assignedTo": null, "action": sleep}
]

func loiter(node, body):
	var wait_time = randf_range(5,10)
	await get_tree().create_timer(wait_time).timeout
	print("loiter done")

func sleep(node, body):
	var anime = body.get_node("Gary/AnimationPlayer")
	anime.play("Sleep - Start")
	await anime.animation_finished
	
	var old_collider = body.get_node("collider")
	var new_collider = body.get_node("sleep_collider")
	old_collider.disabled = true
	new_collider.disabled = false
	
	var wait_time = randf_range(20,40)
	
	var wait_cycles = floor(wait_time/2.6)
	for cycle in range(0,wait_cycles):
		anime.play("Sleep - Idle")
		await get_tree().create_timer(2.6).timeout
	
	old_collider.disabled = false
	new_collider.disabled = true
	anime.play("Wake Up")
	await anime.animation_finished
