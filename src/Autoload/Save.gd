extends Node

const SAVEFILE = "user://saveFile.save"
const SAVEKEYS = "user://keyBinds.ini"

var standard_keybinds = {
	"MoveLeft": 65,
	"MoveRight": 68,
	"Jump": 32,
	"Crouch": 16777238,
	"Attack": 87,
	"Dash": 16777237
}

var game_data = {}
var keybinds = {}
var configfile

func _ready():
	load_data()
	load_keys()

func load_data():
	var file = File.new()
	if not file.file_exists(SAVEFILE):
		game_data = {
			"fullscreen_on": false,
			"bloom_on": true,
			"vsync_on": true,
			"brightness": 1,
			"master_vol": -10,
			"language": "en"
		}
		save_data()
	file.open(SAVEFILE, File.READ)
	game_data = file.get_var()
	file.close()

func load_keys():
	configfile = ConfigFile.new()
	if configfile.load(SAVEKEYS) == OK:
		for key in configfile.get_section_keys("keybinds"):
			var key_value = configfile.get_value("keybinds", key)
			if str(key_value) != "":
				keybinds[key] = key_value
			else:
				keybinds[key] = null
	else:
		# Create .ini file
		for key in standard_keybinds.keys():
			var key_value = standard_keybinds[key]
			configfile.set_value("keybinds", key, key_value)
		configfile.save(SAVEKEYS)
		keybinds = standard_keybinds.duplicate()

func save_data():
	var file = File.new()
	file.open(SAVEFILE, File.WRITE)
	file.store_var(game_data)
	file.close()

func save_keys():
	for key in keybinds.keys():
		var key_value = keybinds[key]
		if key_value != null:
			configfile.set_value("keybinds", key, key_value)
		else:
			configfile.set_value("keybinds", key, "")
	configfile.save(SAVEKEYS)
