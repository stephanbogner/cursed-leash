extends RigidBody2D

const UP = Vector2(0, -1)
const ACC = 30
const MAXSPEED = 200
var motion = Vector2()

var in_control = "player1"

func _ready():
	#self.set_weight(10)
	#self.set_mass(10)
	pass

func _physics_process(delta):
	if Input.is_action_pressed(in_control + "_forward"):
		motion.y -= ACC
	elif Input.is_action_pressed(in_control + "_backward"):
		motion.y += ACC
	else:
		motion.y = lerp(motion.y, 0, 0.2)

	if Input.is_action_pressed(in_control + "_left"):
		motion.x -= ACC
	elif Input.is_action_pressed(in_control + "_right"):
		motion.x += ACC
	else:
		motion.x = lerp(motion.x, 0, 0.2)
	
	if motion.x != 0 or motion.y != 0:
		self.rotation = motion.angle() + PI / 2
	
	motion.x = clamp(motion.x, -MAXSPEED, MAXSPEED)
	motion.y = clamp(motion.y, -MAXSPEED, MAXSPEED)
	
	self.set_linear_velocity(motion)
#	motion = move_and_slide(motion, UP)


func _on_SoulSwitchTimer_timeout():
	if in_control == "player2":
		in_control = "player1"
	else:
		in_control = "player2"
