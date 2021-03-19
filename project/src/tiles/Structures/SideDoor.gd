extends Door

export var rightFacing := true

func open():
	walls.set_cell(0,0, 5, rightFacing)
	walls.set_cell(0,-1, -1, rightFacing)
	walls.set_cell(0,-2, 8, rightFacing)
	open_sfx.play()


func close():
	walls.set_cell(0,0, 3, rightFacing)
	walls.set_cell(0,-1, 1, rightFacing)
	walls.set_cell(0,-2, 7, rightFacing)
	close_sfx.play()
