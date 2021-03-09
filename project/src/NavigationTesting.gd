extends Node2D


var shaman_runto := Vector2()


onready var player := $Player
onready var nav_instance := $NavigationPolygonInstance
onready var enemy := $BigDemon
onready var shaman := $DemonShaman
onready var nav := $Navigation2D
onready var line := $Line2D


func _process(_delta):
#	for enemy in get_tree().get_nodes_in_group("enemies"):
#		enemy.set_navigation(nav_instance.navpoly, player)
	var shaman_to_player = Vector2(player.position.x - shaman.position.x, player.position.y - shaman.position.y)
	var shaman_runto = shaman.position - shaman_to_player
	var path = nav.get_simple_path(shaman.position, shaman_runto)
	line.points = path
