extends KinematicBody2D


export (PackedScene) var tack

var attacking := false

onready var muzzle_t := $Muzzle_t
onready var muzzle_r := $Muzzle_r
onready var muzzle_l := $Muzzle_l
onready var muzzle_b := $Muzzle_b
onready var tack_shot_fx := $TackShot


func _physics_process(_delta):
	if !attacking:
		attacking = true
		var tt = tack.instance()
		var tr = tack.instance()
		var tl = tack.instance()
		var tb = tack.instance()
		tt.init(self)
		tr.init(self)
		tl.init(self)
		tb.init(self)
		owner.add_child(tt)
		owner.add_child(tr)
		owner.add_child(tl)
		owner.add_child(tb)
		tt.transform = muzzle_t.global_transform
		tr.transform = muzzle_r.global_transform
		tl.transform = muzzle_l.global_transform
		tb.transform = muzzle_b.global_transform
		tack_shot_fx.play()
		yield(get_tree().create_timer(1), "timeout")
		attacking = false
