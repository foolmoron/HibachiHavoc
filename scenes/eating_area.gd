extends Area2D

@export var map_from_dir_to_x: Curve
@export var map_from_dir_to_y: Curve

func _physics_process(delta: float) -> void:
    position.x = map_from_dir_to_x.sample_baked(FaceLandmarker.dir_latest.x)
    position.y = map_from_dir_to_y.sample_baked(FaceLandmarker.dir_latest.y)

func _on_Area2D_body_entered(body: Node) -> void:
    pass