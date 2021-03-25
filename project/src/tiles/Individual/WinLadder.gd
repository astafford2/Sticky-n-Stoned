extends Node2D


const win_hud = preload("res://src/GUI/WinHUD.tscn")

func _ready():
	pass


func _on_Area2D_body_entered(body):
	if body.has_method("shoot"):
		var wh = win_hud.instance()
		get_parent().add_child(wh)
