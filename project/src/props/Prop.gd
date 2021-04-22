extends RigidBody2D


onready var hit_box := $HitBox


func _ready():
	self.connect("sleeping_state_changed", self, "_on_sleeping_state_changed")


func _on_sleeping_state_changed():
	yield(get_tree().create_timer(1), "timeout")
	mode = RigidBody2D.MODE_STATIC
	hit_box.set_deferred("disabled", true)
