extends Node2D


var dungeon_scene := "res://src/Rooms/Testing/BasicDungeon.tscn"


func _ready():
	pass


func _on_Play_pressed():
	var _ignored = get_tree().change_scene(dungeon_scene)
