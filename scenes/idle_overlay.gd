extends Node2D

signal startGame()
signal resetFood(newFoods : Array[Texture])

@export var foodsToStart: Array[Node] = []
@export var idle_foodSprites : Array[Texture]

func _ready() -> void:
	resetFood.emit(idle_foodSprites)
	$CanvasLayer.show()
	for food in foodsToStart:
		food.tree_exited.connect(_on_Food_Ate.bind(food))

func _on_Food_Ate(node: Node):
	foodsToStart.erase(node)
	if foodsToStart.size() == 0:
		$CanvasLayer.hide()
		startGame.emit()
