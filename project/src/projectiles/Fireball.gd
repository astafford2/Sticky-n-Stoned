extends Projectile


func init(Thrower):
	thrower = Thrower


func _ready():
	speed = 350
	projectile = true


func projectileActivity(delta):
	position += transform.x * speed * delta

func _on_hit_single_call():
	call_deferred("queue_free")
