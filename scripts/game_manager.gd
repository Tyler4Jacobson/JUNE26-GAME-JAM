extends Node

class_name game_manager

static var score: int = 0

static func add_point():
	score += 1
	print(score)
