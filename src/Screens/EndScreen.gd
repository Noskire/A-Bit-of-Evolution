extends Control

onready var sceneTree: = get_tree()
onready var lTime: Label = get_node("Time")
onready var enterBoard = get_node("EnterBoard")

export(String, FILE) var level_path: = ""
export(String, FILE) var screen_path: = ""

var submit = false

func _ready():
	var savedTime = Save.game_data.time_score
	var bestTime = Save.game_data.best_time_score
	if bestTime == -1 or bestTime > savedTime:
		Save.game_data.best_time_score = savedTime
		Save.save_data()
		lTime.set_text(tr("TIME") + " %ss " % int(savedTime) + tr("NEWHIGHSCORE"))
		enterBoard.set_visible(true)
	else:
		lTime.set_text(tr("TIME") + " %ss" % int(savedTime))
		enterBoard.set_visible(false)
	$CanvasLayer.send_request()

func _on_RestartBtn_button_up():
	var err
	err = sceneTree.change_scene(level_path)
	if err != OK:
		print("Error change_scene RestartButton")

func _on_MainMenuBtn_button_up():
	var err
	err = sceneTree.change_scene(screen_path)
	if err != OK:
		print("Error change_scene MenuButton")
