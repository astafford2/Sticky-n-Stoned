extends Node

class_name Activateable

var activated = false
var toggleable = false
var projectile_activateable = false
var traps := []
var sfx : AudioStreamPlayer = null


func _physics_process(_delta):
	if !(traps.size() == 0): #prevents crash just in case there is no longer a trap
		if activated:
			for trap in traps:
				trap.activate()
		else:
			for trap in traps:
				trap.deactivate()


func update_traps_from_children():
	for child in self.get_children():
		if child.is_in_group("trap"):
			traps.push_back(child)



func on_body_entered(body):
	if body.is_in_group("projectile") and projectile_activateable:
		if toggleable and activated:
			activated = false
		else:
			activated = true
		if sfx:
			sfx.play()


func Interact(_body):
	if toggleable and activated:
		activated = false
	else:
		activated = true
	if sfx:
		sfx.play()
