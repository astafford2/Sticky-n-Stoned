extends Projectile


var t := 0.0
var p0 := Vector2()
var p1 := Vector2()
var p2 := Vector2()


onready var interactionBox := $InteractionBox


func _ready():
	damage = 3
	self.add_to_group("inventoryItem")
	self.add_to_group("interactable")
	hurtBox.set_deferred("disabled", true)


func _process(_delta):
	if t == 1:
		_on_body_entered(null)


#func hitActivity(delta):
#	position -= transform.x * speed * delta / 2


func projectileActivity(delta):
	t += delta/1.5
	t = clamp(t, 0, 1)
	position = _quadratic_bezier(p0, p1, p2, t)


func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	var r = q0.linear_interpolate(q1, t)
	return r


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
	p0 = self.global_position
	p1 = self.global_position+Vector2(140, -283)
	p2 = self.global_position+Vector2(290, 0)
	projectile = true
	player.remove_child(self)
	player.get_parent().add_child(self)
	position = player.get_position()
	return true #tells the player that the object is no longer in their inventory


func _on_hit_single_call():
	hurtBox.set_deferred("disabled", true)
	yield(get_tree().create_timer(0.5), "timeout")
	interactionBox.set_deferred("disabled", false)
	hit = false
	self.add_to_group("interactable")
