extends Node2D

class MyAStar:
	extends AStar

	func _compute_cost(u, v):
		return abs(u - v)

	func _estimate_cost(u, v):
		return min(0, abs(u - v) - 1)

class_name GenerationBase

var rng = RandomNumberGenerator.new()
var tiles := {}
var obstacles := {}
var max_size:float = 0
var valids: AStar
var door_points = []
#var testingAStar

onready var Rooms := $Rooms
onready var Floor := $Floor
onready var Walls := $Walls


onready var FakeRoom := load("res://src/Rooms/Level 1/SpawnRoom.tscn")
#Rooms

#Spawns up to minimum at 100% and then any more past to maximum at Probability
onready var spawnInfo = { #This should ideally never get used other than for testing
	FakeRoom : [1,1,1]
}

var wallConversions = {
	[13,6] : 21,
	[13,25] : [12,6],
	[12, 13] : [20,6],
	[12,25] : [16, 6],
	[13, 6] : 19,
	[25, 6] : 18,
	[27, 25] : [27,6],
	[27, 13] : [27,6]
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	rng.randomize()

#Spawns all rooms to be used in total generation | Specs can be used for specified segments
func spawnRooms(Specs = spawnInfo):
	for room in Specs.keys():
		print(Specs.keys())
		var roomInfo = Specs.get(room)
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

#Moves rooms under "Rooms" node to new locations
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
	updateMaxsize()
	#max_size = (dist + 32) * 2

#Tries to place a tile of value at location | Checks for mergability and updates location
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

#Places floor tiles along provided Paths
func placeFloorsOnPaths(Paths):
	var new = []
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
			new.append(cellPos)
			match (direction):
				[Vector3(-1, 0, 0), Vector3(-1,0,0)]: #Left, so up
					Floor.set_cellv(cellPos+Vector2(0, -1), 0)
					new.append(cellPos+Vector2(0, -1))
				[Vector3(1, 0, 0), Vector3(1,0,0)]: #Right, so up
					Floor.set_cellv(cellPos+Vector2(0, -1), 0)
					new.append(cellPos+Vector2(0, -1))
				[Vector3(0, -1, 0), Vector3(0,-1,0) ]: #Up, so left
					Floor.set_cellv(cellPos+Vector2(-1, 0), 0)
					new.append(cellPos+Vector2(-1, 0))
				[Vector3(0, 1, 0), Vector3(0,1,0) ]: #Down, so left
					Floor.set_cellv(cellPos+Vector2(-1, 0), 0)
					new.append(cellPos+Vector2(-1, 0))
				[Vector3(-1, 0, 0), Vector3(0,-1,0) ]: #Left Up, so left
					Floor.set_cellv(cellPos+Vector2(-1, 0), 0)
					new.append(cellPos+Vector2(-1, 0))
				[Vector3(-1, 0, 0), Vector3(0,1,0) ]: #Left Down, so left up/left up
					Floor.set_cellv(cellPos+Vector2(-1, 0), 0)
					new.append(cellPos+Vector2(-1, 0))
					Floor.set_cellv(cellPos+Vector2(-1, -1), 0)
					new.append(cellPos+Vector2(-1, -1))
					Floor.set_cellv(cellPos+Vector2(0, -1), 0)
					new.append(cellPos+Vector2(0, -1))
				[Vector3(1, 0, 0), Vector3(0,-1,0) ]: #Right Up, so none
					pass
				[Vector3(1, 0, 0), Vector3(0,1,0) ]: #Right Down, so up
					Floor.set_cellv(cellPos+Vector2(0, -1), 0)
					new.append(cellPos+Vector2(0, -1))
				[Vector3(0, -1, 0), Vector3(-1,0,0) ]: #Up Left, so up
					Floor.set_cellv(cellPos+Vector2(0, -1), 0)
					new.append(cellPos+Vector2(0, -1))
				[Vector3(0, -1, 0), Vector3(1,0,0) ]: #Up Right, so left up/left up
					Floor.set_cellv(cellPos+Vector2(-1, 0), 0)
					new.append(cellPos+Vector2(-1, 0))
					Floor.set_cellv(cellPos+Vector2(-1, -1), 0)
					new.append(cellPos+Vector2(-1, -1))
					Floor.set_cellv(cellPos+Vector2(0, -1), 0)
					new.append(cellPos+Vector2(0, -1))
				[Vector3(0, 1, 0), Vector3(-1,0,0) ]: #Down Left, none
					pass
				[Vector3(0, 1, 0), Vector3(1,0,0) ]: #Down Right, left
					Floor.set_cellv(cellPos+Vector2(-1, 0), 0)
					new.append(cellPos+Vector2(-1, 0))
	return new

#Connects all given points (validP) within the AStar (valids) by checking for adjacent locations
func connectPoints(validP):
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

#Places Walls around the already populated floors
func placeWallsAroundFloors(FloorCells):
	for cell in FloorCells:
		var u =cell + Vector2(0,1)
		var d = cell + Vector2(0,-1)
		var l = cell + Vector2(-1,0)
		var r =  cell + Vector2(1,0)
		var up =  Floor.get_cellv(u) == -1
		var down =  Floor.get_cellv(d) == -1
		var left =  Floor.get_cellv(l) == -1
		var right =  Floor.get_cellv(r) == -1
		
		if checkTileNotOnMap(d) and down:
			placeOrMerge(d, 27)
			placeOrMerge(d + Vector2(0,-1), 6)
		if checkTileNotOnMap(u) and up:
			placeOrMerge(cell, 6)
			placeOrMerge(u, 12)
		if checkTileNotOnMap(l) and left:
			placeOrMerge(l, 13)
		if checkTileNotOnMap(r) and right:
			placeOrMerge(r, 25)
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

#Updates the Obstacles variable (Includes prior made hallways after makeHalls is called)
func updateObstacles():
	var new = []
	for tileset in tiles.keys():
			var used = tileset.get_used_cells()
			for cell in used:
				var global_pos = Floor.world_to_map(tileset.map_to_world(cell) + tiles.get(tileset).global_position)
				obstacles[global_pos] = tileset
				new.append(global_pos)
	for tileset in [Floor, Walls]:
		var used = tileset.get_used_cells()
		for cell in used:
			obstacles[cell] = tileset
			new.append(cell)
	return new

#Updates the max_size variable to reflect the new room
func updateMaxsize():
	var mostPositive = Vector2(-1000, -1000)
	var mostNegative = Vector2(INF, INF)
	for room in Rooms.get_children():
		var roomRect : Rect2 = room.getRect2().grow(1024) #Grow by 32 tiles for hallways
		var start = roomRect.position
		var end = roomRect.end
		for point in [start, end]:
			if point.x > mostPositive.x:
				mostPositive.x = point.x
			if point.y > mostPositive.y:
				mostPositive.y = point.y
			if point.x < mostNegative.x:
				mostNegative.x = point.x
			if point.y < mostNegative.y:
				mostNegative.y = point.y
	var diff = (mostPositive - mostNegative) / 64 #32 for tiles, halfed to make it even
	diff.x = ceil(diff.x) * 4 #fix to make it even
	diff.y = ceil(diff.y) * 4 #fix to make it even
	if diff.x > diff.y:
		max_size = int(diff.x)
		return
	max_size = int(diff.y)
	return


func updateValids():
	updateObstacles()
	var neighborDoor = []
	for point in door_points:
		for cell in getNearby(point, 3):
			neighborDoor.append(cell)
	for cell in obstacles:
		var cellI = calculate_point_index(cell)
		var nearby = getNearby(cell, 4)
		if valids.has_point(cellI) and !door_points.has(cell) and !neighborDoor.has(cell):
			valids.remove_point(cellI)
		for ncell in nearby:
			var ncellI = calculate_point_index(ncell)
			if valids.has_point(ncellI) and !door_points.has(ncell) and !neighborDoor.has(ncell):
					valids.remove_point(ncellI)

#Does NOT update around max_size
func createValids(doorPositions):
	valids = MyAStar.new()
	var validP := [] #A list of all points in valids
	updateObstacles()
	populateValidsWithRange(0,0,max_size,max_size, validP)
	validP = forceAddDoorwayConnections(doorPositions, validP)
	connectPoints(validP)

#Creates Hallways between the placed Rooms
func makeHalls(path = null):
	var rooms := Rooms.get_children() #Each individual room
	var doorPositions := gatherDoorPositions(rooms) #We use a dicitonary so that we can have to position [key] and the owner room [value]
	if valids:
		updateValids()
	else:
		createValids(doorPositions)
	if !path:
		path = find_mst(doorPositions)
	var Paths = getPaths(valids, path) #calculate path between locations
	#place Floors
	var newFloors = placeFloorsOnPaths(Paths)
	placeWallsAroundFloors(newFloors)
#	testingAStar = valids

#Returns true if tile is already on map
func checkTileNotOnMap(TilePosition) -> bool:
	var valid = true
	for cell in obstacles:
		if TilePosition == cell:
			valid = false
	return valid

#Returns an array of neighboring cells within a 3x3 radius (including diagonals)
func getNearby(TilePosition, radius=3) -> Array:
	var result = []
	for x in range(-radius, radius):
		for y in range(-radius, radius):
			result.append(TilePosition+ Vector2(x,y))
	return result

#Returns true if there is not obstacle, false otherwise
func checkPlacementValid(TilePosition) -> bool:
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

#Point index formula
func calculate_point_index(point) -> int:
	return (max_size + point.x) + max_size * (max_size + point.y) 

#Returns true if point is outside of valid map
func is_out_map(point) -> bool:
	#Assumes in grid location
	return point.x < -(max_size / 2) or point.y < -(max_size / 2) or point.x >= (max_size/2) or point.y >= (max_size/2)

#returns an Array of Valid points for pathing
func populateValidsWithRange(startx, starty, endx, endy, validP):
	for y2 in range(starty, endy):
		var y = y2-(max_size/2)
		for x2 in range(startx, endx):
			var x = x2-(max_size/2)
			var point = Vector2(x, y)
			if !checkPlacementValid(point):
				continue
			var worldLoc = Floor.map_to_world(point)
			var point_index = calculate_point_index(point)
			valids.add_point(point_index, Vector3(worldLoc.x, worldLoc.y, 0.0))
			validP.append(point)

#Gathers position2d from rooms | Return structure {DoorPosition (Vector3) : room}
func gatherDoorPositions(rooms) -> Dictionary:
	var doorPositions := {}
	for room in rooms: #Get all door Positions
		var tiles = room.get_Tiles()
		#populate the tiles[] for later obstacle generation
		tiles[tiles[0]] = room
		tiles[tiles[1]] = room
		var doors = room.get_DoorPositions()
		for door in doors:
			doorPositions[Vector3(door.global_position.x, door.global_position.y, 0)] = room
	return doorPositions

#Forces addition of points to validP (which is returned), which are from the nearest valid point, into the door Position
func forceAddDoorwayConnections(doorPositions, currentValidP) -> Array:
	var validP = currentValidP
	for p in doorPositions.keys():
		var point = Floor.world_to_map(Vector2(p.x, p.y))
		var closest_I = valids.get_closest_point(p)
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
			door_points.append(newP)
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
			door_points.append(newP)
			valids.add_point(newP_I, Vector3(newP_W.x, newP_W.y, 0.0))
			directionVector.y -= direction
	return validP

#Returns an Array of Path arrays based on provided map and desired connections (path)
func getPaths(map, path) -> Array:
	var calculated = []
	var Paths = []
	for p in path.get_points():
			for c in path.get_point_connections(p):
				var s = map.get_point_position(map.get_closest_point(path.get_point_position(p)))
				var g = map.get_point_position(map.get_closest_point(path.get_point_position(c)))
				var start= Floor.world_to_map(Vector2(s.x, s.y))
				var goal = Floor.world_to_map(Vector2(g.x, g.y))
				var startIndex = calculate_point_index(start)
				var goalIndex = calculate_point_index(goal)
				if !(calculated.has([goalIndex, startIndex]) or calculated.has([startIndex, goalIndex])):
					Paths.append(map.get_point_path(startIndex, goalIndex))
					calculated.append([startIndex, goalIndex])
	return Paths

#Returns a merged value if there is one, otherwise null
func wallAddition(value1, value2) -> int:
	var newValue = wallConversions.get([value1, value2])
	if newValue == null:
		newValue = wallConversions.get([value2, value1])
	return newValue

#Finds the Minimum distance path and returns a new AStar with these connections
func find_mst(doors) -> AStar:
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
