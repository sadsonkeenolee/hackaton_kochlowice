extends RigidBody3D

var bottom_raycast: RayCast3D = null
var front_dir = Vector3.ZERO

func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	var floor = get_lowest_face()
	match floor:
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
		pass
	
	
func _physics_process(delta: float) -> void:
	pass
	
	
		

	
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
