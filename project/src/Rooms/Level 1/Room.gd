extends Node2D

var open = true
var objective_complete = false
var started = false

onready var rect_shape := $Dimensions/Shape
onready var floors := $Floors
onready var walls := $Walls
onready var doors := $Doors
onready var door_entities := $DoorEntities
onready var enemies := $Enemies
onready var player_detection := $PlayerDetection
onready var nav_instance := $NavigationPolygonInstance

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalMaster.connect("doorsOpenOrClose", self, "toggleDoors")
	player_detection.connect("body_entered", self, "_on_PlayerDetection_body_entered")


func setEnemyTargets():
	for enemy in enemies.get_children():
		if enemy.has_method("set_navPoly"):
			enemy.set_navPoly(nav_instance.navpoly)


func _process(_delta):
	if !objective_complete and started:
		objectiveHandler()
	
	if Input.is_action_just_pressed("cheat_infinite_health"):
		get_parent().get_parent().get_node("Player").health = 999999999999999999


func objectiveHandler():
	if enemies.get_child_count() == 0:
		objective_complete = true
		SignalMaster.doorsOpenOrClose(door_entities)


func getRect2():
	return Rect2(rect_shape.global_position - rect_shape.shape.extents, rect_shape.shape.extents * 2)


func updateFloors():
	floors.instanceTiles()


func get_DoorPositions():
	return doors.get_children()


func get_Tiles():
	return [floors, walls]


func toggleDoors(room):
	if room == door_entities:
		if open and !objective_complete:
			closeDoors()
			open = false
		else:
			openDoors()


func closeDoors():
	for door in door_entities.get_children():
		if door.has_method("close"):
			door.close()


func openDoors():
	for door in door_entities.get_children():
		if door.has_method("open"):
			door.open()


func getTeleporters():
	var Teleporters = get_node("Teleporters")
	if Teleporters:
		return Teleporters.get_children()


func _on_PlayerDetection_body_entered(body):
	if body.has_method("shoot") and !objective_complete and !started:
		toggleDoors(door_entities)
		started = true
		for enemy in enemies.get_children():
			if enemy.has_method("set_target"):
				enemy.set_target(body)
