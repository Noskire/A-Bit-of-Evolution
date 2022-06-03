extends Control

onready var sceneTree: = get_tree()
onready var pauseOverlay: ColorRect = get_node("PauseOverlay")
onready var paused: Label = get_node("PauseOverlay/Paused")

export(String, FILE) var next_scene_path: = ""

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		if pauseOverlay.visible: # Paused
			sceneTree.paused = false
			pauseOverlay.visible = false
		else:
			sceneTree.paused = true
			pauseOverlay.visible = true
			$PauseOverlay/VBox/ResumeBtn.grab_focus()
		sceneTree.set_input_as_handled()

func _on_ResumeBtn_button_up():
	sceneTree.paused = false
	pauseOverlay.visible = false

func _on_RestartBtn_button_up():
	sceneTree.paused = false
	var err
	err = sceneTree.reload_current_scene()
	if err != OK:
		print("Error reload_scene RestartButton")

func _on_MainMenuBtn_button_up():
	sceneTree.paused = false
	
	var err
	err = sceneTree.change_scene(next_scene_path)
	if err != OK:
		print("Error change_scene MenuButton")
