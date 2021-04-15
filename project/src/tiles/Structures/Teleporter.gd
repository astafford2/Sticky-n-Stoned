extends Area2D

var teleport_to
var cooldown = 0
var linked_portal

func _ready():
	pass 


func _process(delta):
	if cooldown >0:
		cooldown -=delta


func linkToLocation(location:Vector2):
	teleport_to = location


func linkToPortal(portal):
	linked_portal = portal
	linkToLocation(portal.global_position + Vector2(0,50))


func doubleLinkPortals(portal):
	linkToPortal(portal)
	portal.linkToPortal(self)


func _on_Teleporter_body_entered(body):
	if teleport_to and cooldown <=0:
		body.global_position = teleport_to
		cooldown = 3
		linked_portal.cooldown = 10
