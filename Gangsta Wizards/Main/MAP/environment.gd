extends Node3D

@export var time: float = 18 #In hours, military time
var print_timer = 0.0

@onready var celestial_axis = $CelestialBodies
@onready var env = $WorldEnvironment
@onready var sun = $CelestialBodies/Sun
@onready var moon = $CelestialBodies/Moon

var dist_from_noon: float
var energy: float

var day_length: float = 600 #In irl seconds, this is how long a 24h day should be
var rotation_deg: float = 0

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	#Change time
	
	time += (24.0 / day_length) * delta
	if time >= 24.0:
		time -= 24.0
	
	#Roate celestial bodies
	rotation_deg = ((time/24.0) * 360) - 180.0
	celestial_axis.rotation_degrees.z = rotation_deg
	
	#Change the environmental lighting
	dist_from_noon = abs(time - 12)
	energy = max(0.1, 0.8 - (dist_from_noon / 12))
	env.environment.ambient_light_energy = energy
	env.environment.background_energy_multiplier = energy
	
	print_timer += delta
	if print_timer >= 1.0:
		#print("energy is ", energy)
		#print("time is ", time)
		print_timer = 0
