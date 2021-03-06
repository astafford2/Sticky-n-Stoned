extends Mob

class_name GreenSlime


var GlueSpatter = preload("res://src/projectiles/Enemy/GlueSpatter.tscn")

var glued := false
var velocity := Vector2()
var spatter : Area2D = null
var Foot1 = null
var feetArea = null
var managedPits = []
var room

onready var gs_sprite := $GSSprite
onready var glue_landing_fx := $GlueLanding
onready var Foot1S := $FallingBox/Foot
onready var DetectRadius := $DetectRadius

func _ready():
	room = self.get_parent().get_parent()
	RUN_SPEED = 105
	Health = 2
	health_bar.set_max_health(Health)
# warning-ignore:return_value_discarded
	SignalMaster.connect("overlapped", self, "_on_feet_overlapped")


func set_target(body):
	Target = body


func _process(_delta):
	gs_sprite.animation = "run" if velocity != Vector2.ZERO else "idle"
	gs_sprite.play()
	gs_sprite.flip_h = true if sign(velocity.x) == -1 else false
	
	if Health <= 0:
		kill_enemy()
	UpdateFooting()


func _physics_process(_delta):
	velocity = Vector2.ZERO
	if Target:
		velocity = global_position.direction_to(Target.global_position) * RUN_SPEED
	velocity = move_and_slide(velocity, Vector2.ZERO)


func glue(amount, time):
	if !glued:
		glued = true
		glue_landing_fx.play()
		spatter = GlueSpatter.instance()
		self.call_deferred("add_child", spatter)
		spatter.position += Vector2(0, 7)
		RUN_SPEED = RUN_SPEED-amount
		yield(get_tree().create_timer(time), "timeout")
		spatter.queue_free()
		RUN_SPEED = RUN_SPEED+amount
		glued=false


func damagedActivity(thrower, damage):
	Health -= damage
	Target = thrower


func UpdateFooting():
	Foot1 = Rect2(Foot1S.global_position - Foot1S.shape.extents, Foot1S.shape.extents * 2)
	feetArea = floor(Foot1.get_area())
	var totalArea := 0
	if managedPits.size() > 0:
		for pit in managedPits:
			var overlapArea := 0
			for foot in [Foot1]:
				overlapArea += foot.clip(pit).get_area()
			if overlapArea == 0:
					managedPits.erase(pit)
			totalArea += overlapArea
	if ceil(totalArea) >= feetArea:
		pitfalled()


func pitfalled():
	queue_free()


func kill_enemy():
	call_deferred("queue_free")
	if spatter:
		spatter.call_deferred("queue_free")


func _on_feet_overlapped(area, rect):
	if area == self:
		if !managedPits.has(rect):
			managedPits.append(rect)


func _on_DetectRadius_body_entered(body):
	if body.has_method("shoot") and room.started:
		Target = body


func _on_DetectRadius_body_exited(body):
	if body.has_method("shoot"):
		Target = null
