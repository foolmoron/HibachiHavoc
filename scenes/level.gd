extends Node

signal levelEnd(message : String)
@export var win_message := "Plate Cleaned!"
@export var lose_message := "Indigestion..."
@onready var currentFoodBar := foodBarMax
@onready var currentHealthBar := healthBarMax

#VARIABLES TO ADJUST IN INSPECTOR FOR GAMEPLAY OPTIMIZATION
@export var musicIdx := 0
@export var foodBarMax : int = 15
@export var healthBarMax : int = 20
@export var spawn_timer_waittime := 3.0
@export var foodSpeedVariation := 1.1

#SPAWNING FOOD
var spawnpoints : Array[Vector2] = [Vector2(-105,-112), Vector2(325,-220), Vector2(540,-220), Vector2(1595,-220), Vector2(2025,-112)]
var foodItem : PackedScene = preload("res://scenes/FoodItem.tscn")
var foodItems : Array
@onready var spawnTimer := Timer.new()

func _ready() -> void:
	$IdleOverlay.show()
	$Transition.hide()
	spawnTimer.wait_time = spawn_timer_waittime
	spawnTimer.timeout.connect(_spawnFoodItems)
	clearFood()
	Global.switchMusic(musicIdx)

func clearFood():
	for item in foodItems:
		item.queue_free()
	foodItems.clear()

func _spawnFoodItems():
	if Global.isPlaying:
		#spawn a food item at random location w/force
		var new_food = foodItem.instantiate()
		new_food.set_position(Global.randomItem(spawnpoints))
		add_child(new_food)
		
		# WHAT TO DO TO MAKE IT RECOGNIZE TOUCHING PLAYER AREA COLLIDER?
		# OLD CODE:
		#new_food.body_entered.connect(collision_detected)
		
		new_food.apply_impulse(Vector2(960 * foodSpeedVariation, 540 * foodSpeedVariation))
		#start timer again
		spawnTimer.start()

func _physics_process(delta: float) -> void:
	if currentFoodBar == 0:
		winLevel()
		clearFood()
	elif currentHealthBar == 0:
		loseLevel()
		clearFood()


#GAME CONTROL
func beginGame():
	$IdleOverlay.hide()
	Global.isPlaying = true
	_spawnFoodItems()

func winLevel():
	levelEnd.emit(win_message)
	$Transition.show()

func loseLevel():
	levelEnd.emit(lose_message)
	$Transition.show()
