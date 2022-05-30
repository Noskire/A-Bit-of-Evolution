extends Area2D

onready var anim_player: AnimationPlayer = get_node("AnimationPlayer")

func _on_body_entered(body):
	body.picked()
	anim_player.play("FadeOut")

func _on_animation_finished(anim_name):
	if anim_name == "FadeOut":
		queue_free()
