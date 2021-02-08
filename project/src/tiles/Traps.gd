extends Node2D

class_name Traps


var activated := false
var deactivated := true


func _ready():
	pass


# what the child trap will do when activated
func activated():
	pass


# what the child trap will do when deactivated or idle
func deactivated():
	pass
