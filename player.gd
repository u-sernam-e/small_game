extends CharacterBody2D


const MAX_SPEED = 600.0
const ACCELERATION = 100.0
const JUMP_VELOCITY = -600.0
const FAST_FALL_VELOCITY = 1000.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("p1_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	#fast falling
	if Input.is_action_pressed("p1_down") and !is_on_floor():
		if velocity.y > 0:
			velocity.y = FAST_FALL_VELOCITY # if falling, set a high velocity down
		else:
			velocity.y += get_gravity().y * delta * 2 # if rising, increase gravity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("p1_left", "p1_right")
	print(direction)
	if direction:
		velocity.x = move_toward(velocity.x, MAX_SPEED * direction, ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION)

	move_and_slide()
