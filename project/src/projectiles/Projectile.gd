extends Area2D

var projectile = false
var hit = false
var thrower : KinematicBody2D = null
export var speed = 200

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
		self.remove_from_group("projectile")
		hitActivity(delta)

func projectileActivity(_delta):
	pass

func hitActivity(_delta):
	pass
