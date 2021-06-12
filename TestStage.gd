extends Node2D

# Layer 1 Person
# Layer 2 Dog
# Layer 3 Rope

var Rope = preload("res://Rope.tscn")
var rope
var start_pos := Vector2(100, 100)
var end_pos := Vector2(200, 200)

onready var Person = get_node("Person")
onready var Dog = get_node("Dog")
onready var Cam = get_node("Cam")

var barkZips = [
	preload("res://sounds/Bark zip 1.ogg"),
	preload("res://sounds/Bark zip 2.ogg"),
	preload("res://sounds/Bark zip 3.ogg"),
	preload("res://sounds/Bark zip 4.ogg"),
	preload("res://sounds/Bark zip 5.ogg")
]

func _ready():
	$SoulSwitchTimer.set_wait_time(15)
	$SoulSwitchTimer.start()
	rope = Rope.instance()
	add_child(rope)
	rope.spawn(Person, Dog)
	$Cam/Shader.get_material().set_shader_param("shaderStrength", 0)

func _physics_process(delta):
	var time_left = $SoulSwitchTimer.get_time_left()
	print(time_left)
	if time_left < 5:
		var fraction = 1 - time_left/5
		$Cam/Shader.get_material().set_shader_param("shaderStrength", fraction)
	
	if Input.is_action_just_pressed("player1_action_primary"):
		rope.pull()
		#Dog.get_node("C/reaction-zip").play()
		var barkPlayer = AudioStreamPlayer.new()
		add_child(barkPlayer)
		var selectedSound = barkZips[randi() % (barkZips.size() - 1)] # Via https://docs.godotengine.org/en/latest/tutorials/math/random_number_generation.html#getting-a-random-number
		selectedSound.set_loop(false)
		barkPlayer.set_stream(selectedSound)
		barkPlayer.autoplay = true
		barkPlayer.play()
		Cam.get_node("ScreenShake").start(0.05, 15, 24, 0)
		
	var person_position = Person.get_position()
	var dog_position = Dog.get_position()
	var position_between_players = (person_position + dog_position) / 2
	Cam.global_position = position_between_players
#func _input(event):
#	if event is InputEventMouseButton and !event.is_pressed():
#		if start_pos == Vector2.ZERO:
#			start_pos = get_global_mouse_position()
#		else:
#			end_pos = get_global_mouse_position()
#			var rope = Rope.instance()
#			add_child(rope)
#			rope.spwan_rope(start_pos, end_pos)
#			start_pos = Vector2.ZERO
#			end_pos = Vector2.ZERO


func _on_SoulSwitchTimer_timeout():
	print("switch")
	$Cam/Shader.get_material().set_shader_param("shaderStrength", 0)
	pass # Replace with function body.
