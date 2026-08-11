extends Node3D

@onready var lever = $"Slot Machine2/Lever"
@onready var wheel1 = $"Slot Machine2/Slot Wheel1"
@onready var wheel2 = $"Slot Machine2/Slot Wheel2"
@onready var wheel3 = $"Slot Machine2/Slot Wheel3"

var gambling = false
#The index values that the wheels will land on
var w1
var w2
var w3
#The index values that the wheels are/were on
var o1 = 0
var o2 = 0
var o3 = 0

func damage(dmg):
	if not gambling:
		gambling = true
		pull_lever()
		
func pull_lever():
	gamble()
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(lever, "rotation_degrees:x", 74, 0.5)
	
	await get_tree().create_timer(0.6).timeout
	
	var tween2 = create_tween()
	tween2.set_trans(Tween.TRANS_CUBIC)
	tween2.set_ease(Tween.EASE_OUT)
	tween2.tween_property(lever, "rotation_degrees:x", 0, 0.5)
	

func gamble():
	#Pre-determined outcome:
	w1 = randi_range(0,9)
	#rig higher odds of wheel 2 matching
	var check1 = randf_range(0,1)
	if check1 > 0.5:
		#Wheel 2 matches
		w2 = w1
	else:
		w2 = randi_range(0,9) #This could still win!
	#rig higher odds of wheel 3 matching
	var check2 = randf_range(0,1)
	if check2 > 0.5:
		#Wheel 3 matches
		w3 = w2
	else:
		w3 = randi_range(0,9)
	print(w1,w2,w3)
	spin_to(wheel1,w1,o1,2.5)
	spin_to(wheel2,w2,o2,3)
	spin_to(wheel3,w3,o3,3.5)
	await get_tree().create_timer(3.6).timeout
	o1 = w1
	o2 = w2
	o3 = w3
	gambling = false
	
func spin_to(wheel, new_index: int, old_index: int, duration := 2.5) -> void:
	var total := 360.0 * 10 + new_index * 36.0 - old_index * 36.0
	var tween = create_tween()
	tween.tween_property(wheel, "rotation_degrees:x", total, duration).as_relative()
