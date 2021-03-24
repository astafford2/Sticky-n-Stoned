extends Node2D

var open = true
var objectiveComplete = false

onready var rectShape := $Dimensions/Shape
onready var Floors := $Floors
onready var Walls := $Walls
onready var Doors := $Doors
onready var DoorEntities := $DoorEntities
onready var Enemies := $Enemies
onready var PlayerDetection := $PlayerDetection
onready var nav_instance := $NavigationPolygonInstance

# Called when the node enters the scene tree for the first time.
func _ready():
	print(self)
	SignalMaster.connect("doorsOpenOrClose", self, "toggleDoors")
	PlayerDetection.connect("body_entered", self, "_on_PlayerDetection_body_entered")
	
	var player = owner.get_node("Player")
	
	for enemy in Enemies.get_children():
		if enemy.has_method("set_navigation"):
			enemy.set_navigation(nav_instance.navpoly, player)
	pass # Replace with function body.


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
	var tempSelf = self
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
	if body.has_method("shoot") and !objectiveComplete:
		toggleDoors(DoorEntities)
