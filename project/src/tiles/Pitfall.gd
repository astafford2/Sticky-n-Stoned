extends Area2D


func _on_Pitfall_body_entered(body):
	if body.has_method("shoot"):
		body.pitfalled(global_position+Vector2(16, 16))
