extends Sprite2D

@export var hasPlate : bool = true
var totalFood : int = 0
var mealItem : PackedScene = preload("res://scenes/meal_item.tscn")
var mealItems : Array

func _on_start(amountFood: int) -> void:
	if hasPlate:
		totalFood = amountFood
	print("total food on plate: ", totalFood)

func _on_idle_overlay_reset_food(newFoods: Array[Texture]) -> void:
	if Global.isPlaying:
		print("Should be making food: ", totalFood)
		for i in range(totalFood):
			var new_meal_item := mealItem.instantiate()
			new_meal_item.global_position = Vector2(970.0 + randf_range(-131.0, 131.0), 919.0 +  randf_range(-1.0, 80.0))
			print("Food appearing on screen at " + str(new_meal_item.global_position))
			new_meal_item.texture = Global.randomItem(newFoods)
			get_tree().root.add_child(new_meal_item)
			mealItems.append(new_meal_item)

func subtractFromMeal():
	if totalFood != 0:
		var item = Global.randomItem(mealItems)
		mealItems.erase(item)
		item.queue_free()
		print("one less food on plate")
