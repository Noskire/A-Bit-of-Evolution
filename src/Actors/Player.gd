extends KinematicBody2D

onready var sprite: Sprite = get_node("Sprite")
onready var collision: CollisionShape2D = get_node("CollisionShape2D")
onready var animPlayer: AnimationPlayer = get_node("Anims")

const FLOOR_NORMAL: = Vector2.UP

export var speed: = Vector2(600.0, 1000.0)
export var gravity: = 3000.0

var _velocity: = Vector2.ZERO

# Upgrades
var upgrades = {"MoveRight": false, "MoveLeft": false, "Jump": false, "MoveSpeed": false, "Crouch": false,
				"Up6": false, "Up7": false, "Up8": false, "Up9": false, "Up10": false}

# TO TEST ONLY #
var upgrades2 = {"MoveRight": true, "MoveLeft": true, "Jump": true, "MoveSpeed": true, "Crouch": true,
				"Up6": true, "Up7": true, "Up8": true, "Up9": true, "Up10": true}
# TO TEST ONLY #

var partsNeeded = [1, 2, 3, 5, 7, 11, 13, 17, 19, 23]
var upgradesUnlockeds = 0
var partsCollected = 0

func _physics_process(_delta: float) -> void:
	var is_jump_interrupted: = Input.is_action_just_released("Jump") and _velocity.y < 0.0
	var direction: = get_direction()
	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
	_velocity = move_and_slide(_velocity, FLOOR_NORMAL)
	
	# Crouch
	if Input.is_action_pressed("Crouch") and upgrades.Crouch:
		sprite.scale.y = 1
		collision.scale.y = 0.5
	else:
		sprite.scale.y = 2
		collision.scale.y = 1

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if animPlayer.current_animation != "Attack":
				animPlayer.play("Attack")

func get_direction() -> Vector2:
	var out = Vector2.ZERO
	if upgrades.MoveRight:
		out.x += Input.get_action_strength("MoveRight")
	if upgrades.MoveLeft:
		out.x -= Input.get_action_strength("MoveLeft")
	out.y = -1.0 if Input.is_action_just_pressed("Jump") and is_on_floor() and upgrades.Jump else 1.0
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
				upgrades.Up6 = true
				print("Now you can Up6")
			6:
				upgrades.Up7 = true
				print("Now you can Up7")
			7:
				upgrades.Up8 = true
				print("Now you can Up8")
			8:
				upgrades.Up9 = true
				print("Now you can Up9")
			9:
				upgrades.Up10 = true
				print("Now you can Up10")
		partsCollected -= partsNeeded[upgradesUnlockeds]
		upgradesUnlockeds += 1

func _on_AttackArea_body_entered(body):
	body.get_destroyed()
