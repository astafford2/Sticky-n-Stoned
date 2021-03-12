extends Node2D

var rng = RandomNumberGenerator.new()
var path 
var Tiles := {}
var obstacles := {}
var maxsize := 0


#temp
var validsT

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
	pass
#	if path:
#		for p in path.get_points():
#			for c in path.get_point_connections(p):
#				var pp= path.get_point_position(p)
#				var cp = path.get_point_position(c)
#				draw_line(Vector2(pp.x,pp.y), Vector2(cp.x,cp.y), Color(1,1,0), 15, true)
#	if validsT:
#		for paths in validsT:
#			var point_start = paths[0]
#			var point_end = paths[len(paths) - 1]
#
#			var last_point = Vector2(point_start.x, point_start.y)
#			for index in range(1, len(paths)):
#				var current_point =Vector2(paths[index].x, paths[index].y)
#				draw_line(last_point, current_point, Color(1,0,0), 5, true)
#				last_point = current_point

#		for p in validsT.get_points():
#			for c in validsT.get_point_connections(p):
#				var pp = validsT.get_point_position(p)
#				var cp = validsT.get_point_position(c)
#				draw_line(Vector2(pp.x,pp.y), Vector2(cp.x,cp.y), Color(1, 0, 0), 5, true)


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
	var dist := 10
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
				currentTaken.append(currentRect.grow(192))
				if !currentRoom.has_method("updateFloors"):
					currentRoom.queue_free()
					break
				currentRoom.updateFloors()
				break
		if valid:
			rooms.erase(currentRoom)
		else:
			dist += 10
	#64 is the maximum size for a single room
	maxsize = (dist+32)*2


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


func checkTileNotOnMap(TilePosition):
	var valid = true
	for cell in obstacles:
		if TilePosition == cell:
			valid = false
	return valid

func updateObstacles():
	for tileset in Tiles.keys():
			var used = tileset.get_used_cells()
			for cell in used:
				var globalPos = Floor.world_to_map(tileset.map_to_world(cell) + Tiles.get(tileset).global_position)
				obstacles[globalPos] = tileset

func checkPlacementValid(TilePosition):
	var valid = true
	if !obstacles:
		updateObstacles()
	for cell in obstacles:
		var tileset = obstacles.get(cell)
		var standardPos = cell
		var left =  TilePosition+ Vector2(-1,0) == standardPos
		var right =  TilePosition+ Vector2(1,0) == standardPos
		var up =  TilePosition+ Vector2(0,1) == standardPos or TilePosition+ Vector2(0,2) == standardPos
		var down =  TilePosition+ Vector2(0,-1) == standardPos or TilePosition+ Vector2(0,-2) == standardPos
		var topright = TilePosition+ Vector2(1,1) == standardPos
		var topleft = TilePosition+ Vector2(-1,1) == standardPos
		var bottomright = TilePosition+ Vector2(1,-1) == standardPos
		var bottomleft = TilePosition+ Vector2(-1,-1) == standardPos
		var posIs = TilePosition == standardPos
		if left or right or up or down or posIs or topright or topleft or bottomright or bottomleft:
			if tileset.tile_set == Floor.tile_set and !posIs:
				continue
			valid = false
	
	return valid


func calculate_point_index(point):
	return (maxsize + point.x) + maxsize * (maxsize + point.y) 


func is_out_map(point):
	#Assumes in grid location
# warning-ignore:integer_division
# warning-ignore:integer_division
# warning-ignore:integer_division
# warning-ignore:integer_division
	return point.x < -(maxsize / 2) or point.y < -(maxsize / 2) or point.x >= (maxsize/2) or point.y >= (maxsize/2)


func getRangePoints(userdata): #designed for multi-threading
	var startx = userdata[0]
	var starty = userdata[1]
	var endx = userdata[2]
	var endy = userdata[3]
	var returnInfo = [] # Entry is array [point, point_index, Vector3(worldLoc.x, worldLoc.y, 0.0)]
	for y2 in range(starty, endy):
		var y = y2-(maxsize/2)
		for x2 in range(startx, endx):
			var x = x2-(maxsize/2)
			var point = Vector2(x, y)
			if !checkPlacementValid(point):
				continue
			var worldLoc = Floor.map_to_world(point)
			var point_index = calculate_point_index(point)
			returnInfo.append([point, point_index, Vector3(worldLoc.x, worldLoc.y, 0.0)])
	return returnInfo


func makeHalls():
	var rooms := Rooms.get_children()
	var doorPositions := {} #We use a dicitonary so that we can have to position [key] and the owner room [value]
	for room in rooms: #Get all door Positions
		var tiles = room.get_Tiles()
		Tiles[tiles[0]] = room
		Tiles[tiles[1]] = room
		var doors = room.get_DoorPositions()
		for door in doors:
			doorPositions[Vector3(door.global_position.x, door.global_position.y, 0)] = room
	yield(get_tree(), 'idle_frame')
	path = find_mst(doorPositions)
	#MST and Tiles have been populated
	print("MST found")
	var validP = []
	var valids = AStar.new()
# warning-ignore:unused_variable
	var map_size = Vector2(maxsize, maxsize)
	#Add valid points to valids (This is the longest generation step)
	var thread1 = Thread.new()
	var thread2 = Thread.new()
	var thread3 = Thread.new()
	var thread4 = Thread.new()
	thread1.start(self, "getRangePoints", [0,0, ceil(maxsize/2), ceil(maxsize/2)])
	thread2.start(self, "getRangePoints", [ceil(maxsize/2),0, maxsize, ceil(maxsize/2)])
	thread3.start(self, "getRangePoints", [0,ceil(maxsize/2), ceil(maxsize/2), maxsize])
	thread4.start(self, "getRangePoints", [ceil(maxsize/2),ceil(maxsize/2), maxsize, maxsize])
	var set1 = thread1.wait_to_finish()
	var set2 = thread2.wait_to_finish()
	var set3 = thread3.wait_to_finish()
	var set4 = thread4.wait_to_finish()
	for set in [set1, set2, set3, set4]:
		for data in set:
			validP.append(data[0])
			valids.add_point(data[1], data[2])
#	for y2 in range(map_size.y):
#		var y = y2 - (maxsize / 2)
#		for x2 in range(map_size.x):
#			var x = x2 - (maxsize / 2)
#			var point = Vector2(x, y)
#			if !checkPlacementValid(point):
#				continue
#			var worldLoc = Floor.map_to_world(point) 
#			var point_index = calculate_point_index(point)
#			validP.append(point)
#			valids.add_point(point_index, Vector3(worldLoc.x, worldLoc.y, 0.0))
	#Connect all valid points
	for point in validP:
		var point_index = calculate_point_index(point)
		var points_relative = PoolVector2Array([
			Vector2(point.x + 1, point.y),
			Vector2(point.x, point.y+1),
			Vector2(point.x - 1, point.y),
			Vector2(point.x, point.y-1)])
		for point_relative in points_relative:
			var point_relative_index = calculate_point_index(point_relative)
			if is_out_map(point_relative):
				continue
			if not valids.has_point(point_relative_index):
				continue
			valids.connect_points(point_index, point_relative_index, false)
	var Paths = []
	#calculate path between locations
	var calculated = []
	for p in path.get_points():
			for c in path.get_point_connections(p):
				var s = valids.get_point_position(valids.get_closest_point(path.get_point_position(p)))
				var g = valids.get_point_position(valids.get_closest_point(path.get_point_position(c)))
				var start= Floor.world_to_map(Vector2(s.x, s.y))
				var goal = Floor.world_to_map(Vector2(g.x, g.y))
				var startIndex = calculate_point_index(start)
				var goalIndex = calculate_point_index(goal)
				if !(calculated.has([goalIndex, startIndex]) or calculated.has([startIndex, goalIndex])):
					Paths.append(valids.get_point_path(startIndex, goalIndex))
					calculated.append([startIndex, goalIndex])
	#place Floors
	for singlePath in Paths:
		for point in singlePath:
			var cellPos = Floor.world_to_map(Vector2(point.x, point.y))
			Floor.set_cellv(cellPos, 0)
			if checkPlacementValid(cellPos+ Vector2(-1, 0)) and Floor.get_cellv(cellPos+Vector2(-1, 0)) == -1:
				Floor.set_cellv(cellPos+ Vector2(-1, 0), 0)
			if checkPlacementValid(cellPos+ Vector2(1, 0)) and Floor.get_cellv(cellPos+Vector2(1, 0)) == -1:
				Floor.set_cellv(cellPos+ Vector2(1, 0), 0)
			if checkPlacementValid(cellPos+ Vector2(0, 1)) and Floor.get_cellv(cellPos+Vector2(0, 1)) == -1:
				Floor.set_cellv(cellPos+ Vector2(0, 1), 0)
			if checkPlacementValid(cellPos+ Vector2(0, -1)) and Floor.get_cellv(cellPos+Vector2(0, -1)) == -1:
				Floor.set_cellv(cellPos+ Vector2(0, -1), 0)
	#Place Walls around Floors:
	for cell in Floor.get_used_cells():
		var u =cell + Vector2(0,1)
		var d = cell + Vector2(0,-1)
		var l = cell + Vector2(-1,0)
		var r =  cell + Vector2(1,0)
		var up =  Floor.get_cellv(u) == -1
		var down =  Floor.get_cellv(d) == -1
		var left =  Floor.get_cellv(l) == -1
		var right =  Floor.get_cellv(r) == -1
		
		if down and Walls.get_cellv(d) == -1 and checkTileNotOnMap(d):
			Walls.set_cellv(d, 9)
			Walls.set_cellv(cell+Vector2(0,-2), 6)
		if up and Walls.get_cellv(u) == -1 and checkTileNotOnMap(u):
			Walls.set_cellv(cell, 6)
			Walls.set_cellv(u, 9)
		if left and Walls.get_cellv(l) == -1 and checkTileNotOnMap(l):
			Walls.set_cellv(l, 13)
		if right and Walls.get_cellv(r) == -1 and checkTileNotOnMap(r):
			Walls.set_cellv(r, 25)
		
		
	#validsT = Paths
	validsT = valids
	


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
