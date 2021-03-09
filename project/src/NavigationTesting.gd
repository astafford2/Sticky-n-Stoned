extends Node2D


var shaman_runto := Vector2()


onready var player := $Player
onready var nav_instance := $NavigationPolygonInstance
onready var enemy := $BigDemon
onready var shaman := $DemonShaman
onready var path := $Line2D


func _ready():
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.set_navigation(nav_instance.navpoly, player)


func _process(delta):
	path.points = shaman.navpath
