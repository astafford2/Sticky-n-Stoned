extends Mob

class_name GreenSlime


var foot1 = null
var feet_area = null
var managed_pits = []
var room

onready var gs_sprite := $GSSprite
onready var glue_landing_fx := $GlueLanding
onready var foot1S := $FallingBox/Foot

func _ready():
	room = self.get_parent().get_parent()
	RUN_SPEED = 105
	Health = 2
	health_bar.set_max_health(Health)
# warning-ignore:return_value_discarded
	SignalMaster.connect("overlapped", self, "_on_feet_overlapped")


func set_target(body):
	target = body


func _process(_delta):
	gs_sprite.animation = "run" if velocity != Vector2.ZERO else "idle"
	gs_sprite.play()
	gs_sprite.flip_h = true if sign(velocity.x) == -1 else false
	
	if Health <= 0:
		kill_enemy()
	UpdateFooting()


func _physics_process(_delta):
	velocity = Vector2.ZERO
	if target:
		velocity = global_position.direction_to(target.global_position) * RUN_SPEED
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
	target = thrower


func UpdateFooting():
	foot1 = Rect2(foot1S.global_position - foot1S.shape.extents, foot1S.shape.extents * 2)
	feet_area = floor(foot1.get_area())
	var total_area := 0
	if managed_pits.size() > 0:
		for pit in managed_pits:
			var overlap_area := 0
			for foot in [foot1]:
				overlap_area += foot.clip(pit).get_area()
			if overlap_area == 0:
					managed_pits.erase(pit)
			total_area += overlap_area
	if ceil(total_area) >= feet_area:
		pitfalled()


func pitfalled():
	queue_free()


func _on_feet_overlapped(area, rect):
	if area == self:
		if !managed_pits.has(rect):
			managed_pits.append(rect)


func _on_DetectRadius_body_entered(body):
	if body.has_method("shoot") and room.started:
		target = body


func _on_DetectRadius_body_exited(body):
	if body.has_method("shoot"):
		target = null
