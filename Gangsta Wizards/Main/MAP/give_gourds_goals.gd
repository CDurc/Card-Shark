extends Node3D

var all_goals = []
var special_goals = []  #Goals that require coordination between two gourds and therefore MUST give the tasks at the same time
var g1 = []
var g2 = []

@onready var gourdling1 = $"../Gourdling"
@onready var gourdling2 = $"../Gourdling2"

func randomize_into_lists(pool: Array, list1: Array, list2: Array):
	var shuffled_pool = pool.duplicate()
	shuffled_pool.shuffle()
	
	for i in range(shuffled_pool.size()):
		if i % 2 == 0:
			list1.append(shuffled_pool[i])
		else:
			list2.append(shuffled_pool[i])

func _ready():
	special_goals = [
		{"goal": $GourdFightSpot1/FightSpot1, "task": "fight_task", "time": 40},
		{"goal": $GourdFightSpot1/FightSpot2, "task": "fight_task", "time": 40}
	]
	
	all_goals = [
		{"goal": $"../Gourd Goals/SitSpot3", "task": "sit", "time": 20},
		{"goal": $"../Gourd Goals/Bush Puncher", "task": "punch_task", "time": 12},
		{"goal": $"../Gourd Goals/AnotherGoal", "task": "punch_task", "time": 12},
		[
			{"goal": $"../Gourd Goals/SeedyDoorSpot", "task": "open_door"},
			{"goal": $"../Gourd Goals/SeedySitSpot1", "task": "sit", "time": 40},
			{"goal": $"../Gourd Goals/SeedyDoorSpot/IndoorSpot", "task": "open_door_exit"},
		],
				[
			{"goal": $"../Gourd Goals/SeedyDoorSpot", "task": "open_door"},
			{"goal": $"../Gourd Goals/SeedySitSpot2", "task": "sit", "time": 40},
			{"goal": $"../Gourd Goals/SeedyDoorSpot/IndoorSpot", "task": "open_door_exit"},
		],
				[
			{"goal": $"../Gourd Goals/SeedyDoorSpot", "task": "open_door"},
			{"goal": $"../Gourd Goals/SeedySitSpot3", "task": "sit", "time": 40},
			{"goal": $"../Gourd Goals/SeedyDoorSpot/IndoorSpot", "task": "open_door_exit"},
		],
		{"goal": $"../Gourd Goals/SitSpot2", "task": "sit", "time": 20},
	]
	
	distribute_special_goals()
	randomize_into_lists(all_goals, g1, g2)
	
	# Convert task strings to Callables for each gourdling
	flatten_goals_with_callables(g1, gourdling1.goal_task_queue, gourdling1)
	gourdling1.start_next_goal_task()
	
	flatten_goals_with_callables(g2, gourdling2.goal_task_queue, gourdling2)
	gourdling2.start_next_goal_task()

func distribute_special_goals():
	# Use the same flatten function for special goals
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
