extends PathFollow3D

@export var mps: float
@export var left_path: bool

@onready var anime: AnimationPlayer = $goblin_6/AnimationPlayer
@onready var gob = $goblin_6
@onready var left_paths = get_node("/root/Rootbeer/LeftFlyRails")
@onready var right_paths = get_node("/root/Rootbeer/RightFlyRails")

var flying = true
var mod_speed: float
var rand_mod = randi_range(-3,3) #no need to be an int idk

func _ready() -> void:
	mod_speed = mps + rand_mod
	flap_loop()
	print(left_paths)


func _process(delta: float) -> void:
	if flying and gob.can_move:
		progress += mod_speed * delta
		if progress_ratio >= 0.995:
			change_rails()
		


func flap_loop() -> void:
	while flying:
		var rand_wait := randi_range(2, 6)
		await get_tree().create_timer(rand_wait).timeout
		if flying: #Second check is important here, trust
			anime.play("Flying")

func change_rails() -> void:
	flying = false
	var rails: Node3D
	if left_path:
		rails = right_paths
	else:
		rails = left_paths
	var rail_children = rails.get_children()
	var random_rail = rail_children.pick_random()
	print("RANDOM RAIL CHOSEN:  ", random_rail)
	self.reparent(random_rail)
	progress = 0
	flying = true
	left_path = !left_path
	
	
