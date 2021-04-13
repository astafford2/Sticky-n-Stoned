extends MarginContainer


func _ready():
	pass


func _on_ReplayButton_pressed():
	get_tree().reload_current_scene()
	get_tree().paused = false
