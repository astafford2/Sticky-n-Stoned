extends Node


# Declare member variables here. Examples:
signal attacked(thrower, target, damage)
signal overlapped(body, rect)
signal enteredValidTile(body, tile)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func attacked(thrower, target, damage):
	emit_signal("attacked", thrower, target, damage)


func overlapped(body, rect):
	emit_signal("overlapped", body, rect)


func enteredValidTile(body, tile):
	emit_signal("enteredValidTile", body, tile)
