extends Control

func _ready() -> void:
	await get_tree().create_timer(0.3).timeout
	GameManager.load_next_scene()
