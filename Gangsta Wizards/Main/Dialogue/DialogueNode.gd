class_name DialogueNode extends Resource

@export var text: String = ""
@export var options: Array[String] = []
@export var options_goto: Array[int] = []  #If theres a check, go here on success

# Stat check per option ("" means no check)
@export var options_check_property: Array[String] = []  # e.g. "has_key", "strength", ""
@export var options_check_value: Array[int] = []        # Value to compare against (1 = true for bools), -1 = no check needed
@export var options_fail_goto: Array[int] = []         #If theres a check, go here on fail

#Call a method when needed
@export var options_call_method: Array[String] = []
