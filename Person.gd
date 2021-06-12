extends RigidBody2D

const UP = Vector2(0, -1)
const ACC = 30
const MAXSPEED = 200
var motion = Vector2()

func _ready():
	#self.set_weight(10)
	#self.set_mass(10)
	pass

func _physics_process(delta):
	if Input.is_action_pressed("person_up"):
		motion.y -= ACC
	elif Input.is_action_pressed("person_down"):
		motion.y += ACC
	else:
		motion.y = lerp(motion.y, 0, 0.2)

	if Input.is_action_pressed("person_left"):
		motion.x -= ACC
	elif Input.is_action_pressed("person_right"):
		motion.x += ACC
	else:
		motion.x = lerp(motion.x, 0, 0.2)
	
	if motion.x != 0 or motion.y != 0:
		self.rotation = motion.angle() + PI / 2
	
	motion.x = clamp(motion.x, -MAXSPEED, MAXSPEED)
	motion.y = clamp(motion.y, -MAXSPEED, MAXSPEED)
	
	self.set_linear_velocity(motion)
#	motion = move_and_slide(motion, UP)
