extends CanvasLayer

@export var win_message := "Plate Cleaned!"
@export var lose_message := "Indigestion..."
@export var delay_in_sec := 5.0 
@onready var timer : Timer = $Timer
@onready var countdown := $Countdown
@onready var message := $Message

func _ready() -> void:
	timer.wait_time = delay_in_sec

func _physics_process(_delta: float) -> void:
	countdown.text = str(timer.time_left).pad_decimals(0)

func _on_Level_End(didWin : bool):
	print("Level end")
	Global.isPlaying = false
	if didWin:
		message.text = win_message
	else:
		message.text = lose_message
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
