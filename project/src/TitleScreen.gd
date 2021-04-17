extends Node2D


var loading_scene := "res://src/Loading.tscn"


func _ready():
	pass


func _on_Play_pressed():
	var _ignored = get_tree().change_scene(loading_scene)
