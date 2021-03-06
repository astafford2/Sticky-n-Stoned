extends Activateable

onready var sprite := $Sprite
onready var press_fx := $ButtonPress

const mat := preload("res://src/defaultMaterial.tres")

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

func _physics_process(_delta):
	if activated:
		sprite.texture = preload("res://assets/tiles/ButtonPressed.png")
	else:
		sprite.texture = preload("res://assets/tiles/Button.png")

func _on_Button_body_entered(body):
	self.on_body_entered(body)


func highlight():
	sprite.set_material(mat)

func unhighlight():
	sprite.set_material(null)
