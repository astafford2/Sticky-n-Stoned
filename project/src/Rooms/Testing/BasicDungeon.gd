extends Node2D


export (PackedScene) var slime
export (Script) var script2


func _process(_delta):
	if Input.is_action_pressed("cheat_kill"):
		if Input.is_action_just_pressed("kill_enemies"):
			for enemy in get_tree().get_nodes_in_group("enemies"):
				enemy.kill_enemy()
			print(get_children())
	
	if Input.is_action_just_pressed("spawn_slime_flesh"):
		var slime_flesh = slime.instance()
		slime_flesh.set_script(script2)
		slime_flesh.position = $Player.position + Vector2(50, 0)
		add_child(slime_flesh)
	
	if Input.is_action_just_pressed("cheat_infinite_health"):
		get_node("Player").health = 999999999999999999
