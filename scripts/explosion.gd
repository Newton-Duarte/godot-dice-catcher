extends Node2D

@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D

var is_rare: bool = false
var is_bad: bool = false

func _ready() -> void:
	if is_rare:
		cpu_particles_2d.color = ColorManager.RARE_COLOR
	elif is_bad:
		cpu_particles_2d.color = ColorManager.BAD_COLOR

	cpu_particles_2d.emitting = true

func _on_cpu_particles_2d_finished() -> void:
	queue_free()
