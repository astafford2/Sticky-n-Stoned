extends Area2D

var projectile := false
var hit := false
var thrower : KinematicBody2D = null
var damage := 0
export var speed := 200

onready var hurtBox := $Hurtbox
onready var sprite := $Sprite


#All projectiles should have these functions
func _ready():
	pass


func _physics_process(delta):
	if projectile:
		self.add_to_group("projectile")
		projectileActivity(delta)
	elif hit:
		if self.is_in_group("projectile"):
			self.remove_from_group("projectile")
		hitActivity(delta)


func projectileActivity(_delta):
	pass


func hitActivity(_delta):
	pass


func _on_hit_single_call():
	pass


func _on_body_entered(body):
	if projectile and body != thrower:
		SignalMaster.attacked(thrower, body, damage)
		projectile = false
		hit = true
		thrower = null
		_on_hit_single_call()
