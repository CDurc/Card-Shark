extends Node3D

@onready var camera: Camera3D = $"../../Cam Work/Camera3D"

@export var arm_path: NodePath		# arrow / needle node
@export var horizontal_only := true	# yaw only (compass)
@export var arm_base_length := 1.0	# mesh default length in world units

@onready var arm: Node3D = get_node_or_null(arm_path)
@onready var chips = arm.get_node("SharkArm/ArmBone/Skeleton3D/BoneAttachment3D/Chips")
@onready var collider = chips.get_node("Area3D")

var arm_orig_scale: Vector3 = Vector3.ONE

var hovered_area: Area3D = null
var hovered_mesh: MeshInstance3D = null
var original_mat: Material = null
const HOVER_COLOR := Color(0, 0, 0, 0.5)

var extending = false
var extended = false
var stretch_step = 0.01

func _ready() -> void:
	if arm:
		arm_orig_scale = arm.scale
	await get_tree().create_timer(10).timeout
	extending = true

func _physics_process(_delta: float) -> void:
	
	if extending and stretch_step < 1:
		stretch_step += 0.4 * _delta
	elif extending and stretch_step >1:
		stretch_step = 1
	
	var mouse_pos := get_viewport().get_mouse_position()
	var origin := camera.project_ray_origin(mouse_pos)
	var dir := camera.project_ray_normal(mouse_pos)
	var target := origin + dir * 1000.0
	
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
	
	# ── rotate + scale the arm ───────────────────────────────────────────
	var hit_pos := target
	if result:
		hit_pos = result.position
	_point_arm(hit_pos)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var bodies = collider.get_overlapping_areas()
		if len(bodies) == 1:
			print(bodies)
			if bodies[0].has_method("launch_scene"):
				bodies[0].call("launch_scene")
			
		elif len(bodies) > 1:
			print("multiple buttons selected")
		elif len(bodies) < 1:
			print("no buttons selected")
		else:
			print("idk wtf")

# ───────────────────────────────────────────────────────────────────────────
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

# ─────────────────────── compass arm helper ───────────────────────────────
func _point_arm(hit: Vector3) -> void:
	if !arm:
		return

	var pivot := arm.global_transform.origin
	var to_hit := hit - pivot
	if horizontal_only:
		to_hit.y = 0.0
	if to_hit.length_squared() < 0.0001:
		return
	
	# orient first
	arm.look_at(pivot + to_hit, Vector3.UP)
	
	var dist := to_hit.length()
	var z_scale := dist / arm_base_length
	arm.scale = Vector3(
		arm_orig_scale.x,
		arm_orig_scale.y,
		arm_orig_scale.z * z_scale * stretch_step
	)
	chips.scale = Vector3(
		arm_orig_scale.x,
		arm_orig_scale.y,
		arm_orig_scale.z / (z_scale * stretch_step)
	)
