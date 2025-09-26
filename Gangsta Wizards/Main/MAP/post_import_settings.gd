@tool
extends EditorScenePostImport

# Called automatically after a .glb is imported
func _post_import(scene: Node) -> Node:
	var phys_node = scene.get_node_or_null("1 - PHYS")
	var manual_node = scene.get_node_or_null("2 - Manual")
	if phys_node:
		_setup_physics_for_meshes(phys_node)
		print("RUNNING AUTO PHYSICS ENABLER 1-2-4")
		
		
		
	return scene

# Recursively find MeshInstance3D and enable physics
func _setup_physics_for_meshes(node: Node) -> void:
	if node is MeshInstance3D:
		# Check if it already has a physics body child
		var body: StaticBody3D = null
		for child in node.get_children():
			if child is StaticBody3D:
				body = child
				break
		
		# If no StaticBody3D exists, create one
		if body == null:
			body = StaticBody3D.new()
			node.add_child(body)
			# Attach a collision shape from mesh
			var shape = node.mesh.create_trimesh_shape()
			if shape:
				var col = CollisionShape3D.new()
				col.shape = shape
				body.add_child(col)
		
		# Set collision layers/mask: layers 1,2,4
		body.collision_layer = (1 << 0) | (1 << 1) | (1 << 3)
		body.collision_mask  = (1 << 0) | (1 << 1) | (1 << 3)
	
	# Recurse into children
	for child in node.get_children():
		_setup_physics_for_meshes(child)
