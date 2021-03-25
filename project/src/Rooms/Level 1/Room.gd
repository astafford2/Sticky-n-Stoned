extends Node2D

var open = true
var objectiveComplete = false
var started = false

onready var rectShape := $Dimensions/Shape
onready var Floors := $Floors
onready var Walls := $Walls
onready var Doors := $Doors
onready var DoorEntities := $DoorEntities
onready var Enemies := $Enemies
onready var PlayerDetection := $PlayerDetection

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalMaster.connect("doorsOpenOrClose", self, "toggleDoors")


func _process(_delta):
	if !objectiveComplete:
		objectiveHandler()


func objectiveHandler():
	if Enemies.get_child_count() == 0:
		objectiveComplete = true
		SignalMaster.doorsOpenOrClose(DoorEntities)


func getRect2():
	return Rect2(rectShape.global_position - rectShape.shape.extents, rectShape.shape.extents * 2)

func updateFloors():
	Floors.instanceTiles()

func get_DoorPositions():
	return Doors.get_children()

func get_Tiles():
	return [Floors, Walls]

func toggleDoors(room):
	if room == DoorEntities:
		if open and !objectiveComplete:
			closeDoors()
			open = false
		else:
			openDoors()

func closeDoors():
	for door in DoorEntities.get_children():
		if door.has_method("close"):
			door.close()


func openDoors():
	for door in DoorEntities.get_children():
		if door.has_method("open"):
			door.open()


func _on_PlayerDetection_body_entered(body):
	if body.has_method("shoot") and !objectiveComplete and !started:
		toggleDoors(DoorEntities)
		started = true
