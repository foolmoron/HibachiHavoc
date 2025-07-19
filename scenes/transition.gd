extends Node2D

@export var delay_in_sec := 5.0 
@onready var timer : Timer = $Timer
@onready var countdown := $CanvasLayer/VBoxContainer/Countdown
@onready var message := $CanvasLayer/Message

func _ready() -> void:
	timer.wait_time = delay_in_sec
	_on_Level_End("Win!")

func _physics_process(_delta: float) -> void:
	countdown.text = str(timer.time_left).pad_decimals(0)

func _on_timer_timeout() -> void:
	print("timer timeout")
	if message.text.contains("Indigestion"):
		Global.streak = 0
		print("streak: " + str(Global.streak))
		Global.switchScene(-1)
	else:
		Global.streak += 1;
		print("streak: " + str(Global.streak))
		Global.switchScene(Global.currentScene + 1)

func _on_Level_End(new_msg : String):
	Global.isPlaying = false
	message.text = new_msg
	timer.start()
