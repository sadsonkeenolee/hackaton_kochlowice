extends RigidBody3D

var bottom_raycast: RayCast3D = null
var front_dir = Vector3.ZERO

var force = Vector3.ZERO
var aforce = Vector3.ZERO

var jump_charge

func _ready() -> void:
	continuous_cd = true
	gravity_scale = 5.0


func _process(delta: float) -> void:
	force = Vector3.ZERO
	aforce = Vector3.ZERO
	var dir = Vector3.ZERO

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
		
	if bottom_raycast == null or not bottom_raycast.is_colliding():
		$GPUParticles3D.emitting = false
		return
	else:
		$GPUParticles3D.emitting = true
	
	if Input.is_action_just_pressed("jump"):
		jump_charge = 0
		return
	if Input.is_action_pressed("jump"):
		jump_charge += delta
		return
		
	if Input.is_action_pressed("go_forward"):
		dir += front_dir
	if Input.is_action_pressed("go_back"):
		dir -= front_dir
	if Input.is_action_pressed("go_right"):
		dir += front_dir.rotated(Vector3.UP, -PI/2)
	if Input.is_action_pressed("go_left"):
		dir += front_dir.rotated(Vector3.UP, PI/2)
	
	dir = dir.normalized()
	
	if Input.is_action_just_released("jump"):
		force = jump(min(jump_charge,0.5), dir)*150
		aforce = dir_to_aforce(dir)
		jump_charge = 0
		return

	force = dir*10

func _physics_process(delta: float) -> void:
	if force.length() > 0:
		apply_central_force(force*10000)

	apply_torque_impulse(aforce*10000)


func get_lowest_face() -> String:
	var down = -Vector3.UP  # światowy dół

	var directions = {
		"up": transform.basis.y,
		"down": -transform.basis.y,
		"left": -transform.basis.x,
		"right": transform.basis.x,
		"front": -transform.basis.z,
		"back": transform.basis.z
	}

	var lowest_face = "none"
	var max_dot = -2.0

	for face in directions.keys():
		var dot_val = directions[face].dot(down)
		if dot_val > max_dot:
			max_dot = dot_val
			lowest_face = face

	return lowest_face
	
func jump(charge, dir):
	force = Vector3.UP * charge * 5 + dir
	return force

func dir_to_aforce(dir):
	if dir.length() == 0:
		return Vector3.ZERO
	else:
		return -dir.cross(Vector3.UP).normalized()
