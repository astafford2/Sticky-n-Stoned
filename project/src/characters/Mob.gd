extends KinematicBody2D

class_name Mob

export var Health : int

var RUN_SPEED := 0
var Glued = false
var Target : KinematicBody2D = null

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalMaster.connect("attacked", self, "_on_self_damaged")
	pass


func _on_self_damaged(thrower: KinematicBody2D, target: KinematicBody2D, damage: int):
	if target == self:
		damagedActivity(thrower, damage)

func damagedActivity(_thrower, _damage):
	pass
