@tool
extends EditorScript

func _run():
	var glb_paths = [
		"res://models/my_model.glb",
		"res://models/other.glb",
	]
	for path in glb_paths:
		var scene = load(path).instantiate()
		_set_layer_and_mask_recursively(scene)
		ResourceSaver.save(path, scene)  # overwrites with corrected scene

func _set_layer_and_mask_recursively(node: Node) -> void:
	if node is CollisionObject3D:
		node.collision_layer = 1 << 1
		node.collision_mask = 1 << 1
	for child in node.get_children():
		_set_layer_and_mask_recursively(child)
