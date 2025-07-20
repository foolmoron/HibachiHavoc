extends Node
class_name FloatAround

@export var amplitude := 50.0
@export var sin_frequency := 3.2
@export var cos_frequency := 2.2

@onready var parent := get_parent() as Node2D
@onready var base := parent.position
@onready var sin_phase := randf_range(0, 2 * PI)
@onready var cos_phase := randf_range(0, 2 * PI)

func _process(delta: float) -> void:
    sin_phase += delta * sin_frequency
    cos_phase += delta * cos_frequency
    parent.position = base + Vector2(sin(sin_phase), cos(cos_phase)) * amplitude
