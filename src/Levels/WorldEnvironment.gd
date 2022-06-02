extends WorldEnvironment

func _ready():
	var err
	err = GlobalSettings.connect("bloom_toggled", self, "_on_bloom_toggled")
	if err != OK:
		print("Error WorldE Connect Bloom")
	err = GlobalSettings.connect("brightness_updated", self, "_on_brightness_updated")
	if err != OK:
		print("Error WorldE Connect Brightness")

func _on_bloom_toggled(value):
	environment.glow_enabled = value
	environment.glow_bloom = 0

func _on_brightness_updated(value):
	environment.adjustment_brightness = value
