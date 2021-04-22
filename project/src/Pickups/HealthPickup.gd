extends Area2D


func pickedUp():
	queue_free()


func _on_HealthPickup_body_entered(body):
	if body.has_method("shoot"):
		SignalMaster.heal(body, 2, self)
