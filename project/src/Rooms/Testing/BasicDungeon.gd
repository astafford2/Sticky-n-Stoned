extends Node2D


export (PackedScene) var slime
export (Script) var script2

onready var player_cam := $Player/PlayerCam
onready var pause_menu := $PauseMenu


func _process(_delta):
	if Input.is_action_pressed("cheat_kill"):
		if Input.is_action_just_pressed("kill_enemies"):
			for enemy in get_tree().get_nodes_in_group("enemies"):
				enemy.kill_enemy()
	
	if Input.is_action_just_pressed("spawn_slime_flesh"):
		var slime_flesh = slime.instance()
		slime_flesh.set_script(script2)
		slime_flesh.position = $Player.position + Vector2(50, 0)
		add_child(slime_flesh)
	
	if Input.is_action_just_pressed("cheat_infinite_health"):
		get_node("Player").health = 999999999999999999
	
	if Input.is_action_just_pressed("pause_game"):
		get_tree().paused = true
		var screen_center = player_cam.get_camera_screen_center()
		pause_menu.set_position(Vector2(screen_center.x - pause_menu.rect_size.x/2, screen_center.y - pause_menu.rect_size.y/2))
		pause_menu.show()
		


func _on_Unpause_pressed():
	pause_menu.hide()
	get_tree().paused = false
