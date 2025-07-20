extends RigidBody2D

@export var foodSprites : Array[Texture]

func _ready() -> void:
	$Sprite2D.texture = Global.randomItem(foodSprites)
