extends Node2D


onready var player := $Player
onready var nav := $Navigation2D
onready var enemy := $BigDemon
onready var enemy2 := $BigDemon2
onready var line1 := $Line2D
onready var line2 := $Line2D2


func _process(_delta):
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.set_navigation(nav.get_simple_path(enemy.global_position, player.global_position))
