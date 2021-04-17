extends TileMap

const Pit = preload("res://src/tiles/Individual/Pitfall.tscn")
const PitReturn = preload("res://src/tiles/Individual/PitReturn.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	instanceTiles()
	pass


func instanceTiles():
	var pit_edges = get_used_cells_by_id(2)
	var pits = get_used_cells_by_id(3)
	var valid_footing = get_used_cells_by_id(0)
	instanceSceneAt(pit_edges, Pit)
	instanceSceneAt(pits, Pit)
	instanceSceneAt(valid_footing, PitReturn)


func _physics_process(_delta):
	pass


func instanceSceneAt(cells: Array, scene):
	var tile_position
	for tile in cells:
		var new_scene = scene.instance()
		tile_position = map_to_world(tile)
		new_scene.set_position(tile_position)
		self.add_child(new_scene)
