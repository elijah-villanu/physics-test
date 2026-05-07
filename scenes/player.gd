extends CharacterBody2D

# References to related nodes
@onready var animated_sprite: AnimatedSprite2D = $Animations
@onready var dash_cooldown: Timer = $DashCooldown
@onready var dash_duration: Timer = $DashDuration

const SPEED = 175.0
const JUMP_VELOCITY = -300
const GRAVITY = Vector2(0, 800.0)
const DASH_SPEED = 500.0

# Tracks where the last direction faces for the idle animation
var face: bool = false

var dashing: bool = false
var on_ice: bool = false
var can_dash: bool = true

# Player state machine
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
		
	if (Input.is_action_pressed("dash") and can_dash):
		dashing = true
		can_dash = false
		dash_duration.start()
		dash_cooldown.start()

	# Handles left and right movement (has deceleration)
	# Inputs set on project settings
	var direction :float = Input.get_axis("move_left", "move_right")
	if direction:
		# Input.get_axis returns a negative value (left) and positive (right)
		if (direction > 0):
			face = false
			play_animation("RUN", face)
		elif (direction < 0):
			face = true
			play_animation("RUN", face)
		velocity.x = direction * SPEED
		
		# Handles dash
		if (dashing):
			velocity.x = direction * DASH_SPEED
			velocity.y = 0
			play_animation("DASH", face)
	else:
		# deceleration with move_towrads from SPEED to 0
		play_animation("IDLE", face)
		if (on_ice): 
			velocity.x = move_toward(velocity.x, 0, SPEED)
		else:
			velocity.x = move_toward(velocity.x, 0, 1)

	# Handles movement and collisions for the CharacterBody2D
	move_and_slide()



# Takes in the animation name to play and where it should face (true is left, right false)
func play_animation(animation: String, flip: bool) -> void:
	animated_sprite.play(animation)
	animated_sprite.flip_h = flip

# Runs on timer finished
func _on_dash_cooldown_timeout() -> void:
	can_dash = true

func _on_dash_duration_timeout() -> void:
	dashing = false
