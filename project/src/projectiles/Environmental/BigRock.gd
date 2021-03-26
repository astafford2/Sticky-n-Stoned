extends Projectile


var t := 0.0
var p0 := Vector2()
var p1 := Vector2()
var p2 := Vector2()


onready var interactionBox := $InteractionBox
onready var animPlayer := $AnimationPlayer
onready var big_rock_fx := $BigRockHitSfx
onready var AOE := $AOE
onready var AOEbox := $AOE/AOEbox
onready var AOESplash := $AOESplash


func _ready():
	damage = 3
	speed = 100
	self.add_to_group("inventoryItem")
	self.add_to_group("interactable")
	hurtBox.set_deferred("disabled", true)


func _process(_delta):
	if t == 1:
		AOESplash.visible = true
		AOESplash.play("splash")
		AOEbox.set_deferred("disabled", false)
		yield(get_tree().create_timer(1.4),"timeout")
		AOEbox.set_deferred("disabled", true)
		AOESplash.visible = false
		projectile = false
		thrower = null


#func hitActivity(delta):
#	position -= transform.x * speed * delta / 2


func projectileActivity(delta):
#	position += transform.x * speed * delta
	t += delta/2
	t = clamp(t, 0, 1)
	position = _quadratic_bezier(p0, p1, p2, t)
	animPlayer.play("arcThrow")


func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	var r = q0.linear_interpolate(q1, t)
	return r


func get_curve_points(muzzle_angle):
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
	interactionBox.set_deferred("disabled", true)
	position =  Vector2(0, 20)


func Use():
	t = 0.0
	var player = self.get_parent()
	var muzzle_angle = player.muzzle.global_rotation
	p0 = self.global_position
	p2 = Vector2(p0.x + (290 * cos(muzzle_angle)), p0.y + (290 * sin(muzzle_angle)))
	p1 = Vector2(p0.x + (145 * cos(muzzle_angle)), p0.y + (145 * sin(muzzle_angle)))
	var dist = get_curve_points(muzzle_angle)
	p1 = Vector2(p1.x + (dist * -abs(cos(muzzle_angle - (PI/2)))), p1.y + (dist * -abs(sin(muzzle_angle - (PI/2)))))
	projectile = true
	player.remove_child(self)
	player.get_parent().add_child(self)
	position = player.get_position()
	rotation = 0
#	hurtBox.set_deferred("disabled", false)
	return true #tells the player that the object is no longer in their inventory


func _on_hit_single_call():
	big_rock_fx.play()
	hurtBox.set_deferred("disabled", true)
	yield(get_tree().create_timer(0.5), "timeout")
	interactionBox.set_deferred("disabled", false)
	hit = false
	self.add_to_group("interactable")


func _on_AnimationPlayer_animation_finished(_anim_name):
#	_on_body_entered(null)
	pass


func _on_AOE_body_entered(body):
	if projectile and body != thrower:
		SignalMaster.attacked(thrower, body, damage)
#		projectile = false
		hit = true
#		thrower = null
		_on_hit_single_call()
