extends Area2D

onready var anim: AnimationPlayer = get_node("AnimationPlayer")

export var retreatPosition: Vector2 = Vector2(2190, 734)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Idle":
		anim.play("Prepare")
	elif anim_name == "Prepare":
		anim.play("Active")
	elif anim_name == "Active":
		anim.play("Idle")

func _on_Trap_body_entered(body):
	body.get_hit(retreatPosition)
