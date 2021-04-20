extends KinematicBody2D

class_name Mob

export var Health : int

var RUN_SPEED := 0
var Glued = false
var Target : KinematicBody2D = null
var spatter : Area2D = null
var healthPickup = preload("res://src/Pickups/HealthPickup.tscn")

onready var health_bar := $HealthBar


func _ready():
# warning-ignore:return_value_discarded
	SignalMaster.connect("attacked", self, "_on_self_damaged")


func _process(_delta):
	health_bar.set_current_health(Health)


func _on_self_damaged(thrower: KinematicBody2D, target: KinematicBody2D, damage: int):
	if target == self:
		damagedActivity(thrower, damage)


func damagedActivity(_thrower, _damage):
	pass


func kill_enemy():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	if rng.randi_range(1, 10) == 1:
		var pickup = healthPickup.instance()
		self.get_parent().get_parent().add_child(pickup)
	call_deferred("queue_free")
	if spatter:
		spatter.call_deferred("queue_free")
		
