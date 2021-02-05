extends Area2D

export var speed = 350

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	position += transform.x * speed * delta

func _on_GlueBullet_body_entered(body):
	if !body.has_method("shoot"):
		queue_free()
	if body.is_in_group("glueable"):
		body.glue(70, 5)
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
