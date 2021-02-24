extends Traps


var rect : Rect2

onready var pit := $PitfallShape


func _ready():
	rect = Rect2(pit.global_position - pit.shape.extents, pit.shape.extents * 2)


func activate(_delta):
	var intersecting = get_overlapping_areas()
	if intersecting.size() > 0:
		for area in get_overlapping_areas():
			SignalMaster.overlapped(area.get_parent(), rect)

# what the child trap will do when deactivated or idle
func deactivated(_delta):
	pass
