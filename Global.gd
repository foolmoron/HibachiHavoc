extends Node

var audioControl : AudioControl

func reset():
	audioControl.switchMusic()

func switchScene(nextScene : PackedScene):
	get_tree().change_scene_to_packed(nextScene)
	
