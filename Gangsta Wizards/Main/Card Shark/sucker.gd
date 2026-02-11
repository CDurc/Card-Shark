extends Area3D

@export var fly_speed: float = 5.0 

@onready var target_node = $Suckpoint
@onready var second_target_node = $Swallowpoint
@onready var ray = $Suckpoint/Ray

var flying_characters = {}
var to_remove = []

func _ready():
	connect("body_entered", _on_body_entered)

func _physics_process(delta):
	# Create a list of characters to remove
	for character in flying_characters.keys():
		var ref = flying_characters[character].get_ref()
		if ref == null:  # The character has been deleted!
			to_remove.append(character)
		else:
			suck(ref, delta, target_node)  # Only process if still valid

	# Remove deleted characters from the dictionary
	for character in to_remove:
		flying_characters.erase(character)


func _on_body_entered(body):
	if body is CharacterBody3D and target_node and body.is_in_group("Enemies"):
		print("Character entered:", body.name)
		flying_characters[body] = weakref(body)  # Store a weak reference
		if body.can_move:
			body.can_move = false


func suck(character, delta, target):  #Called every frame while in flying_list
	#Check if sucked player has CharacterCenter
	if character.has_node("CharacterCenter"):
		var center_node = character.get_node("CharacterCenter")
		var center_pos = center_node.global_transform.origin 
		var direction = (target.global_transform.origin - center_pos).normalized()
		character.velocity = direction * fly_speed
		character.move_and_slide()

	else:
		#Use CharacterBody3D center if they don't
		var direction = (target.global_transform.origin - character.global_transform.origin).normalized()
		character.velocity = direction * fly_speed
		character.move_and_slide()
		
	if character.global_position.distance_to(target.global_position) < 2.0:
		to_remove.append(character)
		var tween = create_tween()
		tween.tween_property(character, "global_position", second_target_node.global_position, 0.1)
		tween.tween_callback(func():
			if character:
				character.can_move = true
				character.damage(100)
		)
		print("tweening")
	
func _on_parent_deleting():
	# Restore can_move for all characters still being sucked
	for character in flying_characters.keys():
		var ref = flying_characters[character].get_ref()
		if ref != null:
			ref.can_move = true
			print("parent deleted, restoring can_move for", ref.name)
