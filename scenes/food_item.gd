extends RigidBody2D

@export var foodSprites : Array[Texture]

func _ready() -> void:
	await get_tree().create_timer(10.0).timeout
	queue_free()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.linear_velocity = state.linear_velocity.normalized() * max(state.linear_velocity.length(), 100)

func _on_resetFoodSprites(newFoods : Array[Texture]):
	foodSprites = newFoods
	$Sprite2D.texture = Global.randomItem(foodSprites)
