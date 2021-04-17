extends Area2D


func _ready():
	SignalMaster.connect("destroyed", self, "pickedUp")


func pickedUp(target):
	if target==self:
		queue_free()


func _on_HealthPickup_body_entered(body):
	if body.has_method("shoot"):
		SignalMaster.heal(body, 2, self)
