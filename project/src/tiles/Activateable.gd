extends Node

var activated = false
var toggleable = false
var projectileActivateable = false
var playerActivateable = false
var traps := []


func _ready():
	pass 


func _physics_process(delta):
	if !(traps.size() == 0): #prevents crash just in case there is no longer a trap
		if activated:
			for trap in traps:
				trap.activated = true
		else:
			for trap in traps:
				trap.activated = false


func on_body_entered(body):
	if body.is_in_group("projectile") and projectileActivateable:
		if toggleable and activated:
			activated = false
		else:
			activated = true


func Interact(_body):
	if toggleable and activated:
		activated = false
	else:
		activated = true
