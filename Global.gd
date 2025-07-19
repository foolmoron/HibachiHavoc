extends Node

var currentScene : String
var level1 : PackedScene = preload("res://scenes/level1.tscn")
var level2 : PackedScene = preload("res://scenes/level2.tscn")
var level3 : PackedScene = preload("res://scenes/level3.tscn")

#variables to return to titlescreen after no user interaction for a while
var idleTimer : Timer
@export var idle_delay : int = 60

func _ready() -> void:
	idleTimer = Timer.new()
	idleTimer.wait_time = idle_delay   #wait for idleness
	currentScene
	switchMusic("menu")
	_loadScene(level1)

#switch to next scene and change music to that scene's music; 
func switchScene(nextScene : String):
	while nextScene != "":
		match nextScene:
			"idleOverlay":
				nextScene = currentScene
				break
			"level1":
				_loadScene(level1)
			"level2":
				_loadScene(level2)
			"level3":
				_loadScene(level3)
		switchMusic("menu")
		nextScene = ""

func _loadScene(scene : PackedScene):
	get_tree().change_scene_to_packed(scene)


### AUDIO CONTROL ###
func switchMusic(song : String):
	AudioController.stream = load(song)
	AudioController.play()

func eat():
	var eatSFX = AudioController.get_child(0)
	if(eatSFX.playing):
		eatSFX.stop()
	eatSFX.play()


### IDLE CONTROL ###
func _on_IdleTimer_Timeout():
	switchScene("idleOverlay")

func _physics_process(delta: float) -> void:
	if (false):    # if input happens at any time, reset the idleTimer. 
		idleTimer.start()
