extends AnimatedSprite2D

func _process(delta: float) -> void:
    frame = 1 if FaceLandmarker.mouth_open_latest else 0