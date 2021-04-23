extends Node2D


var main_menu_scene := "res://src/TitleScreen.tscn"
var loading_scene := "res://src/Loading.tscn"


func _ready():
	pass


func _on_ReplayButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene(loading_scene)


func _on_MainMenuButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene(main_menu_scene)
