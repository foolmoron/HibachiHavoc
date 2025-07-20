extends Area2D

var food_particles_scn : PackedScene = preload("res://scenes/food_particles.tscn")

signal ate_food(food_item: Node)

@export var map_from_dir_to_x: Curve
@export var map_from_dir_to_y: Curve

enum State {
	TOUCHED_WITH_MOUTH_CLOSED,
	TOUCHED_WITH_MOUTH_OPEN,
}

var items_touching: Dictionary[Node, State] = {}

func _ready() -> void:
	connect("body_entered", _on_Area2D_body_entered)
	connect("body_exited", _on_Area2D_body_exited)

func _physics_process(delta: float) -> void:
	position.x = map_from_dir_to_x.sample_baked(FaceLandmarker.dir_latest.x)
	position.y = map_from_dir_to_y.sample_baked(FaceLandmarker.dir_latest.y)

	if FaceLandmarker.mouth_open_latest:
		for item in items_touching:
			if items_touching[item] == State.TOUCHED_WITH_MOUTH_CLOSED:
				items_touching[item] = State.TOUCHED_WITH_MOUTH_OPEN
	else:
		for item in items_touching:
			if items_touching[item] == State.TOUCHED_WITH_MOUTH_OPEN:
				ate_food.emit(item)
				items_touching.erase(item)
				item.queue_free()
				if Global.isPlaying:
					Global.foods_eaten += 1
				var particles = food_particles_scn.instantiate()
				particles.connect("finished", particles.queue_free)
				(particles as CPUParticles2D).emitting = true
				particles.global_position = item.global_position
				get_tree().current_scene.add_child(particles)

func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("food"):
		items_touching[body] = State.TOUCHED_WITH_MOUTH_CLOSED

func _on_Area2D_body_exited(body: Node) -> void:
	if body.is_in_group("food"):
		items_touching.erase(body)
