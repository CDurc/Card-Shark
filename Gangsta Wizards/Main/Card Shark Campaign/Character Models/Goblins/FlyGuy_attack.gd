extends CharacterBody3D

@export var health :int

@onready var initial_health = health #This HAS to be onready to recieve the export vars
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var PF = $".."
@onready var mesh = $"gobby bones6" #Not technically the mesh but use this node like it is
@onready var mesh_attacking_rot = mesh.rotation_degrees
@onready var mesh_flying_rot = mesh_attacking_rot + Vector3(90,0,0)
@onready var anime = $AnimationPlayer
@onready var healthbar = $Control/Healthbar/Helth
@onready var money_drop = preload("res://Card Shark Campaign/Spells/5d_money_drop.tscn")

var dist: float = 1000
var attacking = false
var looking = false
var can_attack = true
var destroyed = false


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
	var next_point = player.global_transform.origin + player_move_dir * 3 #Aim ahead of player and GO
	
	await launch(next_point)
	#await get_tree().create_timer(1.32).timeout
	looking = false #probs need a look forward line
	attacking = false
	PF.flying = true
	
	rotation = Vector3(0,0,0)
	anime.play("Attack End")
	await get_tree().create_timer(4).timeout
	can_attack = true
	
	
func launch(target_point: Vector3, speed := 25.0) -> void:
	var start_pos := global_position

	# --- Compute launch direction and distance ---
	var overshoot_vec := target_point - global_position
	var overshoot_dir := overshoot_vec.normalized()
	var launch_distance := overshoot_vec.length()
	var launch_time := launch_distance / speed

	var launch_timer := get_tree().create_timer(launch_time)

	# --- LAUNCH TOWARD TARGET WITH COLLISIONS ---
	while launch_timer.time_left > 0:
		velocity = overshoot_dir * speed
		move_and_slide()
		await get_tree().process_frame

	# --- RETURN TO START WITH COLLISIONS ---
	var return_time := 0.6
	var return_timer := get_tree().create_timer(return_time)

	while return_timer.time_left > 0:
		var target_dir := (start_pos - global_position).normalized()
		var return_speed := global_position.distance_to(start_pos) / return_timer.time_left

		velocity = target_dir * return_speed
		move_and_slide()
		await get_tree().process_frame

func destroy():
	Audio.play("sounds/enemy_destroy.ogg")
	destroyed = true
	PF.queue_free()
	drop_money()

func damage(amount):
	health -= amount
	var health_ratio = float(health)/float(initial_health)
	var R_color = (1 - health_ratio)  #Should just got to 208 tbh
	var G_color = health_ratio
	healthbar.color = Color(R_color,G_color,0)
	healthbar.scale.x = health_ratio
	print(health_ratio)
	if health <= 0 and not destroyed:
		destroy()

func drop_money():
	var money = money_drop.instantiate()
	money.global_position = self.global_position
	get_tree().root.add_child(money)
