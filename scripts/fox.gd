class_name Fox

extends Area2D

signal point_scored

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sounds: AudioStreamPlayer2D = $Sounds

@export var speed: float = 200.0

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("ui_left", "ui_right")
	if !is_zero_approx(direction):
		sprite_2d.flip_h = direction > 0.0

	position.x += speed * direction * delta

func _on_area_entered(area: Area2D) -> void:
	if area is Dice:
		sounds.play()
		point_scored.emit()
		area.queue_free()
