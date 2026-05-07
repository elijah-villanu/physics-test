extends CharacterBody2D

# References to related nodes
@onready var animated_sprite: AnimatedSprite2D = $Animations
@onready var dash_cooldown: Timer = $DashCooldown
@onready var dash_duration: Timer = $DashDuration

const SPEED = 175.0
const JUMP_VELOCITY = -300
const GRAVITY = Vector2(0, 800.0)
const DASH_SPEED = 550.0

# Ice specific constants
const ICE_ACCELERATION: float = 0.01
const SLIDING_VAL: float = 0.1
const FULL_STOP_VAL: float = 15 

# Tracks where the last direction faces for the idle animation
var face: bool = false

var dashing: bool = false
var on_ice: bool = false
var can_dash: bool = true

# Player state machine (WILL IMPLEMENT LATER)
#enum PlayerState {
	#IDLE,
	#RUN,
	#JUMP,
	#DASH
#}

func _physics_process(delta: float) -> void:
	# Add the gravity (is_on_floor on perpendicular surfaces with collisions)
	if not is_on_floor():
		on_ice = false
		velocity += GRAVITY * delta
	else:
		on_ice = true

	# Handles jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		play_animation("JUMP", face)
		
	if (Input.is_action_pressed("dash") and can_dash):
		dashing = true
		can_dash = false
		dash_duration.start()
		dash_cooldown.start()
	
	# Inputs set on project settings
	# Input.get_axis returns a negative value (left) and positive (right)
	var direction :float = Input.get_axis("move_left", "move_right")
	if direction:
		# Handles left and right movement (has deceleration)
		if (direction > 0):
			face = false
			play_animation("RUN", face)
		elif (direction < 0):
			face = true
			play_animation("RUN", face)
		if is_on_ice():
			velocity.x = get_ice_movement(direction, velocity.x)
		else:
			velocity.x = get_normal_movement(direction)
		
		# Handles dash
		if (dashing):
			velocity.x = direction * DASH_SPEED
			velocity.y = 0
			play_animation("DASH", face)
	else:
		# deceleration with move_towrads from SPEED to 0
		play_animation("IDLE", face)
		if !is_on_ice():
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# Handles movement and collisions for the CharacterBody2D
	move_and_slide()

func get_normal_movement(direction: float) -> float:
	return direction * SPEED

func get_ice_movement(direction: float, curr_velocity: float) -> float:
	if direction != 0:
		# Uses linear interpolation to replicate slow change in acceleration
		return lerp(curr_velocity, direction * SPEED, ICE_ACCELERATION)
	else:
		if curr_velocity < FULL_STOP_VAL and curr_velocity > -FULL_STOP_VAL:
			return 0
		return lerp(curr_velocity, 0.0, SLIDING_VAL)

# Takes in the animation name to play and where it should face (true is left, right false)
func play_animation(animation: String, flip: bool) -> void:
	# This is due to the animated sprite being offset by the current collision
	match animation:
		"IDLE":
			animated_sprite.position.x = 0.0
			animated_sprite.position.y = -10.5
		"RUN":
			animated_sprite.position.x = 1.0
			animated_sprite.position.y = -15.0
		"DASH":
			animated_sprite.position.x = 11.0
			animated_sprite.position.y = -17.0
		"JUMP":
			animated_sprite.position.x = -1.0
			animated_sprite.position.y = -10.0
	animated_sprite.play(animation)
	animated_sprite.flip_h = flip

# Runs on timer finished
func _on_dash_cooldown_timeout() -> void:
	can_dash = true

func _on_dash_duration_timeout() -> void:
	dashing = false

# Checks if the surface is ice
func is_on_ice() -> bool:
	var collider = get_last_slide_collision()
	if !collider:
		return false
	return collider.get_collider().name == "Ice"
