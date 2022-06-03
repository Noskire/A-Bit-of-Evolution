extends Popup

onready var settingsTab = $Bg/Tabs
onready var displayOptionBtn = $Bg/Tabs/STOPTIONS/Margin/Grid/DisplayOptions
onready var bloomBtn = $Bg/Tabs/STOPTIONS/Margin/Grid/BloomBtn
onready var vsyncBtn = $Bg/Tabs/STOPTIONS/Margin/Grid/VSyncBtn
onready var brightValue = $Bg/Tabs/STOPTIONS/Margin/Grid/HBox/BgtValue
onready var brightSlider = $Bg/Tabs/STOPTIONS/Margin/Grid/HBox/BgtSlider
onready var masterValue = $Bg/Tabs/STOPTIONS/Margin/Grid/HBox2/VolValue
onready var masterSlider = $Bg/Tabs/STOPTIONS/Margin/Grid/HBox2/VolSlider
onready var languageBtn = $Bg/Tabs/STOPTIONS/Margin/Grid/Languages
onready var keyGrid = $Bg/Tabs/STKEYS/Margin/Grid
onready var btnScript = load("res://src/UserInterface/KeyButton.gd")

var buttons = {}
var keybinds

func _ready():
	displayOptionBtn.select(1 if Save.game_data.fullscreen_on else 0)
	GlobalSettings.toggle_fullscreen(Save.game_data.fullscreen_on)
	bloomBtn.pressed = Save.game_data.bloom_on
	vsyncBtn.pressed = Save.game_data.vsync_on
	brightSlider.value = Save.game_data.brightness
	
	masterSlider.value = Save.game_data.master_vol
	
	if Save.game_data.language == "en":
		TranslationServer.set_locale("en")
		languageBtn.selected = 1
	elif Save.game_data.language == "pt":
		TranslationServer.set_locale("pt")
		languageBtn.selected = 2
	
	GlobalSettings.set_keybinds()
	keybinds = Save.keybinds.duplicate()
	for key in keybinds.keys():
		var label = Label.new()
		var button = Button.new()
		
		label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		button.set_h_size_flags(Control.SIZE_EXPAND)
		button.set_h_size_flags(Control.SIZE_SHRINK_END)
		
		label.set_text(tr(str(key)))
		
		var button_value = keybinds[key]
		if button_value != null:
			button.text = OS.get_scancode_string(button_value)
		else:
			button.text.set_text(tr("STKUNASSIGNED"))
			pass
		
		button.set_script(btnScript)
		button.key = key
		button.value = button_value
		button.menu = self
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		
		keyGrid.add_child(label)
		if key == "Attack":
			var lbm = Label.new()
			lbm.set_text("LMB / ")
			lbm.set_h_size_flags(Control.SIZE_EXPAND)
			lbm.set_h_size_flags(Control.SIZE_SHRINK_END)
			
			var hbox = HBoxContainer.new()
			hbox.add_child(lbm)
			hbox.add_child(button)
			hbox.set_h_size_flags(Control.SIZE_EXPAND)
			hbox.set_h_size_flags(Control.SIZE_SHRINK_END)
			
			keyGrid.add_child(hbox)
		else:
			keyGrid.add_child(button)
		
		buttons[key] = button

func _on_DisplayOptions_item_selected(index):
	GlobalSettings.toggle_fullscreen(true if index == 1 else false)

func _on_BloomBtn_toggled(button_pressed):
	GlobalSettings.toggle_bloom(button_pressed)

func _on_VSyncBtn_toggled(button_pressed):
	GlobalSettings.toggle_vsync(button_pressed)

func _on_BgtSlider_value_changed(value):
	GlobalSettings.update_brightness(value)
	brightValue.text = str(Save.game_data.brightness)

func _on_VolSlider_value_changed(value):
	GlobalSettings.update_vol(value)
	masterValue.text = str(Save.game_data.master_vol)

func _on_Languages_item_selected(index):
	if index == 1:
		TranslationServer.set_locale("en")
		Save.game_data.language = "en"
	elif index == 2:
		TranslationServer.set_locale("pt")
		Save.game_data.language = "pt"
	Save.save_data()

func _on_Reset_button_up():
	keybinds = Save.standard_keybinds.duplicate()
	Save.keybinds = Save.standard_keybinds.duplicate()
	for k in keybinds.keys():
		buttons[k].value = keybinds[k]
		buttons[k].text = OS.get_scancode_string(keybinds[k])
	GlobalSettings.set_keybinds()
	GlobalSettings.write_config()

func _on_Save_button_up():
	Save.keybinds = keybinds.duplicate()
	GlobalSettings.set_keybinds()
	GlobalSettings.write_config()

func change_bind(key, value):
	keybinds[key] = value
	for k in keybinds.keys():
		if k != key and value != null and keybinds[k] == value:
			keybinds[k] = null
			buttons[k].value = null
			buttons[k].set_text(tr("STKUNASSIGNED"))

func _on_Tabs_tab_selected(tab):
	if tab == 2:
		settingsTab.current_tab = 0
		self.visible = false
