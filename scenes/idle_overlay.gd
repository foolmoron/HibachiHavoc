extends Node2D

signal startGame()

@export var foodsToStart: Array[Node] = []

func _ready() -> void:
	for food in foodsToStart:
		food.tree_exited.connect(_on_Food_Ate.bind(food))

func _on_Food_Ate(node: Node):
	foodsToStart.erase(node)
	if foodsToStart.size() == 0:
		startGame.emit()

#TEMPORARY
func _input(event: InputEvent) -> void:
	if event.is_action("TempInput"):
		_on_Food_Ate(foodsToStart[0])
