extends Door

export var right_facing := false


func ready():
	walls.set_cellv(Vector2(0,1), 10)
	walls.set_cellv(Vector2(3,1), -1)

func open():
	walls.set_cell(0,0, 5, right_facing)
	walls.set_cell(0,-1, -1, right_facing)
	walls.set_cell(0,-2, 8, right_facing)
	open_sfx.play()


func close():
	walls.set_cell(0,0, 3, right_facing)
	walls.set_cell(0,-1, 1, right_facing)
	walls.set_cell(0,-2, 7, right_facing)
	close_sfx.play()
