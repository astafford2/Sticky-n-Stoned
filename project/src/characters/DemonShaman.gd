extends "res://src/characters/Mob.gd"

export (PackedScene) var GlueSpatter

var glued := false
var velocity := Vector2()
var spatter : Area2D = null

onready var bd_sprite := $BDSprite
onready var glue_landing_fx := $GlueLanding


func _ready():
	pass
