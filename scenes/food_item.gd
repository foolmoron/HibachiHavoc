extends RigidBody2D

@export var spriteList : Array[Sprite2D]
@onready var sprite : Sprite2D = $Sprite2D

func _ready() -> void:
	sprite.texture = Global.randomItem(spriteList)
