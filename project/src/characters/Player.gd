extends KinematicBody2D

export (PackedScene) var GlueBullet
export var health := 6

var run_speed := 100
var velocity := Vector2()
var interactablesInRange = []
var inventory = null
var last_door : Node2D = null
var canShoot = true

onready var player_sprite := $PlayerSprite
onready var health_GUI := $HealthLayer/HealthGUI
onready var muzzle := $Muzzle
onready var glue_launch_fx := $GlueLaunch
onready var hurt_fx := $HurtSound
onready var animation_player := $AnimationPlayer

func _ready():
	pass


func _process(_delta):
	health_GUI.update_health(health)
	if health <= 0:
		kill_player()

func _physics_process(_delta):
	muzzle.look_at(get_global_mouse_position())
	if Input.is_action_pressed("move_up"):
		velocity.y = -run_speed
	elif Input.is_action_pressed("move_down"):
		velocity.y = run_speed
	else:
		velocity.y = 0
	if Input.is_action_pressed("move_right"):
		player_sprite.flip_h = false
		velocity.x = run_speed
	elif Input.is_action_pressed("move_left"):
		player_sprite.flip_h = true
		velocity.x = -run_speed
	else:
		velocity.x = 0
	if Input.is_action_just_pressed("shoot_glue") and canShoot:
		shoot()
		canShoot = false
		yield(get_tree().create_timer(0.25), "timeout")
		canShoot = true
	
	if Input.is_action_just_pressed("use_weapon") and inventory != null:
		if inventory.Use():
			inventory = null
	
	if Input.is_action_just_pressed("interact"):
		if!interactablesInRange.empty():
			var closest = null
			var distance = 90000
			for obj in interactablesInRange:
				#determine who the closest is if any
				var objp = obj.get_position()
				var selfp = self.get_position()
				if closest == null:
					closest = obj
					distance = objp.distance_to(selfp)
				elif objp.distance_to(selfp) < distance:
					closest = obj
					distance = objp.distance_to(selfp)
			if closest.is_in_group("inventoryItem"): #Check to make sure there isnt something in the current inventory
				#update Inventory and Interact
				inventory = closest #might have to be changed later for non inventory interactables
				closest.Interact(self)
			else:
				closest.Interact(self)
	
	if inventory != null:
		inventory.rotation = muzzle.global_rotation
	
	
	player_sprite.animation = "run" if velocity != Vector2.ZERO else "idle"
	
	player_sprite.play()
	velocity = move_and_slide(velocity, Vector2.ZERO)


func player_hit():
	player_sprite.play("hit")
	hurt_fx.play()
	health -= 1


func shoot():
	var b = GlueBullet.instance()
	owner.add_child(b)
	b.transform = muzzle.global_transform
	glue_launch_fx.play()


func kill_player():
	call_deferred("queue_free")


func pitfalled(center):
	position = center
	animation_player.play("pitfalled")
	yield(animation_player, "animation_finished")
	scale = Vector2(0.75, 0.75)
	rotation_degrees = 0
	position.y += 20
	player_hit()


func set_door(door):
	last_door = door


func freeze_player():
	run_speed = 0


func unfreeze_player():
	run_speed = 100


func _on_PlayerArea_body_entered(body):
	if body.is_in_group("enemies"):
		player_hit()


func _on_PlayerArea_body_exited(_body):
	pass


func _on_PlayerArea_area_entered(area):
	if area.is_in_group("interactable"):
		interactablesInRange.append(area)


func _on_PlayerArea_area_exited(area):
	if area.is_in_group("interactable"):
		interactablesInRange.erase(area)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "pitfalled":
		scale = Vector2(0.75, 0.75)
		rotation_degrees = 0
		position.y += 20
