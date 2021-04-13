extends Node2D


var dungeon_scene := "res://src/Rooms/Level1.tscn"


func _ready():
	pass


func _on_Play_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene(dungeon_scene)
