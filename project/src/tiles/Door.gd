extends Node2D


var open_texture = preload("res://assets/tiles/door_open.png")
var closed_texture = preload("res://assets/tiles/door_closed.png")

onready var door_sprite := $Sprite
onready var closed_shape := $ClosedShape
onready var open_shape_1 := $OpenShape
onready var open_shape_2 := $OpenShape2
onready var open_sfx := $OpenSfx
onready var close_sfx := $CloseSfx


func _ready():
	closed_shape.set_deferred("disabled", true)


func open():
	door_sprite.texture = open_texture
	open_shape_1.set_deferred("disabled", false)
	open_shape_2.set_deferred("disabled", false)
	closed_shape.set_deferred("disabled", true)
	open_sfx.play()


func close():
	door_sprite.texture = closed_texture
	closed_shape.set_deferred("disabled", false)
	open_shape_1.set_deferred("disabled", true)
	open_shape_2.set_deferred("disabled", true)
	close_sfx.play()


func _on_DoorArea_body_entered(body):
	if body.has_method("shoot"):
		body.set_door(get_parent())
		z_index = -1


func _on_DoorArea_body_exited(body):
	if body.has_method("shoot"):
		close()
		z_index = 0
