extends Node

const MAIN = preload("uid://dhs65ok2aa7vc")
const GAME = preload("uid://xlj61jrmvlld")
const LOADING = preload("uid://bhxltqtcpw5uh")

var next_scene: PackedScene

func load_next_scene() -> void:
	get_tree().change_scene_to_packed(next_scene)

func load_main_scene() -> void:
	next_scene = MAIN
	get_tree().change_scene_to_packed(LOADING)

func load_game_scene() -> void:
	next_scene = GAME
	get_tree().change_scene_to_packed(LOADING)
