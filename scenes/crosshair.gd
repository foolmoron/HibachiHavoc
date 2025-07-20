extends AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	frame = 1 if FaceLandmarker.mouth_open_latest else 0
	visible = FaceLandmarker.player_detected_latest
