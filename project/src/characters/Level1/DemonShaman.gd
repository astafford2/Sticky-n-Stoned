extends Mob

export (PackedScene) var GlueSpatter
export (PackedScene) var fireball

var glued := false
var velocity := Vector2()
var spatter : Area2D = null
var canShoot := true
var flee := false
var attacking := false
var shaman_to_nav_target := Vector2()
var shaman_runto := Vector2()
var navpath := PoolVector2Array()

onready var ds_sprite := $DSSprite
onready var muzzle := $Muzzle
onready var glue_landing_fx := $GlueLanding
onready var fireball_shot_fx := $FireballShot
onready var nav := $Navigation2D
onready var nav_target : KinematicBody2D


func _ready():
	RUN_SPEED = 120
	Health = 4
	health_bar.set_max_health(Health)


func _process(_delta):
	if Health <= 0:
		kill_enemy()
	
	if nav_target:
		shaman_to_nav_target = Vector2(nav_target.position.x - self.position.x, nav_target.position.y - self.position.y)
		shaman_runto = self.position - shaman_to_nav_target
		navpath = nav.get_simple_path(self.position, shaman_runto)
		print("Player: " + str(nav_target.global_position))
		print(shaman_runto)


func _physics_process(_delta):
	velocity = Vector2.ZERO
	if Target:
		if flee:
			ds_sprite.animation = "walk"
#			velocity = -(position.direction_to(Target.position) * RUN_SPEED)
			pathfind()
		muzzle.look_at(Target.global_position)
		if canShoot:
			ds_sprite.animation = "shoot"
			attack()
	else:
		ds_sprite.animation = "idle"
	velocity = move_and_slide(velocity, Vector2.ZERO)


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
	navpath = nav.get_simple_path(self.position, shaman_runto)


func attack():
	if !attacking:
		attacking = true
		var f = fireball.instance()
		f.init(self)
		owner.add_child(f)
		f.transform = muzzle.global_transform
		fireball_shot_fx.play()
		yield(get_tree().create_timer(1.3), "timeout")
		attacking = false


func glue(amount, time):
	if !glued:
		glued = true
		glue_landing_fx.play()
		spatter = GlueSpatter.instance()
		self.call_deferred("add_child", spatter)
		spatter.position += Vector2(0, 4)
		RUN_SPEED = RUN_SPEED-amount
		yield(get_tree().create_timer(time), "timeout")
		spatter.queue_free()
		RUN_SPEED = RUN_SPEED+amount
		glued=false


func damagedActivity(thrower, damage):
	Health -= damage
	Target = thrower


func kill_enemy():
	call_deferred("queue_free")
	if spatter:
		spatter.call_deferred("queue_free")


func _on_DetectRadius_body_entered(body):
	if body.has_method("shoot"):
		Target = body


func _on_DetectRadius_body_exited(body):
	if body.has_method("shoot"):
		Target = null


func _on_FleeRange_body_entered(body):
	if body.has_method("shoot"):
		flee = true
		canShoot = false


func _on_FleeEdge_body_exited(body):
	if body.has_method("shoot"):
		flee = false
		canShoot = true
