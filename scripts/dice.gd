class_name Dice

extends Area2D

signal off_screen

@onready var sprite_2d: Sprite2D = $Sprite2D

const SPEED: float = 150.0
const ROTATION_SPEED: float = 5.0

var rotate_directions: Array[float] = [-1.0, 1.0]
var rotate_direction: float = 1.0
var speed_multiplier: float = 1.0
var points: int = 1
var dice_rare_color: Color = Color("#FFD700")
var is_rare: bool = false

func _ready() -> void:
	rotate_direction = rotate_directions.pick_random()

func _physics_process(delta: float) -> void:
	sprite_2d.rotate((ROTATION_SPEED * rotate_direction) * delta)
	position.y += (SPEED * speed_multiplier) * delta
	check_off_screen()

func setup_rare_dice() -> void:
	is_rare = true
	points = 5
	modulate = dice_rare_color

func check_off_screen() -> void:
	if get_viewport_rect().end.y < position.y:
		off_screen.emit()
		queue_free()
