extends Node2D

signal startGame()

@export var foodsToStart: Array[Node] = []

func _ready() -> void:
	$CanvasLayer.show()
	for food in foodsToStart:
		food.tree_exited.connect(_on_Food_Ate.bind(food))

func _on_Food_Ate(node: Node):
	foodsToStart.erase(node)
	if foodsToStart.size() == 0:
		$CanvasLayer.hide()
		startGame.emit()
