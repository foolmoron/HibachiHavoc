class_name IdleOverlay
extends Node2D

signal startGame()
signal resetFood(newFoods : Array[Texture])

@export var foodsToStart: Array[Node] = []
@export var idle_foodSprites : Array[Texture]
@export var TOTAL_text := "Total Food Eaten During Exhibit"

@onready var totalCountLabel: RichTextLabel = $"CanvasLayer/TOTAL total Count"
@onready var totalCountTemplate: String = totalCountLabel.text

func _ready() -> void:
	totalCountLabel.text = totalCountTemplate.replace("{NUM}", str(Global.total_food_over_lifespan + Global.food_eaten_in_session))
	$CanvasLayer.show()
	resetFood.emit(idle_foodSprites)

func reportFoodWasEaten(node: Node):
	if foodsToStart.has(node):
		foodsToStart.erase(node)
		if foodsToStart.size() == 0:
			startGame.emit()
			resetFood.emit(idle_foodSprites)
			$CanvasLayer.hide()

func _process(delta: float) -> void:
	if FaceLandmarker.camera_feed != null and (Time.get_ticks_msec() - FaceLandmarker._last_camera_frame_timestamp_ms) < 500:
		%CameraStatus.color = Color.DARK_GREEN
	else:
		%CameraStatus.color = Color.DARK_RED
