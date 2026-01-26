extends RigidBody3D

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var collision = $CollisionShape3D
@onready var tool = $".."
@onready var nade_spawn = $"../GrenadeSpawn"
@onready var particles = $Particles/Particles
@onready var bubbles = $Particles/Bubbles
@onready var smoke = $Particles/Smoke
@onready var global_smoke = $Particles/Global_Smoke
@onready var global_particles = $Particles/Global_Particles

@export var damage: float = 55
@export var timer: float = 5.25

var rand_t = randf_range(-2.25,2.25)
var pin_pulled: = false
var has_exploded: bool = false  # To prevent multiple triggers
var dud_boom_scene = preload("res://Particles/dud_gambler_boom.tscn")
var small_boom_scene = preload("res://Particles/small_gambler_boom.tscn")
var medium_boom_scene = preload("res://Particles/medium_gambler_boom.tscn")
var large_boom_scene = preload("res://Particles/large_gambler_boom.tscn")
var huge_boom_scene = preload("res://Particles/huge_gambler_boom.tscn")
var time = 0
var t = 0 #This is capped after throwing while time is not
var p_ratio: float = 0.0
var b_ratio: float = 0.0
var thrown: = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("FUCK")
	print("TIMER AT FIRST WAS", timer)
	print("RAND_T CHOSEN WAS",  rand_t)
	timer = timer + rand_t
	print("TIMER NOW IS,",timer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if pin_pulled:
		if time < timer:
			time += delta
			p_ratio = 1.0 - exp(-pow(time / 4.0, 3.0))
			b_ratio = 1.0 - exp(-pow(time / 3.0, 2.0))
			particles.amount_ratio = p_ratio
			bubbles.amount_ratio = b_ratio

		else:
			if thrown == false:  #If not thrown, cook time was how long you held it
				t = time
			pin_pulled = false
			boom()

func pull_pin():
	pin_pulled = true
	smoke.emitting = true
	particles.emitting = true
	bubbles.emitting = true
	

func throw_grenade_g():
	thrown = true
	print("P RATIO ON RELEASE", p_ratio)
	var p = p_ratio #How far the particles have progressed
	t = time #Time since pin pulled
	print("YOU HELD THE NADE FOR:   ", t)
	self.reparent(get_tree().root)
	self.freeze = false
	var cam_forward = -player.camera.global_transform.basis.z
	cam_forward.y *= 1.3  #Exaggerate
	cam_forward = cam_forward.normalized()

	linear_velocity = cam_forward * 12
	print("THROWN")
	collision.disabled = false
	await get_tree().create_timer(0.1).timeout
	global_smoke.emitting = true
	await get_tree().create_timer(0.25).timeout
	global_particles.amount_ratio = p
	global_particles.emitting = true


var boomi
func boom():
	if t < 0.4:
		print("dud")
		boomi = dud_boom_scene.instantiate()
		boomi.global_position = self.global_position + 0.4*Vector3.UP
	elif t < 2:
		print("small")
		boomi = small_boom_scene.instantiate()
		boomi.global_position = self.global_position + 0.4*Vector3.UP
	elif t < 3.8:
		print("medium")
		boomi = medium_boom_scene.instantiate()
		boomi.global_position = self.global_position + 0.8*Vector3.UP
	elif t < 5.1:
		print("large")
		boomi = large_boom_scene.instantiate()
		boomi.global_position = self.global_position + 1.5*Vector3.UP
	elif t >= 5.1:
		print("huge")
		boomi = huge_boom_scene.instantiate()
		boomi.global_position = self.global_position + 1.5*Vector3.UP
	get_tree().root.add_child(boomi)
	has_exploded = true
	queue_free()
