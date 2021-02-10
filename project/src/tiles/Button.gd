extends "res://src/tiles/Activateable.gd"

onready var sprite := $Sprite

func _ready():
	projectileActivateable = true
	playerActivateable = true
	toggleable = true
	self.add_to_group("interactable")
	self.add_to_group("projectileInteractable")
	
	#Temporary code
	trap = self.get_child(2)

func _physics_process(delta):
	if activated:
		sprite.texture = preload("res://assets/tiles/ButtonPressed.png")
	else:
		sprite.texture = preload("res://assets/tiles/Button.png")

func _on_Button_body_entered(body):
	self.on_body_entered(body)
