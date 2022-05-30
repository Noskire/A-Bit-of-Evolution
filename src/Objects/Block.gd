extends KinematicBody2D

func _ready():
	pass # Replace with function body.

func get_destroyed():
	queue_free()
