extends Node3D

var speed = 10.0
var enemy_list = []
var target_enemy = null
var seeking = false

@onready var rb = $Rig

func _ready():
	await get_tree().create_timer(0.4).timeout
	seeking = true
	target_enemy = get_nearest_enemy()

func _physics_process(delta):
	if not is_instance_valid(rb):
		return  # RigidBody freed; safely exit the method

	if target_enemy and is_instance_valid(target_enemy) and seeking:
		var direction = (target_enemy.global_position - rb.global_position).normalized()
		var target_rotation = transform.looking_at(target_enemy.global_position, Vector3.UP).basis.get_euler()
		rb.rotation = rb.rotation.slerp(target_enemy.rotation, 0.1)

		rb.linear_velocity = direction * speed

func get_nearest_enemy():
	var nearest_enemy = null
	var nearest_distance = INF

	for enemy in enemy_list:
		if not is_instance_valid(enemy): #redundant?  added a second check because a crash was caused once
			continue
		var distance = rb.global_position.distance_to(enemy.global_position) if is_instance_valid(enemy) else null
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_enemy = enemy

	return nearest_enemy
