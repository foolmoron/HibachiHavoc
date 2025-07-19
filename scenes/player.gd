extends Area2D

@onready var isTouchingFood : bool

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("food"):
		isTouchingFood = true

func _on_body_exited(body: Node2D) -> void:
	pass # Replace with function body.

#when mouth close
#check if mouth open
#check if food there
#close mouth bool
