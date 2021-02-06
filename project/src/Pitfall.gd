extends Area2D


var delta2


func _process(delta):
	delta2 = delta


func _on_Pitfall_body_entered(body):
	if body.has_method("shoot"):
		body.pitfalled(position+Vector2(16, 16))
