extends Area2D


func _ready():
	pass


func _on_Pitfall_body_entered(body):
	if body.has_method("shoot"):
		body.player_hit()
		body.rotation += 50
