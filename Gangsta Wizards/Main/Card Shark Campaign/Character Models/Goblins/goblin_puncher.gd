extends CharacterBody3D

@export var follow_distance = 4
@export var attack_distance = 2
@export var follow_speed = 2.0
@export var gravity_strength = 20.0
@export var can_move = true
@export var damaging = false

var player
var health := 100
var destroyed := false
var attacking = false

@onready var area3D = $Area3D
@onready var damaged_bodies = area3D.damaged_bodies
@onready var monitor = area3D.monitoring
@onready var anime = get_node("goblin_2/AnimationPlayer")

func _ready():
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta):
	
	#if is_on_floor():
		#if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			#self.get_node("Goblin/AnimationPlayer").play("Walking")
	

	#distance to player
	var my_pos = global_transform.origin
	var player_pos = player.global_transform.origin
	var dist_to_player = my_pos.distance_to(player_pos)

	#attacking
	if dist_to_player < attack_distance and not attacking:
		attack()

func destroy():
	Audio.play("sounds/enemy_destroy.ogg")
	destroyed = true
	queue_free()
	
func damage(amount):
	health -= amount
	if health <= 0 and !destroyed:
		destroy()
		
func attack():
	#Wind up, can't damage
	attacking = true
	anime.play("Attack")
	await get_tree().create_timer(0.8).timeout
	
	#Damage, swing down
	damaging = true
	monitor = true
	area3D.overlap_check()
	await get_tree().create_timer(0.8).timeout
	
	#Can't damage, wait for next attack
	damaging = false
	monitor = false
	await get_tree().create_timer(1).timeout
	damaged_bodies.clear() #Allow damaged bodies to be hit again
	attacking = false
