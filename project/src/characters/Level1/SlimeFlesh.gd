extends GreenSlime


var slime_flesh_target : KinematicBody2D = null

onready var detect_radius_shape := $DetectRadius/DetectShape


func _ready():
	RUN_SPEED = 105
	Health = 1
	
	slime_flesh_target = get_parent().get_node("Enemies").get_node("KingSlime")
	detect_radius_shape.get_shape().radius = 6
	add_to_group("slimeFleshes")


func _physics_process(_delta):
	velocity = Vector2.ZERO
	if slime_flesh_target:
		velocity = global_position.direction_to(slime_flesh_target.global_position) * RUN_SPEED
	velocity = move_and_slide(velocity, Vector2.ZERO)


func _on_DetectRadius_body_entered(body):
#	if body == slime_flesh_target:
#		slime_flesh_target = null
#		call_deferred("queue_free")
	pass


func _on_DetectRadius_body_exited(_body):
	pass
