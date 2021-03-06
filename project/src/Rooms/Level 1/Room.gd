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
onready var nav_instance := $NavigationPolygonInstance

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalMaster.connect("doorsOpenOrClose", self, "toggleDoors")
	PlayerDetection.connect("body_entered", self, "_on_PlayerDetection_body_entered")


func setEnemyTargets():
	for enemy in Enemies.get_children():
		if enemy.has_method("set_navPoly"):
			enemy.set_navPoly(nav_instance.navpoly)


func _process(_delta):
	if !objectiveComplete and started:
		objectiveHandler()
	
	if Input.is_action_just_pressed("cheat_infinite_health"):
		get_parent().get_parent().get_node("Player").health = 999999999999999999


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


func getTeleporters():
	var Teleporters = get_node("Teleporters")
	if Teleporters:
		return Teleporters.get_children()


func _on_PlayerDetection_body_entered(body):
	if body.has_method("shoot") and !objectiveComplete and !started:
		toggleDoors(DoorEntities)
		started = true
		for enemy in Enemies.get_children():
			if enemy.has_method("set_target"):
				enemy.set_target(body)
