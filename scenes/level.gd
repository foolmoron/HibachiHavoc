extends Node

signal levelEnd(didWin : bool)
signal setMealAmount(amountFood : int)
var currentFoodBar : int
@onready var currentHealthBar := healthBarMax
@onready var localCount: RichTextLabel = $CanvasLayer/Count
@onready var localCountTemplate := localCount.text

#VARIABLES TO ADJUST IN INSPECTOR FOR GAMEPLAY OPTIMIZATION
@export var musicIdx := 0
@export var foodBarMax : int = 15
@export var healthBarMax : int = 20
@export var foodSlowAmount : float = 1.0
@export_range(0.0, 5.0) var food_spawn_interval_min := 1.0
@export_range(0.0, 5.0) var food_spawn_interval_max := 3.0

#SPAWNING FOOD
@export var level := 1
@export var spawnpoints : Array[Node2D] = []
@export var aim_targets : Array[Node2D] = []
var foodItem1 : PackedScene = preload("res://levels/hibachi_foodItem.tscn")
var foodItem2 : PackedScene = preload("res://levels/bakery_foodItem.tscn")
var foodItem3 : PackedScene = preload("res://levels/diner_foodItem.tscn")
var foodItem4 : PackedScene = preload("res://levels/space_foodItem.tscn")
var foodTimeRemaining := 0.0

@export var plate : Plate = null
var m := 0
var foodToMealIndex : Dictionary[Node, int]	= {}

var food_eaten_label_prev := -1

func _ready() -> void:
	$Transition.hide()
	$CanvasLayer.hide()
	$Slowdown1.linear_damp = foodSlowAmount
	$Slowdown2.linear_damp = foodSlowAmount
	currentFoodBar = randi_range(foodBarMax, foodBarMax + int(foodBarMax*0.35))
	setMealAmount.emit(currentFoodBar)
	Global.switchMusic(musicIdx)
	Global.setTransitionColor()

func ateFood(_item : Node):
	if Global.isPlaying:
		currentFoodBar -= 1
		var mealIndex = foodToMealIndex.get(_item, -1)
		plate.deleteFromMeal(mealIndex)

func _spawnFoodItem():
	if not Global.isPlaying:
		return
	
	var new_food: RigidBody2D
	match level:
		1:
			new_food = foodItem1.instantiate() as RigidBody2D
		2:
			new_food = foodItem2.instantiate() as RigidBody2D
		3:
			new_food = foodItem3.instantiate() as RigidBody2D
		4:
			new_food = foodItem4.instantiate() as RigidBody2D
	
	var spawned := false
	m = (m + 1) % plate.mealItems.size()
	for _i in plate.mealItemsAvailable.size():
		var i = (_i + m) % plate.mealItemsAvailable.size()
		if plate.mealItemsAvailable[i]:
			new_food.find_child("Sprite2D").texture = plate.mealItems[i].texture
			foodToMealIndex[new_food] = i
			spawned = true
			break
	
	if not spawned:
		new_food.queue_free()
		return
	
	new_food.global_position = Global.randomItem(spawnpoints).global_position
	add_child(new_food)
	Global.playSound("whoosh")
	
	var target := (Global.randomItem(aim_targets) as Node2D).global_position
	var dir := (target - new_food.global_position).normalized() as Vector2
	new_food.apply_impulse(dir * 2000.0)
	new_food.apply_torque_impulse(randf_range(20.0, 60.0) * (-1 if randf() < 0.5 else 1))

func _physics_process(delta: float) -> void:
	if not Global.isPlaying:
		return
	
	#PLAYING GAME
	if food_eaten_label_prev != Global.food_eaten_in_session:
		localCount.text = localCountTemplate.replace("{NUM}", str(Global.food_eaten_in_session))
		food_eaten_label_prev = Global.food_eaten_in_session
	if currentFoodBar == 0:
		winLevel()
	elif currentHealthBar == 0:
		loseLevel()
	foodTimeRemaining -= delta
	if foodTimeRemaining <= 0.0:
		_spawnFoodItem()
		foodTimeRemaining = randf_range(food_spawn_interval_min, food_spawn_interval_max)


#GAME CONTROL
func beginGame():
	Global.isPlaying = true
	$CanvasLayer.show()
	foodTimeRemaining = 1.0

func winLevel():
	levelEnd.emit(true)
	$Transition.show()
	$CanvasLayer.hide()

func loseLevel():
	levelEnd.emit(false)
	$Transition.show()
	$CanvasLayer.hide()
