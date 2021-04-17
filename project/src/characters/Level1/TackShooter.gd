extends KinematicBody2D


export (PackedScene) var tack

var attackCount :float= 1 -(1/14)
var room
var animStarted = false

onready var muzzle_t := $Muzzle_t
onready var muzzle_r := $Muzzle_r
onready var muzzle_l := $Muzzle_l
onready var muzzle_b := $Muzzle_b
onready var tack_shot_fx := $TackShot
onready var sprite := $TSSprite


func _ready():
	room = self.get_parent().get_parent()


func _physics_process(delta):
	if room.objective_complete:
		sprite.stop()
	if room.started and !room.objective_complete:
		if !animStarted:
			sprite.play()
			animStarted = true
		attackCount += delta
		if attackCount >= 1:
			attackCount -=1
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
			tt.global_position = muzzle_t.global_position
			tr.global_position = muzzle_r.global_position
			tl.global_position = muzzle_l.global_position
			tb.global_position = muzzle_b.global_position
			tack_shot_fx.play()
