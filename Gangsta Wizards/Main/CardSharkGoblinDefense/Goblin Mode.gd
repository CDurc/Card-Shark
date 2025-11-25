extends Node3D

var current_round = 0

@onready var round_label = $RoundTimer/CanvasLayer/Round
@onready var round_timer = $RoundTimer
@onready var big_spawn = $"Big Spawn"
@onready var little_spawns = $"Little Spawns".get_children()
@onready var big_parent_node = $"../NavMap/LargeNav"
@onready var small_parent_node = $"../NavMap/SmallNav"
@onready var enemy_scenes = {
	"pipe": preload("res://Card Shark Campaign/Character Models/Goblins/SMART GOBLIN.tscn"),
	"gun": preload("res://Card Shark Campaign/Character Models/Goblins/SMART SHOOT GOBLIN AUBURN.tscn"),
	"bomb": preload("res://Card Shark Campaign/Character Models/Goblins/SMART BOMBER.tscn"),
	"roll": preload("res://Card Shark Campaign/Character Models/Goblins/SMART ROLL GOBLIN.tscn"),
	"sign": preload("res://Card Shark Campaign/Character Models/Goblins/SMART SIGN GOBLIN.tscn")
}


var rounds = [
	{ "small": {"pipe": 50, "gun": 0, "bomb": 0}, "big": {"roll": 0, "sign": 0} },
	{ "small": {"pipe": 6, "gun": 0, "bomb": 0}, "big": {"roll": 0, "sign": 0} },
	{ "small": {"pipe": 6, "gun": 1, "bomb": 0}, "big": {"roll": 0, "sign": 0} },
	{ "small": {"pipe": 6, "gun": 0, "bomb": 0}, "big": {"roll": 0, "sign": 1} },
	{ "small": {"pipe": 8, "gun": 2, "bomb": 0}, "big": {"roll": 0, "sign": 0} },
	{ "small": {"pipe": 0, "gun": 0, "bomb": 0}, "big": {"roll": 3, "sign": 0} },
	{ "small": {"pipe": 0, "gun": 0, "bomb": 14}, "big": {"roll": 0, "sign": 0} },
	{ "small": {"pipe": 4, "gun": 3, "bomb": 4}, "big": {"roll": 0, "sign": 0} },
	{ "small": {"pipe": 0, "gun": 3, "bomb": 0}, "big": {"roll": 0, "sign": 3} },
	{ "small": {"pipe": 8, "gun": 0, "bomb": 8}, "big": {"roll": 2, "sign": 0} }
]

# Track cooldowns for each spawn point
var spawn_cooldowns = {}
const COOLDOWN_TIME = 2.0

func _ready() -> void:
	# Initialize cooldowns
	for s in little_spawns:
		spawn_cooldowns[s] = 0.0
	spawn_cooldowns[big_spawn] = 0.0

	#Timer timeouts every 20 seconds automatically
	round_timer.connect("timeout", Callable(self, "_on_round_timer_timeout"))
	# Start first round
	start_round(0)
	
	

func _on_round_timer_timeout() -> void:
	# Advance to next round
	current_round += 1
	if current_round >= rounds.size():
		current_round = 0  # loop back to first round, or stop if you prefer

	round_label.text = "Round " + str(current_round+1)
	start_round(current_round)

func _process(delta: float) -> void:
	# Reduce cooldown timers
	for key in spawn_cooldowns.keys():
		if spawn_cooldowns[key] > 0:
			spawn_cooldowns[key] -= delta


func start_round(round_index: int) -> void:
	if round_index < rounds.size():
		current_round = round_index
		var round_data = rounds[round_index]

		# Spawn small enemies
		for enemy_type in round_data["small"].keys():
			for i in range(round_data["small"][enemy_type]):
				spawn_small_enemy(enemy_type)

		# Spawn big enemies
		for enemy_type in round_data["big"].keys():
			for i in range(round_data["big"][enemy_type]):
				spawn_big_enemy(enemy_type)


func spawn_small_enemy(enemy_type: String) -> void:
	# Pick a random little spawn that is off cooldown
	var available: Array = []
	for s in little_spawns:
		if spawn_cooldowns[s] <= 0:
			available.append(s)

	if available.size() == 0:
		await get_tree().create_timer(0.5).timeout
		spawn_small_enemy(enemy_type)
		return

	var spawn_point = available[randi() % available.size()]
	spawn_enemy(enemy_type, spawn_point, small_parent_node)
	spawn_cooldowns[spawn_point] = COOLDOWN_TIME



func spawn_big_enemy(enemy_type: String) -> void:
	if spawn_cooldowns[big_spawn] > 0:
		await get_tree().create_timer(0.5).timeout
		spawn_big_enemy(enemy_type)
		return

	spawn_enemy(enemy_type, big_spawn, big_parent_node)
	spawn_cooldowns[big_spawn] = COOLDOWN_TIME


func spawn_enemy(enemy_type: String, spawn_point: Node3D, parent_node) -> void:
	if not enemy_scenes.has(enemy_type):
		push_error("No scene found for enemy type: " + enemy_type)
		return
	
	var enemy_instance = enemy_scenes[enemy_type].instantiate()
	parent_node.add_child(enemy_instance) 
	
	enemy_instance.global_transform.origin = spawn_point.global_transform.origin
	print("Spawned %s at %s parented to %s" % [enemy_type, spawn_point.name, parent_node])
