extends CharacterBody3D


const SPEED = 4.5

@onready var auto_component = $AutonomyComponent

var body_eating = null

var elapsed = 1.0
func _process(delta):
	elapsed += delta
	if elapsed >= 0.5 and body_eating != null:
		body_eating.health_component.damage(15.0)
		elapsed = 0.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir: Vector2 = auto_component.get_input_dir()
	
	if input_dir != Vector2.ZERO:
		look_at(transform.origin+Vector3(input_dir.x, 0, input_dir.y), Vector3.UP)
	
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#global_position -= transform.basis.z * delta * SPEED
	velocity = -transform.basis.z * SPEED
	move_and_slide()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player3D and body_eating == null:
		body_eating = body

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == body_eating:
		body_eating = null
