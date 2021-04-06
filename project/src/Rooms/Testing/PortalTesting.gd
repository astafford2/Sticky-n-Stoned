extends Node2D

onready var portal1 = $Teleporter
onready var portal2 = $Teleporter2

# Called when the node enters the scene tree for the first time.
func _ready():
	portal1.linkToPortal(portal2)
	portal2.linkToPortal(portal1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
