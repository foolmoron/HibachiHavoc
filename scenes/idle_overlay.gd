extends Node2D

signal startGame()

func _on_Food_Ate():
	startGame.emit()

#TEMPORARY
func _input(event: InputEvent) -> void:
	if event.is_action("TempInput"):
		_on_Food_Ate()
