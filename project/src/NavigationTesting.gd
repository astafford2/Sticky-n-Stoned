extends Node2D


onready var player := $Player
onready var nav_instance := $NavigationPolygonInstance
onready var enemy := $BigDemon
onready var enemy2 := $BigDemon2


func _process(_delta):
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.set_navigation(nav_instance.navpoly, player)
