extends Node

# Load 1st level when loading from main scene
func _ready() -> void:
	Global._loadScene.bind(Global.levels[0]).call_deferred()
