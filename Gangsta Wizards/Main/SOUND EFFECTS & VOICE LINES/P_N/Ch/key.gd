extends Area3D

@export var sound1: AudioStream
@export var sound2: AudioStream
@export var sound3: AudioStream
@export var rare_sound: AudioStream = preload("res://SOUND EFFECTS & VOICE LINES/P_N/Ch/Sound 29.wav")

@onready var sounds = [sound1,sound2,sound3]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Non-enemy-hit")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func damage(dmg):
	var rando = randi_range(1,20)
	if rando == 1:
		spawn_sound(rare_sound)
	else:
		spawn_sound(sounds.pick_random())
	


func spawn_sound(stream: AudioStream):
	var p := AudioStreamPlayer3D.new()
	p.stream = stream
	p.autoplay = true
	p.global_position = self.global_position

	add_child(p)
	#await get_tree().process_frame
	p.global_position = self.global_position

	p.finished.connect(func():
		p.queue_free())
