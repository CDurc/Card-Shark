extends Area3D

@export var target_node: NodePath
@export var fly_speed: float = 5.0 

var flying_characters = {}  # Dictionary to track flying characters

func _ready():
	connect("body_entered", _on_body_entered)

func _physics_process(delta):
	# Create a list of characters to remove
	var to_remove = []

	for character in flying_characters.keys():
		var ref = flying_characters[character].get_ref()
		if ref == null:  # The character has been deleted!
			to_remove.append(character)
		else:
			suck(ref, delta)  # Only process if still valid

	# Remove deleted characters from the dictionary
	for character in to_remove:
		flying_characters.erase(character)


func _on_body_entered(body):
	if body is CharacterBody3D and target_node:
		print("Character entered:", body.name)
		flying_characters[body] = weakref(body)  # Store a weak reference


func suck(character, delta):
	var target = get_node(target_node)
	
	if character.can_move:
		character.can_move = false
	
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
