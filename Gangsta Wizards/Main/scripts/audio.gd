extends Node

# Code adapted from KidsCanCode

var num_players = 12
var bus = "master"

var available = []  # The available players.
var queue = []      # Queue of sounds to play (normal pitch)
var queue_pitch = []  # Queue of sounds with specified pitch

func _ready():
	for i in num_players:
		var p = AudioStreamPlayer.new()
		add_child(p)

		available.append(p)

		p.volume_db = -10
		p.finished.connect(_on_stream_finished.bind(p))
		p.bus = bus

func _on_stream_finished(stream):
	available.append(stream)

# Works exactly like current play
func play(sound_path):
	var sounds = sound_path.split(",")
	queue.append("res://" + sounds[randi() % sounds.size()].strip_edges())

# Play with a specified pitch
func play_pitch(sound_path, pitch):
	var sounds = sound_path.split(",")
	queue_pitch.append({ "path": "res://" + sounds[randi() % sounds.size()].strip_edges(), "pitch": pitch })

func _process(_delta):
	if not available.is_empty():
		var p = available[0]
		
		if not queue_pitch.is_empty():
			var item = queue_pitch.pop_front()
			p.stream = load(item["path"])
			p.pitch_scale = item["pitch"]
			p.play()
			available.pop_front()
		elif not queue.is_empty():
			var path = queue.pop_front()
			p.stream = load(path)
			p.pitch_scale = randf_range(0.9, 1.1)  # random pitch for variety
			p.play()
			available.pop_front()
