extends Node2D

const DICE = preload("res://scenes/dice.tscn")
const GOLDEN_DICE = preload("res://scenes/golden_dice.tscn")
const GAME_OVER = preload("uid://eii2vgkwahql")

@onready var spawn_timer: Timer = $SpawnTimer
@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var music: AudioStreamPlayer = $Music
@onready var negative_sound: AudioStreamPlayer2D = $NegativeSound
@onready var lives_h_box: HBoxContainer = $CanvasLayer/LivesHBox
@onready var extra_life_sound: AudioStreamPlayer2D = $ExtraLifeSound
@onready var feedback_label: Label = $CanvasLayer/FeedbackLabel
@onready var feedback_label_timer: Timer = $FeedbackLabelTimer

const STOPPABLE_GROUP: String = "stoppable"
const MARGIN: float = 180.0
const MAX_LIVES: int = 3
const BONUS_LIVE_POINTS_NEEDED: int = 10
const MAX_DICE_SPEED_MULTIPLIER: float = 2.0
const MIN_SPAWN_TIMER: float = 1.0
const GOLDEN_DICE_CHANCE: int = 10

var _points: int = 0
var _lives: int = 3
var _next_live_bonus_points: int = 0

var _dice_speed_multiplier = 1.0
var _dice_speed_multiplier_tick = 0.25

var _difficulty_multiplier_tick = 0.25

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()

func _ready() -> void:
	feedback_label.hide()
	update_score_label()
	spawn_dice()

func spawn_dice() -> void:
	var rare_dice_number: int = randi() % 100 + 1 <= GOLDEN_DICE_CHANCE
	var new_dice: Dice = GOLDEN_DICE.instantiate() if rare_dice_number else DICE.instantiate()
	var viewport_rect = get_viewport_rect()
	var new_position_x = randf_range(
		viewport_rect.position.x + MARGIN,
		viewport_rect.end.x - MARGIN
	)
	new_dice.position = Vector2(new_position_x, -MARGIN)
	new_dice.off_screen.connect(_on_dice_off_screen)
	new_dice.speed_multiplier = min(_dice_speed_multiplier, MAX_DICE_SPEED_MULTIPLIER)
	add_child(new_dice)

func pause_all() -> void:
	spawn_timer.stop()
	feedback_label_timer.stop()
	var to_stop: Array[Node] = get_tree().get_nodes_in_group(STOPPABLE_GROUP)
	for item in to_stop:
		item.set_physics_process(false)

func update_score_label() -> void:
	score_label.text = "%04d" % _points

func update_lives() -> void:
	var life_icons = lives_h_box.get_children()
	for index in life_icons.size():
		life_icons[index].visible = index < _lives

func show_feedback_label(text: String) -> void:
	feedback_label.text = text
	feedback_label.show()
	feedback_label_timer.start()

func game_over() -> void:
	show_feedback_label("Game Over")
	pause_all()
	music.stop()
	music.stream = GAME_OVER
	music.play()

func _on_dice_off_screen() -> void:
	_lives = max(_lives - 1, 0)
	update_lives()
	show_feedback_label("Miss")
	
	if _lives <= 0:
		game_over()
	else:
		negative_sound.play()

func _on_fox_point_scored(points: int) -> void:
	_points += points
	_next_live_bonus_points += points
	update_score_label()
	show_feedback_label("+%s" % points)
	if _next_live_bonus_points >= BONUS_LIVE_POINTS_NEEDED:
		_next_live_bonus_points -= BONUS_LIVE_POINTS_NEEDED
		_lives = min(_lives + 1, MAX_LIVES)
		extra_life_sound.play()
		show_feedback_label("+%s Life" % 1)
		update_lives()

func _on_feedback_label_timer_timeout() -> void:
	feedback_label.hide()

func _on_difficulty_timer_timeout() -> void:
	_dice_speed_multiplier += _dice_speed_multiplier_tick
	spawn_timer.wait_time = max(spawn_timer.wait_time - _difficulty_multiplier_tick, MIN_SPAWN_TIMER)
