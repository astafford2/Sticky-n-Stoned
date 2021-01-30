extends KinematicBody2D


const RUN_SPEED := 50

var velocity := Vector2()
var player = null

onready var bd_sprite = $BDSprite


func _ready():
	pass


func _process(_delta):
	bd_sprite.animation = "run" if velocity != Vector2.ZERO else "idle"
	bd_sprite.play()
	
	bd_sprite.flip_h = true if sign(velocity.x) == -1 else false


func _physics_process(_delta):
	velocity = Vector2.ZERO
	if player:
		velocity = position.direction_to(player.position) * RUN_SPEED
	velocity = move_and_slide(velocity, Vector2.ZERO)


func _on_DetectRadius_body_entered(body):
	player = body


func _on_DetectRadius_body_exited(_body):
	player = null
