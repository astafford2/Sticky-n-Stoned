extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var projectile = false
var interactable = false
export var speed = 200
var player = null


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _physics_process(delta):
	if interactable and Input.is_action_just_pressed("interact"):
		Interact(player)
	if projectile:
		position += transform.x * speed * delta
		rotation += delta * 1.1

func Interact(body):
	owner.remove_child(self)
	body.add_child(self)
	position = Vector2(0, 20)
	interactable = false

func Thrown():
	projectile = true
	$Hurtbox.disabled = false

func HitsAndFalls():
	projectile = false
	$Hurtbox.disabled = true
	$InteractionBox.disabled = false

func _on_body_entered(body):
	if projectile and !body.has_method("shoot"):
		body.free_queue()
		HitsAndFalls()
	elif !projectile and body.has_method("shoot"):
		interactable = true
		player = body
func _on_body_exit():
	interactable = false
