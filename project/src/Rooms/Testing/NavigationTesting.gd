extends Node2D


var shaman_runto := Vector2()


onready var player := $Player
onready var nav_instance := $NavigationPolygonInstance
onready var trapdoor := $Trapdoor
onready var shaman := $Enemies/DemonShaman
onready var demon := $Enemies/BigDemon
onready var path := $Line2D


func _ready():
#	var multi_poly = Geometry.merge_polygons_2d(nav_instance.navpoly.get_vertices(), trapdoor.navpoly.get_vertices())
#	nav_instance.navpoly.clear_polygons()
#	nav_instance.navpoly.clear_outlines()
#	nav_instance.navpoly.add_polygon(multi_poly)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("set_navigation"):
			enemy.set_navigation(nav_instance.navpoly, player)


func _process(delta):
	path.points = shaman.navpath
