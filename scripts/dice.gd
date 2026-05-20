class_name Dice

extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

const SPEED = 150
const ROTATION_SPEED = 4

var rotate_directions: Array[int] = [-1, 1]
var rotate_direction: int = 1

func _ready() -> void:
	rotate_direction = rotate_directions.pick_random()

func _physics_process(delta: float) -> void:
	sprite_2d.rotate((ROTATION_SPEED * rotate_direction) * delta)
	global_position.y += SPEED * delta
