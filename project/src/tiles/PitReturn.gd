extends Area2D


func _ready():
	pass


func _on_PitReturn_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	if area:
		SignalMaster.enteredValidTile(area.get_owner(), self)
