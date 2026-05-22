extends Control

@onready var high_score_value_label: Label = $MC/HighScoreValueLabel

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		GameManager.load_game_scene()

func _ready() -> void:
	high_score_value_label.text = "%04d" % ScoreManager.high_score
