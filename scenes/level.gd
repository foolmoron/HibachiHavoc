extends Node

signal levelEnd(didWin : bool)
@onready var currentFoodBar := foodBarMax
@onready var currentHealthBar := healthBarMax

#VARIABLES TO ADJUST IN INSPECTOR FOR GAMEPLAY OPTIMIZATION
@export var musicIdx := 0
@export var foodBarMax : int = 15
@export var healthBarMax : int = 20
@export_range(0.0, 5.0) var food_spawn_interval_min := 1.0
@export_range(0.0, 5.0) var food_spawn_interval_max := 3.0

#SPAWNING FOOD
@export var spawnpoints : Array[Node2D] = []
@export var aim_targets : Array[Node2D] = []
var foodItem : PackedScene = preload("res://scenes/FoodItem.tscn")
var foodItems : Array
var foodTimeRemaining := 0.0

func _ready() -> void:
	$Transition.hide()
	$CanvasLayer.hide()
	clearFood()
	Global.switchMusic(musicIdx)

func clearFood():
	for item in foodItems:
		item.queue_free()
	foodItems.clear()

func _spawnFoodItem():
	if not Global.isPlaying:
		return

	var new_food = foodItem.instantiate() as RigidBody2D
	new_food.global_position = Global.randomItem(spawnpoints).global_position
	add_child(new_food)

	var target := (Global.randomItem(aim_targets) as Node2D).global_position
	var dir := (target - new_food.global_position).normalized() as Vector2
	new_food.apply_impulse(dir * 1500.0)
	new_food.apply_torque_impulse(randf_range(20.0, 60.0) * (-1 if randf() < 0.5 else 1))


func _physics_process(delta: float) -> void:
	if not Global.isPlaying:
		return
	if currentFoodBar == 0:
		winLevel()
		clearFood()
	elif currentHealthBar == 0:
		loseLevel()
		clearFood()
	foodTimeRemaining -= delta
	if foodTimeRemaining <= 0.0:
		_spawnFoodItem()
		foodTimeRemaining = randf_range(food_spawn_interval_min, food_spawn_interval_max)


#GAME CONTROL
func beginGame():
	Global.isPlaying = true
	$CanvasLayer.show()
	foodTimeRemaining = 0.0

func winLevel():
	levelEnd.emit(true)
	$Transition.show()

func loseLevel():
	levelEnd.emit(false)
	$Transition.show()
