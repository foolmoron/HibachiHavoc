class_name Plate
extends Sprite2D

@export var hasPlate : bool = true
var totalFood : int = 0
var mealItem : PackedScene = preload("res://scenes/meal_item.tscn")
var mealItems : Array[Node] = []
var mealItemsAvailable : Array[bool] = []

func _on_start(amountFood: int) -> void:
	if hasPlate:
		totalFood = amountFood
	print("total food on plate: ", totalFood)

func _on_idle_overlay_reset_food(newFoods: Array[Texture]) -> void:
	if Global.isPlaying:
		var foodTexturesToUse := newFoods.duplicate()
		while foodTexturesToUse.size() < totalFood:
			foodTexturesToUse.append(Global.randomItem(newFoods))
		foodTexturesToUse.shuffle()

		print("Should be making food: ", foodTexturesToUse)
		for tex in foodTexturesToUse:
			var new_meal_item := mealItem.instantiate()
			new_meal_item.global_position = Vector2(970.0 + randf_range(-171.0, 171.0), 919.0 + randf_range(-1.0, 80.0))
			print("Food appearing on screen at " + str(new_meal_item.global_position))
			new_meal_item.texture = tex
			get_tree().root.add_child(new_meal_item)
			mealItems.append(new_meal_item)
			mealItemsAvailable.append(true)

func deleteFromMeal(i: int):
	mealItemsAvailable[i] = false
	mealItems[i].queue_free()
