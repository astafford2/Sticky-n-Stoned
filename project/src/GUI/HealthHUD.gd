extends MarginContainer


onready var hearts_hbox = $Hearts

var heart_full = preload("res://assets/GUI/ui_heart_full.png")
var heart_half = preload("res://assets/GUI/ui_heart_half.png")
var heart_empty = preload("res://assets/GUI/ui_heart_empty.png")


func update_health(health_value):
	for h in hearts_hbox.get_child_count():
		if health_value > h * 2 + 1:
			hearts_hbox.get_child(h).texture = heart_full
		elif health_value > h * 2:
			hearts_hbox.get_child(h).texture = heart_half
		else:
			hearts_hbox.get_child(h).texture = heart_empty
