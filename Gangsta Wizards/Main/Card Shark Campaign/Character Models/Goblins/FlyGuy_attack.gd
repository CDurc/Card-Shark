extends Node3D

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var PF = $".."
@onready var mesh = $"gobby bones6" #Not technically the mesh but use this node like it is
@onready var mesh_attacking_rot = mesh.rotation_degrees
@onready var mesh_flying_rot = mesh_attacking_rot + Vector3(90,0,0)
@onready var anime = $AnimationPlayer

var dist: float = 1000
var attacking = false
var looking = false
var can_attack = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mesh.rotation_degrees = mesh_flying_rot


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	dist = global_transform.origin.distance_to(player.global_transform.origin)
	if can_attack and dist < 12:
		can_attack = false
		attacking = true
		PF.flying = false
		attack()
	elif looking:
		look_at(player.global_position)

func attack():
	looking = true
	var tween = create_tween()
	tween.tween_property(mesh, "rotation_degrees", mesh_attacking_rot, 1.0)
	print("FLIGHT ATTACK")
	anime.stop()
	anime.play("Flying")
	await get_tree().create_timer(1.7).timeout
	var tween2 = create_tween()
	tween2.tween_property(mesh, "rotation_degrees", mesh_flying_rot, 1.0)
	anime.play("Attack Start")
	await get_tree().create_timer(0.4).timeout
	
	var player_move_dir = player.movement_velocity.normalized() #get direction player is moving to aim ahead
	var next_point = player.global_transform.origin + player_move_dir * 1.3 #Aim ahead of player and GO
	var overshoot_dir = next_point - global_transform.origin
	overshoot_dir = overshoot_dir.normalized()
	
	launch(overshoot_dir)
	
func launch(overshoot_dir_):
	var start_pos = global_position

	# --- LAUNCH TOWARD PLAYER ---
	var launch_time := 1
	var launch_timer := get_tree().create_timer(launch_time)
	while launch_timer.time_left > 0:
		global_position += overshoot_dir_ * (15.0) * get_process_delta_time()
		await get_tree().process_frame

	# --- RETURN TO START ---
	var return_time := 0.6
	var return_timer := get_tree().create_timer(return_time)
	while return_timer.time_left > 0:
		var alpha := 1.0 - (return_timer.time_left / return_time)
		global_position = global_position.lerp(start_pos, alpha)
		await get_tree().process_frame
