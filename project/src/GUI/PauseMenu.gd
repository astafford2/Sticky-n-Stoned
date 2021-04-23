extends PopupPanel


var main_menu := "res://src/TitleScreen.tscn"

onready var master_slider := $MarginContainer/VBoxContainer/MasterVolume/MasterSlider
onready var music_slider := $MarginContainer/VBoxContainer/MusicVolume/MusicSlider
onready var sound_slider := $MarginContainer/VBoxContainer/SoundVolume/SoundSlider


func _ready():
	pass


#func _process(_delta):
#	if Input.is_action_just_pressed("pause_game"):
#		get_parent().unpause()


func _on_Unpause_pressed():
	get_parent().unpause()


func _on_MasterSlider_value_changed(value):
	if value == -24:
		AudioServer.set_bus_mute(0, true)
	else:
		AudioServer.set_bus_mute(0, false)
		AudioServer.set_bus_volume_db(0, master_slider.value)


func _on_MusicSlider_value_changed(value):
	if value == -24:
		AudioServer.set_bus_mute(1, true)
	else:
		AudioServer.set_bus_mute(1, false)
		AudioServer.set_bus_volume_db(1, music_slider.value)


func _on_SoundSlider_value_changed(value):
	if value == -24:
		AudioServer.set_bus_mute(2, true)
	else:
		AudioServer.set_bus_mute(2, false)
		AudioServer.set_bus_volume_db(2, sound_slider.value)


func _on_MainMenu_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene(main_menu)
	get_tree().paused = false
