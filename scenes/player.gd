extends CharacterBody2D

@onready var animated_sprite = $Animations

const SPEED = 175.0
const JUMP_VELOCITY = -300
const GRAVITY = Vector2(0, 800.0)

# Tracks where the last direction faces for the idle animation
var face: bool = false

# Player state machine
enum PlayerState {
	IDLE,
	RUN,
	JUMP,
	DASH
}

func _physics_process(delta: float) -> void:
	# Add the gravity (is_on_floor on perpendicular surfaces with collisions)
	if not is_on_floor():
		velocity += GRAVITY * delta

	# Handles jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handles left and right movement (has deceleration)
	# Inputs set on project settings
	var direction :float = Input.get_axis("move_left", "move_right")
	if direction:
		# Input.get_axis returns a negative value (left) and positive (right)
		if (direction > 0):
			face = false
			play_animation("run", face)
		elif (direction < 0):
			face = true
			play_animation("run", true)
		velocity.x = direction * SPEED
	else:
		# deceleration with move_towrads from SPEED to 0
		play_animation("idle", face)
		velocity.x = move_toward(velocity.x, 0, SPEED)


	# Handles movement and collisions for the CharacterBody2D
	move_and_slide()



# Takes in the animation name to play and where it should face (true is left, right false)
func play_animation(animation: String, flip: bool) -> void:
	animated_sprite.play(animation)
	animated_sprite.flip_h = flip
