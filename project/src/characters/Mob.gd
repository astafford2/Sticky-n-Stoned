extends KinematicBody2D

export var Health : int

var RUN_SPEED := 0
var Glued = false
var Target : KinematicBody2D = null


func _ready():
# warning-ignore:return_value_discarded
	SignalMaster.connect("attacked", self, "_on_self_damaged")
	pass


func _on_self_damaged(thrower: KinematicBody2D, target: KinematicBody2D, damage: int):
	if target == self:
		damagedActivity(thrower, damage)


func damagedActivity(_thrower, _damage):
	pass
