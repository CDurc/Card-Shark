extends PathFollow3D

@export var mps: float = 10

@onready var anime: AnimationPlayer = $goblin_6/AnimationPlayer

var flying = true


func _ready() -> void:
	flap_loop()


func _process(delta: float) -> void:
	if flying:
		progress += mps * delta


func flap_loop() -> void:
	while flying:
		var rand_wait := randi_range(2, 6)
		await get_tree().create_timer(rand_wait).timeout
		if flying: #Second check is important here, trust
			anime.play("Flying")
