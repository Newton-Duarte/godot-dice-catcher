extends Node

const MAIN = preload("uid://dhs65ok2aa7vc")
const GAME = preload("uid://xlj61jrmvlld")
const LOADING = preload("uid://bhxltqtcpw5uh")

var next_scene: PackedScene

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		var current_mode = DisplayServer.window_get_mode()
		if current_mode == DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		elif current_mode == DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		

func load_next_scene() -> void:
	get_tree().change_scene_to_packed(next_scene)

func load_main_scene() -> void:
	next_scene = MAIN
	get_tree().change_scene_to_packed(LOADING)

func load_game_scene() -> void:
	next_scene = GAME
	get_tree().change_scene_to_packed(LOADING)
