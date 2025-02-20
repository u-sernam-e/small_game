extends CharacterBody2D

signal shoot_bullet(bullet : Transform2D, player_number : int)

const MAX_SPEED = 600.0
const ACCELERATION = 100.0
const JUMP_VELOCITY = -600.0
const FAST_FALL_VELOCITY = 1000.0

@export var player_number = 1

func _physics_process(delta: float) -> void:
	# Bullet launching
	if Input.is_action_just_pressed(player_input("shoot", player_number)):
		shoot_bullet.emit($Pivot/Gun/BulletFirePoint.global_transform, player_number)
	
	# Gun moving
	move_gun(delta)
	
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
	if direction:
		velocity.x = move_toward(velocity.x, MAX_SPEED * direction, ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION)

	move_and_slide()


func _on_death_plane_body_entered(body: Node2D) -> void:
	print(str(player_number) + ", " + str(body.player_number))
	if body.player_number == player_number:
		die()

func die() -> void:
	$DeathSound.play()
	hide()

# use this because there is different inputs for p1 and p2
func player_input(input : String, p_number : int) -> String:
	return "p" + str(p_number) + "_" + input

func move_gun(delta: float):
	$Pivot.rotation = move_toward($Pivot.rotation, velocity.angle(), absf($Pivot.rotation - velocity.angle()) * delta * velocity.length() * 0.005)
	
	if velocity.x != 0 and $Pivot/Gun.position.x != 0:
		$Pivot.rotation = PI/2 - abs(PI/2 - $Pivot.rotation)*(velocity.x/abs(velocity.x))


func _on_area_2d_area_entered(area: Area2D) -> void:
	if "player_number" in area and area.player_number != player_number:
		die()
