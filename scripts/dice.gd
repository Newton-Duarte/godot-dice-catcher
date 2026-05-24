class_name Dice

extends Area2D

signal off_screen(dice: Dice)

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D

const SPEED: float = 150.0
const ROTATION_SPEED: float = 5.0

var rotate_directions: Array[float] = [-1.0, 1.0]
var rotate_direction: float = 1.0
var speed_multiplier: float = 1.0
var points: int = 1
var is_rare: bool = false
var is_bad: bool = false

func _ready() -> void:
	rotate_direction = rotate_directions.pick_random()
	if is_rare:
		modulate = ColorManager.RARE_COLOR
		cpu_particles_2d.color = ColorManager.RARE_COLOR
	elif is_bad:
		modulate = ColorManager.BAD_COLOR
		cpu_particles_2d.color = ColorManager.BAD_COLOR

func _physics_process(delta: float) -> void:
	sprite_2d.rotate((ROTATION_SPEED * rotate_direction) * delta)
	position.y += (SPEED * speed_multiplier) * delta

func setup_rare_dice() -> void:
	is_rare = true
	points = 5

func setup_bad_dice() -> void:
	is_bad = true

func _on_screen_exited() -> void:
	off_screen.emit(self)
	queue_free()
