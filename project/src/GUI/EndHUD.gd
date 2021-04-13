extends MarginContainer


func _ready():
	pass


func _on_ReplayButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
	get_tree().paused = false
