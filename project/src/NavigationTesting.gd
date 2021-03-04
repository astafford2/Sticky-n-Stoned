extends Node2D


onready var player := $Player
onready var enemy := $BigDemon
onready var nav := $Navigation2D
onready var path_line := $Line2D


func _ready():
	pass


func _process(delta):
	var path = nav.get_simple_path(enemy.position, player.position)
	path_line.points = path
	enemy.path = path
