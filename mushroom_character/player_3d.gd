extends CharacterBody3D
class_name Player3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var cam_scene = $MovableCamera3D
@onready var health_component = $HealthComponent
@onready var ui = $UI

var input_dir = Vector3.ZERO
var jumping = false # Are we jumping?
var dead = false
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	elif velocity.y <= 0:
		# We're not jumping if we're on the floor!
		jumping = false
	
	if dead:
		return
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jumping = true
		velocity.y = JUMP_VELOCITY
	
	rotation_degrees.y = cam_scene.camrot_h * delta * 150
	
	var new_input_dir = Input.get_vector("left", "right", "forward", "backward")
	input_dir = Vector3(new_input_dir.x, new_input_dir.y, 0)
	
	# No input_dir.x; Astronauts don't seem to be able to strafe on the moon.
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var speed_mult = 1
	if direction:
		if not input_dir.y < 0:
			speed_mult = 0.65 # Move slower when not going straight forwards.
		
		var old_velocity_y = velocity.y
		velocity.y = 0.0
		velocity.x = lerp(velocity.x, direction.x, 0.6)
		velocity.z = lerp(velocity.z, direction.z, 0.6)
		velocity = velocity.normalized() * SPEED * speed_mult
		velocity.y = old_velocity_y
		
	elif not direction and not jumping:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()

func _on_health_component_just_died() -> void:
	$UI.display_you_lose()
	dead = true
