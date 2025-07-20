extends RigidBody2D

@export var foodSprites : Array[Texture]

func _ready() -> void:
	$Sprite2D.texture = Global.randomItem(foodSprites)

func _on_resetFoodSprites(newFoods : Array[Texture]):
	foodSprites = newFoods
	$Sprite2D.texture = Global.randomItem(foodSprites)
