extends Node

static var isPlaying : bool
static var didEat : bool
static var total_food_over_lifespan : int;

@onready var streak : int = 0;
@onready var food_eaten_in_session : int = 0;
@onready var currentScene : int = 0;
var levels : Array[PackedScene] = [preload("res://levels/level1.tscn"), preload("res://levels/level2.tscn"), preload("res://levels/level3.tscn"), preload("res://levels/level4.tscn")]
var songs : Array[AudioStream] = [preload("res://audio/music/Theme 2b.mp3")]
var wiper : PackedScene = preload("res://scenes/wiper.tscn")

#variables to return to titlescreen after no user interaction for a while
var idle_delay := 3.0
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
	didEat = false
	load_data()

#switch to next scene and change music to that scene's music; 
func switchScene(nextScene : int):
	save_data()
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
	if didEat and not FaceLandmarker.player_detected_latest:
		idle_time += delta
		if idle_time >= idle_delay:
			idle_time = 0.0
			Global.doWipe(Color(0.14, 0.05, 0.3), func():
				reset()
				await switchScene(-1)
			)
	else:
		idle_time = 0.0

func reset():
	print("reset")
	save_data()
	idle_time = 0.0
	isPlaying = false
	didEat = false
	streak = 0
	food_eaten_in_session = 0
	load_data()

func doWipe(color : Color, onWipeCallback: Callable = func(): pass):
	var w := wiper.instantiate()
	w.get_node("Sprite2D").modulate = color
	get_tree().root.add_child(w)
	await get_tree().create_timer(0.425).timeout
	await onWipeCallback.call()
	await get_tree().create_timer(0.4).timeout
	w.queue_free()


#PERSISTENT DATA ACROSS SESSIONS
func save_data():
	var save_file = FileAccess.open("user://hibachihavoc.save", FileAccess.WRITE)
	var node_data = { "total" : total_food_over_lifespan + food_eaten_in_session }
	# JSON provides a static method to serialized JSON string.
	var json_string = JSON.stringify(node_data)
	# Store the save dictionary as a new line in the save file.
	save_file.store_line(json_string)

func load_data():
	if not FileAccess.file_exists("user://hibachihavoc.save"):
		total_food_over_lifespan = 0
		return # Error! We don't have a save to load.
	
	var save_file = FileAccess.open("user://hibachihavoc.save", FileAccess.READ)
	var json_string = save_file.get_line()
	var json = JSON.new()
	
	# Check if there is any error while parsing the JSON string
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return
	
	# Get the data from the JSON object.
	var node_data = json.data
	total_food_over_lifespan = node_data["total"]
