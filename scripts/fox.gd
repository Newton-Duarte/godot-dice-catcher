class_name Fox

extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var speed: float = 200.0

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("ui_left", "ui_right")
	if !is_zero_approx(direction):
		sprite_2d.flip_h = direction > 0.0

	position.x += speed * direction * delta
