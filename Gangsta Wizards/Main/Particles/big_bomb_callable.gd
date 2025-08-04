#Smart Bomber bomb script
extends Node3D

@export var auto_remove_after := 2.0  # Seconds before auto-cleanup
@onready var player = get_tree().get_nodes_in_group("Player").front() #Im gonna start fetching player this way, in case game ever becomes multiplayer change to player list

func boom():
	# Start particles
	$Smoke.emitting = true
	$Fire.emitting = true


	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = auto_remove_after
	add_child(timer)

	timer.timeout.connect(self._on_timer_timeout)

	timer.start()
	
	#EXPLOSIVE IMPULSE
	var overlapping_bodies = $BombArea.get_overlapping_bodies()
	if player in overlapping_bodies:
		print("Player is inside the area!")
		var impulse_dir = $"..".face_dir
		impulse_dir = 100*(impulse_dir+Vector3(0,2,0))
		print(impulse_dir)
		player.trigger_ragdoll(impulse_dir)

func _on_timer_timeout() -> void:
	queue_free()
