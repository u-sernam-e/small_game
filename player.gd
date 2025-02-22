extends CharacterBody2D

signal shoot_bullet(bullet : Transform2D, player_number : int)
const FIRERATE: float = 0.07 # FIRERATE seconds until next bullet is shot
var timeSinceShot: float = 0

const MAX_SPEED: float = 450.0
const ACCELERATION: float = 100.0
const JUMP_VELOCITY: float = -600.0
const FAST_FALL_VELOCITY: float = 1000.0
const AIR_CONTROL: float = 0.6 #how versatile the player can move (so far, only affects the x direction)

@export var player_number: int = 1

var plrSprite: Texture2D = null

#sprites
var availableCharSprites: Array[Texture2D] = [
	preload("res://Textures/Characters/FisBowl.png"),
	preload("res://Textures/Characters/Squid.png"),
	preload("res://Textures/Characters/AppelJuic.png")
]

#i would use a separate class for this if we were to commit to using this probject
const ANG_RES: int = 32 #number of available angles
var anglesArr: Array[float] = [] #angles are stored in counter-clockwise order
var currentAngleIndex = 0
var fwd_vec: Vector2

func _enter_tree() -> void:
	#initialize angle array
	anglesArr.resize(ANG_RES)
	for i in range(ANG_RES):
		anglesArr[i] = i * PI/(ANG_RES/2)
	
	#initialize sprites
	match player_number:
		1:
			var spriteIndex: int = randi_range(0, availableCharSprites.size()-1)
			plrSprite = availableCharSprites[spriteIndex]
			availableCharSprites.erase(spriteIndex)
		2:
			plrSprite = availableCharSprites[randi_range(0, availableCharSprites.size()-1)]
		_:
			print("No sprite was set for player_number = ", player_number)
	$Sprite2D.texture = plrSprite
	
	var cshape = $CollisionShape2D.shape
	var collisionH: float = cshape.height + (cshape.radius * 2)
	var collisionW: float = cshape.radius * 2
	fwd_vec = Vector2(collisionW / $Sprite2D.texture.get_width(), collisionH / $Sprite2D.texture.get_height())
	$Sprite2D.scale = fwd_vec


func _physics_process(delta: float) -> void:
	# Bullet launching
	timeSinceShot += delta
	
	if Input.is_action_pressed(player_input("shoot", player_number)) and timeSinceShot >= FIRERATE:
		shoot_bullet.emit($Pivot/Gun/BulletFirePoint.global_transform, player_number)
		timeSinceShot = 0
	
	# Gun moving
	move_gun()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_just_pressed(player_input("up", player_number)) and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$JumpSound.play()
	
	# fast falling
	if Input.is_action_pressed(player_input("down", player_number)) and !is_on_floor():
		if velocity.y > 0:
			velocity.y = FAST_FALL_VELOCITY # if falling, set a high velocity down
		else:
			velocity.y += get_gravity().y * delta * 2 # if rising, increase gravity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	var direction := Input.get_axis(player_input("left", player_number), player_input("right", player_number))
	
	var vXApplied: float =  MAX_SPEED * direction
	if not is_on_floor():
		vXApplied *= AIR_CONTROL
	velocity.x = move_toward(velocity.x, vXApplied, ACCELERATION)	
	
	if direction == 1:
		$Sprite2D.scale.x = fwd_vec.x
	elif direction == -1:
		$Sprite2D.scale.x = -fwd_vec.x
	else:
		pass
	

	move_and_slide()

func _on_death_plane_body_entered(body: Node2D) -> void:
	print(str(player_number) + ", " + str(body.player_number))
	if body.player_number == player_number:
		die()

func die() -> void:
	$DeathSound.play()
	hide()

#rotate gun counterclockwise or clockwise based on key pressed
func move_gun():
	var cw: bool = Input.is_action_pressed(player_input("aim_clockwise", player_number))
	var ccw: bool = Input.is_action_pressed(player_input("aim_counterclockwise", player_number))
	if !(cw and ccw):
		if cw:
			currentAngleIndex += 1
			if currentAngleIndex >= anglesArr.size():
				currentAngleIndex = 0
		elif ccw:
			currentAngleIndex -= 1
			if currentAngleIndex <= 0:
				currentAngleIndex = anglesArr.size()-1
			
	$Pivot.rotation = anglesArr[clamp(currentAngleIndex, 0, anglesArr.size())]

# use this because there is different inputs for p1 and p2
func player_input(input : String, p_number : int) -> String:
	return "p" + str(p_number) + "_" + input
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	if "player_number" in area and area.player_number != player_number:
		die()
