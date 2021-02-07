extends Node2D


var open_texture = preload("res://assets/tiles/door_open.png")
var closed_texture = preload("res://assets/tiles/door_closed.png")

onready var door_sprite := $Sprite
onready var closed_shape := $ClosedShape
onready var open_shape_1 := $OpenShape
onready var open_shape_2 := $OpenShape2


func open():
	door_sprite.texture = open_texture
	open_shape_1.disabled = false
	open_shape_2.disabled = false
	closed_shape.disabled = true


func close():
	door_sprite.texture = closed_texture
	closed_shape.disabled = false
	open_shape_1.disabled = true
	open_shape_2.disabled = true


func _on_DoorArea_body_entered(body):
	if body.has_method("shoot"):
		body.set_door(get_parent())
