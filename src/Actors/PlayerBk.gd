extends KinematicBody2D

onready var sprite: Sprite = get_node("Sprite")
onready var partsInfo: Label = get_node("CanvasLayer/PartsInfo")
onready var animPlayer: AnimationPlayer = get_node("Anims")
onready var tween: Tween = get_node("Tween")

const FLOOR_NORMAL: = Vector2.UP

export var speed: = Vector2(150.0, 600.0)
export var gravity: = 1500.0

var _velocity: = Vector2.ZERO
var doubleJump = true
var wakingUp = true
var getting_hit = false

# Upgrades
var upgrades = {"MoveRight": false, "MoveLeft": false, "Jump": false, "MoveSpeed": false, "Crouch": false,
				"Dash": false, "Attack": false, "DoubleJump": false, "Up9": false, "Up10": false}

# TO TEST ONLY #
var upgrades2 = {"MoveRight": true, "MoveLeft": true, "Jump": true, "MoveSpeed": true, "Crouch": true,
				"Dash": true, "Attack": true, "DoubleJump": true, "Up9": true, "Up10": true}
# TO TEST ONLY #

var partsNeeded = [1, 2, 3, 5, 7, 11, 13, 17, 19, 23]
var upgradesUnlockeds = 0
var partsCollected = 0

func _physics_process(_delta: float) -> void:
	if not getting_hit and not wakingUp:
		var direction: = get_direction()
		var is_jump_interrupted: = Input.is_action_just_released("Jump") and _velocity.y < 0.0
		if is_jump_interrupted:
			animPlayer.play("JumpDown")
		if animPlayer.current_animation == "JumpUp" or animPlayer.current_animation == "JumpDown":
			if is_on_floor():
				animPlayer.play("Idle")
		
		# Crouch
		if Input.is_action_pressed("Crouch") and upgrades.Crouch:
			animPlayer.play("Croch")
		
		# Dash
		if Input.is_action_just_pressed("Dash") and animPlayer.current_animation != "Dash" and upgrades.Dash:
			animPlayer.play("Dash")
			speed.x = speed.x * 2
		
		# Reset Double Jump
		if is_on_floor():
			doubleJump = true

		# Move
		_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
		_velocity = move_and_slide(_velocity, FLOOR_NORMAL)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed and upgrades.Attack:
			if animPlayer.current_animation != "Attack":
				animPlayer.play("Attack")

func get_direction() -> Vector2:
	var out = Vector2.ZERO
	if upgrades.MoveRight:
		out.x += Input.get_action_strength("MoveRight")
	if upgrades.MoveLeft:
		out.x -= Input.get_action_strength("MoveLeft")
	
	# Direction Facing
	if out.x > 0:
		if animPlayer.current_animation == "Idle":
			animPlayer.play("Moving")
		sprite.scale.x = 1
	elif out.x < 0:
		if animPlayer.current_animation == "Idle":
			animPlayer.play("Moving")
		sprite.scale.x = -1
	
	if Input.is_action_just_pressed("Jump") and is_on_floor() and upgrades.Jump:
		out.y = -1.0
		animPlayer.play("JumpUp")
	elif Input.is_action_just_pressed("Jump") and doubleJump and upgrades.DoubleJump:
		out.y = -1.0
		animPlayer.play("JumpUp")
		doubleJump = false
	else:
		out.y = 1.0
	return out

func calculate_move_velocity(
		linear_velocity: Vector2,
		direction: Vector2,
		momentum: Vector2,
		is_jump_interrupted: bool
	) -> Vector2:
	# momentum = speed, change name to not use the same name of the global var
	var out: = linear_velocity
	out.x = momentum.x * direction.x
	out.y += gravity * get_physics_process_delta_time()
	if direction.y == -1.0:
		out.y = momentum.y * direction.y
	if is_jump_interrupted:
		out.y = 0.0
	return out

func picked() -> void:
	partsCollected += 1
	if partsCollected >= partsNeeded[upgradesUnlockeds]:
		match upgradesUnlockeds:
			0:
				upgrades.MoveRight = true
				animPlayer.play("WakingUp")
				print("Now you can move to the Right")
			1:
				upgrades.MoveLeft = true
				print("Now you can move to the Left")
			2:
				upgrades.Jump = true
				print("Now you can Jump")
			3:
				upgrades.MoveSpeed = true
				speed.x = speed.x * 2
				print("Now you can move faster")
			4:
				upgrades.Crouch = true
				print("Now you can Crouch")
			5:
				upgrades.Dash = true
				print("Now you can Dash")
			6:
				upgrades.Attack = true
				print("Now you can Attack")
			7:
				upgrades.DoubleJump = true
				print("Now you can DoubleJump")
			8:
				upgrades.Up9 = true
				print("Now you can Up9")
			9:
				upgrades.Up10 = true
				print("Now you can Up10")
		partsCollected -= partsNeeded[upgradesUnlockeds]
		upgradesUnlockeds += 1
	partsInfo.set_text(str(partsCollected, " / ", partsNeeded[upgradesUnlockeds]))

func get_hit(retreatPosition: Vector2) -> void:
	getting_hit = true
	tween.interpolate_property(self, "position", position, retreatPosition, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	#interpolate_property(object: Object, property: NodePath, initial_val: Variant, final_val: Variant, 
	#duration: float, trans_type: TransitionType = 0, ease_type: EaseType = 2, delay: float = 0)

func _on_AttackArea_body_entered(body):
	body.get_destroyed()

func _on_animation_finished(anim_name):
	if anim_name == "WakingUp":
		wakingUp = false
		animPlayer.play("Idle")
	elif anim_name == "Attack" or anim_name == "JumpDown":
		animPlayer.play("Idle")
	elif anim_name == "Dash":
		speed.x = speed.x / 2
		animPlayer.play("Idle")
	elif anim_name == "JumpUp":
		animPlayer.play("JumpDown")

func _on_tween_completed(_object, _key):
	getting_hit = false
