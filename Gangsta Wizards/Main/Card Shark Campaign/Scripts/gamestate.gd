extends Node

enum GameMode { GAMEPLAY, DIALOGUE }

var current_mode = GameMode.GAMEPLAY

signal money_changed(new_value)

var money: int = 0:
	set(value):
		money = value
		emit_signal("money_changed", money)
