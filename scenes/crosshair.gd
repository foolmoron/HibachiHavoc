extends AnimatedSprite2D

@onready var particles: CPUParticles2D = $CPUParticles2D

func _ready() -> void:
	particles.reparent.call_deferred(get_tree().current_scene)

func _physics_process(_delta: float) -> void:
	frame = 1 if FaceLandmarker.mouth_open_latest else 0
	visible = FaceLandmarker.player_detected_latest
	
	particles.emitting = visible && frame == 1
	if !particles.emitting:
		particles.global_position = global_position
	else:
		particles.global_position = lerp(particles.global_position, global_position, 0.2)
