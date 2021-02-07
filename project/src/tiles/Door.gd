extends Node2D


func _on_DoorArea_body_entered(body):
	if body.has_method("shoot"):
		body.set_door(get_parent())
