extends CanvasLayer


var room

onready var title := $Title
onready var health_gauge := $HealthBar/HealthGauge


func _ready():
	room = get_parent().get_parent().get_parent()


func _process(_delta):
	if room.started:
		title.visible = true
		health_gauge.visible = true


func set_max_health(max_health):
	health_gauge.max_value = max_health


func set_current_health(health):
	health_gauge.value = health
