extends Node2D

onready var queue = preload("res://src/resource_queue.gd").new()

func _ready():
	queue.start()
	queue.queue_resource("res://src/Rooms/Level1.tscn", true)

func _process(_delta):
	if queue.is_ready("res://src/Rooms/Level1.tscn"):
		var _ignored = get_tree().change_scene("res://src/Rooms/Level1.tscn")

