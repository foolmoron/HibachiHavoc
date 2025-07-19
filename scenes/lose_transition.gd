extends Node2D

@export var delay_in_sec := 5.0 
@onready var timer : Timer = $Timer
var countdown_base := "Back to title in "

func _ready() -> void:
	pass


func _on_timer_timeout() -> void:
	Global.switchScene()
