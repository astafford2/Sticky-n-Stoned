extends Mob


export (PackedScene) var GlueSpatter
export (PackedScene) var slime_flesh
export (Script) var slime_flesh_script

var glued = 5
var velocity := Vector2()
var Foot1 = null
var feetArea = null
var managedPits = []
var room
var activity : FuncRef = funcref(self, "chase")
var animTime :float= 10
var totalTime :float = 0
var rockCount := 0
var rocks = []
var rng = RandomNumberGenerator.new()

onready var sprite := $KSSprite
onready var shape := $KSShape
#onready var glue_landing_fx := $GlueLanding
onready var Foot1S := $FallingBox/Foot
onready var muzzle := $Muzzle

func _ready():
	rng.randomize()
	room = self.get_parent().get_parent()
	RUN_SPEED = 130
	Health = 100
# warning-ignore:return_value_discarded
	SignalMaster.connect("overlapped", self, "_on_feet_overlapped")
	add_to_group("enemies")
	add_to_group("glueable")


func hit(delta):
	animTime -= delta
	var tilemap: TileMap = self.get_parent().get_parent().floors
	if animTime > 0:
		sprite.animation = "hit"
		for n in range(10):
			rng.randomize()
			var sf = slime_flesh.instance()
			sf.set_script(slime_flesh_script)
			var valid = false
			while !valid:
				sf.position = self.position + Vector2(rng.randi_range(-350, 350), rng.randi_range(-350, 350))
				var floorPosition = tilemap.world_to_map(sf.position)
				if tilemap.get_used_cells().has(floorPosition):
					valid =true
			room.add_child(sf)
			Health -= 2
		animTime = 0
	else:
		activity.set_function("chase")
		animTime = 10


func jumpStart():
	animTime = 3
	totalTime = 3
	activity.set_function("jump")
	sprite.animation = "jump"
	shape.set_deferred("disabled", true)
	sprite.play()


func jump(delta):
	animTime -= delta
	if animTime >0:
		if sprite.frame <= 8:
			sprite.position += Vector2(0, -5)
			shape.position += Vector2(0, -5)
			for rock in rocks:
				if rock:
					rock.position += Vector2(0, -5)
		else:
			sprite.position += Vector2(0, 5)
			shape.position += Vector2(0, 5)
			for rock in rocks:
				if rock:
					rock.position += Vector2(0, 5)
		if sprite.frame == 17:
			sprite.position = Vector2(0,0)
			shape.position = Vector2(0,6)
		#throw rocks
			for rock in rocks:
				rock.Use()
			rocks.clear()
			animTime = 0
	else:
		shape.set_deferred("disabled", false)
		activity.set_function("hit")
		animTime = 3


func chase(delta):
	if animTime > 0 and Target:
		animTime -= delta
		sprite.animation = "run" if velocity != Vector2.ZERO else "idle"
		sprite.play()
		velocity = Vector2.ZERO
		if Target:
			velocity = global_position.direction_to(Target.global_position) * RUN_SPEED
		velocity = move_and_slide(velocity, Vector2.ZERO)
	elif animTime >0:
		pass
	else:
		jumpStart();


func _process(_delta):
	sprite.flip_h = true if sign(velocity.x) == -1 else false
	if Health <= 0:
		for thing in get_parent().get_children():
			thing.call_deferred("queue_free")
		kill_enemy()


func _physics_process(delta):
	if !activity:
		activity.set_function("chase")
	activity.call_func(delta)


func glue(amount, time):
	glued -= 1
	if glued <= 0:
		glued = 1
		return
	#glue_landing_fx.play()
	if !spatter:
		spatter = GlueSpatter.instance()
		self.call_deferred("add_child", spatter)
		spatter.position += Vector2(0, 7)
	RUN_SPEED = 130-(amount*1.5/glued)
	yield(get_tree().create_timer(time), "timeout")
	glued +=1
	if glued > 5:
		glued = 5
	if glued == 5 and spatter:
		spatter.queue_free()
		RUN_SPEED = 130
		return
	RUN_SPEED = 130-(amount*1.5/glued)


func damagedActivity(thrower, damage):
	Health -= damage
	Target = thrower


func _on_feet_overlapped(_area, _rect):
	pass


func _on_DetectRadius_body_entered(body):
	if body.has_method("shoot") and room.started:
		Target = body


func _on_SlurpArea_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	if area.is_in_group("interactable") and !rocks.has(area):
		rocks.append(area)
		area.Interact(self)
		area.rotation = rng.randi_range(-180,180)
		area.position = Vector2(rng.randi_range(-5,5), rng.randi_range(-5,5))


func _on_SlimeRegenArea_body_entered(body):
	if body.is_in_group("slimeFleshes"):
		body.call_deferred("queue_free")
		Health += 2
