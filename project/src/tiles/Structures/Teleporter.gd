extends Area2D

var teleportTo
var cooldown = 0
var linkedPortal

func _ready():
	pass 


func _process(delta):
	if cooldown >0:
		cooldown -=delta


func linkToLocation(location:Vector2):
	teleportTo = location


func linkToPortal(portal):
	linkedPortal = portal
	linkToLocation(portal.global_position + Vector2(0,50))


func doubleLinkPortals(portal):
	linkToPortal(portal)
	portal.linkToPortal(self)


func _on_Teleporter_body_entered(body):
	if teleportTo and cooldown <=0:
		body.global_position = teleportTo
		cooldown = 3
		linkedPortal.cooldown = 10
