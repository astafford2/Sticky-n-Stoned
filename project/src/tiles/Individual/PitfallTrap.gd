extends Traps


var rect : Rect2
var opened := false

onready var pit := $PitfallShape
onready var sprite := $Sprite


func _ready():
	rect = Rect2(pit.global_position - pit.shape.extents, pit.shape.extents * 2)


func activateActivity(_delta):
	if !opened:
		opened = true
		#Sprite plays
		sprite.animation = "Opening"
	var intersecting = get_overlapping_areas()
	if intersecting.size() > 0:
		for area in get_overlapping_areas():
			SignalMaster.overlapped(area.get_parent(), rect)

# what the child trap will do when deactivated or idle
func deactivateActivity(_delta):
	if opened:
		var intersecting = get_overlapping_areas()
		if intersecting.size() > 0:
			for area in get_overlapping_areas():
				SignalMaster.overlapped(area.get_parent(), rect)
