extends Control

onready var playButton = $Menu/PlayButton
onready var settingsMenu = $SettingsMenu

export(String, FILE) var nextScenePath: = ""

func _ready():
	playButton.grab_focus()

func _on_PlayButton_button_up():
	var err = get_tree().change_scene(nextScenePath)
	if err != OK:
		print("Error MainScreen")

func _on_SettingsButton_button_up():
	settingsMenu.popup_centered()
