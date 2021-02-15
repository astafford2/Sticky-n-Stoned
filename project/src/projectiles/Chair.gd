extends "res://src/projectiles/Projectile.gd"

export (PackedScene) var ChairLeg
export (PackedScene) var ChairPiece

var rng = RandomNumberGenerator.new()

var health : int = 2

onready var interactionBox := $InteractionBox


# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("inventoryItem")

func hitActivity(delta):
	health -=1
	add_to_group("interactable")
	HitsAndFalls()
	position -= transform.x * speed * delta / 2
	sprite.rotation -= 10 * delta

func projectileActivity(delta):
	position += transform.x * speed * delta
	sprite.rotation += 30 * delta

func _process(_delta):
	if health <= 0:
		var leg1 = ChairLeg.instance()
		var leg2 = ChairLeg.instance()
		var leg3 = ChairLeg.instance()
		var back = ChairPiece.instance()
		var pieces = [leg1, leg2, leg3, back]
		for piece in pieces:
			get_node("/root").add_child(piece)
			piece.transform = self.global_transform
			rng.randomize()
			piece.rotation = rng.randf_range(0.0, 360.0)
			piece.HitsAndFalls()
		queue_free()

func Interact(body):
	thrower = body
	self.get_parent().remove_child(self)
	body.add_child(self)
	position =  Vector2(0, 20)
	interactionBox.set_deferred("disabled", true)

func Use():
	remove_from_group("interactable")
	projectile = true
	var player = self.get_parent()
	player.remove_child(self)
	player.get_parent().add_child(self)
	position = player.get_position()
	hurtBox.set_deferred("disabled", false)
	return true #tells the player that the object is no longer in their inventory

func HitsAndFalls():
	hurtBox.set_deferred("disabled", true)
	yield(get_tree().create_timer(0.5), "timeout")
	interactionBox.set_deferred("disabled", false)
	hit = false
