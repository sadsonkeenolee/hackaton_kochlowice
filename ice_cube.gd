extends CharacterBody3D

@export var FRICTION := 2.0

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Vector3.ZERO
	if Input.is_action_pressed("go_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("go_back"):
		direction += transform.basis.z
	if Input.is_action_pressed("go_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("go_right"):
		direction += transform.basis.x
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		velocity.z = move_toward(velocity.z, 0, FRICTION * delta)

	move_and_slide()
