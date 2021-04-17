extends Node2D

class_name Door

onready var open_sfx := $OpenSfx
onready var close_sfx := $CloseSfx
onready var walls := $Walls

export var top:=true

func _ready():
	if top:
		walls.set_cellv(Vector2(0,1), 18)
		walls.set_cellv(Vector2(3,1), 19)

func open():
	walls.set_cellv(Vector2(1,0), 12)
	walls.set_cellv(Vector2(2,0), 13)
	if top:
		walls.set_cellv(Vector2(1,1), 14)
		walls.set_cellv(Vector2(2,1), 15)
	else:
		walls.set_cellv(Vector2(1,1), 22)
		walls.set_cellv(Vector2(2,1), 23)
	open_sfx.play()


func close():
	if top:
		walls.set_cellv(Vector2(1,0), 6)
		walls.set_cellv(Vector2(2,0), 9)
		walls.set_cellv(Vector2(1,1), 20)
		walls.set_cellv(Vector2(2,1), 8)
	else:
		walls.set_cellv(Vector2(1,0), 6)
		walls.set_cellv(Vector2(2,0), 9)
		walls.set_cellv(Vector2(1,1), 7)
		walls.set_cellv(Vector2(2,1), 21)
	close_sfx.play()


#func _on_DoorArea_body_exited(body):
#	if body.has_method("shoot"):
#		var parent = get_parent()
#		SignalMaster.doorsOpenOrClose(parent)
