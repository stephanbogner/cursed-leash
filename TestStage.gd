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

func _ready():
	rope = Rope.instance()
	add_child(rope)
	rope.spawn(Person, Dog)

func _physics_process(delta):
	if Input.is_action_just_pressed("leash_pull"):
		rope.pull()
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
