extends Mob

export (PackedScene) var GlueSpatter

var glued := false
var velocity := Vector2()
var spatter : Area2D = null
var Foot1 = null
var Foot2 = null
var feetArea = null
var managedPits = []
var navpath := PoolVector2Array()
var demon_runto := Vector2()

onready var bd_sprite := $BDSprite
onready var glue_landing_fx := $GlueLanding
onready var Foot1S := $FallingBox/Foot1
onready var Foot2S := $FallingBox/Foot2
onready var nav := $Navigation2D
onready var nav_target : KinematicBody2D

func _ready():
	RUN_SPEED = 110
	Health = 6
	health_bar.set_max_health(Health)
# warning-ignore:return_value_discarded
	SignalMaster.connect("overlapped", self, "_on_feet_overlapped")


func _process(_delta):
	bd_sprite.animation = "run" if velocity != Vector2.ZERO else "idle"
	bd_sprite.play()
	bd_sprite.flip_h = true if sign(velocity.x) == -1 else false
	
	if Health <= 0:
		kill_enemy()
	UpdateFooting()
	
	if nav_target:
		navpath = nav.get_simple_path(self.global_position, get_parent().to_local(nav_target.global_position))
#		print(navpath)
#		print("Player: " + str(nav_target.global_position))
#		print("Player2: " + str(get_parent().get_parent().get_parent().get_parent().get_node("Player").global_position))
		get_parent().get_parent().get_node("Line2D").points = navpath


func _physics_process(_delta):
	velocity = Vector2.ZERO
	if Target:
#		velocity = global_position.direction_to(Target.global_position) * RUN_SPEED
		pathfind()
#	velocity = move_and_slide(velocity, Vector2.ZERO)


func pathfind():
	# Calculate movement distance for current frame
	# Does not multiply delta as move_and_slide does that itself
	var distance_to_walk = RUN_SPEED
	
	# Move enemy along path until run out of movement or path ends
	while distance_to_walk > 0 and navpath.size() > 0:
		var distance_to_next_point = position.distance_to(navpath[0])
		if distance_to_walk <= distance_to_next_point:
			# Enemy does not have enough movement left to get to next point
#			position += position.direction_to(path[0]) * distance_to_walk
			velocity = move_and_slide(position.direction_to(navpath[0])*distance_to_walk, Vector2.ZERO)
		else:
			# enemy gets to next point
			velocity = move_and_slide(position.direction_to(navpath[0])*distance_to_walk, Vector2.ZERO)
			navpath.remove(0)
		# Update distance to walk
		distance_to_walk -= distance_to_next_point


func set_navigation(nav_poly, target):
	nav.navpoly_add(nav_poly, Transform2D.IDENTITY)
	nav_target = target
	navpath = nav.get_simple_path(self.global_position, get_parent().to_local(nav_target.global_position))

func glue(amount, time):
	if !glued:
		glued = true
		glue_landing_fx.play()
		spatter = GlueSpatter.instance()
		self.call_deferred("add_child", spatter)
		spatter.position += Vector2(0, 5)
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
	Foot2 = Rect2(Foot2S.global_position - Foot2S.shape.extents, Foot2S.shape.extents * 2)
	feetArea = floor(Foot1.get_area() + Foot2.get_area())
	var totalArea := 0
	if managedPits.size() > 0:
		for pit in managedPits:
			var overlapArea := 0
			for foot in [Foot1, Foot2]:
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
	if body.has_method("shoot"):
		Target = body


func _on_DetectRadius_body_exited(body):
	if body.has_method("shoot"):
		Target = null
