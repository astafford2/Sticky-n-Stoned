extends KinematicBody2D


const run_speed := 200

var velocity := Vector2()

onready var player_sprite := $PlayerSprite


func _ready():
	pass


func _physics_process(delta):
	if Input.is_action_pressed("move_up"):
		velocity.y = -run_speed
	elif Input.is_action_pressed("move_down"):
		velocity.y = run_speed
	if Input.is_action_pressed("move_right"):
		player_sprite.flip_h = false
		velocity.x = run_speed
	elif Input.is_action_pressed("move_left"):
		player_sprite.flip_h = true
		velocity.x = -run_speed
