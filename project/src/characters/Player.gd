extends KinematicBody2D

export (PackedScene) var GlueBullet
export var health := 6

var run_speed := 100
var velocity := Vector2()
var interactablesInRange = []
var inventory = null
var last_door : Node2D = null
var last_ValidTile = null
var canShoot = true
var rolling = false
var Foot1 = null
var Foot2 = null
var feetArea = null
var managedPits = []
var canRoll := true

onready var player := $"."
onready var player_sprite := $PlayerSprite
onready var health_GUI := $HealthLayer/HealthGUI
onready var muzzle := $Muzzle
onready var glue_launch_fx := $GlueLaunch
onready var hurt_fx := $HurtSound
onready var animation_player := $AnimationPlayer
onready var Foot1S := $FallingBox/Foot1
onready var Foot2S := $FallingBox/Foot2
onready var dodge_tween := $DodgeRollTween


func _ready():
# warning-ignore:return_value_discarded
	SignalMaster.connect("overlapped", self, "_on_feet_overlapped")
# warning-ignore:return_value_discarded
	SignalMaster.connect("enteredValidTile", self, "UpdateLastTile")
	SignalMaster.connect("attacked", self, "player_hit")


func _process(_delta):
	health_GUI.update_health(health)
	if health <= 0:
		kill_player()
	if !rolling:
		UpdateFooting()

func _physics_process(_delta):
	muzzle.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("dodge_roll") and canRoll:
		dodge_roll()
		canRoll = false
		yield(get_tree().create_timer(0.5), "timeout")
		canRoll = true
	
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
				if closest == null and obj.is_in_group("interactable"):
					closest = obj
					distance = objp.distance_to(selfp)
				elif objp.distance_to(selfp) < distance:
					closest = obj
					distance = objp.distance_to(selfp)
			if closest != null: 
				#Check to make sure there isnt something in the current inventory
				if !inventory:
					#update Inventory and Interact
					inventory = closest #might have to be changed later for non inventory interactables
					interactablesInRange.erase(inventory)
					closest.Interact(self)
			else:
				closest.Interact(self)
	
	if inventory != null:
		inventory.rotation = muzzle.global_rotation
	
	
	player_sprite.animation = "run" if velocity != Vector2.ZERO else "idle"
	
	player_sprite.play()
	velocity = move_and_slide(velocity, Vector2.ZERO)


func player_hit(thrower, target, damage):
	if target == self:
		player_sprite.play("hit")
		hurt_fx.play()
		health -= damage


func shoot():
	var b = GlueBullet.instance()
	owner.add_child(b)
	b.transform = muzzle.global_transform
	glue_launch_fx.play()


func dodge_roll():
	freeze_player()
	set_collision_mask_bit(2, false)
	dodge_tween.interpolate_property(player, "position",
		player.position, (player.position + Vector2(sign(velocity.x)*100, sign(velocity.y)*100)), 0.3,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	dodge_tween.start()
	yield(dodge_tween, "tween_completed")
	unfreeze_player()
	set_collision_mask_bit(2, true)


func kill_player():
	call_deferred("queue_free")


func pitfalled():
	rolling = true
	Foot1S.set_deferred("disabled", true)
	Foot2S.set_deferred("disabled", true)
	animation_player.play("pitfalled")
	yield(animation_player, "animation_finished")
	scale = Vector2(0.75, 0.75)
	rotation_degrees = 0
	if last_ValidTile:
		global_position = last_ValidTile.global_position
	else:
		global_position = Vector2(0,0)
	player_hit(null, self, 1)
	Foot1S.set_deferred("disabled", false)
	Foot2S.set_deferred("disabled", false)
	rolling = false


func set_door(door):
	last_door = door


func freeze_player():
	run_speed = 0


func unfreeze_player():
	run_speed = 100


func UpdateFooting():
	Foot1 = Rect2(Foot1S.global_position - Foot1S.shape.extents, Foot1S.shape.extents * 2)
	Foot2 = Rect2(Foot2S.global_position - Foot2S.shape.extents, Foot2S.shape.extents * 2)
	feetArea = floor(Foot1.get_area() + Foot2.get_area())
	var totalArea := 0
	if managedPits.size() > 0:
		for pit in managedPits:
			var overlapArea := 0
			for foot in [Foot1, Foot2]:
				overlapArea += foot.clip(pit).get_area()
			if overlapArea == 0:
					managedPits.erase(pit)
			totalArea += overlapArea
	if ceil(totalArea) >= feetArea:
		pitfalled()


func UpdateLastTile(body, tile):
	if body==self:
		last_ValidTile = tile


func _on_feet_overlapped(area, rect):
	if area == self:
		if !managedPits.has(rect):
			managedPits.append(rect)


func _on_PlayerArea_body_entered(body):
	if body.is_in_group("enemies"):
		player_hit(null, self, 1)


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
