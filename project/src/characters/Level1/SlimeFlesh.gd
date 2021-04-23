extends GreenSlime


var slime_flesh_target : KinematicBody2D = null

onready var detect_radius_shape := $DetectRadius/DetectShape


func _ready():
	RUN_SPEED = 75
	Health = 1
	slime_sound.stream = load("res://assets/Audio/Plop.wav")
	set_collision_layer_bit(2, true)
	set_collision_mask_bit(0, false)
	slime_flesh_target = get_parent().get_node("Enemies").get_node("KingSlime")
	detect_radius_shape.get_shape().radius = 10
	remove_from_group("enemies")
	add_to_group("slimeFleshes")
	add_to_group("interactable")


func Interact(_body):
	queue_free()
	

func _physics_process(_delta):
	velocity = Vector2.ZERO
	if slime_flesh_target:
		velocity = global_position.direction_to(slime_flesh_target.global_position) * RUN_SPEED
	velocity = move_and_slide(velocity, Vector2.ZERO)


func _on_DetectRadius_body_entered(body):
	if body.has_method("shoot"):
		slime_sound.play()
		call_deferred("queue_free")


func _on_DetectRadius_body_exited(_body):
	pass
