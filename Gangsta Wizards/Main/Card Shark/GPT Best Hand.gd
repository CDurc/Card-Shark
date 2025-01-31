extends Node

#Testing
func _ready():
	var my_seven_cards = [
		{"rank": 2, "suit": "hearts"},  # Ace of Hearts
		{"rank": 4, "suit": "hearts"},  # King of Hearts
		{"rank": 4, "suit": "diamonds"},  # Queen of Hearts
		{"rank": 2, "suit": "hearts"},  # Jack of Hearts
		{"rank": 6, "suit": "hearts"},  # 10 of Hearts
		{"rank": 3, "suit": "spades"},
		{"rank": 5, "suit": "diamonds"}
	]
	#var best_hand = get_best_poker_hand(my_seven_cards)
	#print(best_hand)  # Expected: "Royal Flush"


func get_best_poker_hand(cards):
	# Sort the cards by rank (ascending) using a custom comparator (boolean)
	cards.sort_custom(Callable(self, "_compare_cards"))

	# Group cards by rank and suit
	var rank_counts = {}
	var suit_counts = {}
	for card in cards:
		var r = card["rank"]
		var s = card["suit"]

		if not rank_counts.has(r):
			rank_counts[r] = 0
		rank_counts[r] += 1

		if not suit_counts.has(s):
			suit_counts[s] = []
		suit_counts[s].append(r)

	# Convert rank_counts to a sorted list of frequencies (ascending)
	var counts = rank_counts.values()
	counts.sort()

	# Identify any suit with >= 5 cards (possible flush)
	var possible_flush_suits = []
	for s in suit_counts.keys():
		if suit_counts[s].size() >= 5:
			possible_flush_suits.append(s)

	# Check Royal Flush / Straight Flush
	for flush_suit in possible_flush_suits:
		var flush_ranks = suit_counts[flush_suit].duplicate()
		flush_ranks.sort()

		# Check Royal Flush (10, 11, 12, 13, 14 all present)
		if _contains_all(flush_ranks, [10, 11, 12, 13, 14]):
			return "Royal Flush"

		# Check Straight Flush (is_straight on those ranks)
		if is_straight(flush_ranks):
			return "Straight Flush"

	# Four of a Kind
	if counts[counts.size() - 1] == 4:
		return "Four of a Kind"

	# Full House (3 + 2)
	if counts[counts.size() - 1] == 3 and counts.size() > 1 and counts[counts.size() - 2] >= 2:
		return "Full House"

	# Flush (≥5 cards same suit)
	for s in suit_counts.keys():
		if suit_counts[s].size() >= 5:
			return "Flush"

	# Straight (all suits)
	var all_ranks = []
	for card in cards:
		all_ranks.append(card["rank"])
	if is_straight(all_ranks):
		return "Straight"

	# Three of a Kind
	if counts[counts.size() - 1] == 3:
		return "Three of a Kind"

	# Two Pair
	var pair_count = 0
	for c in counts:
		if c == 2:
			pair_count += 1
	if pair_count >= 2:
		return "Two Pair"

	# One Pair
	if counts[counts.size() - 1] == 2:
		return "One Pair"

	# High Card
	return "High Card"


func is_straight(ranks):
	# Sort the list
	var sorted_ranks = ranks.duplicate()
	sorted_ranks.sort()

	# Remove duplicates manually
	var unique_ranks = []
	for val in sorted_ranks:
		if val not in unique_ranks:
			unique_ranks.append(val)

	# Check for any 5 consecutive ranks
	for i in range(unique_ranks.size() - 4):
		if unique_ranks[i + 4] - unique_ranks[i] == 4:
			return true

	# Check Ace as "1" in A-2-3-4-5
	if 14 in unique_ranks and 2 in unique_ranks and 3 in unique_ranks and 4 in unique_ranks and 5 in unique_ranks:
		return true

	return false


# Comparator for Godot 4: return true if a goes before b (ascending)
func _compare_cards(a, b) -> bool:
	return a["rank"] < b["rank"]


# Utility to check if an array "source" contains all elements in array "needed"
func _contains_all(source_array, needed_array) -> bool:
	for needed in needed_array:
		if needed not in source_array:
			return false
	return true
