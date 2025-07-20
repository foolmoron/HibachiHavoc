extends Node

signal levelEnd(didWin : bool)
@onready var currentFoodBar := foodBarMax
@onready var currentHealthBar := healthBarMax
@onready var local_count := $CanvasLayer/Count
const prefix := "[center][outline_size=20][outline_color=#331E1D]Total Food Eaten: "
const suffix := "[/outline_color][/outline_size][/center]"

#VARIABLES TO ADJUST IN INSPECTOR FOR GAMEPLAY OPTIMIZATION
@export var musicIdx := 0
@export var foodBarMax : int = 15
@export var healthBarMax : int = 20
@export_range(0.0, 5.0) var food_spawn_interval_min := 1.0
@export_range(0.0, 5.0) var food_spawn_interval_max := 3.0

#SPAWNING FOOD
@export var level := 1
@export var spawnpoints : Array[Node2D] = []
@export var aim_targets : Array[Node2D] = []
var foodItem1 : PackedScene = preload("res://levels/hibachi_foodItem.tscn")
var foodItem2 : PackedScene = preload("res://levels/bakery_foodItem.tscn")
var foodItem3 : PackedScene = preload("res://levels/space_foodItem.tscn")
var foodItems : Array
var foodTimeRemaining := 0.0

func _ready() -> void:
	$Transition.hide()
	$CanvasLayer.hide()
	clearFood()
	Global.switchMusic(musicIdx)

func ateFood(_item : Node):
	currentFoodBar -= 1

func clearFood():
	for item in foodItems:
		item.queue_free()
	foodItems.clear()

func _spawnFoodItem():
	if not Global.isPlaying:
		return
	
	var new_food
	match level:
		1:
			new_food = foodItem1.instantiate() as RigidBody2D
		2:
			new_food = foodItem2.instantiate() as RigidBody2D
		3:
			new_food = foodItem3.instantiate() as RigidBody2D
	new_food.global_position = Global.randomItem(spawnpoints).global_position
	add_child(new_food)

	var target := (Global.randomItem(aim_targets) as Node2D).global_position
	var dir := (target - new_food.global_position).normalized() as Vector2
	new_food.apply_impulse(dir * 1500.0)
	new_food.apply_torque_impulse(randf_range(20.0, 60.0) * (-1 if randf() < 0.5 else 1))


func _physics_process(delta: float) -> void:
	if not Global.isPlaying:
		return
	
	#PLAYING GAME
	local_count.text = prefix + str(Global.foods_eaten) + suffix
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
	$CanvasLayer.hide()

func loseLevel():
	levelEnd.emit(false)
	$Transition.show()
	$CanvasLayer.hide()
