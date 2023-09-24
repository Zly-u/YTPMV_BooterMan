class_name Global

extends Node

static var has_restarted: bool = false
static var carry_score: int = 0

static func restart(tree: SceneTree):
	has_restarted = true
	tree.reload_current_scene()

static func set_carry_score(score: int):
	carry_score = score
	
static func get_carry_score():
	return carry_score

static func clear_carry_score():
	carry_score = 0

static func save(score: int):
	var saved_score: ConfigFile = ConfigFile.new()
	
	var _error = saved_score.load("user://score.save")
	
	var prev_score: int = saved_score.get_value("Score", "points", 0)
	if prev_score < score:
		saved_score.set_value("Score", "points", score)

	saved_score.save("user://score.save")


static func load_score():
	var saved_score: ConfigFile = ConfigFile.new()
	var _error = saved_score.load("user://score.save")
	return saved_score.get_value("Score", "points", 0)
