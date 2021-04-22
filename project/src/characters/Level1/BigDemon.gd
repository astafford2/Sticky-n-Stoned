extends Mob

var feet_area = null
var managed_pits = []
var nav_path := PoolVector2Array()
var room

onready var bd_sprite := $BDSprite
onready var glue_landing_fx := $GlueLanding
onready var foot1S := $FallingBox/Foot1
onready var foot2S := $FallingBox/Foot2
onready var nav := $Navigation2D

func _ready():
	RUN_SPEED = 110
	Health = 6
	health_bar.set_max_health(Health)
# warning-ignore:return_value_discarded
	SignalMaster.connect("overlapped", self, "_on_feet_overlapped")
	room = self.get_parent().get_parent()


func _process(_delta):
	bd_sprite.animation = "run" if velocity != Vector2.ZERO else "idle"
	bd_sprite.play()
	bd_sprite.flip_h = true if sign(velocity.x) == -1 else false
	
	if Health <= 0:
		kill_enemy()
	UpdateFooting()
	
	if target and room.started:
		var correctTargetPos = target.global_position - room.global_position
		nav_path = nav.get_simple_path(self.position, correctTargetPos)


func _physics_process(_delta):
	velocity = Vector2.ZERO
	if target:
		pathfind()


func pathfind():
	# Calculate movement distance for current frame
	# Does not multiply delta as move_and_slide does that itself
	var distance_to_walk = RUN_SPEED
	
	# Move enemy along path until run out of movement or path ends
	while distance_to_walk > 0 and nav_path.size() > 0:
		var distance_to_next_point = position.distance_to(nav_path[0])
		if distance_to_walk <= distance_to_next_point:
			# Enemy does not have enough movement left to get to next point
#			position += position.direction_to(path[0]) * distance_to_walk
			velocity = move_and_slide(position.direction_to(nav_path[0])*distance_to_walk, Vector2.ZERO)
		else:
			# enemy gets to next point
			velocity = move_and_slide(position.direction_to(nav_path[0])*distance_to_walk, Vector2.ZERO)
			nav_path.remove(0)
		# Update distance to walk
		distance_to_walk -= distance_to_next_point


func set_navPoly(nav_poly):
	nav.navpoly_add(nav_poly, Transform2D.IDENTITY)


func set_target(target):
	target = target
	var correctTargetPos = target.global_position - room.global_position
	nav_path = nav.get_simple_path(self.position, correctTargetPos)


func set_navigation(nav_poly, target):
	nav.navpoly_add(nav_poly, Transform2D.IDENTITY)
	target = target
	nav_path = nav.get_simple_path(self.global_position, get_parent().to_local(target.global_position))


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
	target = thrower


func UpdateFooting():
	if managed_pits:
		var foot1 = Rect2(foot1S.global_position - foot1S.shape.extents, foot1S.shape.extents * 2)
		var foot2 = Rect2(foot2S.global_position - foot2S.shape.extents, foot2S.shape.extents * 2)
		feet_area = floor(foot1.get_area() + foot2.get_area())
		var total_area := 0
		if managed_pits.size() > 0:
			for pit in managed_pits:
				var overlap_area := 0
				for foot in [foot1, foot2]:
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
	if body.has_method("shoot"):
		target = body


func _on_DetectRadius_body_exited(body):
	if body.has_method("shoot"):
		target = null
