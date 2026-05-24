class_name Fox

extends Area2D

const EXPLOSION = preload("uid://dwvkskgguox8e")

signal dice_caught(dice: Dice)

const EDGE_SPRITE_MARGIN = 55.0

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sounds: AudioStreamPlayer2D = $Sounds
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D

@export var speed: float = 300.0

var viewport_rect: Rect2

func _ready() -> void:
	viewport_rect = get_viewport_rect()

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("ui_left", "ui_right")
	if is_zero_approx(direction):
		animation_player.play("RESET")
		cpu_particles_2d.emitting = false
	elif !is_zero_approx(direction):
		animation_player.play("walk")
		cpu_particles_2d.emitting = true
		sprite_2d.flip_h = direction > 0.0
	var new_pos_x = position.x + speed * direction * delta
	position.x = clampf(new_pos_x, viewport_rect.position.x + EDGE_SPRITE_MARGIN, viewport_rect.end.x - EDGE_SPRITE_MARGIN)

func show_explosion(dice: Dice) -> void:
	var explosion_scene = EXPLOSION.instantiate()
	explosion_scene.global_position = dice.global_position
	if dice.is_rare:
		explosion_scene.is_rare = true
	elif dice.is_bad:
		explosion_scene.is_bad = true
	get_parent().add_child(explosion_scene)

func _on_area_entered(area: Area2D) -> void:
	if area is Dice:
		show_explosion(area)
		dice_caught.emit(area)
		sounds.pitch_scale = randf_range(0.75, 1.5)
		sounds.play()
		area.queue_free()
