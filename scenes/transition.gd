extends CanvasLayer

var prefix := "[center][outline_size=45][outline_color=#331E1D]"
var suffix := "[/outline_color][/outline_size][/center]"
@export var win_message := "Plate Cleaned!"
@export var lose_message := "Indigestion..."
@export var delay_in_sec := 5.0 
@onready var timer : Timer = $Timer
@onready var countdown := $Countdown
@onready var message := $Message

func _ready() -> void:
	timer.wait_time = delay_in_sec

func _physics_process(_delta: float) -> void:
	countdown.text = prefix + str(timer.time_left).pad_decimals(0) + suffix

func _on_Level_End(didWin : bool):
	print("Level end")
	Global.isPlaying = false
	if didWin:
		message.text = prefix + win_message + suffix
	else:
		message.text = prefix + lose_message + suffix
	timer.start()
	await timer.timeout
	if didWin:
		Global.streak += 1;
		print("WON! Win streak: " + str(Global.streak))
		Global.switchScene(Global.currentScene + 1)
	else:
		Global.streak = 0
		print("LOST... Streak: " + str(Global.streak))
		Global.switchScene(-1)
