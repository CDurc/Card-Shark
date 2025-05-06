extends CharacterBody3D

@export var follow_distance = 10
@export var attack_distance = 2
@export var follow_speed = 2.0
@export var gravity_strength = 20.0
@export var can_move = true
@export var can_turn = true
@export var damaging = false
@export var health := 100

var player
var destroyed := false
var attacking = false

@onready var pipe = $Goblin.get_node("Goblin Bones/Skeleton3D/HandContainer/Metal Pipe/Cylinder")
@onready var current_color = pipe.get_active_material(0).albedo_color
@onready var area3D = $Goblin.get_node("Goblin Bones/Skeleton3D/HandContainer/Metal Pipe/Area3D")
@onready var damaged_bodies = area3D.damaged_bodies
@onready var monitor = area3D.monitoring
@onready var anime = get_node("Goblin/AnimationPlayer")

func _ready():
	call_deferred("_find_player")

func _find_player():
	player = get_tree().get_first_node_in_group("Player")
	print("Found player:", player)

func _physics_process(delta):
	
	#if is_on_floor():
		#if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			#self.get_node("Goblin/AnimationPlayer").play("Walking")
	
	if not player:
		return
		
	velocity.y -= gravity_strength * delta
	if is_on_floor():
		velocity.y = 0

	#distance to player
	var my_pos = global_transform.origin
	var player_pos = player.global_transform.origin
	var dist_to_player = my_pos.distance_to(player_pos)

	#Close enough to follow
	if dist_to_player < follow_distance and can_turn:
		var direction = (player_pos - my_pos).normalized()
		# Update only x and z; keep y for gravity
		velocity.x = direction.x * follow_speed
		velocity.z = direction.z * follow_speed
		look_at(Vector3(player_pos.x, my_pos.y, player_pos.z))
	else:
		#Or follow path
		velocity.x = 0
		velocity.z = 0
	
	#attacking
	if dist_to_player < attack_distance and not attacking:
		attack()
	
	if self.can_move: #Basking shark check  mainly
		var on_floor_after = move_and_slide()

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
	anime.stop()
	anime.play("Attack")
	await get_tree().create_timer(0.9).timeout
	
	#Damage, swing down
	damaging = true
	monitor = true
	area3D.overlap_check()
	pipe.get_active_material(0).albedo_color = Color.RED
	await get_tree().create_timer(0.8).timeout
	
	#Can't damage, wait for next attack
	damaging = false
	monitor = false
	pipe.get_active_material(0).albedo_color = current_color
	await get_tree().create_timer(1.5).timeout
	damaged_bodies.clear() #Allow damaged bodies to be hit again
	attacking = false
