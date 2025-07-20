extends Node

static var isPlaying : bool

@onready var streak : int = 0;
@onready var foods_eaten : int = 0;
@onready var currentScene : int = 0;
var levels : Array[PackedScene] = [preload("res://levels/level1.tscn"), preload("res://levels/level2.tscn"), preload("res://levels/level3.tscn")]
var songs : Array[AudioStream] = [preload("res://audio/music/Theme 2b.mp3")]
var wiper : PackedScene = preload("res://scenes/wiper.tscn")

#variables to return to titlescreen after no user interaction for a while
var idle_delay := 5.0
var idle_time := 0.0

#audio variables
@onready var bgMusic = AudioController.get_node("BgMusic")
@onready var soundsToPlay = {
	"eat": AudioController.get_node("EatSFX"),
	"whoosh": AudioController.get_node("WhooshSFX"),
	"level": AudioController.get_node("LevelSFX"),
}


func _ready() -> void:
	isPlaying = false

#switch to next scene and change music to that scene's music; 
func switchScene(nextScene : int):
	if nextScene == -1:
		nextScene = currentScene
	elif nextScene >= levels.size():
		currentScene = 0
	else:
		currentScene = nextScene
	get_tree().change_scene_to_packed.bind(levels[currentScene]).call_deferred()

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

func playSound(soundName : String):
	if not soundsToPlay.has(soundName):
		return
	var sound = soundsToPlay[soundName]
	sound.play()

func _process(delta: float) -> void:
	if isPlaying and not FaceLandmarker.player_detected_latest:
		idle_time += delta
		if idle_time >= idle_delay:
			reset()
			Global.doWipe(func():
				await switchScene(-1)
			)

func reset():
	idle_time = 0.0
	isPlaying = false
	streak = 0
	foods_eaten = 0
	
func doWipe(onWipeCallback: Callable = func(): pass):
	var w := wiper.instantiate()
	get_tree().root.add_child(w)
	await get_tree().create_timer(0.425).timeout
	await onWipeCallback.call()
	await get_tree().create_timer(0.4).timeout
	w.queue_free()
		
