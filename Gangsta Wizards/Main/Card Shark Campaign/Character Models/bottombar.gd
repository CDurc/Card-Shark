extends Control

@onready var ammoUI = $Ammo_icon/Ammo
@onready var moneyUI = $Money_icon/Money

func _ready() -> void:
	GameState.money_changed.connect(_on_money_changed)

	_on_money_changed(GameState.money) #initial money ammount

func _on_money_changed(new_value: int) -> void:
	moneyUI.text = "$" + str(new_value)
