extends Control

@onready var label = $Healthbar
#@onready var camera = $"../../../Player/Head/Camera"
@onready var target = $".."

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var camera = player.get_node("Head/Camera")

func _process(_delta):
	var world_pos = target.global_transform.origin + Vector3.UP * 1.5
	var screen_pos = camera.unproject_position(world_pos)

	# Optionally hide if behind camera
	if camera.is_position_behind(world_pos):
		label.visible = false
	else:
		label.visible = true
		label.position = screen_pos
		label.position = screen_pos - (label.size * 0.5) * label.scale

		var distance = camera.global_transform.origin.distance_to(target.global_transform.origin)
		var scale_factor = clamp(1.0 / distance * 10.0, 0.5, 2.0)
		label.scale = Vector2.ONE * scale_factor
