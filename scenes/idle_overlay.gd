extends Node2D

signal startGame()
signal resetFood(newFoods : Array[Texture])

@export var foodsToStart: Array[Node] = []
@export var idle_foodSprites : Array[Texture]
@export var TOTAL_text := "Total Food Eaten During Exhibit"

@onready var totalCountLabel: RichTextLabel = $"CanvasLayer/TOTAL total Count"
@onready var totalCountTemplate: String = totalCountLabel.text

func _ready() -> void:
	totalCountLabel.text = totalCountTemplate.replace("{NUM}", str(Global.total_food_over_lifespan + Global.food_eaten_in_session))
	$CanvasLayer.show()
	resetFood.emit(idle_foodSprites)
	for food in foodsToStart:
		food.tree_exited.connect(_on_Food_Ate.bind(food))

func _on_Food_Ate(node: Node):
	foodsToStart.erase(node)
	if foodsToStart.size() == 0:
		startGame.emit()
		resetFood.emit(idle_foodSprites)
		$CanvasLayer.hide()
