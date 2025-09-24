@tool
extends EditorScript

func _run():
	var editor_if = get_editor_interface()
	var root = editor_if.get_edited_scene_root()
	if root == null:
		printerr("❌ No scene open!")
		return
	
	var map_node = root.get_node("MAP")
	if map_node == null:
		printerr("❌ Couldn’t find MAP under RootNode")
		return
	
	var count := 0
	_enable_layer2_on_staticbodies(map_node, count)
	print("✅ Updated collision layers/masks for %d StaticBody3D nodes" % count)
	
	# Refresh the editor to show changes immediately
	editor_if.inspect_object(map_node)

func _enable_layer2_on_staticbodies(node: Node, count: int) -> void:
	if node is StaticBody3D:
		node.collision_layer |= 1 << 1  # add layer 2
		node.collision_mask  |= 1 << 1
		count += 1
	
	for child in node.get_children():
		_enable_layer2_on_staticbodies(child, count)
