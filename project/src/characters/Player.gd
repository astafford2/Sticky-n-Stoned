extends KinematicBody2D

export (PackedScene) var GlueBullet
export var health := 6

var run_speed := 100
var velocity := Vector2()
var interactables_in_range = []
var inventory = null
var last_valid_tile = null
var can_shoot = true
var falling = false
var foot1 = null
var foot2 = null
var feet_area = null
var managed_pits = []
var can_roll := true
var is_rolling := false

onready var player := $"."
onready var player_sprite := $PlayerSprite
onready var health_GUI := $HealthLayer/HealthGUI
onready var muzzle := $Muzzle
onready var glue_launch_fx := $GlueLaunch
onready var throw_fx := $ThrowSfx
onready var hurt_fx := $HurtSound
onready var dodge_roll_fx := $DodgeRollSfx
onready var pitfall_fx := $PitfallSfx
onready var animation_player := $AnimationPlayer
onready var foot1S := $FallingBox/Foot1
onready var foot2S := $FallingBox/Foot2
onready var dodge_tween := $DodgeRollTween


func _ready():
# warning-ignore:return_value_discarded
	SignalMaster.connect("overlapped", self, "_on_feet_overlapped")
# warning-ignore:return_value_discarded
	SignalMaster.connect("enteredValidTile", self, "UpdateLastTile")
# warning-ignore:return_value_discarded
	SignalMaster.connect("attacked", self, "player_hit")


func _process(_delta):
	health_GUI.update_health(health)
	if health <= 0:
		kill_player()
	if !falling and !is_rolling:
		UpdateFooting()
	if !interactables_in_range.empty():
		var queued = getClosestInteractable()
		if queued.has_method("highlight"):
			if queued.is_in_group("inventoryItem") and inventory!=null:
				pass
			else:
				queued.highlight()
		for interactable in interactables_in_range:
			if interactable != queued and interactable.has_method("unhighlight"):
				interactable.unhighlight()

func _physics_process(_delta):
	muzzle.look_at(get_global_mouse_position())
	if is_rolling:
		player_sprite.play("dodge_roll")
		var direction = Vector2(sign(velocity.x), sign(velocity.y))
		velocity = (direction * run_speed * 2)
		dodgeRollControls()
	elif falling:
		player_sprite.play("falling")
		velocity = Vector2.ZERO
	else:
		player_sprite.animation = "run" if velocity != Vector2.ZERO else "idle"
		controls()
		
	
	player_sprite.play()
	velocity = move_and_slide(velocity, Vector2.ZERO)


func controls():
	if Input.is_action_just_pressed("dodge_roll") and can_roll and velocity != Vector2.ZERO:
		dodge_roll()
		can_roll = false
		yield(get_tree().create_timer(0.8), "timeout")
		can_roll = true
	
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
	if Input.is_action_just_pressed("shoot_glue") and can_shoot:
		shoot()
		can_shoot = false
		yield(get_tree().create_timer(0.25), "timeout")
		can_shoot = true
	
	if Input.is_action_just_pressed("use_weapon") and inventory != null:
		throw_fx.play()
		if inventory.Use():
			inventory = null
	
	if Input.is_action_just_pressed("interact"):
		pickupInteractable()
	
	if inventory != null:
		inventory.rotation = muzzle.global_rotation


func dodgeRollControls():
	if Input.is_action_just_pressed("interact"):
		pickupInteractable()


func pickupInteractable():
	var closest = getClosestInteractable()
	if closest != null and closest.is_in_group("inventoryItem"): 
		#Check to make sure there isnt something in the current inventory
		if !inventory:
			#update Inventory and Interact
			inventory = closest #might have to be changed later for non inventory interactables
			if inventory.has_method("unhighlight"):
				inventory.unhighlight()
			interactables_in_range.erase(inventory)
			closest.Interact(self)
	elif closest !=null:
		closest.Interact(self)


func getClosestInteractable():
	if!interactables_in_range.empty():
			var closest = null
			var distance = 90000
			for obj in interactables_in_range:
				if !obj:
					interactables_in_range.erase(obj)
					continue
				#determine who the closest is if any
				var objp = obj.get_position()
				var selfp = self.get_position()
				if closest == null and obj.is_in_group("interactable"):
					closest = obj
					distance = objp.distance_to(selfp)
				elif objp.distance_to(selfp) < distance:
					closest = obj
					distance = objp.distance_to(selfp)
			return closest
	else:
		return null


func player_hit(_thrower, target, damage):
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
	dodge_roll_fx.play()
	set_collision_mask_bit(2, false)
	is_rolling = true
	yield(get_tree().create_timer(0.5), "timeout")
	set_collision_mask_bit(2, true)
	is_rolling = false


func kill_player():
	get_parent().player_lose()
	animation_player.play("dead")
#	call_deferred("queue_free")


func pitfalled():
	falling = true
	foot1S.set_deferred("disabled", true)
	foot2S.set_deferred("disabled", true)
	animation_player.play("pitfalled")
	pitfall_fx.play()
	yield(animation_player, "animation_finished")
	scale = Vector2(0.75, 0.75)
	if last_valid_tile:
		global_position = last_valid_tile.global_position
	else:
		global_position = Vector2(0,0)
	player_hit(null, self, 1)
	foot1S.set_deferred("disabled", false)
	foot2S.set_deferred("disabled", false)
	falling = false


func freeze_player():
	run_speed = 0


func unfreeze_player():
	run_speed = 100


func UpdateFooting():
	foot1 = Rect2(foot1S.global_position - foot1S.shape.extents, foot1S.shape.extents * 2)
	foot2 = Rect2(foot2S.global_position - foot2S.shape.extents, foot2S.shape.extents * 2)
	feet_area = floor(foot1.get_area() + foot2.get_area())
	var total_area := 0
	if managed_pits.size() > 0:
		for pit in managed_pits:
			var overlap_area := 0
			for foot in [foot1, foot2]:
				overlap_area += foot.clip(pit).get_area()
			if overlap_area == 0:
					managed_pits.erase(pit)
			total_area += overlap_area
	if ceil(total_area) >= feet_area:
		pitfalled()


func UpdateLastTile(body, tile):
	if body==self:
		last_valid_tile = tile


func _on_feet_overlapped(area, rect):
	if area == self:
		if !managed_pits.has(rect):
			managed_pits.append(rect)


func _on_PlayerArea_body_entered(body):
	if body.is_in_group("enemies"):
		player_hit(null, self, 1)


func _on_PlayerArea_body_exited(_body):
	pass


func _on_PlayerArea_area_entered(area):
	if area.is_in_group("interactable"):
		interactables_in_range.append(area)


func _on_PlayerArea_area_exited(area):
	if interactables_in_range.has(area):
		interactables_in_range.erase(area)
		if area.has_method("unhighlight"):
			area.unhighlight()
