extends Projectile


onready var interactionBox := $InteractionBox
onready var sharp_rock_throw_fx := $SharpRockThrowSfx
onready var sharp_rock_hit_fx := $SharpRockHitSfx

# Called when the node enters the scene tree for the first time.
func _ready():
	damage = 3
	speed = 400
	self.add_to_group("inventoryItem")
	self.add_to_group("interactable")
	hurtBox.set_deferred("disabled", true)


func projectileActivity(delta):
	position += transform.x * speed * delta
	sprite.rotation += 50 * delta


func Interact(body):
	self.remove_from_group("interactable")
	thrower = body
	self.get_parent().remove_child(self)
	body.add_child(self)
	interactionBox.set_deferred("disabled", true)
	position =  Vector2(0, 20)


func Use():
	projectile = true
	var player = self.get_parent()
	player.remove_child(self)
	player.get_parent().add_child(self)
	position = player.get_position()
	hurtBox.set_deferred("disabled", false)
	sharp_rock_throw_fx.play()
	return true #tells the player that the object is no longer in their inventory


func _on_hit_single_call():
	sharp_rock_hit_fx.play()
	hurtBox.set_deferred("disabled", true)
	yield(get_tree().create_timer(0.5), "timeout")
	interactionBox.set_deferred("disabled", false)
	hit = false
	self.add_to_group("interactable")
	call_deferred("queue_free")
