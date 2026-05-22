extends Node

const MAIN = preload("uid://dhs65ok2aa7vc")
const GAME = preload("uid://xlj61jrmvlld")

func load_main_scene() -> void:
	get_tree().change_scene_to_packed(MAIN)

func load_game_scene() -> void:
	get_tree().change_scene_to_packed(GAME)
