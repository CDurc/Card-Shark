#Sourmen
extends Node3D

var all_goals = []
var special_goals = []  #Goals that require coordination between two gourds and therefore MUST give the tasks at the same time
var g1 = []
var g2 = []

@onready var gourdling1 = $"../Sourpeople/Sourman"
@onready var gourdling2 = $"../Sourpeople/Sourman2"

func randomize_into_lists(pool: Array, list1: Array, list2: Array):
	var shuffled_pool = pool.duplicate()
	shuffled_pool.shuffle()
	
	for i in range(shuffled_pool.size()):
		if i % 2 == 0:
			list1.append(shuffled_pool[i])
		else:
			list2.append(shuffled_pool[i])

func _ready():
	all_goals = [
		{"goal": $Idlepoint, "task": "idle_task", "time": 12},
		{"goal": $Idlepoint2, "task": "idle_task", "time": 12},
		{"goal": $Idlepoint3, "task": "idle_task", "time": 12},
		{"goal": $Idlepoint4, "task": "idle_task", "time": 12}
	]
	
	distribute_special_goals()
	randomize_into_lists(all_goals, g1, g2)
	
	# Convert task strings to Callables for each gourdling
	flatten_goals_with_callables(g1, gourdling1.goal_task_queue, gourdling1)
	#gourdling1.start_next_goal_task()
	
	flatten_goals_with_callables(g2, gourdling2.goal_task_queue, gourdling2)
	#gourdling2.start_next_goal_task()

func distribute_special_goals():
	# Use the same flatten function for special goals
	if len(special_goals) > 0:
		flatten_goals_with_callables([special_goals[0]], gourdling1.goal_task_queue, gourdling1)
		flatten_goals_with_callables([special_goals[1]], gourdling2.goal_task_queue, gourdling2)

func flatten_goals_with_callables(goals: Array, queue: Array, gourdling: Node):
	for item in goals:
		if item is Array:
			# Flatten sequences
			for sub_item in item:
				var goal_copy = sub_item.duplicate()
				goal_copy["task"] = Callable(gourdling, sub_item["task"])
				queue.append(goal_copy)
		else:
			var goal_copy = item.duplicate()
			goal_copy["task"] = Callable(gourdling, item["task"])
			queue.append(goal_copy)
