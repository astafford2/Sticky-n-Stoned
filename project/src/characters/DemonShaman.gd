extends Mob

export (PackedScene) var GlueSpatter
export (PackedScene) var fireball

var glued := false
var velocity := Vector2()
var spatter : Area2D = null

onready var bd_sprite := $DSSprite
onready var glue_landing_fx := $GlueLanding


func _ready():
	RUN_SPEED = 120
	Health = 4


func _process(_delta):
	if Health <= 0:
		kill_enemy()


func _physics_process(_delta):
	velocity = Vector2.ZERO
	if Target:
		velocity = -(position.direction_to(Target.position) * RUN_SPEED)
	velocity = move_and_slide(velocity, Vector2.ZERO)


func attack():
	var f = fireball.instance()
	owner.add_child(f)
	f.transform = position.direction_to(Target.position)

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


func damagedActivity(thrower, damage):
	Health -= damage
	Target = thrower


func kill_enemy():
	call_deferred("queue_free")
	if spatter:
		spatter.call_deferred("queue_free")


func _on_DetectRadius_body_entered(body):
	if body.has_method("shoot"):
		Target = body


func _on_DetectRadius_body_exited(body):
	if body.has_method("shoot"):
		Target = null
