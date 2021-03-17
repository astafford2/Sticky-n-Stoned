extends Node2D


func _process(delta):
	if Input.is_action_pressed("cheat_kill"):
		if Input.is_action_just_pressed("kill_enemies"):
			for enemy in get_tree().get_nodes_in_group("enemies"):
				enemy.kill_enemy()
