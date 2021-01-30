extends KinematicBody2D


const RUN_SPEED := 50

var velocity := Vector2()
var player = null


func _ready():
	pass


func _physics_process(delta):
	if player:
		velocity = position.direction_to(player.position) * RUN_SPEED
	velocity = move_and_slide(velocity, Vector2.ZERO)


func _on_DetectRadius_body_entered(body):
	player = body


func _on_DetectRadius_body_exited(_body):
	player = null
	velocity = Vector2.ZERO
