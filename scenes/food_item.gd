extends RigidBody2D

@export var foodSprites : Array[Texture]
@export var autoKillSecs := 10.0

func _ready() -> void:
	if autoKillSecs > 0.0:
		await get_tree().create_timer(autoKillSecs).timeout
		queue_free()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.linear_velocity = state.linear_velocity.normalized() * max(state.linear_velocity.length(), 100)

func _on_resetFoodSprites(newFoods : Array[Texture]):
	foodSprites = newFoods
	$Sprite2D.texture = Global.randomItem(foodSprites)
