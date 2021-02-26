extends "res://src/tiles/Activateable.gd"

onready var sprite := $Sprite
onready var press_fx := $ButtonPress

func _ready():
	projectileActivateable = true
	playerActivateable = true
	toggleable = true
	sfx = press_fx
	self.add_to_group("interactable")
	self.add_to_group("projectileInteractable")
	
	#Temporary code
	for child in self.get_children():
		if child.is_in_group("trap"):
			traps.push_back(child)

func _physics_process(delta):
	if activated:
		sprite.texture = preload("res://assets/tiles/ButtonPressed.png")
	else:
		sprite.texture = preload("res://assets/tiles/Button.png")

func _on_Button_body_entered(body):
	self.on_body_entered(body)
