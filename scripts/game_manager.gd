extends Node

class_name game_manager

static var score: int = 0

func _ready() -> void:
	score = 0

static func add_score() -> void:
	score += 1

static func get_score() -> int:
	return score
