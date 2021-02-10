extends Node2D

class_name Traps

var activated := false


func _ready():
	pass

func _physics_process(delta):
	if activated:
		activate(delta)
	else:
		deactivated(delta)

# what the child trap will do when activated
func activate(_delta):
	pass


# what the child trap will do when deactivated or idle
func deactivated(_delta):
	pass
