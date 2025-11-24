extends PathFollow3D

@export var mps: float

@onready var anime: AnimationPlayer = $goblin_6/AnimationPlayer

var flying = true
var mod_speed: int
var rand_mod = randi_range(-3,3)

func _ready() -> void:
	mod_speed = mps + rand_mod
	flap_loop()


func _process(delta: float) -> void:
	if flying:
		progress += mod_speed * delta


func flap_loop() -> void:
	while flying:
		var rand_wait := randi_range(2, 6)
		await get_tree().create_timer(rand_wait).timeout
		if flying: #Second check is important here, trust
			anime.play("Flying")
