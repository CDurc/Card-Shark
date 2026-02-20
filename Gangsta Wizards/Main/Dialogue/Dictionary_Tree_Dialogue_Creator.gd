class_name DialogueTree extends Resource

@export var speaker_name: String = ""

# Dictionary of dialogue nodes
# Key = node id (int)
# Value = Dictionary with:
#   "text": String
#   "choices": Array[Dictionary]
@export var nodes: Dictionary = {}
