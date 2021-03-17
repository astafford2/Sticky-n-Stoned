extends Node2D

class_name Door

onready var open_sfx := $OpenSfx
onready var close_sfx := $CloseSfx
onready var walls := $Walls


func open():
	walls.set_cellv(Vector2(1,0), 12)
	walls.set_cellv(Vector2(2,0), 13)
	walls.set_cellv(Vector2(1,1), 14)
	walls.set_cellv(Vector2(2,1), 15)
	open_sfx.play()


func close():
	walls.set_cellv(Vector2(1,0), 6)
	walls.set_cellv(Vector2(2,0), 9)
	walls.set_cellv(Vector2(1,1), 7)
	walls.set_cellv(Vector2(2,1), 8)
	close_sfx.play()


#func _on_DoorArea_body_exited(body):
#	if body.has_method("shoot"):
#		var parent = get_parent()
#		SignalMaster.doorsOpenOrClose(parent)
