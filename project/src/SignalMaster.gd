extends Node


# Declare member variables here. Examples:
signal attacked(thrower, target, damage)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func attacked(thrower, target, damage):
	emit_signal("attacked", thrower, target, damage)
