extends MarginContainer


onready var health_gauge := $HealthGauge


func set_max_health(max_health):
	health_gauge.max_value = max_health


func set_current_health(health):
	health_gauge.value = health
