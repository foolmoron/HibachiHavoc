extends Node

static var isPlaying : bool
@onready var streak : int = 0;
@onready var currentScene : int = 0;
var levels : Array[PackedScene] = [preload("res://levels/level1.tscn"), preload("res://levels/level2.tscn"), preload("res://levels/level3.tscn")]
var songs : Array[AudioStream] = [preload("res://audio/music/Theme 2b.mp3")]

#variables to return to titlescreen after no user interaction for a while
var idleTimer : Timer
@export var idle_delay : int = 60

#audio variables
@onready var bgMusic = AudioController.get_node("BgMusic")
@onready var eatSFX = AudioController.get_node("EatSFX")
@onready var whooshSFX = AudioController.get_node("WhooshSFX")


func _ready() -> void:
	isPlaying = false
	idleTimer = Timer.new()
	idleTimer.wait_time = idle_delay   #wait for idleness
	idleTimer.timeout.connect(_on_IdleTimer_Timeout)

#switch to next scene and change music to that scene's music; 
func switchScene(nextScene : int):
	if nextScene == -1:
		nextScene = currentScene
	elif nextScene >= levels.size():
		currentScene = 0
	else:
		isPlaying = true
		currentScene = nextScene
	self._loadScene.bind(levels[currentScene]).call_deferred()

func _loadScene(scene : PackedScene):
	print("switching to next scene")
	get_tree().change_scene_to_packed(scene)

func whichScene(num : int) -> String:
	var level : String = ""
	match num:
		0:
			level = "level1"
		1:
			level = "level2"
		2:
			level = "level3"
	return level

func randomItem(list : Array):
	var index : int = randi() % list.size()
	return list[index]


### AUDIO CONTROL ###
func switchMusic(index : int):
	bgMusic.stream = songs[index]
	bgMusic.play()

func eat():
	if(eatSFX.playing):
		eatSFX.stop()
	eatSFX.play()

func whoosh():
	if(!whooshSFX.playing):
		whooshSFX.play()

### IDLE CONTROL ###
func _on_IdleTimer_Timeout():
	switchScene(-1)

func _physics_process(_delta: float) -> void:
	if (!isPlaying && false):    # if facial input happens at any time, reset the idleTimer. 
		idleTimer.start()
