#extends  "res://playershared.gd"
extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var leftright : float
var forback : float

func _physics_process(delta: float) -> void:
	# Add the gravity.


	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	handleMove(delta, input_dir) 
	
	
func handleMove(delta, inputs):
	if not is_on_floor():
		
		handleair(delta, inputs)
	else: 
		handlefloor(delta, inputs)
	
func handlefloor(delta, inputs):
	var direction := (transform.basis * Vector3(inputs.x, 0, inputs.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	checkVelocityAndMove(delta)

func handleair(delta, inputs):
	velocity += get_gravity() * delta
	checkVelocityAndMove(delta)
	
func checkVelocityAndMove(delta):
	var maxvelocity = 35000;
	if velocity.length() > maxvelocity:
		velocity = maxvelocity
	move_and_slide()
