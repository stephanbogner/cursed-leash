extends RigidBody2D

const UP = Vector2(0, -1)
const ACC = 60
const MAXSPEED = 300
var motion = Vector2(0, 0)
var motion_scale = 1

signal scored

var sound_eating = preload("res://sounds/Eating.ogg")
var in_control = "player2"

func _ready():
	set_contact_monitor( true )
	set_max_contacts_reported( 5 )
	#connect("body_enter",self,"collion_now")
#	self.set_mass(10)
	pass

func playSound(sound):
	var ztPlayer = AudioStreamPlayer.new()
	add_child(ztPlayer)
	sound.set_loop(false)
	ztPlayer.set_stream(sound)
	ztPlayer.play()
	yield(ztPlayer, "finished") #Via https://godotengine.org/qa/67049/help-with-audiostreamplayer
	ztPlayer.queue_free()

func _physics_process(delta):
	var colliding_bodies = get_colliding_bodies()
	if(colliding_bodies.size() > 0 ):
		for b in colliding_bodies:
			var name = b.get_name()
			if name == "CollectibleRigidBody":
					emit_signal("scored", in_control)
					b.smear()
					#var position = b.global_position
					#print(position)
					playSound(sound_eating)
					#b.queue_free()
		#print(colliding_bodies)
		#pass

	if Input.is_action_pressed(in_control + "_forward"):
		motion.y -= ACC
		self.get_node("C/AnimationPlayer").play("Running")
	elif Input.is_action_pressed(in_control + "_backward"):
		motion.y += ACC
		self.get_node("C/AnimationPlayer").play("Running")
	else:
		motion.y = lerp(motion.y, 0, 0.2)

	if Input.is_action_pressed(in_control + "_left"):
		motion.x -= ACC
		self.get_node("C/AnimationPlayer").play("Running")
	elif Input.is_action_pressed(in_control + "_right"):
		motion.x += ACC
		self.get_node("C/AnimationPlayer").play("Running")
	else:
		motion.x = lerp(motion.x, 0, 0.2)
	
	if motion.x != 0 or motion.y != 0:
		self.rotation = motion.angle() + PI / 2
	
	motion.x = clamp(motion.x, -MAXSPEED, MAXSPEED)
	motion.y = clamp(motion.y, -MAXSPEED, MAXSPEED)
	
	self.set_linear_velocity(motion * motion_scale)
	#motion = move_and_slide(motion, UP)

func activate_beast_mode():
	motion_scale = 5
	var timer = Timer.new() #https://gdscript.com/solutions/godot-timing-tutorial/
	timer.autostart = true
	timer.one_shot = true
	timer.wait_time = 0.7
	timer.connect("timeout",self,"_on_timeout") 
	add_child(timer)
	yield(timer, "timeout") #Via https://godotengine.org/qa/67049/help-with-audiostreamplayer
	timer.queue_free()

func _on_timeout():
	motion_scale = 1
	print("now")


func _on_SoulSwitchTimer_timeout():
	if in_control == "player2":
		in_control = "player1"
	else:
		in_control = "player2"
