extends Area2D

class_name Traps

var activated := false


func _ready():
	self.add_to_group("trap")


func _physics_process(delta):
	if activated:
		activateActivity(delta)
	else:
		deactivateActivity(delta)


# what the child trap will do when activated
func activateActivity(_delta):
	pass


# what the child trap will do when deactivated or idle
func deactivateActivity(_delta):
	pass

func activate():
	activated = true

func deactivate():
	activated = false
