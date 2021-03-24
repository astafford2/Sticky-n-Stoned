extends Node2D

class MyAStar:
	extends AStar

	func _compute_cost(u, v):
		return abs(u - v)

	func _estimate_cost(u, v):
		return min(0, abs(u - v) - 1)


var rng = RandomNumberGenerator.new()
var path 
var Tiles := {}
var obstacles := {}
var maxsize:float = 0


onready var Rooms := $Rooms
onready var Floor := $Floor
onready var Walls := $Walls

#Rooms
export (PackedScene) var multiRoom
export (PackedScene) var SideSmallRoom
export (PackedScene) var BossRoom
export (PackedScene) var DescentRoom
export (PackedScene) var LargeRoom
export (PackedScene) var MonsterRoom
export (PackedScene) var SpawnRoom

#Spawns up to minimum at 100% and then any more past to maximum at Probability
onready var spawnInfo = {
	#Room preload : [MinSpawn, MaxSpawn, Probability]
	#Rooms should be organized in order of centrality 
	#single door rooms are last while multi door rooms are first
	SpawnRoom : [1,1,1],
	#multiRoom : [1, 1, 1], 
	SideSmallRoom : [4, 10, 0.5],
	#BossRoom : [1, 1, 1],
	#DescentRoom : [1, 1, 1],
	#MonsterRoom : [2, 3, 0.25], #Currently giving pathing issues
	#LargeRoom : [1, 2, 0.75]
	
}
var wallConversions = {
	[13,6] : 21,
	[13,25] : [12,6],
	[12, 13] : [20,6],
	[12,25] : [16, 6],
	[13, 6] : 19,
	[25, 6] : 18,
	[9, 25] : [9,6],
	[9, 13] : [9,6]
}

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	spawnRooms()
	moveRooms()
	makeHalls()


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
	#32 is the maximum size for a single room
	maxsize = (dist+100)*2


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


func getNearby(TilePosition):
	var result = []
	for x in range(-3, 3):
		for y in range(-3, 3):
			result.append(TilePosition+ Vector2(x,y))
	return result


func checkPlacementValid(TilePosition):
	var nearby = getNearby(TilePosition)
	
	if obstacles.has(TilePosition):
		return false
	for cell in nearby:
		if obstacles.has(cell):
			var tileset = obstacles.get(cell)
			if tileset.tile_set == Floor.tile_set and !(TilePosition == cell):
				continue
			return false
	return true


func calculate_point_index(point):
	return (maxsize + point.x) + maxsize * (maxsize + point.y) 


func is_out_map(point):
	#Assumes in grid location
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


func gatherRangeSets():
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
	return [set1,set2,set3,set4]


func makeHalls():
	var rooms := Rooms.get_children() #Each individual room
	var validP := [] #A list of all points in valids
	var valids := MyAStar.new() #An Astar where all points are connected to neighboring points (hall generation)
	var doorPositions := {} #We use a dicitonary so that we can have to position [key] and the owner room [value]
	for room in rooms: #Get all door Positions
		var tiles = room.get_Tiles()
		#populate the Tiles for later obstacle generation
		Tiles[tiles[0]] = room
		Tiles[tiles[1]] = room
		var doors = room.get_DoorPositions()
		for door in doors:
			doorPositions[Vector3(door.global_position.x, door.global_position.y, 0)] = room
	path = find_mst(doorPositions)
	#MST and Tiles have been populated
	#Add valid points to valids (This is the longest generation step)
	updateObstacles()
	var sets = gatherRangeSets()
	for set in sets:
		for data in set:
			validP.append(data[0])
			valids.add_point(data[1], data[2])
	for p in doorPositions.keys():
		var point = Floor.world_to_map(Vector2(p.x, p.y))
		var closest_I = valids.get_closest_point(p)
		var point_I = calculate_point_index(point)
		var c = valids.get_point_position(closest_I)
		var closest = Floor.world_to_map(Vector2(c.x,c.y))
		var directionVector = point-closest #says left if need to go Left from closest
		while directionVector.x != 0:
			var direction = 1
			if directionVector.x < 0:
				direction = -1
			var newP = closest + Vector2(directionVector.x, 0)
			var newP_W = Floor.map_to_world(newP)
			var newP_I = calculate_point_index(newP)
			validP.append(newP)
			valids.add_point(newP_I, Vector3(newP_W.x, newP_W.y, 0.0))
			directionVector.x -= direction
		while directionVector.y != 0:
			var direction = 1
			if directionVector.y < 0:
				direction = -1
			var newP = closest + Vector2(0, directionVector.y)
			var newP_W = Floor.map_to_world(newP)
			var newP_I = calculate_point_index(newP)
			validP.append(newP)
			valids.add_point(newP_I, Vector3(newP_W.x, newP_W.y, 0.0))
			directionVector.y -= direction
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
		for pointI in range(0, singlePath.size()-1):
			var point = singlePath[pointI]
			var nextPoint = singlePath[pointI + 1]
			var priorPoint = singlePath[pointI - 1]
			var direction = [(point-priorPoint)/32, (nextPoint-point)/32]
			if priorPoint == singlePath[-1]:
				priorPoint = null
				direction = [(point-nextPoint)/32, (point-nextPoint)/32]
			var cellPos = Floor.world_to_map(Vector2(point.x, point.y))
			Floor.set_cellv(cellPos, 0)
			match (direction):
				[Vector3(-1, 0, 0), Vector3(-1,0,0)]: #Left, so up
					Floor.set_cellv(cellPos+Vector2(0, -1), 0)
				[Vector3(1, 0, 0), Vector3(1,0,0)]: #Right, so up
					Floor.set_cellv(cellPos+Vector2(0, -1), 0)
				[Vector3(0, -1, 0), Vector3(0,-1,0) ]: #Up, so left
					Floor.set_cellv(cellPos+Vector2(-1, 0), 0)
				[Vector3(0, 1, 0), Vector3(0,1,0) ]: #Down, so left
					Floor.set_cellv(cellPos+Vector2(-1, 0), 0)

				[Vector3(-1, 0, 0), Vector3(0,-1,0) ]: #Left Up, so left
					Floor.set_cellv(cellPos+Vector2(-1, 0), 0)
				[Vector3(-1, 0, 0), Vector3(0,1,0) ]: #Left Down, so left up/left up
					Floor.set_cellv(cellPos+Vector2(-1, 0), 0)
					Floor.set_cellv(cellPos+Vector2(-1, -1), 0)
					Floor.set_cellv(cellPos+Vector2(0, -1), 0)

				[Vector3(1, 0, 0), Vector3(0,-1,0) ]: #Right Up, so none
					pass
					#Floor.set_cellv(cellPos+Vector2(0, -1), 3)
				[Vector3(1, 0, 0), Vector3(0,1,0) ]: #Right Down, so up
					Floor.set_cellv(cellPos+Vector2(0, -1), 0)

				[Vector3(0, -1, 0), Vector3(-1,0,0) ]: #Up Left, so up
					Floor.set_cellv(cellPos+Vector2(0, -1), 0)
				[Vector3(0, -1, 0), Vector3(1,0,0) ]: #Up Right, so left up/left up
					Floor.set_cellv(cellPos+Vector2(-1, 0), 0)
					Floor.set_cellv(cellPos+Vector2(-1, -1), 0)
					Floor.set_cellv(cellPos+Vector2(0, -1), 0)

				[Vector3(0, 1, 0), Vector3(-1,0,0) ]: #Down Left, none
					pass
					#Floor.set_cellv(cellPos+Vector2(-1, 0), 3)
				[Vector3(0, 1, 0), Vector3(1,0,0) ]: #Down Right, left
					Floor.set_cellv(cellPos+Vector2(-1, 0), 0)

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
		
		if checkTileNotOnMap(d) and down:
			placeOrMerge(d, 9)
			placeOrMerge(d + Vector2(0,-1), 6)
		if checkTileNotOnMap(u) and up:
			placeOrMerge(cell, 6)
			placeOrMerge(u, 12)
		if checkTileNotOnMap(l) and left:
			placeOrMerge(l, 13)
		if checkTileNotOnMap(r) and right:
			placeOrMerge(r, 25)
	#wall cleanup
	var cornerChecks = [Walls.get_used_cells_by_id(13), Walls.get_used_cells_by_id(25)]
	for set in cornerChecks:
		for cell in set:
			var u = cell + Vector2(0,-1)
			var d = cell + Vector2(0, 1)
			var wallV = Walls.get_cellv(cell)
			if Walls.get_cellv(u) == -1 and !obstacles.has(u):
				Walls.set_cellv(u, wallV)
			if Walls.get_cellv(d) == -1 and !obstacles.has(d):
				Walls.set_cellv(d, wallV+1)
		


func placeOrMerge(location, value):
	var currentTile = Walls.get_cellv(location)
	if currentTile == -1:
		Walls.set_cellv(location, value)
		return
	var new = wallAddition(currentTile, value)
	if !new:
		new = wallAddition(value, currentTile)
	if new:
		if typeof(new) == TYPE_INT:
			Walls.set_cellv(location, new)
		else:
			Walls.set_cellv(location, new[0])
			placeOrMerge(location + Vector2(0,-1), new[1])


func wallAddition(value1, value2):
	var newValue = wallConversions.get([value1, value2])
	if newValue == null:
		newValue = wallConversions.get([value2, value1])
	return newValue


func find_mst(doors):
	var Mpath = AStar.new()
	var positions = doors.keys()
	Mpath.add_point(Mpath.get_available_point_id(), positions.pop_front())
	
	while positions:
		var min_dist = INF
		var min_p = null
		var p = null
		for p1 in Mpath.get_points():
			p1 = Mpath.get_point_position(p1)
			for p2 in positions:
				if p1.distance_to(p2) < min_dist and doors.get(p1) != doors.get(p2):
					min_dist = p1.distance_to(p2)
					min_p = p2
					p = p1
		var n = Mpath.get_available_point_id()
		Mpath.add_point(n, min_p)
		Mpath.connect_points(Mpath.get_closest_point(p), n)
		positions.erase(min_p)
	return Mpath
