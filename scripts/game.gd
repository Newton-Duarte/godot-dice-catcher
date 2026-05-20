extends Node2D

const DICE = preload("res://scenes/dice.tscn")

const MARGIN: float = 80.0

@onready var spawn_timer: Timer = $SpawnTimer

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

func _on_dice_game_over() -> void:
	print("GAME OVER")
