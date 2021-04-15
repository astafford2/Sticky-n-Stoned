extends Projectile


var time_along_arc := 0.0
var point0 := Vector2()
var point1 := Vector2()
var point2 := Vector2()
var land := false


onready var interaction_box := $InteractionBox
onready var anim_player := $AnimationPlayer
onready var big_rock_fx := $BigRockHitSfx
onready var AOE := $AOE
onready var AOE_box := $AOE/AOEbox
onready var AOE_splash := $AOESplash


func _ready():
	damage = 3
	speed = 100
	self.add_to_group("inventoryItem")
	self.add_to_group("interactable")
	hurt_box.set_deferred("disabled", true)


func _process(_delta):
	if time_along_arc == 1:
		land = true
		AOE_splash.visible = true
		AOE_splash.play("splash")
		AOE_box.set_deferred("disabled", false)
		if !hit: # if AOE area detects no bodies, hit = false, _on_hit.. is not called
			hit = true
			_on_hit_single_call()
		yield(get_tree().create_timer(0.5),"timeout")
		AOE_box.set_deferred("disabled", true)
		AOE_splash.visible = false
		AOE_splash.stop()
		projectile = false
		time_along_arc = 0.0
		thrower = null
		


#func hitActivity(delta):
#	position -= transform.x * speed * delta / 2


func projectileActivity(delta):
	# updates t to move rock along interpolated curve
	# clamp t to 1 so rock does not move past level
	time_along_arc += delta/2
	time_along_arc = clamp(time_along_arc, 0, 1)
	position = _quadratic_bezier(point0, point1, point2, time_along_arc)


func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	# https://docs.godotengine.org/en/stable/tutorials/math/beziers_and_curves.html#curve2d-curve3d-path-and-path2d
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	var r = q0.linear_interpolate(q1, t)
	return r


func get_curve_distance(muzzle_angle):
	# adjusts distance for curve depending on muzzle angle
	# throwing staight up/down will produce shallow/no curve versus right/left producing noticable curve
	var temp_angle = rad2deg(muzzle_angle)
	temp_angle = abs(temp_angle)
	var dist = ((90 - temp_angle) / 90) * 100
	if temp_angle > 90:
		dist = ((temp_angle - 90) / 90) * 100
	
	return dist


func Interact(body):
	self.remove_from_group("interactable")
	thrower = body
	self.get_parent().remove_child(self)
	body.add_child(self)
	interaction_box.set_deferred("disabled", true)
	position =  Vector2(0, 20)


func Use():
	time_along_arc = 0.0
	var player = self.get_parent()
	var muzzle_angle = player.muzzle.global_rotation
	point0 = self.global_position
	point2 = Vector2(point0.x + (290 * cos(muzzle_angle)), point0.y + (290 * sin(muzzle_angle)))
	point1 = Vector2(point0.x + (145 * cos(muzzle_angle)), point0.y + (145 * sin(muzzle_angle))) # gets middle of curve at ground level
	var dist = get_curve_distance(muzzle_angle)
	# updates middle point with calculated distance for interpolation
	point1 = Vector2(point1.x + (dist * -abs(cos(muzzle_angle - (PI/2)))), point1.y + (dist * -abs(sin(muzzle_angle - (PI/2)))))
	
	projectile = true
	player.remove_child(self)
	player.get_parent().add_child(self)
	position = player.get_position()
	rotation = 0
	anim_player.play("arcThrow")
	AOE_splash.frame = 0
#	hurtBox.set_deferred("disabled", false)
	return true #tells the player that the object is no longer in their inventory


func _on_hit_single_call():
	big_rock_fx.play()
	hurt_box.set_deferred("disabled", true)
	yield(get_tree().create_timer(0.5), "timeout")
	interaction_box.set_deferred("disabled", false)
	hit = false
	self.add_to_group("interactable")


func _on_AnimationPlayer_animation_finished(_anim_name):
#	_on_body_entered(null)
	pass


func _on_AOE_body_entered(body): # with new shape, will someimes not hit anything with collison (only floor) so won't continue
	if projectile and body != thrower:
		SignalMaster.attacked(thrower, body, damage)
#		projectile = false
		hit = true
#		thrower = null
		_on_hit_single_call()
