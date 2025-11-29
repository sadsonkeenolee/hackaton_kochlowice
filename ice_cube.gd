extends RigidBody3D

var bottom_raycast: RayCast3D = null
var front_dir = Vector3.ZERO

var force = Vector3.ZERO
var aforce = Vector3.ZERO

# --------- SKOK ŁADOWANY ---------
var jump_charging := false
var jump_charge := 0.0
var jump_charge_max := 1.0           # ile sekund ładuje się skok
var jump_power := 200000.0           # moc skoku (skalowana charge ratio)

func _ready() -> void:
	continuous_cd = true


func _process(delta: float) -> void:
	var jumped = false
	force = Vector3.ZERO
	aforce = Vector3.ZERO

	# kierunek przodu względem kamery
	front_dir = -$Camera3D.global_transform.basis.z
	front_dir.y = 0
	front_dir = front_dir.normalized()

	# --------- Która ściana jest dolna ---------
	var floor_face = get_lowest_face()
	match floor_face:
		"up":
			bottom_raycast = $RayCast_Up
		"down":
			bottom_raycast = $RayCast_Down
		"front":
			bottom_raycast = $RayCast_Front
		"back":
			bottom_raycast = $RayCast_Back
		"right":
			bottom_raycast = $RayCast_Right
		"left":
			bottom_raycast = $RayCast_Left

	# NIE RUSZAĆ
	if bottom_raycast == null or not bottom_raycast.is_colliding():
		pass


	# --------- RUCH WASD ---------
	if Input.is_action_pressed("go_forward"):
		force += front_dir
	if Input.is_action_pressed("go_back"):
		force -= front_dir
	if Input.is_action_pressed("go_right"):
		force += front_dir.rotated(Vector3.UP, -PI/2)
	if Input.is_action_pressed("go_left"):
		force += front_dir.rotated(Vector3.UP, PI/2)

	# --------- ŁADOWANIE SKOKU ---------
	if Input.is_action_pressed("jump") and bottom_raycast != null and bottom_raycast.is_colliding():
		jump_charging = true
		jump_charge += delta
		print(jump_charge)
		jump_charge = min(jump_charge, jump_charge_max)

	# ZWOLNIENIE SPACJI → SKOK
	if Input.is_action_just_released("jump") and jump_charging:
		jumped = true
		jump_charging = false

	if jumped:
		var charge_ratio = jump_charge / jump_charge_max
		var jump_strength = jump_power * charge_ratio

		# pionowa siła skoku
		force += Vector3.UP * jump_strength

		# rotacja kostki – wokół osi prostopadłej do kierunku ruchu
		if force.length() > 0:
			var axis = force.cross(Vector3.UP).normalized()
			aforce = axis * (jump_strength * 0.001)

		jump_charge = 0.0


func _physics_process(delta: float) -> void:
	# unikamy normalizowania zerowego wektora
	if force.length() > 0:
		apply_central_force(force.normalized() * 5000)

	apply_torque_impulse(aforce)


func get_lowest_face() -> String:
	var local_down = -transform.basis.y

	var directions = {
		"up": Vector3.UP,
		"down": Vector3.DOWN,
		"left": Vector3.LEFT,
		"right": Vector3.RIGHT,
		"front": Vector3.FORWARD,
		"back": Vector3.BACK
	}

	var lowest_face = "none"
	var max_dot = -2.0

	for face in directions.keys():
		var dot_val = local_down.dot(directions[face])
		if dot_val > max_dot:
			max_dot = dot_val
			lowest_face = face

	return lowest_face
