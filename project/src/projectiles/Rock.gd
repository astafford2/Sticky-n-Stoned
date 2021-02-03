extends Area2D

var projectile = false
var interactable = false
var throwable = false
export var speed = 200
var currentbody = null

onready var interactionBox := $InteractionBox
onready var hurtBox := $Hurtbox


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _physics_process(delta):
	if interactable and Input.is_action_just_pressed("interact"):
		Interact(currentbody)
	elif projectile:
		position += transform.x * speed * delta
	elif throwable and Input.is_action_just_pressed("use_weapon"):
		Thrown()
	if !interactable and !projectile and throwable:
		self.rotation = self.get_parent().get_node("Muzzle").global_rotation

func Interact(body):
	self.get_parent().remove_child(self)
	body.add_child(self)
	position =  Vector2(0, 20)
	interactable = false
	throwable = true
	interactionBox.set_deferred("disabled", true)

func Thrown():
	projectile = true
	throwable = false
	var player = self.get_parent()
	player.remove_child(self)
	player.get_parent().add_child(self)
	position = player.get_position()
	hurtBox.set_deferred("disabled", false)

func HitsAndFalls():
	projectile = false
	interactable = true
	hurtBox.set_deferred("disabled", true)
	interactionBox.set_deferred("disabled", false)

func _on_body_entered(body):
	if projectile and !body.has_method("shoot"):
		if body.is_in_group("enemies"):
			body.enemy_hit(1)
		HitsAndFalls()
	elif !projectile and body.has_method("shoot"):
		currentbody = body
		interactable = true

func _on_body_exit():
	interactable = false
