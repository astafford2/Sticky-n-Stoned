extends Node2D

var rng = RandomNumberGenerator.new()
var path 

onready var Rooms := $Rooms
onready var Floor := $Floor
onready var Walls := $Walls

#Rooms
export (PackedScene) var multiRoom
export (PackedScene) var SideSmallRoom

#Spawns up to minimum at 100% and then any more past to maximum at Probability
onready var spawnInfo = {
	#Room preload : [MinSpawn, MaxSpawn, Probability]
	multiRoom : [1, 1, 1], #Pretend this is the character instance room
	SideSmallRoom : [1, 5, 0.5] #Pretend this is a common room
}

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	spawnRooms()
	moveRooms()
	#combineTiles()
	makeHalls()


func _draw():
	if path:
		for p in path.get_points():
			for c in path.get_point_connections(p):
				var pp= path.get_point_position(p)
				var cp = path.get_point_position(c)
				draw_line(Vector2(pp.x,pp.y), Vector2(cp.x,cp.y), Color(1,1,0), 15, true)


func _process(_delta):
	update()


func spawnRooms():
	for room in spawnInfo.keys():
		print(spawnInfo.keys())
		var roomInfo = spawnInfo.get(room)
		var minimum = roomInfo[0]
		var maximum = roomInfo[1]
		var prob = roomInfo[2]
		for n in minimum:
			var roomInstance = room.instance()
			Rooms.add_child(roomInstance)
		for n in maximum-minimum:
			if prob >= rng.randf():
				var roomInstance = room.instance()
				Rooms.add_child(roomInstance)


func moveRooms():
	var rooms := Rooms.get_children()
	var currentTaken := []
	var dist := 16
	while !rooms.empty():
		var currentRoom = rooms[0]
		var valid := true
		for n in 16:
			valid = true
			currentRoom.global_position = Floor.map_to_world(Vector2(rng.randi_range(-dist, dist), rng.randi_range(-dist, dist)))
			if !currentRoom.has_method("getRect2"):
				currentRoom.queue_free()
				break
			var currentRect = currentRoom.getRect2()
			for taken in currentTaken:
				if currentRect.intersects(taken):
					valid = false
			if valid:
				currentTaken.append(currentRect.grow(144))
				if !currentRoom.has_method("updateFloors"):
					currentRoom.queue_free()
					break
				currentRoom.updateFloors()
				break
		if valid:
			rooms.erase(currentRoom)
		else:
			dist += 16


#func combineTiles():
#	var mainFSet = Floor.tile_set
#	var mainWSet = Walls.tile_set
#	for room in Rooms.get_children():
#		var tiles = room.get_Tiles()
#		var floors = tiles[0]
#		var floorSet = floors.tile_set
#		var walls = tiles[1]
#		var wallSet = walls.tile_set
#		for cell in floors.get_used_cells():
#			var value = floors.get_cellv(cell)
#			var pos = floors.map_to_world(cell) + room.global_position
#			var autotile = floors.get_cell_autotile_coord(pos.x, pos.y)
#			Floor.set_cell(Floor.world_to_map(pos).x,Floor.world_to_map(pos).y , value, false, false, false, Vector2(1,1))
#		for cell in walls.get_used_cells():
#			var value = walls.get_cellv(cell)
#			var pos = walls.map_to_world(cell) + room.global_position
#			var autotile = walls.get_cell_autotile_coord(pos.x, pos.y)
#			Walls.set_cell(Walls.world_to_map(pos).x,Walls.world_to_map(pos).y , value, false, false, false, Vector2(1,1))
#		floors.clear()
#		walls.clear()


func makeHalls():
	var rooms := Rooms.get_children()
	var doorPositions := {} #We use a dicitonary so that we can have to position [key] and the owner room [value]
	for room in rooms: #Get all door Positions
		var doors = room.get_DoorPositions()
		for door in doors:
			doorPositions[Vector3(door.global_position.x, door.global_position.y, 0)] = room
	yield(get_tree(), 'idle_frame')
	path = find_mst(doorPositions)


func find_mst(doors):
# warning-ignore:shadowed_variable
	var path = AStar.new()
	var positions = doors.keys()
	path.add_point(path.get_available_point_id(), positions.pop_front())
	
	while positions:
		var min_dist = INF
		var min_p = null
		var p = null
		for p1 in path.get_points():
			p1 = path.get_point_position(p1)
			for p2 in positions:
				if p1.distance_to(p2) < min_dist and doors.get(p1) != doors.get(p2):
					min_dist = p1.distance_to(p2)
					min_p = p2
					p = p1
		var n = path.get_available_point_id()
		path.add_point(n, min_p)
		path.connect_points(path.get_closest_point(p), n)
		positions.erase(min_p)
	return path
