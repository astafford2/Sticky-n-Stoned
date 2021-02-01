extends Area2D

func _ready():
	pass

func _physics_process(delta):
	position += transform.x * delta
