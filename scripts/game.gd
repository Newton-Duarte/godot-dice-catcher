extends Node2D

const DICE = preload("res://scenes/dice.tscn")
const GAME_OVER = preload("uid://eii2vgkwahql")

@onready var spawn_timer: Timer = $SpawnTimer
@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var music: AudioStreamPlayer = $Music
@onready var negative_sound: AudioStreamPlayer2D = $NegativeSound
@onready var lives_h_box: HBoxContainer = $CanvasLayer/LivesHBox
@onready var extra_life_sound: AudioStreamPlayer2D = $ExtraLifeSound
@onready var feedback_label: Label = $CanvasLayer/FeedbackLabel
@onready var feedback_label_timer: Timer = $FeedbackLabelTimer
@onready var bad_dice_timer: Timer = $BadDiceTimer
@onready var elapsed_timer_label: Label = $CanvasLayer/ElapsedTimerLabel
@onready var game_over_label: Label = $CanvasLayer/GameOverLabel
@onready var press_to_play_label: Label = $CanvasLayer/PressToPlayLabel

const STOPPABLE_GROUP: String = "stoppable"
const MARGIN: float = 180.0
const MAX_LIVES: int = 3
const MAX_DICE_SPEED_MULTIPLIER: float = 2.0
const MIN_SPAWN_TIMER: float = 1.0
const GOLDEN_DICE_CHANCE_PERCENT: int = 10
const BAD_DICE_CHANCE_PERCENT: int = 5
const MIN_BAD_DICE_TIMER: float = 3.0
const MAX_MUSIC_PITCH_SCALE: float = 1.5
const MAX_POINTS_MULTIPLIER: int = 5
const DEFAULT_BONUS_LIVE_POINTS_NEEDED: int = 10
const DEFAULT_STREAK_GOAL: int = 10

var _points: int = 0
var _points_multiplier: int = 1
var _streak_count: int = 0
var _streak_goal: int = DEFAULT_STREAK_GOAL
var _lives: int = 3
var _bonus_live_points_needed: int = 10
var _next_live_bonus_points: int = 0
var _elapsed_time: float = 0

var _dice_speed_multiplier = 1.0
var _dice_speed_multiplier_tick = 0.1
var _difficulty_multiplier_tick = 0.1
var _bad_dice_timer_tick = 0.1
var _music_pitch_scale_tick = 0.05

enum GAME_STATE { PLAY, PAUSED, GAMEOVER }

var _game_state: GAME_STATE = GAME_STATE.PLAY

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and _game_state == GAME_STATE.GAMEOVER:
		get_tree().reload_current_scene()
	if event.is_action_pressed("restart"):
		GameManager.load_main_scene()

func _ready() -> void:
	feedback_label.hide()
	update_score_label()
	spawn_dice()

func _process(delta: float) -> void:
	if _game_state == GAME_STATE.PLAY:
		_elapsed_time += delta
		update_elapsed_time_label()

func update_elapsed_time_label() -> void:
	var minutes: float = _elapsed_time / 60
	var seconds: float = fmod(_elapsed_time, 60)
	elapsed_timer_label.text = "%02d:%02d" % [minutes, seconds]

func spawn_dice() -> void:
	var new_dice = get_dice_to_spawn()
	var should_spawn_golden_dice: bool = randi() % 100 + 1 <= GOLDEN_DICE_CHANCE_PERCENT
	if should_spawn_golden_dice:
		new_dice.setup_rare_dice()
	add_child(new_dice)

func get_dice_to_spawn() -> Dice:
	var new_dice: Dice = DICE.instantiate()
	var viewport_rect = get_viewport_rect()
	var new_position_x = randf_range(
		viewport_rect.position.x + MARGIN,
		viewport_rect.end.x - MARGIN
	)
	new_dice.position = Vector2(new_position_x, -MARGIN)
	new_dice.off_screen.connect(_on_dice_off_screen)
	new_dice.speed_multiplier = _dice_speed_multiplier
	return new_dice

func pause_all() -> void:
	spawn_timer.stop()
	feedback_label_timer.stop()
	bad_dice_timer.stop()
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
	_game_state = GAME_STATE.GAMEOVER
	ScoreManager.high_score = _points
	feedback_label.hide()
	game_over_label.show()
	pause_all()
	music.stop()
	music.stream = GAME_OVER
	music.play()
	await get_tree().create_timer(2.0).timeout
	press_to_play_label.show()

func lose_life() -> void:
	_lives = max(_lives - 1, 0)
	_points_multiplier = 1
	_streak_count = 0
	_bonus_live_points_needed = DEFAULT_BONUS_LIVE_POINTS_NEEDED
	show_feedback_label("-1 Life")
	update_lives()

	if _lives <= 0:
		game_over()
	else:
		negative_sound.play()

func check_bonus_life() -> void:
	if _next_live_bonus_points >= _bonus_live_points_needed:
		_next_live_bonus_points -= _bonus_live_points_needed
		_lives = min(_lives + 1, MAX_LIVES)
		extra_life_sound.play()
		show_feedback_label("+1 Life")
		update_lives()

func check_streak() -> void:
	if _points_multiplier == MAX_POINTS_MULTIPLIER:
		return
	if _streak_count >= _streak_goal:
		_points_multiplier = min(_points_multiplier + 1, MAX_POINTS_MULTIPLIER)
		show_feedback_label("x%d Combo" % _points_multiplier)
		_streak_count = 0
		_bonus_live_points_needed = DEFAULT_BONUS_LIVE_POINTS_NEEDED * _points_multiplier

func _on_dice_off_screen(is_bad: bool) -> void:
	if is_bad: return
	show_feedback_label("Miss")
	lose_life()

func _on_feedback_label_timer_timeout() -> void:
	feedback_label.hide()

func _on_difficulty_timer_timeout() -> void:
	_dice_speed_multiplier = min(_dice_speed_multiplier + _dice_speed_multiplier_tick, MAX_DICE_SPEED_MULTIPLIER)
	spawn_timer.wait_time = max(spawn_timer.wait_time - _difficulty_multiplier_tick, MIN_SPAWN_TIMER)
	bad_dice_timer.wait_time = max(bad_dice_timer.wait_time - _bad_dice_timer_tick, MIN_BAD_DICE_TIMER)
	music.pitch_scale = min(music.pitch_scale + _music_pitch_scale_tick, MAX_MUSIC_PITCH_SCALE)

func _on_bad_dice_timer_timeout() -> void:
	var bad_dice: Dice = get_dice_to_spawn()
	bad_dice.setup_bad_dice()
	add_child(bad_dice)

func _on_fox_lose_life() -> void:
	lose_life()

func _on_fox_dice_caught(dice: Dice) -> void:
	if dice.is_bad:
		lose_life()
		return
	
	var dice_points = dice.points * _points_multiplier
	_points += dice_points
	_next_live_bonus_points += dice_points
	_streak_count += 1
	show_feedback_label("+%s" % dice_points)
	update_score_label()
	check_bonus_life()
	check_streak()
