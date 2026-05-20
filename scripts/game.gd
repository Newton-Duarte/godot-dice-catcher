extends Node2D

const DICE = preload("res://scenes/dice.tscn")

const STOPPABLE_GROUP: String = "stoppable"
const MARGIN: float = 80.0

@onready var spawn_timer: Timer = $SpawnTimer

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()

func _ready() -> void:
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

func _on_dice_game_over() -> void:
	pause_all()

func _on_fox_point_scored() -> void:
	print("Point scored: Game")
