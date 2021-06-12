extends Node2D

# Layer 1 Person
# Layer 2 Dog
# Layer 3 Rope

var Rope = preload("res://Rope.tscn")
var start_pos := Vector2(100, 100)
var end_pos := Vector2(200, 200)

onready var Person = get_node("Person")
onready var Dog = get_node("Dog")

func _ready():
	var rope = Rope.instance()
	add_child(rope)
	rope.spawn(Person, Dog)

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
