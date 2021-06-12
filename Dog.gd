extends RigidBody2D

const UP = Vector2(0, -1)
const ACC = 60
const MAXSPEED = 300
var motion = Vector2(0, 0)
var motion_scale = 1

func _ready():
#	self.set_mass(10)
	pass

func _physics_process(delta):
	if Input.is_action_pressed("dog_up"):
		motion.y -= ACC
		self.get_node("C/AnimationPlayer").play("Running")
	elif Input.is_action_pressed("dog_down"):
		motion.y += ACC
		self.get_node("C/AnimationPlayer").play("Running")
	else:
		motion.y = lerp(motion.y, 0, 0.2)

	if Input.is_action_pressed("dog_left"):
		motion.x -= ACC
		self.get_node("C/AnimationPlayer").play("Running")
	elif Input.is_action_pressed("dog_right"):
		motion.x += ACC
		self.get_node("C/AnimationPlayer").play("Running")
	else:
		motion.x = lerp(motion.x, 0, 0.2)
	
	if motion.x != 0 or motion.y != 0:
		self.rotation = motion.angle() + PI / 2
	
	motion.x = clamp(motion.x, -MAXSPEED, MAXSPEED)
	motion.y = clamp(motion.y, -MAXSPEED, MAXSPEED)
	
	if Input.is_action_just_pressed("dog_dash"):
		#self.apply_central_impulse(Vector2(3000, 0))
		motion_scale = 5
		var timer = Timer.new() #https://gdscript.com/solutions/godot-timing-tutorial/
		timer.autostart = true
		timer.one_shot = true
		timer.wait_time = 1
		timer.connect("timeout",self,"_on_timeout") 
		add_child(timer)
	
	self.set_linear_velocity(motion * motion_scale)
	#motion = move_and_slide(motion, UP)

func _on_timeout():
	motion_scale = 1
	print("now")
