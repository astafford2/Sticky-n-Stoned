extends Area2D

var rect = null

onready var pit := $PitfallShape


func _ready():
	rect = Rect2(pit.global_position - pit.shape.extents, pit.shape.extents * 2)


func _process(_delta):
	var intersecting = get_overlapping_areas()
	if intersecting.size() > 0:
		for area in get_overlapping_areas():
			SignalMaster.overlapped(area.get_parent(), rect)
