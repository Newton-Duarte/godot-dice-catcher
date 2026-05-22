class_name Fox

extends Area2D

signal point_scored(points: int)
signal lose_life

const EDGE_SPRITE_MARGIN = 55.0

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sounds: AudioStreamPlayer2D = $Sounds

@export var speed: float = 300.0

var viewport_rect: Rect2

func _ready() -> void:
	viewport_rect = get_viewport_rect()

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("ui_left", "ui_right")
	if !is_zero_approx(direction):
		sprite_2d.flip_h = direction > 0.0
	var new_pos_x = position.x + speed * direction * delta
	position.x = clampf(new_pos_x, viewport_rect.position.x + EDGE_SPRITE_MARGIN, viewport_rect.end.x - EDGE_SPRITE_MARGIN)

func _on_area_entered(area: Area2D) -> void:
	if area is Dice:
		if area.is_bad:
			lose_life.emit()
			area.queue_free()
			return

		sounds.play()
		point_scored.emit(area.points)
		area.queue_free()
