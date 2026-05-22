extends Node

const SCORES_PATH: String = "user://dice_catcher_score.res"

var high_score: int = 0:
	get:
		return high_score
	set(value):
		if value > high_score:
			high_score = value
			save_high_core()

func _ready() -> void:
	load_high_score()

func load_high_score() -> void:
	if ResourceLoader.exists(SCORES_PATH):
		var saved_high_score: HighScoreResource = load(SCORES_PATH)
		if saved_high_score:
			high_score = saved_high_score.high_score

func save_high_core() -> void:
	var high_score_to_save: HighScoreResource = HighScoreResource.new()
	high_score_to_save.high_score = high_score
	ResourceSaver.save(high_score_to_save, SCORES_PATH)
