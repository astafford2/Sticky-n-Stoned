extends KinematicBody2D

export (PackedScene) var GlueSpatter
export var health : int

var RUN_SPEED := 110
var glued = false

var velocity := Vector2()
var player : KinematicBody2D = null
var spatter : Area2D = null

onready var bd_sprite := $BDSprite
onready var glue_landing_fx := $GlueLanding


func _ready():
	pass


func _process(_delta):
	bd_sprite.animation = "run" if velocity != Vector2.ZERO else "idle"
	bd_sprite.play()
	bd_sprite.flip_h = true if sign(velocity.x) == -1 else false
	
	if health <= 0:
		kill_enemy()


func _physics_process(_delta):
	velocity = Vector2.ZERO
	if player:
		velocity = position.direction_to(player.position) * RUN_SPEED
	velocity = move_and_slide(velocity, Vector2.ZERO)

func glue(amount, time):
	if !glued:
		glued = true
		glue_landing_fx.play()
		spatter = GlueSpatter.instance()
		self.call_deferred("add_child", spatter)
		spatter.position += Vector2(0, 20)
		RUN_SPEED = RUN_SPEED-amount
		yield(get_tree().create_timer(time), "timeout")
		spatter.queue_free()
		RUN_SPEED = RUN_SPEED+amount
		glued=false


func enemy_hit(damage, thrower):
	health -= damage
	player = thrower
	print("damaged")


func kill_enemy():
	call_deferred("queue_free")
	if spatter:
		spatter.call_deferred("queue_free")


func _on_DetectRadius_body_entered(body):
	if body.has_method("shoot"):
		player = body


func _on_DetectRadius_body_exited(_body):
	player = null
