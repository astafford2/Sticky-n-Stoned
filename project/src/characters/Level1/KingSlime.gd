extends Mob


export (PackedScene) var GlueSpatter

var glued = 10
var velocity := Vector2()
var spatter : Area2D = null
var Foot1 = null
var feetArea = null
var managedPits = []

onready var sprite := $Sprite
#onready var glue_landing_fx := $GlueLanding
onready var Foot1S := $FallingBox/Foot

func _ready():
	RUN_SPEED = 100
	Health = 2
# warning-ignore:return_value_discarded
	SignalMaster.connect("overlapped", self, "_on_feet_overlapped")
	add_to_group("enemies")
	add_to_group("glueable")


func _process(_delta):
	sprite.animation = "run" if velocity != Vector2.ZERO else "idle"
	sprite.play()
	sprite.flip_h = true if sign(velocity.x) == -1 else false
	
	if Health <= 0:
		kill_enemy()


func _physics_process(_delta):
	velocity = Vector2.ZERO
	if Target:
		velocity = global_position.direction_to(Target.global_position) * RUN_SPEED
	velocity = move_and_slide(velocity, Vector2.ZERO)

func glue(amount, time):
	glued -= 1
	if glued <= 0:
		glued = 1
	#glue_landing_fx.play()
	spatter = GlueSpatter.instance()
	self.call_deferred("add_child", spatter)
	spatter.position += Vector2(0, 7)
	RUN_SPEED = 100-(amount/glued)
	yield(get_tree().create_timer(time), "timeout")
	spatter.queue_free()
	glued +=1
	RUN_SPEED = 100-(amount/glued)


func damagedActivity(thrower, damage):
	Health -= damage
	Target = thrower


func kill_enemy():
	call_deferred("queue_free")
	if spatter:
		spatter.call_deferred("queue_free")
