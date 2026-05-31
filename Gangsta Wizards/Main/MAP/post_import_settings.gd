@tool
extends EditorScenePostImport

func _post_import(scene: Node) -> Node:
	var phys_node = scene.get_node_or_null("1 - PHYS")
	var manual_node = scene.get_node_or_null("2 - MANUAL")
	
	if phys_node:
		_setup_physics_for_meshes(phys_node)
		print("RUNNING AUTO PHYSICS ENABLER 1-2-4 FOR 1-PHYS")
		
	if manual_node:
		_setup_physics_for_meshes(manual_node)
		print("RUNNING AUTO PHYSICS ENABLER 1-2-4 FOR 2-MANUAL")
	
	return scene


func _setup_physics_for_meshes(node: Node) -> void:
	# Only handle MeshInstance3D nodes
	if node is MeshInstance3D:
		var found_body := false

		# Update all existing StaticBody3D children
		for child in node.get_children():
			if child is StaticBody3D:
				_set_physics_layers(child)
				found_body = true

		# If no StaticBody3D exists, create one from the mesh
		if not found_body:
			var body = StaticBody3D.new()
			node.add_child(body)
			
			var mesh = node.mesh
			if mesh:
				var shape = mesh.create_trimesh_shape()
				if shape:
					var col = CollisionShape3D.new()
					col.shape = shape
					body.add_child(col)
			
			_set_physics_layers(body)

	# Recurse safely into children
	for child in node.get_children():
		_setup_physics_for_meshes(child)


func _set_physics_layers(body: StaticBody3D) -> void:
	body.collision_layer = (1 << 0) | (1 << 1) | (1 << 3) | (1 << 6)
	body.collision_mask  = (1 << 0) | (1 << 1) | (1 << 3) | (1 << 6)
