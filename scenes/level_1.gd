extends Node2D

signal levelEnd(message : String)
@export var win_message := "Plate Cleaned!"
@export var lose_message := "Indigestion..."

func _ready() -> void:
	$IdleOverlay.show()
	$Transition.hide()

func beginGame():
	$IdleOverlay.hide()
	Global.isPlaying = true

func winLevel():
	levelEnd.emit(win_message)

func loseLevel():
	levelEnd.emit(lose_message)
