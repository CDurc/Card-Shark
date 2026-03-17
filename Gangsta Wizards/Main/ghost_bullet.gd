extends Node3D

var immediate_mesh: ImmediateMesh
var mesh_instance: MeshInstance3D

@onready var raycast: RayCast3D = $Raycast

func _ready() -> void:
	immediate_mesh = ImmediateMesh.new()
	
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color.RED
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = immediate_mesh
	mesh_instance.material_override = mat
	add_child(mesh_instance)

func draw_ray() -> void:
	immediate_mesh.clear_surfaces()
	
	if not raycast.is_colliding():
		return
	
	var local_to := to_local(raycast.get_collision_point())
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	immediate_mesh.surface_add_vertex(Vector3.ZERO)
	immediate_mesh.surface_add_vertex(local_to)
	immediate_mesh.surface_end()
