extends Node2D

const DICE = preload("res://scenes/dice.tscn")
const GAME_OVER = preload("uid://eii2vgkwahql")

const STOPPABLE_GROUP: String = "stoppable"
const MARGIN: float = 80.0

@onready var spawn_timer: Timer = $SpawnTimer
@onready var score_label: Label = $ScoreLabel
@onready var music: AudioStreamPlayer = $Music

var _points: int = 0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()

func _ready() -> void:
	update_score_label()
	spawn_dice()

func spawn_dice() -> void:
	var new_dice: Dice = DICE.instantiate()
	var viewport_rect = get_viewport_rect()
	var new_position_x = randf_range(
		viewport_rect.position.x + MARGIN,
		viewport_rect.end.x - MARGIN
	)
	new_dice.position = Vector2(new_position_x, -MARGIN)
	new_dice.game_over.connect(_on_dice_game_over)
	add_child(new_dice)

func pause_all() -> void:
	spawn_timer.stop()
	var to_stop: Array[Node] = get_tree().get_nodes_in_group(STOPPABLE_GROUP)
	for item in to_stop:
		item.set_physics_process(false)

func update_score_label() -> void:
	score_label.text = "%04d" % _points

func _on_dice_game_over() -> void:
	pause_all()
	music.stop()
	music.stream = GAME_OVER
	music.play()

func _on_fox_point_scored() -> void:
	_points += 1
	update_score_label()
