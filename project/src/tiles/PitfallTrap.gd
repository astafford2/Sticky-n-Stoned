extends "res://src/tiles/Traps.gd"

onready var sprite := $Sprite
onready var shape := $PitfallShape

func _ready():
	pass # Replace with function body.

func activate(_delta):
	sprite.texture = preload("res://assets/tiles/hole.png")

# what the child trap will do when deactivated or idle
func deactivated(_delta):
	sprite.texture = preload("res://assets/tiles/RegularTIle.png")


func _on_PitfallTrap_body_entered(body):
	if body.has_method("shoot") and activated:
		body.pitfalled(global_position+Vector2(16, 16))
