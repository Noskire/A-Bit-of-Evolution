extends KinematicBody2D

onready var sceneTree: = get_tree()
onready var sprite: Sprite = get_node("Sprite")
onready var partsInfo: Label = get_node("CanvasLayer/PartsInfo")
onready var upgradeInfo: Label = get_node("CanvasLayer/UpgradeInfo")
onready var upgradeTimer: Timer = get_node("UpgradeTimer")
onready var animPlayer: AnimationPlayer = get_node("AnimationPlayer")
onready var tween: Tween = get_node("Tween")

export(String, FILE) var nextScenePath: = ""

const FLOOR_NORMAL: = Vector2.UP
export var speed: = Vector2(150.0, 600.0)
export var normal_speed: = 150.0
export var dash_speed: = 600.0
export var gravity: = 1500.0

var _velocity: = Vector2.ZERO
var doubleJump = true
var wakingUp = true
var getting_hit = false
var currentTime

enum STATES {IDLE, MOVING, JUMPING, ATTACKING, DASHING, CROUCHING}
var state = STATES.IDLE
var crouched = false

# Upgrades
var upgrades = {"MoveRight": false, "MoveLeft": false, "Jump": false, "MoveSpeed": false, "Crouch": false,
				"Dash": false, "Attack": false, "DoubleJump": false}

# TO TEST ONLY #
var upgrades2 = {"MoveRight": true, "MoveLeft": true, "Jump": true, "MoveSpeed": true, "Crouch": true,
				"Dash": true, "Attack": true, "DoubleJump": true}
# TO TEST ONLY #

var partsNeeded = [1, 2, 3, 5, 7, 11, 13, 17, 1, 0]
var upgradesUnlockeds = 0
var partsCollected = 0

func _ready():
	partsInfo.set_text(str(tr("TOUPGRADE"), partsCollected, " / ", partsNeeded[upgradesUnlockeds]))
	currentTime = 0

func _physics_process(delta: float) -> void:
	currentTime += delta
	if not getting_hit and not wakingUp:
		var direction: = get_direction()
		var is_jump_interrupted: = Input.is_action_just_released("Jump") and _velocity.y < 0.0
		
		# Crouch
		if Input.is_action_just_pressed("Crouch") and upgrades.Crouch:
			if not crouched:
				crouched = true
				animPlayer.play("Crouch")
			else:
				crouched = false
				animPlayer.play("Stood")
			state = STATES.CROUCHING
		
		# Dash
		#if Input.is_action_just_pressed("Dash") and animPlayer.current_animation != "Dash" and upgrades.Dash:
		if Input.is_action_just_pressed("Dash") and upgrades.Dash:
			if not crouched:
				animPlayer.play("Dash")
			else:
				animPlayer.play("CDash")
			state = STATES.DASHING
			speed.x = dash_speed
		if state != STATES.DASHING:
			speed.x = normal_speed
		
		# Reset Double Jump
		if is_on_floor():
			doubleJump = true
		
		# Move
		_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
		_velocity = move_and_slide(_velocity, FLOOR_NORMAL)

func _input(event):
	if not getting_hit and not wakingUp:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT and event.pressed and upgrades.Attack:
				if not crouched:
					if animPlayer.current_animation != "Attack":
						animPlayer.play("Attack")
						state = STATES.ATTACKING
				else:
					if animPlayer.current_animation != "CAttack":
						animPlayer.play("CAttack")
						state = STATES.ATTACKING
		if Input.is_action_just_pressed("Attack") and upgrades.Attack:
				if not crouched:
					if animPlayer.current_animation != "Attack":
						animPlayer.play("Attack")
						state = STATES.ATTACKING
				else:
					if animPlayer.current_animation != "CAttack":
						animPlayer.play("CAttack")
						state = STATES.ATTACKING

func get_direction() -> Vector2:
	var out = Vector2.ZERO
	if upgrades.MoveRight:
		out.x += Input.get_action_strength("MoveRight")
	if upgrades.MoveLeft:
		out.x -= Input.get_action_strength("MoveLeft")
	
	# Direction Facing
	if abs(out.x) > 0:
		if out.x > 0:
			sprite.scale.x = 1
		else:
			sprite.scale.x = -1
		if state == STATES.IDLE:
			state = STATES.MOVING
			if upgrades.Jump:
				if not crouched:
					animPlayer.play("Moving")
				else:
					animPlayer.play("CMoving")
			else:
				animPlayer.play("Moving_wj")
	else:
		if state == STATES.MOVING:
			state = STATES.IDLE
			if upgrades.Jump:
				if not crouched:
					animPlayer.play("Idle")
				else:
					animPlayer.play("CIdle")
			else:
				animPlayer.play("Idle_wj")
	
	if Input.is_action_just_pressed("Jump") and is_on_floor() and upgrades.Jump:
		out.y = -1.0
		if not crouched:
			animPlayer.play("Jump")
		else:
			animPlayer.play("CJump")
		state = STATES.JUMPING
	elif Input.is_action_just_pressed("Jump") and doubleJump and upgrades.DoubleJump:
		out.y = -1.0
		doubleJump = false
		if not crouched:
			animPlayer.play("Jump")
		else:
			animPlayer.play("CJump")
		state = STATES.JUMPING
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
				animPlayer.play("Waking")
				upgradeInfo.set_text(str(tr("UPGRADE0"), " (", OS.get_scancode_string(Save.keybinds.MoveRight), ")"))
			1:
				upgrades.MoveLeft = true
				upgradeInfo.set_text(str(tr("UPGRADE1"), " (", OS.get_scancode_string(Save.keybinds.MoveLeft), ")"))
			2:
				upgrades.Jump = true
				upgradeInfo.set_text(str(tr("UPGRADE2"), " (", OS.get_scancode_string(Save.keybinds.Jump), ")"))
			3:
				upgrades.MoveSpeed = true
				normal_speed = normal_speed * 2
				speed.x = normal_speed
				upgradeInfo.set_text(tr("UPGRADE3"))
			4:
				upgrades.Crouch = true
				upgradeInfo.set_text(str(tr("UPGRADE4"), " (", OS.get_scancode_string(Save.keybinds.Crouch), ")"))
			5:
				upgrades.Dash = true
				upgradeInfo.set_text(str(tr("UPGRADE5"), " (", OS.get_scancode_string(Save.keybinds.Dash), ")"))
			6:
				upgrades.Attack = true
				upgradeInfo.set_text(str(tr("UPGRADE6"), " (LMB/", OS.get_scancode_string(Save.keybinds.Attack), ")"))
			7:
				upgrades.DoubleJump = true
				upgradeInfo.set_text(tr("UPGRADE7"))
			8:
				wakingUp = true
				animPlayer.play("Sleeping")
				upgradeInfo.set_text(tr("UPGRADE8"))
		upgradeInfo.set_visible(true)
		upgradeTimer.start()
		partsCollected -= partsNeeded[upgradesUnlockeds]
		upgradesUnlockeds += 1
	partsInfo.set_text(str(tr("TOUPGRADE"), partsCollected, " / ", partsNeeded[upgradesUnlockeds]))

func get_hit(retreatPosition: Vector2) -> void:
	var get_result
	getting_hit = true
	get_result = tween.interpolate_property(self, "position", position, retreatPosition, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	get_result = tween.start()
	if not get_result:
		print("Tween Error")
	#interpolate_property(object, property, initial_val, final_val, duration, TransitionType, EaseType, delay)

func _on_animation_finished(anim_name):
	if anim_name == "Waking":
		animPlayer.play("Idle_wj")
		wakingUp = false
		state = STATES.IDLE
	if anim_name == "Attack" or anim_name == "Dash" or anim_name == "Jump" or anim_name == "Stood":
		animPlayer.play("Idle")
		state = STATES.IDLE
		if anim_name == "Dash":
			speed.x = normal_speed
	elif anim_name == "CAttack" or anim_name == "CDash" or anim_name == "CJump" or anim_name == "Crouch":
		animPlayer.play("CIdle")
		state = STATES.IDLE
		if anim_name == "CDash":
			speed.x = normal_speed
	elif anim_name == "Sleeping":
		$CanvasLayer/CanvasModulate.get_darker()
		$EndTimer.start()

func _on_AttackArea_body_entered(body):
	body.get_destroyed()

func _on_CAttackArea_body_entered(body):
	body.get_destroyed()

func _on_tween_completed(_object, _key):
	getting_hit = false

func _on_EndTimer_timeout():
	var savedTime = Save.game_data.time_score
	if savedTime == -1 or savedTime > currentTime:
		Save.game_data.time_score = currentTime
		Save.save_data()
	var err
	err = sceneTree.change_scene(nextScenePath)
	if err != OK:
		print("Error change_scene EndTimer")

func _on_UpgradeTimer_timeout():
	upgradeInfo.set_visible(false)
