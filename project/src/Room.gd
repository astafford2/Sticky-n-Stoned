extends Node2D

onready var rectShape := $Dimensions/Shape
onready var Floors := $Floors
onready var Walls := $Walls
onready var Doors := $Doors

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func getRect2():
	return Rect2(rectShape.global_position - rectShape.shape.extents, rectShape.shape.extents * 2)

func updateFloors():
	Floors.instanceTiles()

func get_DoorPositions():
	return Doors.get_children()

func get_Tiles():
	return [Floors, Walls]
