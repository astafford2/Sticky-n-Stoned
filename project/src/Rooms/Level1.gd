extends GenerationBase

#Rooms
onready var BossRoom := load("res://src/Rooms/Level 1/Boss Room.tscn")
onready var DescentRoom := load("res://src/Rooms/Level 1/DescentRoom.tscn")
onready var LargeRoom := load("res://src/Rooms/Level 1/Large Room.tscn")
onready var MonsterRoom := load("res://src/Rooms/Level 1/Monster Room.tscn")
onready var multi1Room := load("res://src/Rooms/Level 1/Multi-Room(pitfalls).tscn")
onready var multi2Room := load("res://src/Rooms/Level 1/Multi-Room(pitfalls)Variation.tscn")
onready var multi3Room := load("res://src/Rooms/Level 1/Multi-RoomVariation.tscn")
onready var multi4Room := load("res://src/Rooms/Level 1/Multi-Room.tscn")
onready var SideRoom := load("res://src/Rooms/Level 1/SideSmallRoom.tscn")
onready var SpawnRoom := load("res://src/Rooms/Level 1/SpawnRoom.tscn")
onready var BossGauntStart := load("res://src/Rooms/Level 1/BossGauntStart.tscn")

onready var DemonChambers1 := load("res://src/Rooms/Level 1/DemonChambers.tscn")
onready var DemonChambers2 := load("res://src/Rooms/Level 1/DemonChambers(AlternateEntrance).tscn")
onready var EasyPitRoom := load("res://src/Rooms/Level 1/EasierPitRoom.tscn")
onready var PitRoom := load("res://src/Rooms/Level 1/PitRoom.tscn")
#Room Groupings
onready var TwoDoors = [multi1Room, multi3Room, multi2Room, multi4Room, DemonChambers1, DemonChambers2, EasyPitRoom, PitRoom]


var ManualPaths = AStar.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	wallConversions = {
		[13,6] : 21,
		[13,25] : [12,6],
		[12, 13] : [20,6],
		[12,25] : [16, 6],
		[13, 6] : 19,
		[25, 6] : 18,
		[27, 25] : [27,6],
		[27, 13] : [27,6]
	}
	rng.randomize()
	randomize()
	var fan1 = generateFanRooms(SpawnRoom)
	var fan2 = generateFanRooms(SpawnRoom)

	var BossSegment = generateBossRooms(BossGauntStart, 3, 0)
	moveAllSegments([fan1, fan2, BossSegment])
	FanPathUpdates(fan1)
	FanPathUpdates(fan2)
	BossPathUpdates(BossSegment)
	
	#spawnRooms(roomInfo)
	#moveRooms()
	updateMaxsize()
	makeHalls(ManualPaths)
	ManualPaths = connectHubs([fan1, fan2, BossSegment])
	for room in Rooms.get_children():
		if room.has_method("setEnemyTargets"):
			room.setEnemyTargets()


func _process(_delta):
	if Input.is_action_just_pressed("pause_game"):
		get_tree().paused = true
		position_hud(pause_menu)
		pause_menu.show()
	if Input.is_action_pressed("cheat_kill"):
		if Input.is_action_just_pressed("kill_enemies"):
			for enemy in get_tree().get_nodes_in_group("enemies"):
				enemy.kill_enemy()


#func _draw():
#	if ManualPaths:
#		for p in ManualPaths.get_points():
#			var pp = ManualPaths.get_point_position(p)
#			draw_line(Vector2(pp.x-1,pp.y-1), Vector2(pp.x+1,pp.y+1), Color(0,1,0), 30, true)
#			for c in ManualPaths.get_point_connections(p):
#				var cp = ManualPaths.get_point_position(c)
#				draw_line(Vector2(pp.x,pp.y), Vector2(cp.x, cp.y), Color(1,0,0), 5, true)


func connectHubs(segments):
	var portals := {} #Structured | hubPos : Teleporters
	var hubPositions = []
	for segment in segments:
		var hubPos = segment[0].global_position
		var hubPos3 = Vector3(hubPos.x, hubPos.y, 0)
		hubPositions.append(hubPos3)
		portals[hubPos3] = segment[0].getTeleporters()
	#Retrieved All Portals
	var connections = find_hubMST(hubPositions)
	var established = []
	for p in connections.get_points():
		var startPortals = portals[connections.get_point_position(p)]
		for c in connections.get_point_connections(p):
			var endPortals = portals[connections.get_point_position(c)]
			if !established.has([startPortals, endPortals]) and !established.has([endPortals, startPortals]):
				established.append([startPortals, endPortals])
				startPortals.pop_front().doubleLinkPortals(endPortals.pop_front())
	for hub in portals.keys():
		for leftPortals in portals[hub]:
			leftPortals.queue_free()
	return connections


func find_hubMST(HubPositions):
	var Mpath = AStar.new()
	var positions = HubPositions
	Mpath.add_point(Mpath.get_available_point_id(), positions.pop_front())
	
	while positions:
		var min_dist = INF
		var min_p = null
		var p = null
		for p1 in Mpath.get_points():
			p1 = Mpath.get_point_position(p1)
			for p2 in positions:
				if p1.distance_to(p2) < min_dist:
					min_dist = p1.distance_to(p2)
					min_p = p2
					p = p1
		var n = Mpath.get_available_point_id()
		Mpath.add_point(n, min_p)
		Mpath.connect_points(Mpath.get_closest_point(p), n)
		positions.erase(min_p)
	return Mpath

#Currently very inefficient. Fix later
func oldConnectHubs(segments):
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
	#At this point, points holds all of the door locations that are known to be available
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
			specs.append(SideRoom)
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
		if i == size-2:
			specs.append(BossRoom)
			continue
		if i == size-1:
			specs.append(DescentRoom)
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
