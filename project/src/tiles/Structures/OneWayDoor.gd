extends Door

var openable := false
var currentlyOpen := false

func _ready():
	self.add_to_group("trap")
	close()

func open():
	if openable and !currentlyOpen:
		walls.set_cellv(Vector2(1,0), 12)
		walls.set_cellv(Vector2(2,0), 13)
		if top:
			walls.set_cellv(Vector2(1,1), 14)
			walls.set_cellv(Vector2(2,1), 15)
		else:
			walls.set_cellv(Vector2(1,1), 22)
			walls.set_cellv(Vector2(2,1), 23)
		open_sfx.play()
		currentlyOpen = true


func close():
	if !openable:
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


func activate():
	openable = true
	open()


func deactivate(): #This is to assure no crashing with interactions of the button
	pass
