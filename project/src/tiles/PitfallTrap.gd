extends Traps


var rect : Rect2

onready var pit := $PitfallShape
onready var open := $Open
onready var closed := $Closed


func _ready():
	rect = Rect2(pit.global_position - pit.shape.extents, pit.shape.extents * 2)
	activated = true


func activate(_delta):
	closed.visible = false
	open.visible = true
	var intersecting = get_overlapping_areas()
	if intersecting.size() > 0:
		for area in get_overlapping_areas():
			SignalMaster.overlapped(area.get_parent(), rect)

# what the child trap will do when deactivated or idle
func deactivated(_delta):
	closed.visible = true
	open.visible = false
