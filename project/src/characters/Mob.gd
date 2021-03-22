extends KinematicBody2D

class_name Mob

export var Health : int

var RUN_SPEED := 0
var Glued = false
var Target : KinematicBody2D = null

onready var health_bar := $HealthBar


func _ready():
# warning-ignore:return_value_discarded
	SignalMaster.connect("attacked", self, "_on_self_damaged")
	pass


func _process(_delta):
	health_bar.set_current_health(Health)


func _on_self_damaged(thrower: KinematicBody2D, target: KinematicBody2D, damage: int):
	if target == self:
		damagedActivity(thrower, damage)


func damagedActivity(_thrower, _damage):
	pass
