extends Node2D

@export var delay_in_sec := 5.0 
@onready var timer : Timer = $Timer
@onready var countdown := $CanvasLayer/VBoxContainer/Countdown

func _ready() -> void:
	timer.wait_time = delay_in_sec

func _physics_process(_delta: float) -> void:
	countdown.text = str(timer.time_left).pad_decimals(1)

func _on_timer_timeout() -> void:
	Global.switchScene("idleOverlay")
