@tool
extends EditorScript

func _run():
	var selection := get_editor_interface().get_selection()
	var nodes := selection.get_selected_nodes()

	if nodes.size() != 1 or not nodes[0] is AnimationPlayer:
		push_error("Select exactly one AnimationPlayer.")
		return

	var anim_player: AnimationPlayer = nodes[0]
	var removed := 0

	print("=== Animation Cleanup Start ===")

	for anim_name in anim_player.get_animation_list():
		var anim := anim_player.get_animation(anim_name)
		if anim == null:
			continue

		print("\nAnimation:", anim_name)

		for track_idx in range(anim.get_track_count() - 1, -1, -1):
			var path := anim.track_get_path(track_idx)
			var key_count := anim.track_get_key_count(track_idx)
			var track_type := anim.track_get_type(track_idx)

			# Bone track detection (Godot 4)
			var is_bone_track := (
				path.get_subname_count() >= 1 and
				(
					track_type == Animation.TYPE_POSITION_3D or
					track_type == Animation.TYPE_ROTATION_3D or
					track_type == Animation.TYPE_SCALE_3D
				)
			)

			if not is_bone_track:
				continue

			if key_count <= 1:
				print(
					" REMOVING | Keys:", key_count,
					"| Type:", track_type,
					"| Path:", path
				)
				anim.remove_track(track_idx)
				removed += 1

	print("\n=== Cleanup complete ===")
	print("Removed %d bone tracks with <= 1 keyframe." % removed)
