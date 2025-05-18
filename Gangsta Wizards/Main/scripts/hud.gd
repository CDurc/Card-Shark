extends CanvasLayer


func _on_player_health_updated(health) -> void:
	print("oof")
	$Health.text = str(health) + "%"
