extends TileMap


const Pit = preload("res://src/tiles/Pitfall.tscn")
const PitReturn = preload("res://src/tiles/PitReturn.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	var pitEdges = get_used_cells_by_id(2)
	var pits = get_used_cells_by_id(3)
	var validFooting = get_used_cells_by_id(0)
	instanceSceneAt(pitEdges, Pit)
	instanceSceneAt(pits, Pit)
	instanceSceneAt(validFooting, PitReturn)


func _physics_process(_delta):
	pass


func instanceSceneAt(cells: Array, scene):
	var tilePosition
	for tile in cells:
		var newScene = scene.instance()
		tilePosition = map_to_world(tile)
		newScene.set_position(tilePosition)
		self.add_child(newScene)
