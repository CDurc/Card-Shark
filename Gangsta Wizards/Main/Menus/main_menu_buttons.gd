extends Node3D

@onready var camera: Camera3D = $"../../Cam Work/Camera3D"

var hovered_area: Area3D = null
var hovered_mesh: MeshInstance3D = null
var original_mat: Material = null
const HOVER_COLOR := Color(0, 0, 0, 0.5)	# tweak highlight colour

func _physics_process(_delta: float) -> void:
	var mouse_pos := get_viewport().get_mouse_position()
	var origin := camera.project_ray_origin(mouse_pos)
	var target := origin + camera.project_ray_normal(mouse_pos) * 1000.0
	
	var query := PhysicsRayQueryParameters3D.new()
	query.from = origin
	query.to = target
	query.collision_mask = 1
	query.collide_with_areas = true
	query.collide_with_bodies = false
	
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	
	if result and result.collider is Area3D:
		var area := result.collider as Area3D
		if area != hovered_area:
			_clear_hover()
			_apply_hover(area)
	else:
		_clear_hover()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if hovered_area:
			print("Clicked:", hovered_area.name)
			# call your click action here, e.g. hovered_area.emit_signal("pressed")

# ────────────────────────────────────────────────────────────────────────────────
func _apply_hover(area: Area3D) -> void:
	hovered_area = area
	hovered_mesh = area.get_parent() as MeshInstance3D
	if hovered_mesh:
		original_mat = hovered_mesh.get_active_material(0)
		var hover_mat := original_mat.duplicate()
		hover_mat.albedo_color = HOVER_COLOR
		hovered_mesh.set_surface_override_material(0, hover_mat)

func _clear_hover() -> void:
	if hovered_mesh:
		hovered_mesh.set_surface_override_material(0, original_mat)
	hovered_area = null
	hovered_mesh = null
	original_mat = null
