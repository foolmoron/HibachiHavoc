extends Node2D

signal startGame()
signal resetFood(newFoods : Array[Texture])

@export var foodsToStart: Array[Node] = []
@export var idle_foodSprites : Array[Texture]
@export var TOTAL_text := "Total Food Eaten During Exhibit"

func _ready() -> void:
	$"CanvasLayer/TOTAL total Count".text = "[center][outline_size=20][outline_color=#331E1D]" + TOTAL_text + ": \n" + str(Global.total_food_over_lifespan + Global.food_eaten_in_session) + "[/outline_color][/outline_size][/center]"
	$CanvasLayer.show()
	for food in foodsToStart:
		food.tree_exited.connect(_on_Food_Ate.bind(food))

func _on_Food_Ate(node: Node):
	foodsToStart.erase(node)
	if foodsToStart.size() == 0:
		resetFood.emit(idle_foodSprites)
		$CanvasLayer.hide()
		startGame.emit()
