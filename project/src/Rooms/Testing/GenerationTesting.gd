extends GenerationBase

#Rooms
onready var multiRoom := load("res://src/Rooms/Level 1/Multi-Room.tscn")
onready var SideSmallRoom := load("res://src/Rooms/Level 1/SideSmallRoom.tscn")
onready var BossRoom := load("res://src/Rooms/Level 1/Boss Room.tscn")
onready var DescentRoom := load("res://src/Rooms/Level 1/DescentRoom.tscn")
onready var LargeRoom := load("res://src/Rooms/Level 1/Large Room.tscn")
onready var MonsterRoom := load("res://src/Rooms/Level 1/Monster Room.tscn")
onready var SpawnRoom := load("res://src/Rooms/Level 1/SpawnRoom.tscn")

onready var Segment1 := load("res://src/Rooms/Testing/SegmentHelper1.tscn")
onready var Segment2 := load("res://src/Rooms/Testing/SegmentHelper2.tscn")


var ManualPaths = AStar.new()

onready var roomInfo = {
	#Room preload : [MinSpawn, MaxSpawn, Probability]
	#Rooms should be organized in order of centrality 
	#single door rooms are last while multi door rooms are first
#	SpawnRoom : [1,1,1],
#	multiRoom : [1, 4, 1], 
#	SideSmallRoom : [2, 3, 0.5],
#	#BossRoom : [1, 1, 1],
#	DescentRoom : [1, 1, 1],
#	MonsterRoom : [1, 3, 0.25], #Currently very loud
#	#LargeRoom : [1, 2, 0.75]
}

onready var testFan = {
	multiRoom: [1,4,1],
	Segment1: [1,1,1],
	SideSmallRoom : [1, 1, 1],
	Segment2: [1,1,1],
	MonsterRoom : [1, 3, 0.25]
}

onready var TwoDoors = [multiRoom, Segment1, Segment2, MonsterRoom]


# Called when the node enters the scene tree for the first time.
func _ready():
	wallConversions = {
		[13,6] : 21,
		[13,25] : [12,6],
		[12, 13] : [20,6],
		[12,25] : [16, 6],
		[13, 6] : 19,
		[25, 6] : 18,
		[9, 25] : [9,6],
		[9, 13] : [9,6]
	}
	rng.randomize()
	randomize()
	#var fan1 = generateFanRooms(SpawnRoom)
	#var fan2 = generateFanRooms(SpawnRoom, 7, -90, 90)
	var BossSegment = generateBossRooms(SpawnRoom, 3, 0)
	#moveAllSegments([fan1, fan2, BossSegment])
	#FanPathUpdates(fan1)
	#FanPathUpdates(fan2)
	BossPathUpdates(BossSegment)
	
	#spawnRooms(roomInfo)
	#moveRooms()
	updateMaxsize()
	makeHalls(ManualPaths)
	#ManualPaths = get_HubConnections([fan1, fan2, BossSegment])
	#makeHalls(ManualPaths)


#func _draw():
#	if valids:
#		for p in valids.get_points():
#			var pp = valids.get_point_position(p)
##			draw_line(Vector2(pp.x-1,pp.y-1), Vector2(pp.x+1,pp.y+1), Color(0,1,0), 30, true)
#			for c in valids.get_point_connections(p):
#				var cp = valids.get_point_position(c)
#				draw_line(Vector2(pp.x,pp.y), Vector2(cp.x, cp.y), Color(1,0,0), 5, true)

#Currently very inefficient. Fix later
func get_HubConnections(segments):
	var Hubs = []
	for segment in segments:
		Hubs.append(segment[0])
	var connections = AStar.new()
	var points = []
	for hub in Hubs:
		for door in hub.get_DoorPositions():
			var fixLoc = Floor.map_to_world(Floor.world_to_map(door.global_position))
			var pointI = calculate_point_index(Floor.world_to_map(door.global_position)) 
			if ManualPaths.has_point(pointI):
				continue
			points.append(fixLoc)
	for i in range(0, points.size()):
		for j in range(i, points.size()):
			if i==j:
				continue
			var point = points[i]
			var vec3Point = Vector3(point.x, point.y, 0)
			var pointI = calculate_point_index(Floor.world_to_map(point))
			var conpoint = points[j]
			var vec3conPoint = Vector3(conpoint.x, conpoint.y, 0)
			var conpointI = calculate_point_index(Floor.world_to_map(conpoint))
			if !connections.has_point(pointI):
				connections.add_point(pointI, vec3Point)
			if !connections.has_point(conpointI):
				connections.add_point(conpointI, vec3conPoint)
			connections.connect_points(pointI, conpointI)
	return connections


func moveAllSegments(segments):
	var avoidance = []
	for segment in segments:
		avoidance = moveSegment(segment[1], segment[0],  avoidance)


func moveSegment(rooms, HubInstance, avoidance = []):
	var dist = 16
	var valid = false
	var size: Rect2 = getSegmentRect(rooms, HubInstance)
	if avoidance.empty():
		avoidance.append(size)
		for room in rooms:
			room.updateFloors()
		return avoidance
	var movement = Vector2(0,0)
	while !valid:
		valid = true
		movement = Vector2(rng.randi_range(-dist, dist), rng.randi_range(-dist, dist))
		HubInstance.global_position += Floor.map_to_world(movement)
		for room in rooms:
			room.global_position += Floor.map_to_world(movement)
		size = getSegmentRect(rooms, HubInstance)
		for segmentRect in avoidance:
			if size.intersects(segmentRect):
				valid = false
				HubInstance.global_position -= Floor.map_to_world(movement)
				for room in rooms:
					room.global_position -= Floor.map_to_world(movement)
				break
		if valid:
			for room in rooms:
				room.updateFloors()
		dist += 16
	avoidance.append(size)
	return avoidance


func getSegmentRect(rooms, Hub):
	var mostNegative = Vector2(INF, INF)
	var mostPositive = Vector2(-9999999, -9999999)
	var allRooms = rooms.duplicate()
	allRooms.append(Hub)
	for room in allRooms:
		var roomRect : Rect2 = room.getRect2().grow(192)
		var start = roomRect.position
		var end = roomRect.end
		for point in [start,end]:
			if point.x < mostNegative.x:
				mostNegative.x = point.x
			if point.x > mostPositive.x:
				mostPositive.x = point.x
			if point.y < mostNegative.y:
				mostNegative.y = point.y
			if point.y > mostPositive.y:
				mostPositive.y = point.y
	var diff = mostPositive-mostNegative
	return Rect2(mostNegative.x, mostNegative.y, diff.x, diff.y)


func ConnectClosestDoorConnections(room1, room2, takenDoorLocations = []):
	var closestIn = null
	var closestOut = null
	var smallestDist = INF
	for door in room1.get_DoorPositions():
		if takenDoorLocations.has(door):
			continue
		for priorDoor in room2.get_DoorPositions():
			if takenDoorLocations.has(priorDoor):
				continue
			var distance = priorDoor.global_position.distance_to(door.global_position)
			if distance < smallestDist:
				closestIn = door
				closestOut = priorDoor
				smallestDist = distance
	if closestIn and closestOut:
		var inI = calculate_point_index(Floor.world_to_map(closestIn.global_position))
		var outI = calculate_point_index(Floor.world_to_map(closestOut.global_position))
		if !ManualPaths.has_point(inI):
			ManualPaths.add_point(inI, Vector3(closestIn.global_position.x, closestIn.global_position.y, 0))
		if !ManualPaths.has_point(outI):
			ManualPaths.add_point(outI, Vector3(closestOut.global_position.x, closestOut.global_position.y, 0))
		ManualPaths.connect_points(inI, outI)
		takenDoorLocations.append(closestIn)
		takenDoorLocations.append(closestOut)
	return takenDoorLocations


func getNewFanInfo(size):
	var specs = []
	var middle = floor(float(size)/2)
	for i in range (size):
		if i == middle:
			specs.append(SideSmallRoom)
			continue
		TwoDoors.shuffle()
		specs.append(TwoDoors[0])
	return specs


func FanPathUpdates(Fan):
	var Hub = Fan[0]
	var Rooms = Fan[1]
	var angle = 0
	var increment = -180/(Rooms.size()-1)
	var priorRoom = Hub
	var takenDoorLocations = []
	for roomInstance in Rooms:
		updateMaxsize()
		if angle ==-90 or angle == -180:
			takenDoorLocations = ConnectClosestDoorConnections(roomInstance, Hub, takenDoorLocations)
		takenDoorLocations = ConnectClosestDoorConnections(roomInstance, priorRoom, takenDoorLocations)
		priorRoom = roomInstance
		angle += increment


func generateFanRooms(Hub, size = 5, totalAngle = -180, startAngle = 0):
	var Specs = getNewFanInfo(size)
	var HubInstance = Hub.instance()
	Rooms.add_child(HubInstance)
	var increment : float= totalAngle/(Specs.size()-1)
	var angle : float= startAngle
	var hubBox: Rect2 =HubInstance.getRect2().grow(192)
	var currentTracked = [hubBox]
	var roomInstances = []
	#Moves Rooms to proper locations and update ManualPaths
	for room in Specs:
		var valid = false
		var roomInstance = room.instance()
		roomInstances.append(roomInstance)
		Rooms.add_child(roomInstance)
		var travelVector = Vector2(256 * cos(deg2rad(angle)), 256 * sin(deg2rad(angle)))
		while !valid:
			roomInstance.global_position += travelVector
			roomInstance.global_position = Floor.map_to_world(Floor.world_to_map(roomInstance.global_position))
			valid = true
			var roomRect = roomInstance.getRect2().grow(192)
			for taken in currentTracked:
				if roomRect.intersects(taken):
					valid = false
		#Generates Path connections between rooms
		angle += increment
		currentTracked.append(roomInstance.getRect2().grow(192))
	return [HubInstance, roomInstances]


func getNewBossInfo(size):
	var specs = []
	for i in range (size):
		if i == size-1:
			specs.append(BossRoom)
			continue
		TwoDoors.shuffle()
		specs.append(TwoDoors[0])
	return specs


func BossPathUpdates(Boss):
	var Hub = Boss[0]
	var Rooms = Boss[1]
	var priorRoom = Hub
	var takenDoorLocations = []
	for roomInstance in Rooms:
		updateMaxsize()
		takenDoorLocations = ConnectClosestDoorConnections(roomInstance, priorRoom, takenDoorLocations)
		priorRoom = roomInstance


func generateBossRooms(Hub, size = 5, angle= 0):
	var Specs = getNewBossInfo(size)
	var HubInstance = Hub.instance()
	Rooms.add_child(HubInstance)
	var hubBox: Rect2 =HubInstance.getRect2().grow(192)
	var currentTracked = [hubBox]
	var roomInstances = []
	#Moves Rooms to proper locations and update ManualPaths
	for room in Specs:
		var valid = false
		var roomInstance = room.instance()
		roomInstances.append(roomInstance)
		Rooms.add_child(roomInstance)
		var travelVector = Vector2(256 * cos(deg2rad(angle)), 256 * sin(deg2rad(angle)))
		while !valid:
			roomInstance.global_position += travelVector
			roomInstance.global_position = Floor.map_to_world(Floor.world_to_map(roomInstance.global_position))
			valid = true
			var roomRect = roomInstance.getRect2().grow(192)
			for taken in currentTracked:
				if roomRect.intersects(taken):
					valid = false
		#Generates Path connections between rooms
		currentTracked.append(roomInstance.getRect2().grow(192))
	return [HubInstance, roomInstances]
