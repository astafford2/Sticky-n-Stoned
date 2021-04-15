extends Projectile


onready var interaction_box := $InteractionBox
onready var rock_hit_fx := $RockHitSfx

# Called when the node enters the scene tree for the first time.
func _ready():
	damage = 1
	self.add_to_group("inventoryItem")
	self.add_to_group("interactable")
	hurt_box.set_deferred("disabled", true)


func hitActivity(delta):
	position -= transform.x * speed * delta / 2
	sprite.rotation -= 20 * delta


func projectileActivity(delta):
	position += transform.x * speed * delta
	sprite.rotation += 50 * delta


func Interact(body):
	self.remove_from_group("interactable")
	thrower = body
	self.get_parent().remove_child(self)
	body.add_child(self)
	interaction_box.set_deferred("disabled", true)
	position =  Vector2(0, 20)


func Use():
	projectile = true
	var player = self.get_parent()
	player.remove_child(self)
	player.get_parent().add_child(self)
	position = player.get_position()
	hurt_box.set_deferred("disabled", false)
	return true #tells the player that the object is no longer in their inventory


func _on_hit_single_call():
	rock_hit_fx.play()
	hurt_box.set_deferred("disabled", true)
	yield(get_tree().create_timer(0.5), "timeout")
	interaction_box.set_deferred("disabled", false)
	hit = false
	self.add_to_group("interactable")
