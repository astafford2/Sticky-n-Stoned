extends KinematicBody2D


export (PackedScene) var tack

var attacking := false

onready var muzzle := $Muzzle


func _ready():
	attacking = true
	yield(get_tree().create_timer(1.4), "timeout")
	attacking = false


func _physics_process(_delta):
	if !attacking:
		attacking = true
		var t = tack.instance()
		t.init(self)
		owner.add_child(t)
		t.transform = muzzle.global_transform
#		fireball_shot_fx.play()
		yield(get_tree().create_timer(3), "timeout")
		attacking = false
