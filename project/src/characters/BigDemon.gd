extends KinematicBody2D

export (PackedScene) var GlueSpatter
export var health : int

var RUN_SPEED := 50
var glued = false

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

func glue(amount, time):
	if !glued:
		glued = true
		var FX = $"SoundFX/Glue Landing"
		FX.play()
		var spatter = GlueSpatter.instance()
		owner.call_deferred("add_child", spatter)
		spatter.transform = $BDShape.global_transform
		RUN_SPEED = RUN_SPEED-amount
		yield(get_tree().create_timer(time), "timeout")
		spatter.queue_free()
		RUN_SPEED = RUN_SPEED+amount
		glued=false


func enemy_hit(damage):
	health -= damage

func _on_DetectRadius_body_entered(body):
	player = body


func _on_DetectRadius_body_exited(_body):
	player = null
