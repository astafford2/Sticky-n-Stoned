extends GreenSlime


func _ready():
	RUN_SPEED = 105
	Health = 1
# warning-ignore:return_value_discarded
	SignalMaster.connect("overlapped", self, "_on_feet_overlapped")


func _physics_process(_delta):
	velocity = Vector2.ZERO
	if Target:
		velocity = global_position.direction_to(Target.global_position) * RUN_SPEED
	velocity = move_and_slide(velocity, Vector2.ZERO)


func _on_DetectRadius_body_entered(body):
	pass


func _on_DetectRadius_body_exited(body):
	pass
