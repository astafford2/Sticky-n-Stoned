extends Node2D


export (PackedScene) var slime
export (Script) var script2

const win_gui = preload("res://src/GUI/WinGUI.tscn")
const death_gui = preload("res://src/GUI/DeathGUI.tscn")

onready var scene_cam := $Camera2D
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
		position_hud(pause_menu)
		pause_menu.show()


func unpause():
	pause_menu.hide()
	get_tree().paused = false


func position_hud(hud):
	var screen_center = player_cam.get_camera_screen_center()
	hud.set_position(Vector2(screen_center.x - hud.rect_size.x/2, screen_center.y - hud.rect_size.y/2))
	return screen_center


func player_win():
	var wg = win_gui.instance()
	position_hud(wg)
	wg.pause_mode = Node.PAUSE_MODE_PROCESS
	get_tree().paused = true
	get_parent().add_child(wg)


func player_lose():
	var dg = death_gui.instance()
	var camera_center = position_hud(dg)
	dg.pause_mode = Node.PAUSE_MODE_PROCESS
	get_tree().paused = true
	get_parent().add_child(dg)
	scene_cam.position = camera_center
	scene_cam.current = true
