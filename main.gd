extends Node

# Load 1st level when loading from main scene
func _ready() -> void:
	Global.switchScene.bind(0).call_deferred()
